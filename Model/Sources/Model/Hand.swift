import Foundation

@MainActor
public final class Hand: ObservableObject {
    
    public enum Size: Int {
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
    let configuration: Configuration
    let size: Size
    
    public init(
        configuration: Configuration,
        size: Size
    ) {
        self.configuration = configuration
        self.size = size
        
//        cards = Array(repeating: Card(), count: size.rawValue)
        cards = []
        (0 ..< self.size.rawValue).forEach { _ in
            cards.append(Card())
        }
    }
    
    public func getPossibleSuits(for card: Card) -> Set<Suit> {
        configuration.allowsRainbows
            ? getPossibleSuitsWithRainbows(for: card)
            : getPossibleSuitsWithoutRainbows(for: card)
    }
    
    public func getPossibleValues(for card: Card) -> Set<Value> {
        card.value == nil ? card.outstandingValues : []
    }
    
    public func applyHint(_ hint: Hint, to hintedCards: [Card]) async {
        let otherCards = Set(self.cards).subtracting(Set(hintedCards))
        
        switch hint {
        case let .value(value):
            hintedCards.forEach { $0.setValue(value) }
            otherCards.forEach { $0.removeOutstandingValue(value) }
            
        case let .suit(suit):
            hintedCards.forEach { $0.setSuits($0.suits.union([suit])) }
            otherCards.forEach { $0.removeOutstandingSuit(suit) }
        }
    }
    
    private func getPossibleSuitsWithoutRainbows(
        for card: Card
    ) -> Set<Suit> {
        card.suits.isEmpty
            ? Set(Suit.allCases).intersection(card.outstandingSuits)
            : []
    }
    
    private func getPossibleSuitsWithRainbows(
        for card: Card
    ) -> Set<Suit> {
        switch card.suits.count {
        case 0:
            return Set(Suit.allCases).intersection(card.outstandingSuits)
            
        case 1:
            return Set(Suit.allCases)
                .subtracting(card.suits)
                .intersection(card.outstandingSuits)
            
        default:
            return []
        }
    }
}
