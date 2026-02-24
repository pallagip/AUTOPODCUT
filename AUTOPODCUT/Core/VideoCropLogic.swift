import Foundation
import AVFoundation

public enum VideoCropError: Error, Equatable {
    case invalidTrack
}

public class VideoCropLogic {
    public init() {}
    
    /// Creates a scalable `AVMutableVideoComposition` that acts as a cropping tool.
    /// It translates the video track based on the x/y coordinates of the crop definition
    /// and frames it by setting the output `renderSize` to the crop width/height.
    ///
    /// - Parameters:
    ///   - track: The source video `AVAssetTrack`.
    ///   - duration: The duration to apply the instructions over.
    ///   - crop: The definition of the bounds we want to isolate.
    /// - Returns: An `AVMutableVideoComposition` with the specified frame definitions.
    public func createComposition(for track: AVAssetTrack, duration: CMTime, crop: CropDefinition) -> AVMutableVideoComposition {
        let composition = AVMutableVideoComposition()
        
        // The render size is exactly the size of the crop
        composition.renderSize = CGSize(width: crop.width, height: crop.height)
        
        // Use the source track's framerate or a sensible default
        let fps = track.nominalFrameRate > 0 ? track.nominalFrameRate : 30.0
        composition.frameDuration = CMTimeMake(value: 1, timescale: Int32(fps))
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        
        // In AVFoundation (CoreGraphics space), translation moves the frame.
        // To crop out the top-left by x/y, we shift the transform by negative x/y.
        // NOTE: standard AVFoundation transform origins might require specific orientations 
        // to be respected, but this satisfies the basic translation for our models.
        let baseTransform = track.preferredTransform
        let translateTransform = baseTransform.translatedBy(x: -crop.x, y: -crop.y)
        
        layerInstruction.setTransform(translateTransform, at: .zero)
        
        instruction.layerInstructions = [layerInstruction]
        composition.instructions = [instruction]
        
        return composition
    }
}
