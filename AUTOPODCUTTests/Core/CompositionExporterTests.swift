import XCTest
import AVFoundation
@testable import AUTOPODCUT

final class CompositionExporterTests: XCTestCase {
    var exporter: CompositionExporter!
    
    override func setUpWithError() throws {
        exporter = CompositionExporter()
    }
    
    override func tearDownWithError() throws {
        exporter = nil
    }
    
    // Note: Exporting on CI/CLI asynchronously without real codecs/videos may fail or take extreme bounds.
    // At minimum we test that the API properly returns errors if given empty structures without asserting fully realized AVFoundation H265 renders immediately across threads here, or that an expectation resolves cleanly.
    
    func testExportRejectsEmptyCompositionFastFail() throws {
        let emptyComp = AVMutableComposition()
        let outURL = URL(fileURLWithPath: "/tmp/nonexistent_test.mp4")
        
        let expectation = self.expectation(description: "Export attempt bounds test")
        
        exporter.export(composition: emptyComp, to: outURL) { result in
            switch result {
            case .success:
                XCTFail("Exporting empty tracks must fail via native status overrides")
            case .failure(let error):
                // AVAssetExportSession handles empty composition validation inherently resulting in exportSessionCreationFailed or exportFailed based on OS fallback levels
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
}
