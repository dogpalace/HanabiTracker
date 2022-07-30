import SwiftUI
import Model

struct CurrentHand: View {
    @EnvironmentObject var hand: Hand
    @Environment(\.options) private var options: Binding<Options>
    @AppStorage("showsConventions") private var showsConventions = true
    
    var body: some View {
        VStack {
            CardRow(hand: hand)
            playOrderConvention
        }
        .padding()
    }
    
    var playOrderConvention: some View {
        Group {
            if showsConventions {
                Spacer()
                HStack {
                    Text("Old")
                    Spacer()
                    Text("New")
                }
                .font(.title2)
            }
        }
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
