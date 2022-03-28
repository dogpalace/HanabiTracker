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
            card.suits.isEmpty,
            .defaultSuits
        )
        
        XCTAssertNil(
            card.value,
            .defaultValue
        )
    }
    
    func testOutstandingSuits() {
        XCTAssertEqual(
            card.outstandingSuits,
            Set(Suit.allCases),
            .defaultOutstandingSuits
        )
    }
    
    func testSettingSuit() {
        card.setSuits([.red])
        
        XCTAssertEqual(
            card.outstandingSuits,
            Set(Suit.allCases).subtracting([.red]),
            .settingSuit
        )
    }
    
    func testRemovingOutstandingSuit() {
        card.removeOutstandingSuit(.green)
        let outstandingSuits = card.outstandingSuits
        
        XCTAssertEqual(
            outstandingSuits,
            Set(Suit.allCases).subtracting([.green]),
            .removeOutstandingSuit
        )
    }
    
    func testOutstandingValues() {
        XCTAssertEqual(
            card.outstandingValues,
            Set(Value.allCases),
            .defaultOutstandingValues
        )
    }
    
    func testSettingValue() {
        card.setValue(.one)
        
        XCTAssertEqual(
            card.outstandingValues,
            Set(Value.allCases).subtracting([.one]),
            .settingValue
        )
    }
    
    func testRemovingOutstandingValue() {
        card.removeOutstandingValue(.five)
        
        XCTAssertEqual(
            card.outstandingValues,
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
    static let settingValue = "Setting a value should remove it from the outstanding values"
    static let removeOutstandingSuit = "A card can remove a suit from its outstanding suits"
    static let removeOutstandingValue = "A card can remove a value from its outstanding values"
}
