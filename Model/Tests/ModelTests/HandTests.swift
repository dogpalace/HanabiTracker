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

    func testHintableSuitsWithoutRainbowsForUnsuitedCard() async throws {
        await useHand(withRainbows: false)
        let card = await getFirstCard()
        let hintableSuits = await hand.getHintableSuits(for: card)
        
        XCTAssertEqual(
            hintableSuits,
            Set(Suit.allCases),
            .WithoutRainbows.hintableSuitsForUnsuitedCard
        )
    }
    
    func testHintableSuitsWithoutRainbowsForSuitedCard() async throws {
        await useHand(withRainbows: false)
        let card = await getFirstCard()
        card.setSuits([.green])
        let hintableSuits = await hand.getHintableSuits(for: card)
                
        XCTAssertEqual(
            hintableSuits,
            [],
            .WithoutRainbows.hintableSuitsForSingleSuitedCard
        )
    }
    
    func testHintableSuitsWithRainbowsForUnsuitedCard() async {
        await useHand(withRainbows: true)
        let card = await getFirstCard()
        let hintableSuits = await hand.getHintableSuits(for: card)
        
        XCTAssertEqual(
            hintableSuits,
            Set(Suit.allCases),
            .WithRainbows.hintableSuitsForUnsuitedCard
        )
    }

    func testHintableSuitsWithRainbowsForSuitedCard() async {
        await useHand(withRainbows: true)
        let card = await getFirstCard()
        card.setSuits([.green])
        let hintableSuits = await hand.getHintableSuits(for: card)
        
        XCTAssertEqual(
            hintableSuits,
            [.yellow, .red, .white, .blue],
            .WithRainbows.hintableSuitsForSingleSuitedCard
        )
    }
    
    func testHintableSuitsWithRainbowsForMultiSuitedCard() async {
        await useHand(withRainbows: true)
        let card = await getFirstCard()
        card.setSuits([.green, .blue])
        let hintableSuits = await hand.getHintableSuits(for: card)
        
        XCTAssertTrue(
            hintableSuits.isEmpty,
            .WithRainbows.hintableSuitsForMultiSuitedCard
        )
    }
    
    func testApplyingSuitHintWithoutRainbows() async {
        await useHand(withRainbows: false)
        
        let startCards = await Array(hand.cards[0 ... 1])
        
        await hand.applyHint(.suit(.red), to: startCards)
        
        for card in startCards {
            let hintableSuits = await hand.getHintableSuits(for: card)
            XCTAssertTrue(
                hintableSuits.isEmpty,
                .WithoutRainbows.applyingSuitHint
            )
        }

        let endCards = await Array(hand.cards[2 ... 3])
        
        for card in endCards {
            let hintableSuits = await hand.getHintableSuits(for: card)
            XCTAssertEqual(
                hintableSuits,
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
            let hintableSuits = await hand.getHintableSuits(for: card)
            XCTAssertEqual(
                hintableSuits,
                Set(Suit.allCases).subtracting([.red]),
                .WithRainbows.applyingSuitHint
            )
        }
        
        let hintableSuits = await hand.getHintableSuits(for: lastCard)
        XCTAssertEqual(
            hintableSuits,
            Set(Suit.allCases).subtracting([.red, .green]),
            .WithRainbows.applyingSuitHint
        )
    }
    
    func testHintableValuesForValuedCard() async {
        await useHand(withRainbows: true)
        let firstCard = await hand.cards.first!
        
        firstCard.setValue(.four)
        let hintableValues = await hand.getHintableValues(for: firstCard)
        
        XCTAssertTrue(
            hintableValues.isEmpty,
            .hintableValuesForValuedCard
        )
    }
    
    func testHintableValuesForCardWithNarrowedValues() async {
        await useHand(withRainbows: true)
        let firstCard = await hand.cards.first!
        firstCard.removeHintableValue(.one)
        firstCard.removeHintableValue(.three)

        let hintableValues = await hand.getHintableValues(for: firstCard)

        XCTAssertEqual(
            hintableValues,
            Set(Value.allCases).subtracting([.three, .one]),
            .hintableValuesForNarrowedValueCard
        )
    }
    
    func testApplyingValueHint() async {
        await useHand(withRainbows: false)
        let firstCard = await hand.cards.first!
        let remainingCards = await Array(hand.cards[1 ... 3])

        await hand.applyHint(.value(.five), to: [firstCard])

        XCTAssertEqual(
            firstCard.value,
            .five,
            .applyingValueHint
        )

        let hintableValues = await hand.getHintableValues(for: firstCard)
        XCTAssertTrue(
            hintableValues.isEmpty,
            .hintableValuesForValuedCard
        )

        for card in remainingCards {
            let hintableValues = await hand.getHintableValues(for: card)
            XCTAssertEqual(
                hintableValues,
                Set(Value.allCases).subtracting([.five]),
                .valueHintNarrowsHintableValues
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
    static let hintableValuesForValuedCard = "A card hinted with a value has that value and no other hintable values"
    static let hintableValuesForNarrowedValueCard = "A card with narrowed outstanding values should only have those as hintable values"
    static let applyingValueHint = "A card hinted with a value should have that value"
    static let valueHintNarrowsHintableValues = "A value hint should narrow the hintable values for cards not part of the hint"
    
    enum WithoutRainbows {
        static let hintableSuitsForUnsuitedCard = "An unsuited card can be any suit"
        static let hintableSuitsForSingleSuitedCard = "A single suited card has one hintable suit"
        static let applyingSuitHint = "Applying a suit hint should eliminate other hintable suits"
    }
    
    enum WithRainbows {
        static let hintableSuitsForUnsuitedCard = "An unsuited card can be any suit"
        static let hintableSuitsForSingleSuitedCard = "A single suited card has four hintable suits"
        static let hintableSuitsForMultiSuitedCard = "A multi-suited card has no hintable suits"
        static let applyingSuitHint = "Applying a suit hint should set the suit for applicable cards and eliminate the suit for others"
    }
}
