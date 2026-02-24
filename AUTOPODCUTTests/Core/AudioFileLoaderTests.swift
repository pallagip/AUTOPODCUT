import XCTest
import AVFoundation

// If module is not available, these classes should at least be part of the test target 
// or available through the @testable import AUTOPODCUT
@testable import AUTOPODCUT

final class AudioFileLoaderTests: XCTestCase {
    var loader: AudioFileLoader!
    var tempFileURL: URL!
    
    override func setUpWithError() throws {
        loader = AudioFileLoader()
        // Create a dummy audio file using AVAudioFile
        tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_audio.wav")
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        let file = try AVAudioFile(forWriting: tempFileURL, settings: format.settings)
        // Write 1 second of audio (44100 frames)
        let frameCount = AVAudioFrameCount(44100)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Failed to create PCM buffer")
            return
        }
        buffer.frameLength = frameCount
        
        // Populate buffer with silence or dummy data
        for channel in 0..<Int(format.channelCount) {
            let channelData = buffer.floatChannelData![channel]
            for frame in 0..<Int(frameCount) {
                channelData[frame] = 0.0 // silence
            }
        }
        
        try file.write(from: buffer)
    }
    
    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempFileURL)
        loader = nil
    }
    
    func testLoadValidAudioFile() throws {
        let info = try loader.load(url: tempFileURL)
        
        XCTAssertEqual(info.channelCount, 2)
        XCTAssertEqual(info.sampleRate, 44100)
        XCTAssertEqual(info.duration, 1.0, accuracy: 0.01)
        XCTAssertEqual(info.url, tempFileURL)
    }
    
    func testLoadNonExistentFileThrows() {
        let nonExistentURL = FileManager.default.temporaryDirectory.appendingPathComponent("does_not_exist.wav")
        XCTAssertThrowsError(try loader.load(url: nonExistentURL)) { error in
            XCTAssertEqual(error as? AudioLoaderError, .fileNotFound)
        }
    }
    
    func testLoadInvalidFormatFileThrows() throws {
        let invalidFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("invalid.txt")
        try "Not an audio file".write(to: invalidFileURL, atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try loader.load(url: invalidFileURL)) { error in
            guard let audioError = error as? AudioLoaderError,
                  case .unreadableFile = audioError else {
                XCTFail("Expected unreadableFile error, got \(String(describing: error))")
                return
            }
        }
        
        try? FileManager.default.removeItem(at: invalidFileURL)
    }
}
