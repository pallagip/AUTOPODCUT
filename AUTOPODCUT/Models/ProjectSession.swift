import Foundation

public struct ChannelMapping: Equatable {
    public let audioChannelIndex: Int
    public var videoURL: URL?
    
    public init(audioChannelIndex: Int, videoURL: URL? = nil) {
        self.audioChannelIndex = audioChannelIndex
        self.videoURL = videoURL
    }
}

public class ProjectSession {
    public private(set) var masterAudioURL: URL?
    public private(set) var audioChannelCount: Int = 0
    public private(set) var mappings: [Int: ChannelMapping] = [:]
    
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
    
    /// Maps a specific video URL to an audio channel index
    public func mapVideo(url: URL, toChannelIndex index: Int) throws {
        guard masterAudioURL != nil else {
            throw SessionError.masterAudioNotSet
        }
        
        guard index >= 0 && index < audioChannelCount else {
            throw SessionError.channelIndexOutOfBounds
        }
        
        mappings[index]?.videoURL = url
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
    }
    
    /// Gets the video URL for a channel. If nil, the system should render a black frame.
    public func videoURLForChannel(_ index: Int) -> URL? {
        return mappings[index]?.videoURL
    }
}
