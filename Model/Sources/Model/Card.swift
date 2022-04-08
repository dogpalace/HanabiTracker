import Foundation
import SwiftUI

public struct Card: Equatable, Hashable, Codable {
    public var hintedSuits = Set<Suit>()
    public var hintableSuits = Set(Suit.allCases)
    public var value: Value?
    public var hintableValues = Set(Value.allCases)

    public let uuid: UUID
    
    // To make it easy to preview
    public init(
        hintedSuits: Set<Suit> = [],
        hintableSuits: Set<Suit> = Set(Suit.allCases),
        value: Value? = nil,
        hintableValues: Set<Value> = Set(Value.allCases),
        uuid: UUID = UUID()
    ) {
        self.hintedSuits = hintedSuits
        self.hintableSuits = hintableSuits
        self.value = value
        self.hintableValues = hintableValues
        self.uuid = uuid
    }
    
    func settingSuits(_ suits: Set<Suit>) -> Card {
        let hintableSuits = hintedSuits.count > 0
        ? []
        : self.hintableSuits.subtracting(suits)
        
        return Card(
            hintedSuits: suits,
            hintableSuits: hintableSuits,
            value: value,
            hintableValues: hintableValues,
            uuid: uuid
        )
    }
    
    func removingHintableSuit(_ suit: Suit) -> Card {
        var updatedHintableSuits = hintableSuits
        updatedHintableSuits.remove(suit)
        
        return Card(
            hintedSuits: hintedSuits,
            hintableSuits: updatedHintableSuits,
            value: value,
            hintableValues: hintableValues,
            uuid: uuid
        )
    }
    
    func settingValue(_ value: Value) -> Card {
        Card(
            hintedSuits: hintedSuits,
            hintableSuits: hintableSuits,
            value: value,
            hintableValues: [],
            uuid: uuid
        )
    }
    
    func removingHintableValue(_ value: Value) -> Card {
        var updatedHintableValues = hintableValues
        updatedHintableValues.remove(value)
        
        return Card(
            hintedSuits: hintedSuits,
            hintableSuits: hintableSuits,
            value: self.value,
            hintableValues: updatedHintableValues
        )
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hintedSuits.hashValue)
        hasher.combine(hintableSuits.hashValue)
        hasher.combine(value?.hashValue)
        hasher.combine(uuid)
    }
    
    public static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.hintedSuits == rhs.hintedSuits
        && lhs.hintableSuits == rhs.hintableSuits
        && lhs.value == rhs.value
        && lhs.hintableValues == rhs.hintableValues
        && lhs.uuid == rhs.uuid
    }
}
