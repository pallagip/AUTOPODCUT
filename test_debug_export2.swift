import Foundation
import AVFoundation

let v1Path = "/Volumes/Lacie2/POTCAST PROJECT/DEMO_1/POTCAST_DEMO_01_4K.mp4"
let v2Path = "/Volumes/Lacie2/POTCAST PROJECT/DEMO_1/POTCAST_DEMO_02_4K.mp4"
let aPath = "/Volumes/Lacie2/POTCAST PROJECT/DEMO_1/POTCAST_DEMO_Hangok.wav"

let outPath = "/Volumes/Lacie2/POTCAST PROJECT/DEMO_1/test_export.mp4"

Task {
    do {
        let v1Asset = AVURLAsset(url: URL(fileURLWithPath: v1Path))
        let v2Asset = AVURLAsset(url: URL(fileURLWithPath: v2Path))
        let aAsset = AVURLAsset(url: URL(fileURLWithPath: aPath))
        
        let comp = AVMutableComposition()
        let v1Track = comp.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let v2Track = comp.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let aTrack = comp.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        
        let v1Source = try await v1Asset.loadTracks(withMediaType: .video).first!
        let v2Source = try await v2Asset.loadTracks(withMediaType: .video).first!
        let aSource = try await aAsset.loadTracks(withMediaType: .audio).first!
        
        let dur1 = CMTime(seconds: 3.0, preferredTimescale: 600)
        let dur2 = CMTime(seconds: 8.2, preferredTimescale: 600)
        let totalDur = CMTimeAdd(dur1, dur2)
        
        try aTrack.insertTimeRange(CMTimeRange(start: .zero, duration: totalDur), of: aSource, at: .zero)
        
        // segment 1: videoOne: 0.0 - 3.0
        try v1Track.insertTimeRange(CMTimeRange(start: .zero, duration: dur1), of: v1Source, at: .zero)
        
        // segment 2: videoTwo: 3.0 - 11.2
        try v2Track.insertTimeRange(CMTimeRange(start: dur1, duration: dur2), of: v2Source, at: dur1)
        
        let vidComp = AVMutableVideoComposition()
        vidComp.renderSize = try await v1Source.load(.naturalSize)
        vidComp.frameDuration = CMTime(value: 1, timescale: 30)
        
        let inst1 = AVMutableVideoCompositionInstruction()
        inst1.timeRange = CMTimeRange(start: .zero, duration: dur1)
        let l1 = AVMutableVideoCompositionLayerInstruction(assetTrack: v1Track)
        inst1.layerInstructions = [l1]
        
        let inst2 = AVMutableVideoCompositionInstruction()
        inst2.timeRange = CMTimeRange(start: dur1, duration: dur2)
        let l2 = AVMutableVideoCompositionLayerInstruction(assetTrack: v2Track)
        inst2.layerInstructions = [l2]
        
        vidComp.instructions = [inst1, inst2]
        
        try? FileManager.default.removeItem(atPath: outPath)
        
        guard let session = AVAssetExportSession(asset: comp, presetName: AVAssetExportPresetHEVCHighestQuality) else {
            print("Could not create session")
            exit(1)
        }
        
        session.videoComposition = vidComp
        session.outputURL = URL(fileURLWithPath: outPath)
        session.outputFileType = .mp4
        
        print("Starting export...")
        await session.export()
        
        if let error = session.error {
            print("Error: \(error)")
        } else {
            print("Success")
        }
    } catch {
        print("Exception: \(error)")
    }
    exit(0)
}

RunLoop.main.run()
