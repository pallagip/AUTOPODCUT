import AVFoundation

Task {
    do {
        let asset = AVURLAsset(url: URL(fileURLWithPath: "/System/Library/Sounds/Glass.aiff"))
        let comp = try await AVMutableVideoComposition(asset: asset)
        print("created")
    } catch {
        print(error)
    }
    exit(0)
}
RunLoop.main.run()
