import Foundation
import CoreMedia
import AVFoundation

Task {
    do {
        let v1Path = "/Volumes/Lacie2/POTCAST PROJECT/DEMO_1/POTCAST_DEMO_01_4K.mp4"
        let v2Path = "/Volumes/Lacie2/POTCAST PROJECT/DEMO_1/POTCAST_DEMO_02_4K.mp4"
        let aPath = "/Volumes/Lacie2/POTCAST PROJECT/DEMO_1/POTCAST_DEMO_Hangok.wav"

        let v1Asset = AVURLAsset(url: URL(fileURLWithPath: v1Path))
        let v2Asset = AVURLAsset(url: URL(fileURLWithPath: v2Path))
        
        let dur1 = try await v1Asset.load(.duration)
        let dur2 = try await v2Asset.load(.duration)
        
        print("Video 1 Duration: \(dur1.seconds)s")
        print("Video 2 Duration: \(dur2.seconds)s")
        
        let v1Track = try await v1Asset.loadTracks(withMediaType: .video).first!
        let v2Track = try await v2Asset.loadTracks(withMediaType: .video).first!
        
        print("Video 1 Track TimeRange: start \(try await v1Track.load(.timeRange).start.seconds), duration \(try await v1Track.load(.timeRange).duration.seconds)")
        print("Video 2 Track TimeRange: start \(try await v2Track.load(.timeRange).start.seconds), duration \(try await v2Track.load(.timeRange).duration.seconds)")
    } catch {
        print(error)
    }
    exit(0)
}
RunLoop.main.run()
