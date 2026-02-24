import Foundation
import CoreMedia

/// Represents a contiguous block of time assigned to a specific audio channel (for camera cuts).
public struct EditDecision: Equatable {
    public let timeRange: CMTimeRange
    public let activeChannelIndex: Int? // nil means fallback to black screen
    
    public init(timeRange: CMTimeRange, activeChannelIndex: Int?) {
        self.timeRange = timeRange
        self.activeChannelIndex = activeChannelIndex
    }
}
