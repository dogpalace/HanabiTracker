import Foundation
import SwiftUI

public class Card: ObservableObject, Equatable, Hashable {
    @Published public var hintedSuits = Set<Suit>()
    @Published public var hintableSuits = Set(Suit.allCases)
    @Published public var value: Value?
    @Published public var hintableValues = Set(Value.allCases)

    public let uuid: UUID
    
    // To make it easy to preview
    public init(
        hintedSuits: Set<Suit> = [],
        hintableSuits: Set<Suit> = Set(Suit.allCases),
        value: Value? = nil,
        hintableValues: Set<Value> = Set(Value.allCases)
    ) {
        self.hintedSuits = hintedSuits
        self.hintableSuits = hintableSuits
        self.value = value
        self.hintableValues = hintableValues
        self.uuid = UUID()
    }
    
    func setSuits(_ suits: Set<Suit>) {
        self.hintedSuits = suits
        
        hintableSuits = hintableSuits.subtracting(suits)
    }
    
    func removeHintableSuit(_ suit: Suit) {
        hintableSuits.remove(suit)
    }
    
    func setValue(_ value: Value) {
        self.value = value
        
        hintableValues = []
    }
    
    func removeHintableValue(_ value: Value) {
        hintableValues.remove(value)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hintedSuits.hashValue)
        hasher.combine(hintableSuits.hashValue)
        hasher.combine(value?.hashValue)
        hasher.combine(uuid)
    }
    
    public static func == (lhs: Card, rhs: Card) -> Bool {
        lhs === rhs
    }
}
