import XCTest
@testable import Model

final class ValueTests: XCTestCase {

    func testAllCases() {
        XCTAssertEqual(
            [Value.one, .two, .three, .four, .five],
            Value.allCases,
            "Should be a finite number of cases"
        )
    }
}
