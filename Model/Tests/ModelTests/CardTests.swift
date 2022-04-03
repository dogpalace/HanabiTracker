import XCTest
@testable import Model

class CardTests: XCTestCase {
    
    var card: Card!

    override func setUp() {
        super.setUp()

        card = Card()
    }

    override func tearDown() {
        super.tearDown()

        card = nil
    }

    func testDefaultInformation() {
        XCTAssertTrue(
            card.hintedSuits.isEmpty,
            .defaultSuits
        )
        
        XCTAssertNil(
            card.value,
            .defaultValue
        )
    }
    
    func testOutstandingSuits() {
        XCTAssertEqual(
            card.hintableSuits,
            Set(Suit.allCases),
            .defaultOutstandingSuits
        )
    }
    
    func testSettingSuit() {
        card.setSuits([.red])
        
        XCTAssertEqual(
            card.hintableSuits,
            Set(Suit.allCases).subtracting([.red]),
            .settingSuit
        )
    }
    
    func testRemovingOutstandingSuit() {
        card.removeHintableSuit(.green)
        let outstandingSuits = card.hintableSuits
        
        XCTAssertEqual(
            outstandingSuits,
            Set(Suit.allCases).subtracting([.green]),
            .removeOutstandingSuit
        )
    }
    
    func testOutstandingValues() {
        XCTAssertEqual(
            card.hintableValues,
            Set(Value.allCases),
            .defaultOutstandingValues
        )
    }
    
    func testSettingValue() {
        card.setValue(.one)
        
        XCTAssertTrue(
            card.hintableValues.isEmpty,
            .settingValue
        )
    }
    
    func testRemovingOutstandingValue() {
        card.removeHintableValue(.five)
        
        XCTAssertEqual(
            card.hintableValues,
            Set(Value.allCases).subtracting([.five]),
            .removeOutstandingValue
        )
    }
}

fileprivate extension String {
    static let defaultSuits = "A card should not have suits by default"
    static let defaultValue = "A card should not know its value by default"
    static let defaultOutstandingSuits = "Outstanding suits contains all suits"
    static let defaultOutstandingValues = "Outstanding values contains all values"
    static let settingSuit = "Setting a suit should remove it from the outstanding suits"
    static let settingValue = "Setting a value should remove all outstanding values"
    static let removeOutstandingSuit = "A card can remove a suit from its outstanding suits"
    static let removeOutstandingValue = "A card can remove a value from its outstanding values"
}
