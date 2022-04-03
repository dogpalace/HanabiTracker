import Foundation

public enum Value: Int, CaseIterable, Comparable {    
    case one = 1
    case two
    case three
    case four
    case five

    public static func < (lhs: Value, rhs: Value) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
