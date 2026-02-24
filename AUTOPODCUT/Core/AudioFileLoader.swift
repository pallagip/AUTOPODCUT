import Foundation
import AVFoundation

public enum AudioLoaderError: Error, Equatable {
    case fileNotFound
    case unreadableFile(String) // Extracted error description for equatability
    case invalidFormat

    public static func == (lhs: AudioLoaderError, rhs: AudioLoaderError) -> Bool {
        switch (lhs, rhs) {
        case (.fileNotFound, .fileNotFound):
            return true
        case (.invalidFormat, .invalidFormat):
            return true
        case let (.unreadableFile(desc1), .unreadableFile(desc2)):
            return desc1 == desc2
        default:
            return false
        }
    }
}

public struct AudioFileInfo {
    public let url: URL
    public let channelCount: AVAudioChannelCount
    public let duration: TimeInterval
    public let sampleRate: Double
}

public class AudioFileLoader {
    public init() {}
    
    public func load(url: URL) throws -> AudioFileInfo {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw AudioLoaderError.fileNotFound
        }
        
        let file: AVAudioFile
        do {
            file = try AVAudioFile(forReading: url)
        } catch {
            throw AudioLoaderError.unreadableFile(error.localizedDescription)
        }
        
        let format = file.fileFormat
        let channelCount = format.channelCount
        let sampleRate = format.sampleRate
        let duration = Double(file.length) / sampleRate
        
        return AudioFileInfo(
            url: url,
            channelCount: channelCount,
            duration: duration,
            sampleRate: sampleRate
        )
    }
}
