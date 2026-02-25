import Foundation

public struct ChannelMapping: Equatable {
    public let audioChannelIndex: Int
    public var videoURL: URL?
    public var cropDefinition: CropDefinition?
    
    public init(audioChannelIndex: Int, videoURL: URL? = nil, cropDefinition: CropDefinition? = nil) {
        self.audioChannelIndex = audioChannelIndex
        self.videoURL = videoURL
        self.cropDefinition = cropDefinition
    }
}

public class ProjectSession {
    public private(set) var masterAudioURL: URL?
    public private(set) var audioChannelCount: Int = 0
    public private(set) var mappings: [Int: ChannelMapping] = [:]
    public private(set) var mediaPool: [URL] = []
    
    public init() {}
    
    public enum SessionError: Error, Equatable {
        case masterAudioNotSet
        case channelIndexOutOfBounds
    }
    
    /// Initializes the session with a master audio file
    public func setMasterAudio(url: URL, channelCount: Int) {
        self.masterAudioURL = url
        self.audioChannelCount = channelCount
        self.mappings.removeAll()
        
        // Initialize default empty mappings for all channels
        for i in 0..<channelCount {
            mappings[i] = ChannelMapping(audioChannelIndex: i, videoURL: nil)
        }
    }
    
    /// Adds a video URL to the media pool
    public func addVideoToPool(url: URL) {
        if !mediaPool.contains(url) {
            mediaPool.append(url)
        }
    }
    
    /// Removes a video URL from the media pool
    public func removeVideoFromPool(url: URL) {
        mediaPool.removeAll { $0 == url }
        // Also unmap any channels that were using this video
        for (index, mapping) in mappings {
            if mapping.videoURL == url {
                try? unmapVideo(forChannelIndex: index)
            }
        }
    }
    
    /// Maps a specific video URL to an audio channel index
    public func mapVideo(url: URL, toChannelIndex index: Int, crop: CropDefinition? = nil) throws {
        guard masterAudioURL != nil else {
            throw SessionError.masterAudioNotSet
        }
        
        guard index >= 0 && index < audioChannelCount else {
            throw SessionError.channelIndexOutOfBounds
        }
        
        mappings[index]?.videoURL = url
        mappings[index]?.cropDefinition = crop
    }
    
    /// Unmaps the video for a specific audio channel (reverting to Black Screen mode)
    public func unmapVideo(forChannelIndex index: Int) throws {
        guard masterAudioURL != nil else {
            throw SessionError.masterAudioNotSet
        }
        
        guard index >= 0 && index < audioChannelCount else {
            throw SessionError.channelIndexOutOfBounds
        }
        
        mappings[index]?.videoURL = nil
        mappings[index]?.cropDefinition = nil
    }
    
    /// Gets the video URL for a channel. If nil, the system should render a black frame.
    public func videoURLForChannel(_ index: Int) -> URL? {
        return mappings[index]?.videoURL
    }
}
