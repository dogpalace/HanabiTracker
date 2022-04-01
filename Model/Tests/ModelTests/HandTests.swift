import XCTest
@testable import Model

class HandTests: XCTestCase {

    let allowsRainbows = false
    var hand: Hand!
    
    override func tearDown() {
        hand = nil
        
        super.tearDown()
    }

    func testHasConfiguration() {
        useHand(withRainbows: false)
        
        let configurationAllowsRainbows = hand.configuration.allowsRainbows
        XCTAssertEqual(
            configurationAllowsRainbows,
            allowsRainbows,
            .hasConfiguration
        )
    }
    
    func testHasSize() {
        useHand(withRainbows: false)
        let size = hand.size
        XCTAssertEqual(size, .four, .hasSize)
    }
    
    func testFourCards() {
        useHand(withRainbows: false)
        let count = hand.cards.count
        XCTAssertEqual(count, 4, .hasFourCards)
    }
    
    func testFiveCards() {
        hand = Hand(
            configuration: .init(allowsRainbows: false),
            size: .five
        )
        let count = hand.cards.count
        
        XCTAssertEqual(count, 5, .hasFiveCards)
    }
    
    // MARK: - Suits

    func testHintableSuitsWithoutRainbowsForUnsuitedCard() throws {
        useHand(withRainbows: false)
        let card = getFirstCard()
        let hintableSuits = hand.getHintableSuits(for: card)
        
        XCTAssertEqual(
            hintableSuits,
            Set(Suit.allCases),
            .WithoutRainbows.hintableSuitsForUnsuitedCard
        )
    }
    
    func testHintableSuitsWithoutRainbowsForSuitedCard() throws {
        useHand(withRainbows: false)
        let card = getFirstCard()
        card.setSuits([.green])
        let hintableSuits = hand.getHintableSuits(for: card)
                
        XCTAssertEqual(
            hintableSuits,
            [],
            .WithoutRainbows.hintableSuitsForSingleSuitedCard
        )
    }
    
    func testHintableSuitsWithRainbowsForUnsuitedCard() {
        useHand(withRainbows: true)
        let card = getFirstCard()
        let hintableSuits = hand.getHintableSuits(for: card)
        
        XCTAssertEqual(
            hintableSuits,
            Set(Suit.allCases),
            .WithRainbows.hintableSuitsForUnsuitedCard
        )
    }

    func testHintableSuitsWithRainbowsForSuitedCard() {
        useHand(withRainbows: true)
        let card = getFirstCard()
        card.setSuits([.green])
        let hintableSuits = hand.getHintableSuits(for: card)
        
        XCTAssertEqual(
            hintableSuits,
            [.yellow, .red, .white, .blue],
            .WithRainbows.hintableSuitsForSingleSuitedCard
        )
    }
    
    func testHintableSuitsWithRainbowsForMultiSuitedCard() {
        useHand(withRainbows: true)
        let card = getFirstCard()
        card.setSuits([.green, .blue])
        let hintableSuits = hand.getHintableSuits(for: card)
        
        XCTAssertTrue(
            hintableSuits.isEmpty,
            .WithRainbows.hintableSuitsForMultiSuitedCard
        )
    }
    
    func testApplyingSuitHintWithoutRainbows() {
        useHand(withRainbows: false)
        
        let startCards = Array(hand.cards[0 ... 1])
        
        hand.applyHint(.suit(.red), to: startCards)
        
        for card in startCards {
            let hintableSuits = hand.getHintableSuits(for: card)
            XCTAssertTrue(
                hintableSuits.isEmpty,
                .WithoutRainbows.applyingSuitHint
            )
        }

        let endCards = Array(hand.cards[2 ... 3])
        
        for card in endCards {
            let hintableSuits = hand.getHintableSuits(for: card)
            XCTAssertEqual(
                hintableSuits,
                Set(Suit.allCases).subtracting([.red]),
                .WithoutRainbows.applyingSuitHint
            )
        }
    }
    
    func testApplyingMultipleSuitHintsWithoutRainbows() {
        useHand(withRainbows: false)
        let card = hand.cards.first!

        hand.applyHint(.suit(.blue), to: [card])
        hand.applyHint(.suit(.green), to: [card])
        
        XCTAssertEqual(
            card.hintedSuits,
            [.blue],
             .WithoutRainbows.ignoresSubsequentSuitHints
        )
    }
    
    func testApplyingMultipleSuitHintsWithRainbows() {
        useHand(withRainbows: true)
        let card = hand.cards.first!

        hand.applyHint(.suit(.blue), to: [card])
        hand.applyHint(.suit(.green), to: [card])
        hand.applyHint(.suit(.yellow), to: [card])
        
        XCTAssertEqual(
            card.hintedSuits,
            [.blue, .green],
            .WithRainbows.ignoresSuitHintsAfterSecond
        )
    }
    
    func testApplyingSuitHintWithRainbows() {
        useHand(withRainbows: true)
        
        let firstCard = hand.cards.first!
        
        // Assume the last card is a rainbow with one suit hinted
        let lastCard = hand.cards.last!
        lastCard.setSuits([.green])
        
        hand.applyHint(.suit(.red), to: [firstCard])
        
        let startingCards = Array(hand.cards[0 ..< 3])
        
        for card in startingCards {
            let hintableSuits = hand.getHintableSuits(for: card)
            XCTAssertEqual(
                hintableSuits,
                Set(Suit.allCases).subtracting([.red]),
                .WithRainbows.applyingSuitHint
            )
        }
        
        let hintableSuits = hand.getHintableSuits(for: lastCard)
        XCTAssertEqual(
            hintableSuits,
            Set(Suit.allCases).subtracting([.red, .green]),
            .WithRainbows.applyingSuitHint
        )
    }
    
    func testSuitForUnsuitedCardWithoutRainbows() {
        useHand(withRainbows: false)
        let firstCard = hand.cards.first!
        let suits = hand.getSuits(for: firstCard)
        
        XCTAssertTrue(
            suits.isEmpty,
            .suitForUnsuitedCard
        )
    }
    
    func testSuitForSuitedCardWithoutRainbows() {
        useHand(withRainbows: false)
        let firstCard = hand.cards.first!
        hand.applyHint(.suit(.yellow), to: [firstCard])

        let suits = hand.getSuits(for: firstCard)
        
        XCTAssertEqual(
            suits,
            [.yellow],
            .WithoutRainbows.suitForSuitedCard
        )
    }
    
    func testSuitForInferredUnsuitedCardWithoutRainbows() {
        useHand(withRainbows: false)
        let firstCard = hand.cards.first!

        hand.applyHint(.suit(.red), to: [hand.cards[2]])
        hand.applyHint(.suit(.green), to: [hand.cards[2]])
        hand.applyHint(.suit(.yellow), to: [hand.cards[2]])
        hand.applyHint(.suit(.blue), to: [hand.cards[2]])
        
        let suits = hand.getSuits(for: firstCard)
        
        XCTAssertEqual(
            suits,
            [.white],
            .WithRainbows.inferredUnsuitedCard
        )
    }
    
    func testSuitForUnsuitedCardWithRainbows() {
        useHand(withRainbows: true)
        let firstCard = hand.cards.first!
        let suits = hand.getSuits(for: firstCard)
        
        XCTAssertTrue(
            suits.isEmpty,
            .suitForUnsuitedCard
        )
    }
    
    func testSuitForSuitedCardWithRainbows() {
        useHand(withRainbows: true)
        let firstCard = hand.cards.first!
        hand.applyHint(.suit(.yellow), to: [firstCard])

        let suits = hand.getSuits(for: firstCard)

        XCTAssertEqual(
            suits,
            [.yellow],
            .WithRainbows.suitForSuitedCard
        )
    }
    
    func testSuitForMultiSuitedCardWithRainbows() {
        useHand(withRainbows: true)
        let firstCard = hand.cards.first!
        hand.applyHint(.suit(.yellow), to: [firstCard])
        hand.applyHint(.suit(.green), to: [firstCard])
        
        let suits = hand.getSuits(for: firstCard)

        XCTAssertEqual(
            suits,
            [.yellow, .green],
            .WithRainbows.suitForMultiSuitedCard
        )
    }
    
    func testSuitForInferredUnsuitedCardWithRainbows() {
        useHand(withRainbows: true)
        let firstCard = hand.cards.first!

        hand.applyHint(.suit(.red), to: [hand.cards[2]])
        hand.applyHint(.suit(.green), to: [hand.cards[2]])
        hand.applyHint(.suit(.yellow), to: [hand.cards[2]])
        hand.applyHint(.suit(.blue), to: [hand.cards[2]])
        
        let suits = hand.getSuits(for: firstCard)
        
        XCTAssertEqual(
            suits,
            [.white],
            .WithRainbows.suitForInferredUnsuitedCard
        )
    }
    
    func testSuitForInferredSuitedCardWithRainbows() {
        useHand(withRainbows: true)
        let firstCard = hand.cards.first!

        hand.applyHint(.suit(.red), to: [firstCard])
        hand.applyHint(.suit(.green), to: [hand.cards[2]])
        hand.applyHint(.suit(.yellow), to: [hand.cards[2]])
        hand.applyHint(.suit(.blue), to: [hand.cards[2]])
        
        let suits = hand.getSuits(for: firstCard)
        
        XCTAssertEqual(
            suits,
            [.red],
            .WithRainbows.inferredSuitedCard
        )
    }
    
    // MARK: - Values

    func testHintableValuesForValuedCard() {
        useHand(withRainbows: true)
        let firstCard = hand.cards.first!
        
        firstCard.setValue(.four)
        let hintableValues = hand.getHintableValues(for: firstCard)
        
        XCTAssertTrue(
            hintableValues.isEmpty,
            .hintableValuesForValuedCard
        )
    }
    
    func testHintableValuesForCardWithNarrowedValues() {
        useHand(withRainbows: true)
        let firstCard = hand.cards.first!
        firstCard.removeHintableValue(.one)
        firstCard.removeHintableValue(.three)

        let hintableValues = hand.getHintableValues(for: firstCard)

        XCTAssertEqual(
            hintableValues,
            Set(Value.allCases).subtracting([.three, .one]),
            .hintableValuesForNarrowedValueCard
        )
    }
    
    func testApplyingValueHint() {
        useHand(withRainbows: false)
        let firstCard = hand.cards.first!
        let remainingCards = Array(hand.cards[1 ... 3])

        hand.applyHint(.value(.five), to: [firstCard])

        XCTAssertEqual(
            firstCard.value,
            .five,
            .applyingValueHint
        )

        let hintableValues = hand.getHintableValues(for: firstCard)
        XCTAssertTrue(
            hintableValues.isEmpty,
            .hintableValuesForValuedCard
        )

        for card in remainingCards {
            let hintableValues = hand.getHintableValues(for: card)
            XCTAssertEqual(
                hintableValues,
                Set(Value.allCases).subtracting([.five]),
                .valueHintNarrowsHintableValues
            )
        }
    }
    
    // MARK: - Card Dismissal
    
    func testDismissingInvalidCard() {
        useHand(withRainbows: false)
        
        let initialCards = hand.cards

        let card = Card()
        hand.dismiss(card)
        
        XCTAssertEqual(
            hand.cards,
            initialCards,
            .dismissingInvalidCard
        )
    }
    
    func testDismissingNewestCard() {
        useHand(withRainbows: false)

        let newestCard = hand.cards.last!
        let olderCards = Array(hand.cards[0 ... 2])
        
        hand.dismiss(newestCard)
        
        XCTAssertNotEqual(
            hand.cards.last,
            newestCard,
            .removesDismissedCards
        )
        XCTAssertEqual(
            hand.cards.count,
            4,
            .replacesDismissedCards
        )
        let indicesForOlderCards = [0 ... 2]
        indicesForOlderCards.forEach { index in
            XCTAssertEqual(
                hand.cards[index],
                olderCards[index],
                .olderCardsDoNotChangePosition
            )
        }
    }
    
    func testDismissingOldestCard() {
        useHand(withRainbows: false)

        let oldestCard = hand.cards.first!
        let remainingCards = Array(hand.cards[1 ... 3])
        
        hand.dismiss(oldestCard)

        XCTAssertNotEqual(
            hand.cards.first,
            oldestCard,
            .removesDismissedCards
        )
        XCTAssertEqual(
            hand.cards.count,
            4,
            .replacesDismissedCards
        )
        let indicesForOlderCards = [0 ... 2]
        indicesForOlderCards.forEach { index in
            XCTAssertEqual(
                hand.cards[index],
                remainingCards[index],
                .newerCardsChangePosition
            )
        }
    }
    
    // MARK: - Rainbow determination
    
    func testIsRainbowWithUnsuitedCardWithoutRainbows() {
        useHand(withRainbows: false)

        XCTAssertFalse(
            hand.isDefinitelyRainbow(hand.cards.first!),
            .WithoutRainbows.cannotBeRainbowCard
        )
    }
    
    func testIsRainbowWithSuitedCardWithoutRainbows() {
        useHand(withRainbows: false)
        hand.applyHint(.suit(.red), to: [hand.cards.first!])
        
        XCTAssertFalse(
            hand.isDefinitelyRainbow(hand.cards.first!),
            .WithoutRainbows.cannotBeRainbowCard
        )
    }

    func testIsRainbowWithUnsuitedCardWithRainbows() {
        useHand(withRainbows: true)

        XCTAssertFalse(
            hand.isDefinitelyRainbow(hand.cards.first!),
            .WithRainbows.cannotBeRainbowCard
        )
    }

    func testIsRainbowForSuitedCardWithRainbows() {
        useHand(withRainbows: true)
        hand.applyHint(.suit(.red), to: [hand.cards.first!])

        XCTAssertFalse(
            hand.isDefinitelyRainbow(hand.cards.first!),
            .WithRainbows.cannotBeRainbowCard
        )
    }
    
    func testIsRainbowForMultiSuitedCardWithRainbows() {
        useHand(withRainbows: true)
        
        hand.applyHint(.suit(.red), to: [hand.cards.first!])
        hand.applyHint(.suit(.blue), to: [hand.cards.first!])

        XCTAssertTrue(
            hand.isDefinitelyRainbow(hand.cards.first!),
            .WithRainbows.isRainbowCard
        )
    }
    
    // MARK: - Helpers
    
    private func getFirstCard() -> Card {
        hand.cards.first!
    }

    private func useHand(withRainbows: Bool) {
        hand = Hand(
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
    static let suitForUnsuitedCard = "A card with no information should not have a suit"
    static let removesDismissedCards = "Dismissed cards are removed from the hand"
    static let replacesDismissedCards = "Dismissed cards are replaced"
    static let olderCardsDoNotChangePosition = "Older cards do not change positions when a newer card is dismissed"
    static let newerCardsChangePosition = "Newer cards change positions when a older card is dismissed"
    static let dismissingInvalidCard = "Dismissing a card that is not in the hand should not impact cards in the hand"
    
    enum WithoutRainbows {
        static let hintableSuitsForUnsuitedCard = "An unsuited card can be any suit"
        static let hintableSuitsForSingleSuitedCard = "A single suited card has one hintable suit"
        static let applyingSuitHint = "Applying a suit hint should eliminate other hintable suits"
        static let ignoresSubsequentSuitHints = "Ignores subsequent suit hints"
        static let suitForSuitedCard = "Without rainbows, a card told about a suit is that suit"
        static let cannotBeRainbowCard = "A card cannot be a rainbow card when rainbows are not allowed"
    }
    
    enum WithRainbows {
        static let hintableSuitsForUnsuitedCard = "An unsuited card can be any suit"
        static let hintableSuitsForSingleSuitedCard = "A single suited card has four hintable suits"
        static let hintableSuitsForMultiSuitedCard = "A multi-suited card has no hintable suits"
        static let applyingSuitHint = "Applying a suit hint should set the suit for applicable cards and eliminate the suit for others"
        static let ignoresSuitHintsAfterSecond = "Only applies the first two suit hints"
        static let inferredUnsuitedCard = "A card can know its suit if all other suits are eliminated"
        static let inferredSuitedCard = "With rainbows, a card cannot make inferences about the remaining unhinted suit"
        static let suitForSuitedCard = "With rainbows, a card may not be only that suit"
        static let suitForInferredUnsuitedCard = "A card can know its suit if all other suits are eliminated"
        static let suitForMultiSuitedCard = "With rainbows, a card may be multiple suits"
        static let cannotBeRainbowCard = "A card with fewer than two hinted suits cannot be definitively rainbow"
        static let isRainbowCard = "A card with two hinted suits is definitely rainbow"
    }
}
