import XCTest
@testable import Model

class HandSizeTests: XCTestCase {

    func testRawValues() {
        XCTAssertEqual(Hand.Size.four.rawValue, 4, .canHaveFourCards)
        XCTAssertEqual(Hand.Size.five.rawValue, 5, .canHaveFiveCards)
    }
}

fileprivate extension String {
    static let canHaveFourCards = "A hand can have four cards"
    static let canHaveFiveCards = "A hand can have five cards"
}
