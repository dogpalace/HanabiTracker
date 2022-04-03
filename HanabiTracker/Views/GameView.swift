import SwiftUI
import Model

struct GameView: View {
    @EnvironmentObject var hand: Hand
    @State private var isShowingOptions = false
    @State private var isPresentingHintSheet = false
    @State private var selectedHint: Hint?
    @State private var isShowingUseCardConfirmation = false
    
    var body: some View {
        NavigationView {
        CurrentHand()
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button { isShowingOptions = true } label: { Image(systemName: "gear") }
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
            .alert(isPresented: $isShowingUseCardConfirmation) {
                Alert(
                    title: Text("Play / Dismiss Card ?"),
                    message: Text("Using a card cannot be undone"),
                    primaryButton: .destructive(
                        Text("Use Card"),
                        action: {
                            hand.dismissSelected()
                            hand.selectedCards = []
                            isShowingUseCardConfirmation = false
                        }
                    ),
                    secondaryButton: .default(Text("Cancel"), action: {
                        isShowingUseCardConfirmation = false
                    })
                )
            }
        }
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
        Button(
            "Play / Discard",
            role: .destructive
        ) {
            isShowingUseCardConfirmation = true
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
            size: .four
        )
        
        var body: some View {
            GameView()
                .environmentObject(hand)
        }
    }

}
