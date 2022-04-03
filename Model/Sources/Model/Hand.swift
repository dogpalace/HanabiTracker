import Foundation

public final class Hand: ObservableObject {
    
    public enum Size: Int, CaseIterable {
        case four = 4
        case five = 5
    }
    
    public struct Configuration {
        public var allowsRainbows: Bool
        
        public init(allowsRainbows: Bool) {
            self.allowsRainbows = allowsRainbows
        }
    }

    @Published public var cards: [Card]
    @Published public var selectedCards = IndexSet()
    
    public private(set) var allowsRainbows: Bool
    private(set) var size: Size
    
    public init(
        allowsRainbows: Bool,
        size: Size
    ) {
        self.allowsRainbows = allowsRainbows
        self.size = size
        
        cards = []
        (0 ..< self.size.rawValue).forEach { _ in
            cards.append(Card())
        }
    }
    
    public func toggleSelection(of card: Card) {
        guard let index = cards.firstIndex(of: card) else { return }
            
        if selectedCards.contains(index) {
            selectedCards.remove(index)
        } else {
            selectedCards.insert(index)
        }
    }
    
    public func dismissSelected() {
        guard selectedCards.count == 1,
              let index = selectedCards.first
        else { return }
        
        dismiss(cards[index])
    }
    
    public func isCardSelected(_ card: Card) -> Bool {
        guard let index = cards.firstIndex(of: card) else { return false }

        return selectedCards.contains(index)
    }
    
    public var hintableValues: [Value] {
        selectedCards
            .map { cards[$0] }
            .reduce(Set(Value.allCases)) { partialResult, card in
                partialResult.intersection(card.hintableValues)
            }
            .sorted()
    }
    
    public var hintableSuits: [Suit] {
        selectedCards
            .map { cards[$0] }
            .reduce(Set(Suit.allCases)) { partialResult, card in
                partialResult.intersection(getHintableSuits(for: card))
            }
            .sorted()
    }
    
    public func reset(allowsRainbows: Bool, size: Size) {
        self.allowsRainbows = allowsRainbows
        self.size = size
        self.selectedCards = []
        
        cards = []
        (0 ..< self.size.rawValue).forEach { _ in
            cards.append(Card())
        }
    }
    
    public func getSuit(for card: Card) -> Suit? {
        if card.hintedSuits.isEmpty,
           card.hintableSuits.count == 1 {
            return getHintableSuits(for: card).first
        }
        
        return allowsRainbows ? nil : card.hintedSuits.first
    }
    
    public func getHintableSuits(for card: Card) -> Set<Suit> {
        allowsRainbows
            ? getHintableSuitsWithRainbows(for: card)
            : getHintableSuitsWithoutRainbows(for: card)
    }
    
    public func applyHint(_ hint: Hint) {
        let hintedCards = selectedCards.map { cards[$0] }
        
        let otherCards = Set(cards).subtracting(Set(hintedCards))
        
        switch hint {
        case let .suit(suit):
            if allowsRainbows {
                applySuitHintWithRainbows(suit: suit, cards: hintedCards)
            } else {
                applySuitHintWithoutRainbows(suit: suit, cards: hintedCards)
            }
            otherCards.forEach { $0.removeHintableSuit(suit) }

        case let .value(value):
            hintedCards.forEach { $0.setValue(value) }
            otherCards.forEach { $0.removeHintableValue(value) }
        }
    }
    
    private func dismiss(_ card: Card) {
        guard let cardPosition = cards.firstIndex(of: card) else { return }
        
        cards.remove(at: cardPosition)
        cards.append(Card())
    }
    
    public func isDefinitelyRainbow(_ card: Card) -> Bool {
        guard allowsRainbows else { return false }
        
        return card.hintedSuits.count == 2
    }
    
    private func applySuitHintWithRainbows(suit: Suit, cards: [Card]) {
        cards.forEach { card in
            guard card.hintedSuits.count < 2 else { return }
            
            card.setSuits(card.hintedSuits.union([suit]))
        }
    }
    
    private func applySuitHintWithoutRainbows(suit: Suit, cards: [Card]) {
        cards.forEach { card in
            guard card.hintedSuits.count < 1 else { return }
            
            card.setSuits([suit])
        }
    }
    
    private func getHintableSuitsWithoutRainbows(
        for card: Card
    ) -> Set<Suit> {
        card.hintedSuits.isEmpty
            ? Set(Suit.allCases).intersection(card.hintableSuits)
        : []
    }
    
    private func getHintableSuitsWithRainbows(
        for card: Card
    ) -> Set<Suit> {
        switch card.hintedSuits.count {
        case 0:
            return Set(Suit.allCases).intersection(card.hintableSuits)
            
        case 1:
            return Set(Suit.allCases)
                .subtracting(card.hintedSuits)
                .intersection(card.hintableSuits)
            
        default:
            return []
        }
    }
}
