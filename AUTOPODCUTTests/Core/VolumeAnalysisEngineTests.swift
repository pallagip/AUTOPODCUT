import XCTest
import AVFoundation
@testable import AUTOPODCUT

final class VolumeAnalysisEngineTests: XCTestCase {
    var engine: VolumeAnalysisEngine!
    
    override func setUpWithError() throws {
        engine = VolumeAnalysisEngine()
    }
    
    override func tearDownWithError() throws {
        engine = nil
    }
    
    func testAnalyzeRMSWithSilenceReturnsZeroes() throws {
        let sampleRate: Double = 44100
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCapacity = AVAudioFrameCount(sampleRate) // 1 second
        
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity)!
        buffer.frameLength = frameCapacity
        
        // Fill channel with 0.0
        if let data = buffer.floatChannelData {
            for i in 0..<Int(frameCapacity) {
                data[0][i] = 0.0
            }
        }
        
        let values = try engine.analyzeRMS(for: buffer, intervalSeconds: 0.1)
        
        // 1 second buffer divided by 0.1 intervals = 10 blocks
        XCTAssertEqual(values.count, 10)
        
        for val in values {
            XCTAssertEqual(val, 0.0)
        }
    }
    
    func testAnalyzeRMSWithConstantSignal() throws {
        let sampleRate: Double = 44100
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCapacity = AVAudioFrameCount(sampleRate) // 1 second
        
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity)!
        buffer.frameLength = frameCapacity
        
        // RMS of a constant 1.0 signal is 1.0.
        // RMS = sqrt(mean(x^2)) = sqrt(mean(1^2)) = sqrt(1) = 1
        if let data = buffer.floatChannelData {
            for i in 0..<Int(frameCapacity) {
                data[0][i] = 1.0
            }
        }
        
        let values = try engine.analyzeRMS(for: buffer, intervalSeconds: 0.5)
        
        XCTAssertEqual(values.count, 2)
        XCTAssertEqual(values[0], 1.0, accuracy: 0.001)
        XCTAssertEqual(values[1], 1.0, accuracy: 0.001)
    }
    
    func testAnalyzeRMSMultiChannelThrowsError() throws {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44100)!
        buffer.frameLength = 44100
        
        XCTAssertThrowsError(try engine.analyzeRMS(for: buffer, intervalSeconds: 0.1)) { error in
            XCTAssertEqual(error as? VolumeAnalysisError, .invalidBufferLayout)
        }
    }
    
    func testAnalyzeRMSInvalidIntervalThrowsError() throws {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44100)!
        buffer.frameLength = 44100
        
        // Interval is longer than the actual buffer
        XCTAssertThrowsError(try engine.analyzeRMS(for: buffer, intervalSeconds: 2.0)) { error in
            XCTAssertEqual(error as? VolumeAnalysisError, .unsupportedInterval)
        }
    }
}
