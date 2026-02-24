import Foundation
import CoreGraphics

public enum CropDefinitionError: Error, Equatable {
    case invalidDimensions
    case negativeCoordinates
}

public struct CropDefinition: Equatable {
    public let x: CGFloat
    public let y: CGFloat
    public let width: CGFloat
    public let height: CGFloat
    
    /// Initializes a CropDefinition with normalized or explicit pixel coordinates.
    /// Values must be non-negative, and dimensions must be greater than zero.
    public init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) throws {
        guard x >= 0 && y >= 0 else {
            throw CropDefinitionError.negativeCoordinates
        }
        guard width > 0 && height > 0 else {
            throw CropDefinitionError.invalidDimensions
        }
        
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    /// Provides the CoreGraphics Rect representation of the crop bounds
    public var rect: CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
