import Foundation

public class ActiveSpeakerStateMachine {
    /// The number of consecutive intervals a new speaker must be the loudest before the camera switches to them.
    public let switchThreshold: Int
    /// The minimum RMS power required to be considered "speaking".
    public let silenceThreshold: Float
    
    public init(switchThreshold: Int = 5, silenceThreshold: Float = 0.01) {
        self.switchThreshold = max(1, switchThreshold)
        self.silenceThreshold = silenceThreshold
    }
    
    /// Analyzes parallel RMS power arrays (one per channel) and outputs an array of active speaker indices.
    /// An output element is `nil` if no one is speaking or silence logic prevails.
    /// - Parameter channelPower: An array of Float arrays, where each inner array represents the RMS power over time for one channel.
    /// - Returns: An array of optional Ints representing the chosen active channel index per interval.
    public func computeActiveSpeakers(channelPower: [[Float]]) -> [Int?] {
        guard !channelPower.isEmpty, let firstChannel = channelPower.first else { return [] }
        let intervalCount = firstChannel.count
        var result = [Int?]()
        result.reserveCapacity(intervalCount)
        
        var currentSpeaker: Int? = nil
        var candidateSpeaker: Int? = nil
        var candidateCount = 0
        
        for i in 0..<intervalCount {
            var loudestChannel: Int? = nil
            var maxPower: Float = silenceThreshold
            
            for channelIndex in 0..<channelPower.count {
                guard i < channelPower[channelIndex].count else { continue }
                let power = channelPower[channelIndex][i]
                if power > maxPower {
                    maxPower = power
                    loudestChannel = channelIndex
                }
            }
            
            if loudestChannel == currentSpeaker {
                candidateSpeaker = nil
                candidateCount = 0
            } else {
                if loudestChannel == candidateSpeaker {
                    candidateCount += 1
                } else {
                    candidateSpeaker = loudestChannel
                    candidateCount = 1
                }
                
                if candidateCount >= switchThreshold {
                    currentSpeaker = candidateSpeaker
                    candidateSpeaker = nil
                    candidateCount = 0
                }
            }
            
            result.append(currentSpeaker)
        }
        
        return result
    }
}
