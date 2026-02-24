import Foundation
import CoreMedia
import AVFoundation

public enum CompositionBuilderError: Error, Equatable {
    case masterAudioMissing
    case failedToAddAudioTrack
    case failedToAddVideoTrack
    case unableToLoadVideoAsset(Int)
}

public protocol AssetLoader {
    func loadAsset(for url: URL) -> AVAsset
}

public class DefaultAssetLoader: AssetLoader {
    public init() {}
    public func loadAsset(for url: URL) -> AVAsset {
        return AVURLAsset(url: url)
    }
}

public class CompositionBuilder {
    private let assetLoader: AssetLoader
    
    public init(assetLoader: AssetLoader = DefaultAssetLoader()) {
        self.assetLoader = assetLoader
    }
    
    /// Builds the final AVMutableComposition linking continuous audio and sequenced edited video tracks.
    ///
    /// - Parameters:
    ///   - session: The project session mapping channels to URL assets.
    ///   - edl: The EditDecision timeline sequence dictating cuts.
    /// - Returns: A complete AVMutableComposition ready for export.
    public func build(session: ProjectSession, edl: [EditDecision]) throws -> AVMutableComposition {
        guard let masterAudioURL = session.masterAudioURL else {
            throw CompositionBuilderError.masterAudioMissing
        }
        
        let composition = AVMutableComposition()
        let masterAsset = assetLoader.loadAsset(for: masterAudioURL)
        
        guard let masterAudioTrack = masterAsset.tracks(withMediaType: .audio).first else {
            throw CompositionBuilderError.failedToAddAudioTrack
        }
        
        guard let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid),
              let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            throw CompositionBuilderError.failedToAddVideoTrack
        }
        
        // Insert Master Audio uninterrupted across its entirety
        let totalTimeRange = CMTimeRange(start: .zero, duration: masterAsset.duration)
        try compositionAudioTrack.insertTimeRange(totalTimeRange, of: masterAudioTrack, at: .zero)
        
        // Pre-load necessary video assets efficiently
        var loadedVideoAssets: [Int: AVAsset] = [:]
        for (index, mapping) in session.mappings {
            if let url = mapping.videoURL {
                loadedVideoAssets[index] = assetLoader.loadAsset(for: url)
            }
        }
        
        // Sequentially construct the video cut
        for decision in edl {
            if let channelIndex = decision.activeChannelIndex,
               let videoAsset = loadedVideoAssets[channelIndex],
               let sourceVideoTrack = videoAsset.tracks(withMediaType: .video).first {
                
                // Cut exact timeline segment (assumes uniformly synced starts)
                try compositionVideoTrack.insertTimeRange(decision.timeRange, of: sourceVideoTrack, at: decision.timeRange.start)
            } else {
                // Fallback to Black via empty time range 
                // Any missing video or explicit `nil` mapping results in a transparent/black gap
                compositionVideoTrack.insertEmptyTimeRange(decision.timeRange)
            }
        }
        
        return composition
    }
}
