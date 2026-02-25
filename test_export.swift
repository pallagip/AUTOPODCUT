import Foundation
import AVFoundation

let preset = AVAssetExportPresetHEVCHighestQuality
let composition = AVMutableComposition()
let session = AVAssetExportSession(asset: composition, presetName: preset)

if let session = session {
    print("Export session created with \(preset)")
    let supported = session.supportedFileTypes
    print("Supported types: \(supported.map { $0.rawValue })")
} else {
    print("Could not create export session")
}
