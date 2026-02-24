import XCTest
import CoreMedia
@testable import AUTOPODCUT

final class EDLGeneratorTests: XCTestCase {
    var generator: EDLGenerator!
    let intervalSeconds: Double = 0.1
    
    override func setUpWithError() throws {
        generator = EDLGenerator()
    }
    
    override func tearDownWithError() throws {
        generator = nil
    }
    
    func testGeneratorEmptyArrayThrows() {
        XCTAssertThrowsError(try generator.generateEDL(from: [], intervalSeconds: intervalSeconds)) { error in
            XCTAssertEqual(error as? EDLGeneratorError, .emptySpeakerSequence)
        }
    }
    
    func testGeneratorInvalidIntervalThrows() {
        XCTAssertThrowsError(try generator.generateEDL(from: [0, 0, 1], intervalSeconds: -0.1)) { error in
            XCTAssertEqual(error as? EDLGeneratorError, .invalidIntervalDuration)
        }
    }
    
    func testGenerateContinuousSingleSpeaker() throws {
        let speakers: [Int?] = [0, 0, 0, 0, 0] // 0.5 seconds total
        let edl = try generator.generateEDL(from: speakers, intervalSeconds: 0.1)
        
        XCTAssertEqual(edl.count, 1)
        XCTAssertEqual(edl[0].activeChannelIndex, 0)
        XCTAssertEqual(edl[0].timeRange.duration.seconds, 0.5, accuracy: 0.001)
        XCTAssertEqual(edl[0].timeRange.start.seconds, 0.0, accuracy: 0.001)
    }
    
    func testGenerateMultipleSpeakers() throws {
        let speakers: [Int?] = [0, 0, 0, 1, 1, 0, 0, nil, nil]
        /* Breakdown (0.1s interval):
           0.0 -> 0.3s (0)
           0.3 -> 0.5s (1)
           0.5 -> 0.7s (0)
           0.7 -> 0.9s (nil)
        */
        let edl = try generator.generateEDL(from: speakers, intervalSeconds: 0.1)
        
        XCTAssertEqual(edl.count, 4)
        
        // Block 1 (Idx 0)
        XCTAssertEqual(edl[0].activeChannelIndex, 0)
        XCTAssertEqual(edl[0].timeRange.start.seconds, 0.0, accuracy: 0.001)
        XCTAssertEqual(edl[0].timeRange.duration.seconds, 0.3, accuracy: 0.001)
        
        // Block 2 (Idx 1)
        XCTAssertEqual(edl[1].activeChannelIndex, 1)
        XCTAssertEqual(edl[1].timeRange.start.seconds, 0.3, accuracy: 0.001)
        XCTAssertEqual(edl[1].timeRange.duration.seconds, 0.2, accuracy: 0.001)
        
        // Block 3 (Idx 0 again)
        XCTAssertEqual(edl[2].activeChannelIndex, 0)
        XCTAssertEqual(edl[2].timeRange.start.seconds, 0.5, accuracy: 0.001)
        XCTAssertEqual(edl[2].timeRange.duration.seconds, 0.2, accuracy: 0.001)
        
        // Block 4 (nil)
        XCTAssertNil(edl[3].activeChannelIndex)
        XCTAssertEqual(edl[3].timeRange.start.seconds, 0.7, accuracy: 0.001)
        XCTAssertEqual(edl[3].timeRange.duration.seconds, 0.2, accuracy: 0.001)
    }
}
