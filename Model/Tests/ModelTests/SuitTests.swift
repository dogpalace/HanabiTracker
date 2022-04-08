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
    
    func testOrder() {
        XCTAssertLessThan(
            Suit.red,
            Suit.yellow,
            "Suits should be in a predictable order"
        )
        XCTAssertLessThan(
            Suit.yellow,
            Suit.green,
            "Suits should be in a predictable order"
        )
        XCTAssertLessThan(
            Suit.green,
            Suit.blue,
            "Suits should be in a predictable order"
        )
        XCTAssertLessThan(
            Suit.blue,
            Suit.white,
            "Suits should be in a predictable order"
        )
    }
    
    func testCodability() throws {
        let encodedSuit = try JSONEncoder().encode(Suit.blue)
        let decodedSuit = try JSONDecoder().decode(Suit.self, from: encodedSuit)
        
        XCTAssertEqual(
            decodedSuit,
            .blue,
            "A suit should be encodable and decodable"
        )
    }
}
