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
    var mR: [Float] = [] // Track 6
    var oR: [Float] = [] // Track 3
    var sampleCount = 0

    while let sampleBuffer = output.copyNextSampleBuffer() {
        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { continue }
        var length = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &dataPointer)
        guard let data = dataPointer else { continue }

        let floatCount = length / MemoryLayout<Float>.size
        let floatPointer = data.withMemoryRebound(to: Float.self, capacity: floatCount) { $0 }
        let frames = floatCount / numChannels

        // Process in chunks
        let window = 4800 // 0.1s
        if frames >= window {
            for chunkStart in stride(from: 0, to: frames - window, by: window) {
                var mSumSq: Float = 0
                var oSumSq: Float = 0
                for f in chunkStart..<chunkStart + window {
                    let mVal = floatPointer[f * numChannels + 5]
                    let oVal = floatPointer[f * numChannels + 2]
                    mSumSq += mVal * mVal
                    oSumSq += oVal * oVal
                }
                mR.append(sqrt(mSumSq / Float(window)))
                oR.append(sqrt(oSumSq / Float(window)))
            }
        }
        sampleCount += frames
        if sampleCount > 48000 * 300 { break } 
    }

    print("Extracted \(mR.count) chunks")
    let sortedM = mR.sorted()
    let noiseFloor = sortedM[max(0, sortedM.count / 20)]
    let peak = sortedM[min(sortedM.count - 1, Int(Double(sortedM.count) * 0.95))]
    let dynamicThresh = noiseFloor + (peak - noiseFloor) * 0.15
    let dynamicThresh25 = noiseFloor + (peak - noiseFloor) * 0.25

    print("Main channel 6:")
    print("NF: \(noiseFloor), Peak: \(peak)")
    print("Thresh 15%: \(dynamicThresh), Thresh 25%: \(dynamicThresh25)")

    var silentCount = 0
    var silentCountWithOther = 0
    for i in 0..<mR.count {
        if mR[i] < dynamicThresh25 { silentCount += 1 }
        if mR[i] < dynamicThresh25 || oR[i] > mR[i] * 1.2 { silentCountWithOther += 1 }
    }
    print("Total windows: \(mR.count)")
    print("Silent (mR < 25% range): \(silentCount)")
    print("Silent (mR < 25% range OR oR > 1.2*mR): \(silentCountWithOther)")
}

Task {
    do {
        try await test()
    } catch {
        print("Error: \(error)")
    }
    exit(0)
}
RunLoop.main.run()
