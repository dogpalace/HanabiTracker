import SwiftUI
import Model

enum ColorSuitMap {
    static func backgroundColor(for suit: Suit) -> Color {
        switch suit {
        case .red: return Color(.red)
        case .yellow: return Color.yellow
        case .green: return Color.green
        case .blue: return Color.blue
        case .white: return Color.white
        }
    }
    
//    static func foregroundColor(for suit: Suit) -> Color {
//        switch suit {
//        case .red: return Color(.red)
//        case .yellow: return Color.yellow
//        case .green: return Color.green
//        case .blue: return Color.blue
//        case .white: return Color.white
//        }
//    }
}
