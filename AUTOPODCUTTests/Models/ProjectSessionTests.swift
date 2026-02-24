import XCTest
@testable import AUTOPODCUT

final class ProjectSessionTests: XCTestCase {
    var session: ProjectSession!
    
    override func setUpWithError() throws {
        session = ProjectSession()
    }
    
    override func tearDownWithError() throws {
        session = nil
    }
    
    func testSetMasterAudioInitializesDefaultMappings() {
        let masterURL = URL(fileURLWithPath: "/dummy/audio.wav")
        session.setMasterAudio(url: masterURL, channelCount: 3)
        
        XCTAssertEqual(session.masterAudioURL, masterURL)
        XCTAssertEqual(session.audioChannelCount, 3)
        
        // Ensure all mappings are created and video URLs default to nil
        for i in 0..<3 {
            XCTAssertNotNil(session.mappings[i])
            XCTAssertEqual(session.mappings[i]?.audioChannelIndex, i)
            XCTAssertNil(session.mappings[i]?.videoURL, "Video mapping should initially track as nil, falling back to black frames.")
        }
    }
    
    func testMapVideoSuccessfully() throws {
        let masterURL = URL(fileURLWithPath: "/dummy/audio.wav")
        session.setMasterAudio(url: masterURL, channelCount: 2)
        
        let videoURL1 = URL(fileURLWithPath: "/dummy/video1.mp4")
        
        try session.mapVideo(url: videoURL1, toChannelIndex: 0)
        XCTAssertEqual(session.videoURLForChannel(0), videoURL1)
        XCTAssertNil(session.videoURLForChannel(1), "Channel 1 should remain nil (black frame)")
    }
    
    func testUnmapVideoSuccessfully() throws {
        let masterURL = URL(fileURLWithPath: "/dummy/audio.wav")
        session.setMasterAudio(url: masterURL, channelCount: 2)
        let videoURL1 = URL(fileURLWithPath: "/dummy/video1.mp4")
        
        try session.mapVideo(url: videoURL1, toChannelIndex: 0)
        try session.unmapVideo(forChannelIndex: 0)
        XCTAssertNil(session.videoURLForChannel(0), "Video should be successfully unmapped (falling back to black screen)")
    }
    
    func testMapVideoToNonExistentChannelThrows() {
        let masterURL = URL(fileURLWithPath: "/dummy/audio.wav")
        session.setMasterAudio(url: masterURL, channelCount: 2)
        let videoURL = URL(fileURLWithPath: "/dummy/video.mp4")
        
        XCTAssertThrowsError(try session.mapVideo(url: videoURL, toChannelIndex: 2)) { error in
            XCTAssertEqual(error as? ProjectSession.SessionError, .channelIndexOutOfBounds)
        }
        
        XCTAssertThrowsError(try session.mapVideo(url: videoURL, toChannelIndex: -1)) { error in
            XCTAssertEqual(error as? ProjectSession.SessionError, .channelIndexOutOfBounds)
        }
    }
    
    func testMapVideoBeforeMasterAudioThrows() {
        let videoURL = URL(fileURLWithPath: "/dummy/video.mp4")
        XCTAssertThrowsError(try session.mapVideo(url: videoURL, toChannelIndex: 0)) { error in
            XCTAssertEqual(error as? ProjectSession.SessionError, .masterAudioNotSet)
        }
    }
}
