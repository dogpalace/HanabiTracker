import XCTest
@testable import Model

class HandTests: XCTestCase {

    let allowsRainbows = false
    var hand: Hand!
    
    override func tearDown() {
        hand = nil
        
        super.tearDown()
    }

    func testHasConfiguration() async {
        await useHand(withRainbows: false)
        
        let configurationAllowsRainbows = await hand.configuration.allowsRainbows
        XCTAssertEqual(
            configurationAllowsRainbows,
            allowsRainbows,
            .hasConfiguration
        )
    }
    
    func testHasSize() async {
        await useHand(withRainbows: false)
        let size = await hand.size
        XCTAssertEqual(size, .four, .hasSize)
    }
    
    func testFourCards() async {
        await useHand(withRainbows: false)
        let count = await hand.cards.count
        XCTAssertEqual(count, 4, .hasFourCards)
    }
    
    func testFiveCards() async {
        hand = await Hand(
            configuration: .init(allowsRainbows: false),
            size: .five
        )
        let count = await hand.cards.count
        
        XCTAssertEqual(count, 5, .hasFiveCards)
    }

    func testPossibleSuitsWithoutRainbowsForUnsuitedCard() async throws {
        await useHand(withRainbows: false)
        let card = await getFirstCard()
        let possibleSuits = await hand.getPossibleSuits(for: card)
        
        XCTAssertEqual(
            possibleSuits,
            Set(Suit.allCases),
            .WithoutRainbows.possibleSuitsForUnsuitedCard
        )
    }
    
    func testPossibleSuitsWithoutRainbowsForSuitedCard() async throws {
        await useHand(withRainbows: false)
        let card = await getFirstCard()
        card.setSuits([.green])
        let possibleSuits = await hand.getPossibleSuits(for: card)
                
        XCTAssertTrue(
            possibleSuits.isEmpty,
            .WithoutRainbows.possibleSuitsForSingleSuitedCard
        )
    }
    
    func testPossibleSuitsWithRainbowsForUnsuitedCard() async {
        await useHand(withRainbows: true)
        let card = await getFirstCard()
        let possibleSuits = await hand.getPossibleSuits(for: card)
        
        XCTAssertEqual(
            possibleSuits,
            Set(Suit.allCases),
            .WithRainbows.possibleSuitsForUnsuitedCard
        )
    }

    func testPossibleSuitsWithRainbowsForSuitedCard() async {
        await useHand(withRainbows: true)
        let card = await getFirstCard()
        card.setSuits([.green])
        let possibleSuits = await hand.getPossibleSuits(for: card)
        
        XCTAssertEqual(
            possibleSuits,
            [.yellow, .red, .white, .blue],
            .WithRainbows.possibleSuitsForSingleSuitedCard
        )
    }
    
    func testPossibleSuitsWithRainbowsForMultiSuitedCard() async {
        await useHand(withRainbows: true)
        let card = await getFirstCard()
        card.setSuits([.green, .blue])
        let possibleSuits = await hand.getPossibleSuits(for: card)
        
        XCTAssertTrue(
            possibleSuits.isEmpty,
            .WithRainbows.possibleSuitsForMultiSuitedCard
        )
    }
    
    func testApplyingSuitHintWithoutRainbows() async {
        await useHand(withRainbows: false)
        
        let startCards = await Array(hand.cards[0 ... 1])
        
        await hand.applyHint(.suit(.red), to: startCards)
        
        for card in startCards {
            let possibleSuits = await hand.getPossibleSuits(for: card)
            XCTAssertTrue(
                possibleSuits.isEmpty,
                .WithoutRainbows.applyingSuitHint
            )
        }

        let endCards = await Array(hand.cards[2 ... 3])
        
        for card in endCards {
            let possibleSuits = await hand.getPossibleSuits(for: card)
            XCTAssertEqual(
                possibleSuits,
                Set(Suit.allCases).subtracting([.red]),
                .WithoutRainbows.applyingSuitHint
            )
        }
    }
    
    func testApplyingSuitHintWithRainbows() async {
        await useHand(withRainbows: true)
        
        let firstCard = await hand.cards.first!
        
        // Assume the last card is a rainbow with one suit hinted
        let lastCard = await hand.cards.last!
        lastCard.setSuits([.green])
        
        await hand.applyHint(.suit(.red), to: [firstCard])
        
        let startingCards = await Array(hand.cards[0 ..< 3])
        
        for card in startingCards {
            let possibleSuits = await hand.getPossibleSuits(for: card)
            XCTAssertEqual(
                possibleSuits,
                Set(Suit.allCases).subtracting([.red]),
                .WithRainbows.applyingSuitHint
            )
        }
        
        let possibleSuits = await hand.getPossibleSuits(for: lastCard)
        XCTAssertEqual(
            possibleSuits,
            Set(Suit.allCases).subtracting([.red, .green]),
            .WithRainbows.applyingSuitHint
        )
    }
    
    func testPossibleValuesForValuedCard() async {
        await useHand(withRainbows: true)
        let firstCard = await hand.cards.first!
        
        firstCard.setValue(.four)
        let possibleValues = await hand.getPossibleValues(for: firstCard)
        
        XCTAssertTrue(
            possibleValues.isEmpty,
            .possibleValuesForValuedCard
        )
    }
    
    func testPossibleValuesForCardWithNarrowedValues() async {
        await useHand(withRainbows: true)
        let firstCard = await hand.cards.first!
        firstCard.removeOutstandingValue(.one)
        firstCard.removeOutstandingValue(.three)

        let possibleValues = await hand.getPossibleValues(for: firstCard)

        XCTAssertEqual(
            possibleValues,
            Set(Value.allCases).subtracting([.three, .one]),
            .possibleValuesForNarrowedValueCard
        )
    }
    
    func testApplyingValueHint() async {
        await useHand(withRainbows: false)
        let firstCard = await hand.cards.first!
        let remainingCards = await Array(hand.cards[1 ... 3])

        await hand.applyHint(.value(.five), to: [firstCard])

        // first card will have possible value of five
        // other cards will have possible values of one through four
        XCTAssertEqual(
            firstCard.value,
            .five,
            .applyingValueHint
        )

        let possibleValues = await hand.getPossibleValues(for: firstCard)
        XCTAssertTrue(
            possibleValues.isEmpty,
            .possibleValuesForValuedCard
        )

        for card in remainingCards {
            let possibleValues = await hand.getPossibleValues(for: card)
            XCTAssertEqual(
                possibleValues,
                Set(Value.allCases).subtracting([.five]),
                .valueHintNarrowsPossibleValues
            )
        }
    }
    
    func testShiftingCards() {
        // todo
    }

    
    // MARK: - Helpers
    
    private func getFirstCard() async -> Card {
        await hand.cards.first!
    }

    private func useHand(withRainbows: Bool) async {
        hand = await Hand(
            configuration: Hand.Configuration(allowsRainbows: withRainbows),
            size: .four
        )
    }
}

fileprivate extension String {
    static let hasConfiguration = "A hand has a configuration"
    static let hasSize = "A hand has a size"
    static let hasFourCards = "A hand can have four cards"
    static let hasFiveCards = "A hand can have five cards"
    static let possibleValuesForValuedCard = "A card hinted with a value has that value and no other possible values"
    static let possibleValuesForNarrowedValueCard = "A card with narrowed outstanding values should only have those as possible values"
    static let applyingValueHint = "A card hinted with a value should have that value"
    static let valueHintNarrowsPossibleValues = "A value hint should narrow the possible values for cards not part of the hint"
    
    enum WithoutRainbows {
        static let possibleSuitsForUnsuitedCard = "An unsuited card can be any suit"
        static let possibleSuitsForSingleSuitedCard = "A single suited card has no possible suits"
        static let applyingSuitHint = "Applying a suit hint should eliminate other possible suits"
    }
    
    enum WithRainbows {
        static let possibleSuitsForUnsuitedCard = "An unsuited card can be any suit"
        static let possibleSuitsForSingleSuitedCard = "A single suited card has four possible suits"
        static let possibleSuitsForMultiSuitedCard = "A multi-suited card has no possible suits"
        static let applyingSuitHint = "Applying a suit hint should set the suit for applicable cards and eliminate the suit for others"
    }
}
