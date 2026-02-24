import XCTest
@testable import AUTOPODCUT

final class ActiveSpeakerStateMachineTests: XCTestCase {
    
    func testQuickSilenceReturnsNil() {
        let machine = ActiveSpeakerStateMachine(switchThreshold: 1, silenceThreshold: 0.1)
        let channel0: [Float] = [0.0, 0.0, 0.0]
        let channel1: [Float] = [0.0, 0.0, 0.0]
        
        let results = machine.computeActiveSpeakers(channelPower: [channel0, channel1])
        XCTAssertEqual(results, [nil, nil, nil])
    }
    
    func testImmediateSwitchWithThresholdOne() {
        let machine = ActiveSpeakerStateMachine(switchThreshold: 1, silenceThreshold: 0.1)
        let channel0: [Float] = [0.5, 0.0, 0.5]
        let channel1: [Float] = [0.0, 0.5, 0.0]
        
        let results = machine.computeActiveSpeakers(channelPower: [channel0, channel1])
        XCTAssertEqual(results, [0, 1, 0])
    }
    
    func testHysteresisWithHigherThreshold() {
        // Requires 3 consecutive intervals to switch
        let machine = ActiveSpeakerStateMachine(switchThreshold: 3, silenceThreshold: 0.1)
        
        // C0 starts loud for 5 intervals
        // C1 attempts to interrupt for 2 intervals (fails to switch)
        // C1 attempts again and holds for 3 intervals (switches)
        let channel0: [Float] = [0.5, 0.5, 0.5, 0.5, 0.5,   0.0, 0.0,   0.0, 0.0, 0.0]
        let channel1: [Float] = [0.0, 0.0, 0.0, 0.8, 0.8,   0.0, 0.0,   0.8, 0.8, 0.8]
        
        let results = machine.computeActiveSpeakers(channelPower: [channel0, channel1])
        
        // Initial setup: C0 needs 3 intervals to register?
        // Wait, at threshold 3:
        // idx 0, 1: highest C0 -> candidate C0, count 1, 2. result nil
        // idx 2: highest C0 -> count 3 -> switch to C0. result 0
        // idx 3, 4: highest C1 -> candidate C1, count 1, 2. result holds 0
        // idx 5, 6: both silent -> candidate nil, drops. result holds 0 (or goes to nil?)
        // Oh wait, if both silent, loudestChannel is nil, which drops to nil if it takes 3 intervals to switch to nil.
        
        XCTAssertEqual(results.count, 10)
        XCTAssertEqual(results[2], 0) // C0 becomes active
        XCTAssertEqual(results[3], 0) // C0 still active despite C1 interruption
        XCTAssertEqual(results[4], 0) // C0 still active
        // After C1 holds for 3 (at idx 7, 8, 9), it should switch to 1.
        XCTAssertEqual(results[9], 1) // C1 becomes active
    }
}
