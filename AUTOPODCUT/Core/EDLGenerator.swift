import Foundation
import CoreMedia

public enum EDLGeneratorError: Error, Equatable {
    case emptySpeakerSequence
    case invalidIntervalDuration
}

public class EDLGenerator {
    
    public init() {}
    
    /// Converts a sequence of active speaker indices into an array of continuous `EditDecision` blocks.
    ///
    /// - Parameters:
    ///   - activeSpeakers: An array where each element represents the active channel index (or nil) for a specific time interval.
    ///   - intervalSeconds: The actual duration of each interval block in seconds (e.g., 0.1 for 100ms analysis windows).
    /// - Returns: A continuous, ordered sequence of EditDecisions representing the timeline cuts.
    public func generateEDL(from activeSpeakers: [Int?], intervalSeconds: Double) throws -> [EditDecision] {
        guard !activeSpeakers.isEmpty else {
            throw EDLGeneratorError.emptySpeakerSequence
        }
        guard intervalSeconds > 0 else {
            throw EDLGeneratorError.invalidIntervalDuration
        }
        
        var decisions: [EditDecision] = []
        var currentStartInterval = 0
        var currentSpeaker = activeSpeakers[0]
        
        // Loop through the intervals identifying boundaries where the speaker changes
        for i in 1..<activeSpeakers.count {
            let speaker = activeSpeakers[i]
            
            if speaker != currentSpeaker {
                // A boundary is found. Resolve the previous block.
                let blockDurationSeconds = Double(i - currentStartInterval) * intervalSeconds
                let startTimeSeconds = Double(currentStartInterval) * intervalSeconds
                
                let startTime = CMTime(seconds: startTimeSeconds, preferredTimescale: 600)
                let duration = CMTime(seconds: blockDurationSeconds, preferredTimescale: 600)
                
                let decision = EditDecision(timeRange: CMTimeRange(start: startTime, duration: duration), activeChannelIndex: currentSpeaker)
                decisions.append(decision)
                
                currentStartInterval = i
                currentSpeaker = speaker
            }
        }
        
        // Resolve the final contiguous block
        let finalBlockDurationSeconds = Double(activeSpeakers.count - currentStartInterval) * intervalSeconds
        let finalStartTimeSeconds = Double(currentStartInterval) * intervalSeconds
        
        let finalStartTime = CMTime(seconds: finalStartTimeSeconds, preferredTimescale: 600)
        let finalDuration = CMTime(seconds: finalBlockDurationSeconds, preferredTimescale: 600)
        
        let finalDecision = EditDecision(timeRange: CMTimeRange(start: finalStartTime, duration: finalDuration), activeChannelIndex: currentSpeaker)
        decisions.append(finalDecision)
        
        return decisions
    }
}
