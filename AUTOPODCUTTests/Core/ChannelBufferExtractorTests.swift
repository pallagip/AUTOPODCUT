import XCTest
import AVFoundation
@testable import AUTOPODCUT

final class ChannelBufferExtractorTests: XCTestCase {
    var extractor: ChannelBufferExtractor!
    var tempFileURL: URL!
    let sampleRate: Double = 44100
    
    override func setUpWithError() throws {
        extractor = ChannelBufferExtractor()
        
        // Setup a dummy stereo (2-channel) audio file for extraction testing
        tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_stereo.wav")
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let file = try AVAudioFile(forWriting: tempFileURL, settings: format.settings)
        
        let frameCount = AVAudioFrameCount(sampleRate) // 1 second
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Could not create buffer")
            return
        }
        buffer.frameLength = frameCount
        
        // Write distinct values to each channel
        // Channel 0 (left): 1.0
        // Channel 1 (right): -1.0
        if let floatData = buffer.floatChannelData {
            for frame in 0..<Int(frameCount) {
                floatData[0][frame] = 1.0
                floatData[1][frame] = -1.0
            }
        }
        
        try file.write(from: buffer)
    }
    
    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempFileURL)
        extractor = nil
    }
    
    func testExtractValidChannelZero() throws {
        let singleChannelBuffer = try extractor.extractChannel(0, from: tempFileURL)
        
        XCTAssertEqual(singleChannelBuffer.format.channelCount, 1)
        XCTAssertEqual(singleChannelBuffer.frameLength, AVAudioFrameCount(sampleRate))
        
        // Verify channel 0 data (1.0)
        let firstFrame = singleChannelBuffer.floatChannelData?[0][0]
        XCTAssertEqual(firstFrame, 1.0)
    }
    
    func testExtractValidChannelOne() throws {
        let singleChannelBuffer = try extractor.extractChannel(1, from: tempFileURL)
        
        XCTAssertEqual(singleChannelBuffer.format.channelCount, 1)
        
        // Verify channel 1 data (-1.0)
        let firstFrame = singleChannelBuffer.floatChannelData?[0][0]
        XCTAssertEqual(firstFrame, -1.0)
    }
    
    func testExtractOutOfBoundsChannelThrowsError() {
        XCTAssertThrowsError(try extractor.extractChannel(2, from: tempFileURL)) { error in
            XCTAssertEqual(error as? ChannelExtractorError, .channelIndexOutOfBounds)
        }
        
        XCTAssertThrowsError(try extractor.extractChannel(-1, from: tempFileURL)) { error in
            XCTAssertEqual(error as? ChannelExtractorError, .channelIndexOutOfBounds)
        }
    }
    
    func testExtractFromInvalidFileThrowsError() {
        let nonExistentURL = FileManager.default.temporaryDirectory.appendingPathComponent("does_not_exist.wav")
        XCTAssertThrowsError(try extractor.extractChannel(0, from: nonExistentURL)) { error in
            guard let audioError = error as? ChannelExtractorError,
                  case .fileReadError = audioError else {
                XCTFail("Expected fileReadError, got \(String(describing: error))")
                return
            }
        }
    }
}
