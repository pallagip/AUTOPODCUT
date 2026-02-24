import Foundation
import Accelerate
import AVFoundation

public enum VolumeAnalysisError: Error, Equatable {
    case invalidBufferLayout
    case unsupportedInterval
}

public class VolumeAnalysisEngine {
    public init() {}
    
    /// Analyzes an AVAudioPCMBuffer and returns an array of average RMS values
    /// calculated over the specified time interval (window).
    ///
    /// - Parameters:
    ///   - buffer: A single-channel AVAudioPCMBuffer.
    ///   - intervalSeconds: The duration of each analysis window in seconds.
    /// - Returns: An array of Float representing the RMS power in each interval window.
    public func analyzeRMS(for buffer: AVAudioPCMBuffer, intervalSeconds: Double) throws -> [Float] {
        guard buffer.format.channelCount == 1, let floatData = buffer.floatChannelData else {
            throw VolumeAnalysisError.invalidBufferLayout
        }
        
        let sampleRate = buffer.format.sampleRate
        let framesPerInterval = vDSP_Length(intervalSeconds * sampleRate)
        
        guard framesPerInterval > 0 && framesPerInterval <= buffer.frameLength else {
            throw VolumeAnalysisError.unsupportedInterval
        }
        
        let channelPointer = floatData[0]
        let totalFrames = Int(buffer.frameLength)
        let intervalCount = totalFrames / Int(framesPerInterval)
        
        var rmsValues = [Float](repeating: 0.0, count: intervalCount)
        
        for i in 0..<intervalCount {
            let offset = i * Int(framesPerInterval)
            var rms: Float = 0.0
            
            // vDSP_rmsqv: Calculates the root mean square of a vector.
            vDSP_rmsqv(channelPointer.advanced(by: offset), 1, &rms, framesPerInterval)
            
            rmsValues[i] = rms
        }
        
        return rmsValues
    }
}
