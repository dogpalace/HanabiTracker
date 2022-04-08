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
    
    func testCodability() throws {
        let encodedValue = try JSONEncoder().encode(Value.three)
        let decodedValue = try JSONDecoder().decode(Value.self, from: encodedValue)
        
        XCTAssertEqual(
            decodedValue,
            .three,
            "A value should be encodable and decodable"
        )
    }
}
