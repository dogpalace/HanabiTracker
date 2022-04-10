import SwiftUI
import Model

struct GameView: View {
    @EnvironmentObject var hand: Hand
    @EnvironmentObject var gameRecord: GameRecord
    @State private var isShowingOptions = false
    @State private var isPresentingHintSheet = false
    @State private var selectedHint: Hint?
    
    var body: some View {
        NavigationView {
            CurrentHand()
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button { isShowingOptions = true } label: { Image(systemName: "gear") }
                        .font(.title)
                        Button("Undo") {
                            gameRecord.hands.removeLast()
                            let priorRecord = gameRecord.hands.removeLast()
                            hand.restore(from: priorRecord)
                        }
                        .disabled(gameRecord.hands.count < 2)
                        .font(.title)
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        useCardButton
                        hintSheetButton
                    }
                }
                .sheet(isPresented: $isShowingOptions) {
                    GameOptions(isPresented: $isShowingOptions)
                }
                .sheet(
                    isPresented: $isPresentingHintSheet,
                    onDismiss: handleHintSheetDismissal,
                    content: { hintSheet }
                )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .padding()
    }
    
    @ViewBuilder
    private var hintSheetButton: some View {
        Button("Hints") {
            isPresentingHintSheet = true
        }
        .font(.title)
        .disabled(isHintSheetButtonDisabled)
    }

    private var isHintSheetButtonDisabled: Bool {
        guard !hand.selectedCards.isEmpty else { return true }

        return hand.hintableValues.isEmpty && hand.hintableSuits.isEmpty
    }
    
    @ViewBuilder
    private var useCardButton: some View {
        Button("Play / Discard") {
            hand.dismissSelected()
            hand.selectedCards = []
        }
        .font(.title)
        .disabled(hand.selectedCards.count != 1)
    }

    private func handleHintSheetDismissal() {
        guard let hint = selectedHint else { return }

        hand.applyHint(hint)
        hand.selectedCards = []
        selectedHint = nil
    }
    
    private var hintSheet: some View {
        Hints(
            hand: hand,
            selectedHint: $selectedHint,
            isPresented: $isPresentingHintSheet
        )
    }
}

struct GameView_Previews: PreviewProvider {
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
        @State var gameRecord = GameRecord()
        
        var body: some View {
            GameView()
                .environmentObject(gameRecord)
                .environmentObject(hand)
        }
    }

}
