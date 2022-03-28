import Foundation

public enum Hint: Hashable {
    case suit(Suit)
    case value(Value)
    
    var isSuitHint: Bool {
        switch self {
        case .suit: return true
        case .value: return false
        }
    }
    
    var isValueHint: Bool {
        switch self {
        case .suit: return false
        case .value: return true
        }
    }
    
    func getSuit() -> Suit? {
        switch self {
        case let .suit(suit): return suit
        default: return nil
        }
    }
    
    func getValue() -> Value? {
        switch self {
        case let .value(value): return value
        default: return nil
        }
    }

}
