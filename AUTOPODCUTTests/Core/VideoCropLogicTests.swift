import XCTest
import AVFoundation
@testable import AUTOPODCUT

final class VideoCropLogicTests: XCTestCase {
    var cropper: VideoCropLogic!
    var tempFileURL: URL!
    
    override func setUpWithError() throws {
        cropper = VideoCropLogic()
        
        // Let's create a stub video to acquire an AVAssetTrack.
        tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_crop_video.mov")
        // Note: For a true test we would write a real AVAsset track,
        // but generating a sample video buffer is complex in tests without a stub file.
        // We will mock the behavior by creating a small empty video file or load a proxy.
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: tempFileURL.path) {
            try fileManager.removeItem(at: tempFileURL)
        }
        
        // Since generating a raw .mov file for AVAsset track extraction is intensive, 
        // we can still test the logic if we extract a track from a dummy written file, 
        // but since AVFoundation doesn't let us easily mock AVAssetTrack without subclassing (which is restricted in Swift),
        // we have to be careful. The simplest valid test is ensuring the logic handles parameters right if given a track.
    }
    
    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempFileURL)
        cropper = nil
    }
    
    // Instead of throwing errors trying to instantiate AVAssetTrack, 
    // we can create a minimalist writer loop to establish a track.
    func testCropLogicConfigurationValid() throws {
        let compositionStub = AVMutableComposition()
        guard let track = compositionStub.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            XCTFail("Failed to create stub track")
            return
        }
        
        // Use our target logic
        let crop = try CropDefinition(x: 100, y: 50, width: 800, height: 600)
        let composition = cropper.createComposition(for: track, duration: CMTime(seconds: 1, preferredTimescale: 30), crop: crop)
        
        XCTAssertEqual(composition.renderSize, CGSize(width: 800, height: 600))
        XCTAssertEqual(composition.instructions.count, 1)
        
        let baseInstruction = composition.instructions[0] as? AVMutableVideoCompositionInstruction
        XCTAssertNotNil(baseInstruction)
        XCTAssertEqual(baseInstruction?.layerInstructions.count, 1)
    }
}
