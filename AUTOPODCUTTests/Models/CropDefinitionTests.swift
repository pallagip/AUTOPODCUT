import XCTest
@testable import AUTOPODCUT

final class CropDefinitionTests: XCTestCase {
    
    func testValidCropInitialization() throws {
        let crop = try CropDefinition(x: 10, y: 20, width: 1920, height: 1080)
        
        XCTAssertEqual(crop.x, 10)
        XCTAssertEqual(crop.y, 20)
        XCTAssertEqual(crop.width, 1920)
        XCTAssertEqual(crop.height, 1080)
        XCTAssertEqual(crop.rect, CGRect(x: 10, y: 20, width: 1920, height: 1080))
    }
    
    func testZeroCoordinatesAllowed() throws {
        let crop = try CropDefinition(x: 0, y: 0, width: 100, height: 100)
        
        XCTAssertEqual(crop.x, 0)
        XCTAssertEqual(crop.y, 0)
        XCTAssertEqual(crop.width, 100)
        XCTAssertEqual(crop.height, 100)
    }
    
    func testNegativeXCoordinateThrows() {
        XCTAssertThrowsError(try CropDefinition(x: -1, y: 0, width: 100, height: 100)) { error in
            XCTAssertEqual(error as? CropDefinitionError, .negativeCoordinates)
        }
    }
    
    func testNegativeYCoordinateThrows() {
        XCTAssertThrowsError(try CropDefinition(x: 0, y: -5, width: 100, height: 100)) { error in
            XCTAssertEqual(error as? CropDefinitionError, .negativeCoordinates)
        }
    }
    
    func testZeroWidthThrows() {
        XCTAssertThrowsError(try CropDefinition(x: 0, y: 0, width: 0, height: 100)) { error in
            XCTAssertEqual(error as? CropDefinitionError, .invalidDimensions)
        }
    }
    
    func testZeroHeightThrows() {
        XCTAssertThrowsError(try CropDefinition(x: 0, y: 0, width: 100, height: 0)) { error in
            XCTAssertEqual(error as? CropDefinitionError, .invalidDimensions)
        }
    }
    
    func testNegativeDimensionsThrows() {
        XCTAssertThrowsError(try CropDefinition(x: 0, y: 0, width: -100, height: 100)) { error in
            XCTAssertEqual(error as? CropDefinitionError, .invalidDimensions)
        }
        
        XCTAssertThrowsError(try CropDefinition(x: 0, y: 0, width: 100, height: -100)) { error in
            XCTAssertEqual(error as? CropDefinitionError, .invalidDimensions)
        }
    }
}
