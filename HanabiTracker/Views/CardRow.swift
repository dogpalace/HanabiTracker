import SwiftUI
import Model

struct CardRow: View {
    @ObservedObject var hand: Hand
    
    var body: some View {
        HStack(alignment: .top) {
            ForEach(hand.cards, id: \.uuid) { card in
                Card(
                    card: card,
                    inferredSuit: hand.getSuit(for: card),
                    hintableSuits: Array(hand.getHintableSuits(for: card)),
                    isBlack: hand.isDefinitelyBlack(card),
                    isRainbow: hand.isDefinitelyRainbow(card),
                    isSelected: hand.isCardSelected(card)
                )
                    .onTapGesture {
                        hand.toggleSelection(of: card)
                    }
            }
        }
    }
}

struct CardRow_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
.previewInterfaceOrientation(.landscapeLeft)
    }
    
    struct Preview: View {
        @StateObject var hand = Hand(
            allowsRainbows: false,
            allowsBlacks: false,
            size: .five
        )

        var body: some View {
            CardRow(hand: hand)
        }
    }

}
