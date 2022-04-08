import Foundation

public final class Hand: ObservableObject, Equatable, Codable {
    
    public enum Size: Int, CaseIterable, Codable {
        case four = 4
        case five = 5
    }
    
    @Published public var cards: [Card]
    @Published public var selectedCards = IndexSet()

    public private(set) var allowsRainbows: Bool
    private(set) var size: Size
    
    public init(
        allowsRainbows: Bool,
        size: Size,
        cards: [Card] = []
    ) {
        self.allowsRainbows = allowsRainbows
        self.size = size
        
        self.cards = cards
        if self.cards.isEmpty {
            (0 ..< self.size.rawValue).forEach { _ in
                self.cards.append(Card())
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        allowsRainbows = try container.decode(Bool.self, forKey: .allowsRainbows)
        size = try container.decode(Size.self, forKey: .size)
        cards = try container.decode([Card].self, forKey: .cards)
        selectedCards = try container.decode(IndexSet.self, forKey: .selectedCards)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(allowsRainbows, forKey: .allowsRainbows)
        try container.encode(size, forKey: .size)
        try container.encode(cards, forKey: .cards)
        try container.encode(selectedCards, forKey: .selectedCards)
    }
    
    public enum CodingKeys: CodingKey {
        case allowsRainbows
        case size
        case cards
        case selectedCards
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
        if card.hintedSuits.isEmpty, card.hintableSuits.count == 1 {
            return getHintableSuits(for: card).first
        }
        
        if card.hintedSuits.count == 1, card.hintableSuits.count == 0 {
            return card.hintedSuits.first
        }
        
        return allowsRainbows ? nil : card.hintedSuits.first
    }
    
    public func getHintableSuits(for card: Card) -> Set<Suit> {
        allowsRainbows
            ? getHintableSuitsWithRainbows(for: card)
            : getHintableSuitsWithoutRainbows(for: card)
    }
    
    public func applyHint(_ hint: Hint) {
        let unselectedCardIndices = cards.indices.filter { !selectedCards.contains($0) }
        
        switch hint {
        case let .suit(suit):
            if allowsRainbows {
                applySuitHintWithRainbows(suit: suit, hintedIndices: selectedCards)
            } else {
                applySuitHintWithoutRainbows(suit: suit, hintedIndices: selectedCards)
            }
            
            unselectedCardIndices.forEach {
                cards[$0] = cards[$0].removingHintableSuit(suit)
            }

        case let .value(value):
            selectedCards.forEach {
                cards[$0] = cards[$0].settingValue(value)
            }
            unselectedCardIndices.forEach {
                cards[$0] = cards[$0].removingHintableValue(value)
            }
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
    
    private func applySuitHintWithRainbows(suit: Suit, hintedIndices: IndexSet) {
        self.cards = self.cards
            .enumerated()
            .map {
                guard hintedIndices.contains($0.offset),
                      $0.element.hintedSuits.count < 2
                else { return $0.element }
            
                return $0.element.settingSuits($0.element.hintedSuits.union([suit]))
        }
    }
    
    private func applySuitHintWithoutRainbows(suit: Suit, hintedIndices: IndexSet) {
        self.cards = self.cards
            .enumerated()
            .map {
                guard hintedIndices.contains($0.offset),
                      $0.element.hintedSuits.count < 1
                else { return $0.element }
                
                return $0.element.settingSuits([suit])
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
    
    public static func createDeepCopy(of hand: Hand) -> Hand {
        let newCards = hand.cards.map {
            Card(
                hintedSuits: $0.hintedSuits,
                hintableSuits: $0.hintableSuits,
                value: $0.value,
                hintableValues: $0.hintableValues,
                uuid: $0.uuid
            )
        }
        let newHand = Hand(
            allowsRainbows: hand.allowsRainbows,
            size: hand.size
        )
        newHand.cards = newCards
        
        return newHand
    }
    
    public func restore(from hand: Hand) {
        allowsRainbows = hand.allowsRainbows
        size = hand.size
        cards = hand.cards
    }
    
    public static func ==(lhs: Hand, rhs: Hand) -> Bool {
        return lhs.allowsRainbows == rhs.allowsRainbows
        && lhs.size == rhs.size
        && lhs.cards.enumerated().allSatisfy { pair in
            let card = pair.element
            let otherCard = rhs.cards[pair.offset]

            return card.hintableSuits == otherCard.hintableSuits
            && card.hintableValues == otherCard.hintableValues
            && card.hintedSuits == otherCard.hintedSuits
            && card.value == otherCard.value
        }
    }
}
