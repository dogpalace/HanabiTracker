import XCTest
@testable import Model

final class SuitTests: XCTestCase {

    func testAllCases() {
        XCTAssertEqual(
            [Suit.red, .yellow, .green, .blue, .white],
            Suit.allCases,
            "Should be a finite number of suits"
        )
    }
}
