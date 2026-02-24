import Foundation
import AVFoundation

public enum ExportError: Error, Equatable {
    case exportSessionCreationFailed
    case exportFailed(String)
    case exportCancelled
}

public class CompositionExporter {
    public init() {}
    
    /// Exports an AVComposition to a specified URL using H.265 (HEVC) codec for highest quality (including 4K) in an MP4 container.
    ///
    /// - Parameters:
    ///   - composition: The fully built composition containing audio and video cuts.
    ///   - outputURL: The file URL where the MP4 will be saved.
    ///   - completion: Completion handler returning true on success or an error on failure.
    public func export(composition: AVComposition, to outputURL: URL, completion: @escaping (Result<Void, ExportError>) -> Void) {
        // Use HEVC Highest Quality preset to ensure if source is 4K, output is 4K H.265
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHEVCHighestQuality) else {
            completion(.failure(.exportSessionCreationFailed))
            return
        }
        
        exportSession.outputURL = outputURL
        // Enforce .mp4 container required by user
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        // Remove existing file if present to prevent silent failure
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(.success(()))
            case .failed:
                let errorDesc = exportSession.error?.localizedDescription ?? "Unknown error"
                completion(.failure(.exportFailed(errorDesc)))
            case .cancelled:
                completion(.failure(.exportCancelled))
            default:
                completion(.failure(.exportFailed("Unexpected export status: \(exportSession.status.rawValue)")))
            }
        }
    }
}
