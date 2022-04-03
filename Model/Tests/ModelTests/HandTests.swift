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
        
        let configurationAllowsRainbows = hand.allowsRainbows
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
            allowsRainbows: false,
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
            .suitForUnsuitedCard
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
            .suitForUnsuitedCard
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
        hand.selectedCards = [0, 1]
        hand.applyHint(.suit(.red))
        
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
        let card = getFirstCard()

        selectFirstCard()
        hand.applyHint(.suit(.blue))
        hand.applyHint(.suit(.green))

        XCTAssertEqual(
            card.hintedSuits,
            [.blue],
             .WithoutRainbows.ignoresSubsequentSuitHints
        )
    }

    func testApplyingMultipleSuitHintsWithRainbows() {
        useHand(withRainbows: true)
        let card = getFirstCard()

        selectFirstCard()
        hand.applyHint(.suit(.blue))
        hand.applyHint(.suit(.green))
        hand.applyHint(.suit(.yellow))

        XCTAssertEqual(
            card.hintedSuits,
            [.blue, .green],
            .WithRainbows.ignoresSuitHintsAfterSecond
        )
    }

    func testApplyingSuitHintWithRainbows() {
        useHand(withRainbows: true)

        // Assume the last card is a rainbow with one suit hinted
        let lastCard = hand.cards.last!
        lastCard.setSuits([.green])

        selectFirstCard()
        hand.applyHint(.suit(.red))

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
        let firstCard = getFirstCard()
        let suit = hand.getSuit(for: firstCard)

        XCTAssertNil(
            suit,
            .suitForUnsuitedCard
        )
    }

    func testSuitForSuitedCardWithoutRainbows() {
        useHand(withRainbows: false)
        let firstCard = getFirstCard()
        selectFirstCard()
        hand.applyHint(.suit(.yellow))

        let suit = hand.getSuit(for: firstCard)

        XCTAssertEqual(
            suit,
            .yellow,
            .WithoutRainbows.suitForSuitedCard
        )
    }

    func testSuitForInferredUnsuitedCardWithoutRainbows() {
        useHand(withRainbows: false)
        let firstCard = getFirstCard()

        selectThirdCard()
        hand.applyHint(.suit(.red))
        hand.applyHint(.suit(.green))
        hand.applyHint(.suit(.yellow))
        hand.applyHint(.suit(.blue))

        let suit = hand.getSuit(for: firstCard)

        XCTAssertEqual(
            suit,
            .white,
            .suitForInferredUnsuitedCard
        )
    }

    func testSuitForUnsuitedCardWithRainbows() {
        useHand(withRainbows: true)
        let firstCard = getFirstCard()
        let suit = hand.getSuit(for: firstCard)

        XCTAssertNil(
            suit,
            .suitForUnsuitedCard
        )
    }

    func testSuitForUnsuitedCardWithOneHintableSuitWithRainbows() {
        useHand(withRainbows: true)
        let firstCard = getFirstCard()

        firstCard.removeHintableSuit(.red)
        firstCard.removeHintableSuit(.green)
        firstCard.removeHintableSuit(.yellow)
        firstCard.removeHintableSuit(.blue)

        let suit = hand.getSuit(for: firstCard)

        XCTAssertEqual(
            suit,
            .white,
            .suitForInferredUnsuitedCard
        )
    }

    func testSuitForSuitedCardWithOneHintableSuitWithRainbows() {
        useHand(withRainbows: true)
        let firstCard = getFirstCard()

        firstCard.hintedSuits = [.green]

        firstCard.removeHintableSuit(.red)
        firstCard.removeHintableSuit(.yellow)
        firstCard.removeHintableSuit(.blue)

        let suit = hand.getSuit(for: firstCard)

        XCTAssertNil(
            suit,
            .WithRainbows.suitForInferredSuitedCard
        )
    }

    func testSuitForSuitedCardWithRainbows() {
        useHand(withRainbows: true)
        let firstCard = getFirstCard()
        
        selectFirstCard()
        hand.applyHint(.suit(.yellow))

        let suit = hand.getSuit(for: firstCard)

        XCTAssertNil(
            suit,
            .WithRainbows.suitForSuitedCard
        )
    }

    func testSuitForMultiSuitedCardWithRainbows() {
        useHand(withRainbows: true)
        let firstCard = getFirstCard()
        
        selectFirstCard()
        hand.applyHint(.suit(.yellow))
        hand.applyHint(.suit(.green))

        let suit = hand.getSuit(for: firstCard)

        XCTAssertNil(
            suit,
            .WithRainbows.suitForMultiSuitedCard
        )
    }

    func testSuitForInferredUnsuitedCardWithRainbows() {
        useHand(withRainbows: true)
        let firstCard = getFirstCard()

        selectThirdCard()
        hand.applyHint(.suit(.red))
        hand.applyHint(.suit(.green))
        hand.applyHint(.suit(.yellow))
        hand.applyHint(.suit(.blue))

        let suit = hand.getSuit(for: firstCard)

        XCTAssertEqual(
            suit,
            .white,
            .suitForInferredUnsuitedCard
        )
    }

    func testSuitForInferredSuitedCardWithRainbows() {
        useHand(withRainbows: true)
        let firstCard = getFirstCard()

        selectFirstCard()
        hand.applyHint(.suit(.red))
        
        selectThirdCard()
        hand.applyHint(.suit(.green))
        hand.applyHint(.suit(.yellow))
        hand.applyHint(.suit(.blue))

        let suit = hand.getSuit(for: firstCard)

        XCTAssertNil(
            suit,
            .WithRainbows.inferredSuitedCard
        )
    }

    // MARK: - Values

    func testHintableValuesWithValuedCard() {
        useHand(withRainbows: true)

        selectFirstCard()
        hand.applyHint(.value(.four))

        let hintableValues = hand.hintableValues

        XCTAssertTrue(
            hintableValues.isEmpty,
            .hintableValuesWithValuedCard
        )
    }

    func testHintableValuesWithNarrowedValues() {
        useHand(withRainbows: true)
        let firstCard = getFirstCard()
        firstCard.removeHintableValue(.one)
        firstCard.removeHintableValue(.three)

        selectFirstCard()
        let hintableValues = hand.hintableValues

        XCTAssertEqual(
            Set(hintableValues),
            Set(Value.allCases).subtracting([.three, .one]),
            .hintableValuesWithNarrowedValueCard
        )
    }

    func testApplyingValueHint() {
        useHand(withRainbows: false)
        let firstCard = getFirstCard()
        let remainingCards = Array(hand.cards[1 ... 3])

        selectFirstCard()
        hand.applyHint(.value(.five))

        XCTAssertEqual(
            firstCard.value,
            .five,
            .applyingValueHint
        )

        let hintableValues = hand.hintableValues
        XCTAssertTrue(
            hintableValues.isEmpty,
            .hintableValuesWithValuedCard
        )

        for card in remainingCards {
            let hintableValues = card.hintableValues
            XCTAssertEqual(
                hintableValues,
                Set(Value.allCases).subtracting([.five]),
                .valueHintNarrowsHintableValues
            )
        }
    }

    // MARK: - Card Dismissal

    func testDismissingWithNoSelectedCards() {
        useHand(withRainbows: false)
        let initialCards = hand.cards

        hand.dismissSelected()

        XCTAssertEqual(
            hand.cards,
            initialCards,
            .dismissingWithNoneSelected
        )
    }
    
    func testDismissingWithTooManySelected() {
        useHand(withRainbows: false)
        let initialCards = hand.cards
        hand.selectedCards = [0, 1]

        hand.dismissSelected()

        XCTAssertEqual(
            hand.cards,
            initialCards,
            .dismissingWithTooManySelected
        )
    }

    func testDismissingNewestCard() {
        useHand(withRainbows: false)

        let newestCard = hand.cards.last!
        let olderCards = Array(hand.cards[0 ... 2])

        hand.selectedCards = [hand.cards.lastIndex(of: newestCard)!]
        hand.dismissSelected()

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

        let oldestCard = getFirstCard()
        let remainingCards = Array(hand.cards[1 ... 3])

        selectFirstCard()
        hand.dismissSelected()

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
            hand.isDefinitelyRainbow(getFirstCard()),
            .WithoutRainbows.cannotBeRainbowCard
        )
    }

    func testIsRainbowWithSuitedCardWithoutRainbows() {
        useHand(withRainbows: false)
        
        selectFirstCard()
        hand.applyHint(.suit(.red))

        XCTAssertFalse(
            hand.isDefinitelyRainbow(getFirstCard()),
            .WithoutRainbows.cannotBeRainbowCard
        )
    }

    func testIsRainbowWithUnsuitedCardWithRainbows() {
        useHand(withRainbows: true)

        XCTAssertFalse(
            hand.isDefinitelyRainbow(getFirstCard()),
            .WithRainbows.cannotBeRainbowCard
        )
    }

    func testIsRainbowForSuitedCardWithRainbows() {
        useHand(withRainbows: true)
        
        selectFirstCard()
        hand.applyHint(.suit(.red))

        XCTAssertFalse(
            hand.isDefinitelyRainbow(getFirstCard()),
            .WithRainbows.cannotBeRainbowCard
        )
    }

    func testIsRainbowForMultiSuitedCardWithRainbows() {
        useHand(withRainbows: true)

        selectFirstCard()
        hand.applyHint(.suit(.red))
        hand.applyHint(.suit(.blue))

        XCTAssertTrue(
            hand.isDefinitelyRainbow(getFirstCard()),
            .WithRainbows.isRainbowCard
        )
    }
    
    // MARK: - Selection
    
    func testSelection() {
        useHand(withRainbows: false)
        let card = getFirstCard()
        
        hand.toggleSelection(of: card)
        
        XCTAssertTrue(hand.isCardSelected(card), .selectedCardIsSelected)
        
        hand.toggleSelection(of: card)
        
        XCTAssertFalse(hand.isCardSelected(card), .unselectedCardIsNotSelected)
    }
    
    // MARK: - Resetting
    
    func testResettingClearsSelectedCards() {
        useHand(withRainbows: true)
        
        selectFirstCard()
        
        hand.reset(allowsRainbows: true, size: .four)
        
        XCTAssertTrue(
            hand.selectedCards.isEmpty,
            .resettingClearsSelectedCards
        )
    }
    
    func testResettingRecreatesCards() {
        useHand(withRainbows: true)
        let originalCards = hand.cards
        
        hand.reset(allowsRainbows: true, size: .four)
        
        XCTAssertNotEqual(originalCards, hand.cards, .resettingRecreatesCards)
    }
    
    func testRecreatingUpdatesHand() {
        useHand(withRainbows: true)
        
        hand.reset(allowsRainbows: false, size: .five)
        
        XCTAssertFalse(hand.allowsRainbows, .resettingUpdatesHandProperties)
        XCTAssertEqual(hand.size, .five, .resettingUpdatesHandProperties)
    }
    
    // MARK: - Helpers
    
    private func selectFirstCard() {
        hand.selectedCards = [0]
    }
    
    private func selectThirdCard() {
        hand.selectedCards = [2]
    }
    
    private func getFirstCard() -> Card {
        hand.cards.first!
    }

    private func useHand(withRainbows: Bool) {
        hand = Hand(
            allowsRainbows: withRainbows,
            size: .four
        )
    }
}

fileprivate extension String {
    static let hasConfiguration = "A hand has a configuration"
    static let hasSize = "A hand has a size"
    static let hasFourCards = "A hand can have four cards"
    static let hasFiveCards = "A hand can have five cards"
    static let hintableValuesWithValuedCard = "There are no hintable values when there is one selected card with a hinted value"
    static let hintableValuesWithNarrowedValueCard = "Hintable values should depend on the hintable values of the selected cards"
    static let applyingValueHint = "A card hinted with a value should have that value"
    static let valueHintNarrowsHintableValues = "A value hint should narrow the hintable values for cards not part of the hint"
    static let suitForUnsuitedCard = "A card with no information should not have a suit"
    static let removesDismissedCards = "Dismissed cards are removed from the hand"
    static let replacesDismissedCards = "Dismissed cards are replaced"
    static let olderCardsDoNotChangePosition = "Older cards do not change positions when a newer card is dismissed"
    static let newerCardsChangePosition = "Newer cards change positions when a older card is dismissed"
    static let dismissingWithNoneSelected = "Dismissing with no selected cards should not impact cards in the hand"
    static let dismissingWithTooManySelected = "Can only dismiss when a single card is selected"
    static let suitForInferredUnsuitedCard = "A card can know its suit if all other suits are eliminated"
    static let selectedCardIsSelected = "A hand can select a card and knows the card is selected"
    static let unselectedCardIsNotSelected = "A hand can deselect a card and knows the card is unselected"
    static let resettingClearsSelectedCards = "Resetting should clear selected cards"
    static let resettingRecreatesCards = "Resetting should recreate the cards in the hand"
    static let resettingUpdatesHandProperties = "Resetting updates the properties of the hand"
    
    enum WithoutRainbows {
        static let hintableSuitsForSingleSuitedCard = "A single suited card has one hintable suit"
        static let applyingSuitHint = "Applying a suit hint should eliminate other hintable suits"
        static let ignoresSubsequentSuitHints = "Ignores subsequent suit hints"
        static let suitForSuitedCard = "Without rainbows, a card told about a suit is that suit"
        static let cannotBeRainbowCard = "A card cannot be a rainbow card when rainbows are not allowed"
    }
    
    enum WithRainbows {
        static let hintableSuitsForSingleSuitedCard = "A single suited card has four hintable suits"
        static let hintableSuitsForMultiSuitedCard = "A multi-suited card has no hintable suits"
        static let applyingSuitHint = "Applying a suit hint should set the suit for applicable cards and eliminate the suit for others"
        static let ignoresSuitHintsAfterSecond = "Only applies the first two suit hints"
        static let inferredUnsuitedCard = "A card can know its suit if all other suits are eliminated"
        static let inferredSuitedCard = "With rainbows, a card cannot make inferences about the remaining unhinted suit"
        static let suitForSuitedCard = "With rainbows, a card with a single hinted suit may have additional other suits"
        static let suitForInferredSuitedCard = "A card with one hinted suit and one hintable suit cannot be definitively one of those suits"
        static let suitForMultiSuitedCard = "With rainbows, a card may be multiple suits"
        static let cannotBeRainbowCard = "A card with fewer than two hinted suits cannot be definitively rainbow"
        static let isRainbowCard = "A card with two hinted suits is definitely rainbow"
    }
}
