import SwiftUI

public struct Options: Equatable {
    public var handSize = Hand.Size.four
    public var allowsBlacks = false
    public var allowsRainbows = false
    public var showsConventions: Bool {
        get {
            if UserDefaults.standard.object(forKey: "showsConventions") == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: "showsConventions")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "showsConventions")
        }
    }
    
    public init() {}
}
