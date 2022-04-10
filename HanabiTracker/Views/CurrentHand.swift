import SwiftUI
import Model

struct CurrentHand: View {
    @EnvironmentObject var hand: Hand
    @Environment(\.options) private var options: Binding<Options>
    
    var body: some View {
        CardRow(hand: hand).padding()
    }
}

struct Hand_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
            .previewInterfaceOrientation(.landscapeLeft)
    }
    
    struct Preview: View {
        @StateObject var hand = Hand(
            allowsRainbows: true,
            allowsBlacks: false,
            size: .four
        )
        
        var body: some View {
            CurrentHand()
                .environmentObject(hand)
        }
    }
}
