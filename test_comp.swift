import Foundation
import AVFoundation

let comp = AVMutableComposition()
let vTrack = comp.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
let url = URL(fileURLWithPath: "/System/Library/Sounds/Glass.aiff")
let asset = AVURLAsset(url: url)

Task {
    do {
        let duration = try await asset.load(.duration)
        let aTrack = try await asset.loadTracks(withMediaType: .audio).first!
        print("Asset duration:", duration.seconds)
        
        try vTrack.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: aTrack, at: CMTime(seconds: 5, preferredTimescale: 600))
        print("Comp duration:", comp.duration.seconds)
        
        try vTrack.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: aTrack, at: CMTime(seconds: 15, preferredTimescale: 600))
        print("Comp duration 2:", comp.duration.seconds)
    } catch {
        print(error)
    }
    exit(0)
}
RunLoop.main.run()
