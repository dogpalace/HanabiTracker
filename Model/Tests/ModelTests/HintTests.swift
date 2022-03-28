import XCTest
@testable import Model

class HintTests: XCTestCase {

    func testSuitHints() {
        let hints = [
            Hint.suit(.red),
            .suit(.yellow),
            .suit(.green),
            .suit(.blue),
            .suit(.white)
        ]
        
        hints.forEach { hint in
            XCTAssertTrue(
                hint.isSuitHint,
                "Hints can indicate if they are suit hints"
            )
        }
    }
    
    func testValueHints() {
        let hints = [
            Hint.value(.one),
            .value(.two),
            .value(.three),
            .value(.four),
            .value(.five)
        ]
        
        hints.forEach { hint in
            XCTAssertTrue(
                hint.isValueHint,
                "Hints can indicate if they are value hints"
            )
        }
    }
    
    func testGettingSuit() {
        let hint = Hint.suit(.green)

        XCTAssertNil(
            hint.getValue(),
            "A suit-based hint should not be able to get its value"
        )
        
        XCTAssertEqual(
            hint.getSuit(),
            .green,
            "A suit-based hint should be able to get its suit"
        )
    }
    
    func testGettingValue() {
        let hint = Hint.value(.two)
        
        XCTAssertEqual(
            hint.getValue(),
            .two,
            "A value-based hint should be able to get its value"
        )

        XCTAssertNil(
            hint.getSuit(),
            "A value-based hint should not be able to get its suit"
        )
    }

}
