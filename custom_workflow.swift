import Foundation
import AVFoundation
import Accelerate

// Configuration
let audioFilePath = "/path/to/audio/file.wav" // Replace with your .wav file
let video1Path = "/path/to/video1.mp4"        // Replace with the Guest video (1 person)
let video2Path = "/path/to/video2.mp4"        // Replace with the Host video (3 people)
let outputPath = "/path/to/output.mp4"        // Change extension to .mp4

let intervalSeconds = 0.5 // Process the audio in 0.5 second chunks

// Audio indices (0-based)
// The user said:
// Track 1 & 2: Stereo mix (indices 0, 1)
// Track 3: Speaker 1 (index 2) -> Video 2
// Track 4: Speaker 2 (index 3) -> Video 2
// Track 5: Speaker 3 (index 4) -> Video 2
// Track 6: Speaker 4 (Guest) (index 5) -> Video 1

let guestChannelIndex = 5
let hostChannelIndices = [2, 3, 4]

func calculateRMS(floatData: UnsafePointer<Float>, frameLength: vDSP_Length) -> Float {
    var rms: Float = 0.0
    vDSP_rmsqv(floatData, 1, &rms, frameLength)
    return rms
}

func extractAndAnalyzeAudio(audioURL: URL, intervalSeconds: Double) throws -> [(time: CMTime, duration: CMTime, activeVideo: Int)] {
    print("Loading audio file...")
    let audioFile = try AVAudioFile(forReading: audioURL)
    let format = audioFile.fileFormat
    let sampleRate = format.sampleRate
    let channelCount = Int(format.channelCount)
    
    guard channelCount >= 6 else {
        fatalError("Error: Expected at least 6 channels, found \(channelCount)")
    }
    
    let frameCount = AVAudioFrameCount(audioFile.length)
    let framesPerInterval = AVAudioFrameCount(intervalSeconds * sampleRate)
    
    guard let sourceBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: frameCount) else {
        fatalError("Failed to create audio buffer")
    }
    
    try audioFile.read(into: sourceBuffer)
    guard let floatChannelData = sourceBuffer.floatChannelData else {
        fatalError("Failed to get float channel data")
    }
    
    let totalFrames = sourceBuffer.frameLength
    let intervalCount = Int(totalFrames / framesPerInterval)
    
    var decisions: [(time: CMTime, duration: CMTime, activeVideo: Int)] = []
    
    var currentActiveVideo: Int = 1 // Default to Video 1 initially
    var currentSegmentStartFrame: AVAudioFramePosition = 0
    
    print("Analyzing audio volumes...")
    
    for i in 0..<intervalCount {
        let offset = i * Int(framesPerInterval)
        
        // Analyze Guest (Video 1)
        let guestRMS = calculateRMS(floatData: floatChannelData[guestChannelIndex].advanced(by: offset), frameLength: vDSP_Length(framesPerInterval))
        
        // Analyze Hosts (Video 2)
        var maxHostRMS: Float = 0.0
        for index in hostChannelIndices {
            let hostRMS = calculateRMS(floatData: floatChannelData[index].advanced(by: offset), frameLength: vDSP_Length(framesPerInterval))
            maxHostRMS = max(maxHostRMS, hostRMS)
        }
        
        let expectedVideo = (guestRMS > maxHostRMS) ? 1 : 2
        
        if expectedVideo != currentActiveVideo {
            if i > 0 {
                let segmentDurationFrames = AVAudioFramePosition(offset) - currentSegmentStartFrame
                let time = CMTime(value: currentSegmentStartFrame, timescale: CMTimeScale(sampleRate))
                let duration = CMTime(value: segmentDurationFrames, timescale: CMTimeScale(sampleRate))
                decisions.append((time: time, duration: duration, activeVideo: currentActiveVideo))
            }
            currentActiveVideo = expectedVideo
            currentSegmentStartFrame = AVAudioFramePosition(offset)
        }
    }
    
    // Final segment
    let finalOffset = intervalCount * Int(framesPerInterval)
    if Int64(totalFrames) > currentSegmentStartFrame {
        let time = CMTime(value: currentSegmentStartFrame, timescale: CMTimeScale(sampleRate))
        let duration = CMTime(value: Int64(totalFrames) - currentSegmentStartFrame, timescale: CMTimeScale(sampleRate))
        decisions.append((time: time, duration: duration, activeVideo: currentActiveVideo))
    }
    
    return decisions
}

func buildAndExport(decisions: [(time: CMTime, duration: CMTime, activeVideo: Int)], audioURL: URL, video1URL: URL, video2URL: URL, outputURL: URL) async throws {
    print("Building composition...")
    
    let composition = AVMutableComposition()
    
    // Load assets
    let audioAsset = AVURLAsset(url: audioURL)
    let video1Asset = AVURLAsset(url: video1URL)
    let video2Asset = AVURLAsset(url: video2URL)
    
    // Wait for properties
    let audioTracks = try await audioAsset.loadTracks(withMediaType: .audio)
    let video1Tracks = try await video1Asset.loadTracks(withMediaType: .video)
    let video2Tracks = try await video2Asset.loadTracks(withMediaType: .video)
    
    guard let firstAudioTrack = audioTracks.first else { fatalError("Audio asset has no audio tracks") }
    guard let video1Track = video1Tracks.first else { fatalError("Video 1 has no video track") }
    guard let video2Track = video2Tracks.first else { fatalError("Video 2 has no video track") }
    
    let compAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
    let compVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
    
    // Add the full audio
    let totalAudioDuration = try await audioAsset.load(.duration)
    try compAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: totalAudioDuration), of: firstAudioTrack, at: .zero)
    
    // Build video track based on decisions
    var currentTime: CMTime = .zero
    
    for decision in decisions {
        let sourceVideoTrack = (decision.activeVideo == 1) ? video1Track : video2Track
        let timeRange = CMTimeRange(start: decision.time, duration: decision.duration)
        
        try compVideoTrack.insertTimeRange(timeRange, of: sourceVideoTrack, at: currentTime)
        currentTime = CMTimeAdd(currentTime, decision.duration)
    }
    
    // Set video frame size correctly from Video 1 (assuming they match)
    let preferredTransform = try await video1Track.load(.preferredTransform)
    compVideoTrack.preferredTransform = preferredTransform
    
    print("Exporting to \(outputURL.path)...")
    if FileManager.default.fileExists(atPath: outputURL.path) {
        try FileManager.default.removeItem(at: outputURL)
    }
    
    // Use HEVC 3840x2160 (4K) preset
    guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHEVC3840x2160) else {
        fatalError("Failed to create export session with HEVC 4K preset. Ensure your source videos support this or the OS supports it.")
    }
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .mp4
    
    await exportSession.export()
    
    if exportSession.status == .completed {
        print("Export completed successfully!")
    } else if let error = exportSession.error {
        print("Export failed: \(error)")
    } else {
        print("Export finished with status \(exportSession.status.rawValue)")
    }
}

func main() async {
    let audioURL = URL(fileURLWithPath: audioFilePath)
    let video1URL = URL(fileURLWithPath: video1Path)
    let video2URL = URL(fileURLWithPath: video2Path)
    let outputURL = URL(fileURLWithPath: outputPath)
    
    do {
        let decisions = try extractAndAnalyzeAudio(audioURL: audioURL, intervalSeconds: intervalSeconds)
        print("Generated \(decisions.count) cuts.")
        
        try await buildAndExport(decisions: decisions, audioURL: audioURL, video1URL: video1URL, video2URL: video2URL, outputURL: outputURL)
        
    } catch {
        print("Error: \(error)")
    }
    exit(0)
}

Task {
    await main()
}

RunLoop.main.run()
