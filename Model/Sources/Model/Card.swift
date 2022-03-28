import Foundation
import SwiftUI

public class Card: ObservableObject, Equatable, Hashable {
    @Published var suits = Set<Suit>()
    @Published var outstandingSuits = Set(Suit.allCases)
    @Published var value: Value?
    @Published var outstandingValues = Set(Value.allCases)

    func setSuits(_ suits: Set<Suit>) {
        self.suits = suits
        
        outstandingSuits = outstandingSuits.subtracting(suits)
    }
    
    func removeOutstandingSuit(_ suit: Suit) {
        outstandingSuits.remove(suit)
    }
    
    func setValue(_ value: Value) {
        self.value = value
        
        outstandingValues.remove(value)
    }
    
    func removeOutstandingValue(_ value: Value) {
        outstandingValues.remove(value)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(suits.hashValue)
        hasher.combine(outstandingSuits.hashValue)
        hasher.combine(value?.hashValue)
    }
    
    public static func == (lhs: Card, rhs: Card) -> Bool {
        lhs === rhs
    }
}
