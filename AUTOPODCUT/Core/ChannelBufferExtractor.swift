import Foundation
import AVFoundation

public enum ChannelExtractorError: Error, Equatable {
    case channelIndexOutOfBounds
    case fileReadError(String)
    case unsupportedFormat

    public static func == (lhs: ChannelExtractorError, rhs: ChannelExtractorError) -> Bool {
        switch (lhs, rhs) {
        case (.channelIndexOutOfBounds, .channelIndexOutOfBounds),
             (.unsupportedFormat, .unsupportedFormat):
            return true
        case let (.fileReadError(desc1), .fileReadError(desc2)):
            return desc1 == desc2
        default:
            return false
        }
    }
}

public class ChannelBufferExtractor {
    public init() {}

    /// Extracts a single audio channel from an audio file into an AVAudioPCMBuffer.
    /// - Parameters:
    ///   - channelIndex: The 0-based index of the channel to extract.
    ///   - url: The URL of the audio file.
    /// - Returns: A single-channel AVAudioPCMBuffer containing the requested channel's audio data.
    public func extractChannel(_ channelIndex: Int, from url: URL) throws -> AVAudioPCMBuffer {
        let file: AVAudioFile
        do {
            file = try AVAudioFile(forReading: url)
        } catch {
            throw ChannelExtractorError.fileReadError(error.localizedDescription)
        }

        let format = file.fileFormat
        guard channelIndex >= 0 && channelIndex < format.channelCount else {
            throw ChannelExtractorError.channelIndexOutOfBounds
        }

        let frameCount = AVAudioFrameCount(file.length)
        
        // Read the file into a buffer using its processing format (standard non-interleaved 32-bit float)
        guard let sourceBuffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount) else {
            throw ChannelExtractorError.unsupportedFormat
        }

        do {
            try file.read(into: sourceBuffer)
        } catch {
            throw ChannelExtractorError.fileReadError(error.localizedDescription)
        }

        // Create a single-channel standard format buffer
        guard let singleChannelFormat = AVAudioFormat(standardFormatWithSampleRate: format.sampleRate, channels: 1),
              let destBuffer = AVAudioPCMBuffer(pcmFormat: singleChannelFormat, frameCapacity: frameCount) else {
            throw ChannelExtractorError.unsupportedFormat
        }

        destBuffer.frameLength = sourceBuffer.frameLength

        // Copy the specific channel data
        guard let sourceData = sourceBuffer.floatChannelData,
              let destData = destBuffer.floatChannelData else {
            throw ChannelExtractorError.unsupportedFormat
        }

        let sourceChannelPtr = sourceData[channelIndex]
        let destChannelPtr = destData[0]

        // Copy frames from source channel to destination
        let byteCount = Int(sourceBuffer.frameLength) * MemoryLayout<Float>.stride
        memcpy(destChannelPtr, sourceChannelPtr, byteCount)

        return destBuffer
    }
}
