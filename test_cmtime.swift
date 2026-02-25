import Foundation
import CoreMedia

let arr = [
    (0.0, 3.0),
    (3.0, 11.200000000000001),
    (11.200000000000001, 14.4),
    (14.4, 50.5),
]

for (start, end) in arr {
    let tStart = CMTime(seconds: start, preferredTimescale: 600)
    let rawSegmentDuration = CMTime(seconds: end - start, preferredTimescale: 600)
    let tEnd = CMTimeAdd(tStart, rawSegmentDuration)
    let tNext = CMTime(seconds: end, preferredTimescale: 600)
    
    print("Start: \(start) -> \(tStart.value)/\(tStart.timescale)")
    print("End val: \(tEnd.value)/\(tEnd.timescale), Next Expected: \(tNext.value)/\(tNext.timescale)")
    if tEnd != tNext {
        print("MISMATCH!")
    }
}
