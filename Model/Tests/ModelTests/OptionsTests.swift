import XCTest
@testable import Model

class OptionsTests: XCTestCase {

    let options = Options()
    
    func testDefaults() {
        XCTAssertEqual(
            options.allowsRainbows,
            false,
            "Should not allow rainbows by default"
        )
        XCTAssertEqual(
            options.handSize,
            .four,
            "Should have a default hand size of four"
        )
    }
}
