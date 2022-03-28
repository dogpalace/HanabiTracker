import Foundation
import SwiftUI

public class Card: ObservableObject, Equatable, Hashable {
    @Published var hintedSuits = Set<Suit>()
    @Published var hintableSuits = Set(Suit.allCases)
    @Published var value: Value?
    @Published var hintableValues = Set(Value.allCases)

    func setSuits(_ suits: Set<Suit>) {
        self.hintedSuits = suits
        
        hintableSuits = hintableSuits.subtracting(suits)
    }
    
    func removeHintableSuit(_ suit: Suit) {
        hintableSuits.remove(suit)
    }
    
    func setValue(_ value: Value) {
        self.value = value
        
        hintableValues.remove(value)
    }
    
    func removeHintableValue(_ value: Value) {
        hintableValues.remove(value)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hintedSuits.hashValue)
        hasher.combine(hintableSuits.hashValue)
        hasher.combine(value?.hashValue)
    }
    
    public static func == (lhs: Card, rhs: Card) -> Bool {
        lhs === rhs
    }
}
