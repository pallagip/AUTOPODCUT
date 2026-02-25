import Foundation
import AVFoundation

let url = URL(fileURLWithPath: "/Volumes/Lacie2/POTCAST PROJECT/DEMO_1/POTCAST_HANGOK.wav")
let asset = AVURLAsset(url: url)

func test() async throws {
    guard let track = try await asset.loadTracks(withMediaType: .audio).first else { return }
    let reader = try AVAssetReader(asset: asset)
    let outputSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatLinearPCM,
        AVLinearPCMBitDepthKey: 32,
        AVLinearPCMIsFloatKey: true,
        AVLinearPCMIsBigEndianKey: false,
        AVLinearPCMIsNonInterleaved: false
    ]
    let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
    reader.add(output)
    reader.startReading()

    let numChannels = 6
    var t6Samples: [Float] = []
    var t3Samples: [Float] = []

    while let sampleBuffer = output.copyNextSampleBuffer() {
        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { continue }
        var length = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &dataPointer)
        guard let data = dataPointer else { continue }

        let floatCount = length / MemoryLayout<Float>.size
        let floatPointer = data.withMemoryRebound(to: Float.self, capacity: floatCount) { $0 }

        let frames = floatCount / numChannels
        for f in 0..<frames {
            let base = f * numChannels
            t3Samples.append(floatPointer[base + 2]) // Track 3 (0-indexed 2)
            t6Samples.append(floatPointer[base + 5]) // Track 6 (0-indexed 5)
        }
        if t6Samples.count > 48000 * 300 { break } // Only first 5 mins
    }
    
    // Compute RMS every 0.1s
    let window = 4800
    for i in stride(from: 0, to: 48000 * 60, by: window) { // First 60 seconds
        if i + window > t6Samples.count { break }
        let ms = t6Samples[i..<i+window]
        let o3 = t3Samples[i..<i+window]
        let rms6 = sqrt(ms.map { $0 * $0 }.reduce(0, +) / Float(window))
        let rms3 = sqrt(o3.map { $0 * $0 }.reduce(0, +) / Float(window))
        let time = Double(i) / 48000.0
        if time.truncatingRemainder(dividingBy: 5.0) < 0.1 {
            print("Time \(time)s -> T6 RMS: \(rms6), T3 RMS: \(rms3)")
        }
    }
}

Task {
    try? await test()
    exit(0)
}
RunLoop.main.run()
