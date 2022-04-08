import SwiftUI
import Model

struct MainView: View {
    @SceneStorage("HanabiTrackerApp.record") private var gameRecord = GameRecord()
    @StateObject private var hand: Hand
    @State private var options: Options
    @State private var isShowingStateRestorationAlert = false

    init() {
        let newOptions = Options()
        _hand = StateObject(
            wrappedValue: Hand(
                allowsRainbows: newOptions.allowsRainbows,
                size: newOptions.handSize
            )
        )
        _options = State(initialValue: newOptions)
    }
    
    var body: some View {
        GameView()
            .environment(\.options, $options)
            .environmentObject(hand)
            .environmentObject(gameRecord)
            .onChange(of: options) {
                gameRecord.hands = []
                hand.reset(
                    allowsRainbows: $0.allowsRainbows,
                    size: $0.handSize
                )
            }
            .onChange(of: hand.cards) { newCards in
                guard gameRecord.hands.last?.cards != newCards else {
                    return
                }
                
                gameRecord.hands.append(Hand.createDeepCopy(of: hand))
            }
            .onAppear {
                // Offer to restore a persisted hand if one is available
                isShowingStateRestorationAlert = gameRecord.hands.count > 1
                
                guard gameRecord.hands.isEmpty else { return }
                
                // Store the initial hand
                gameRecord.hands.append(Hand.createDeepCopy(of: hand))
            }
            .alert(isPresented: $isShowingStateRestorationAlert) {
                stateRestorationAlert
            }
    }
    
    var stateRestorationAlert: Alert {
        Alert(
            title: Text("Resume Playing?"),
            primaryButton: .default(Text("Yes")) {
                hand.restore(from: gameRecord.hands.removeLast())
                isShowingStateRestorationAlert = false
            },
            secondaryButton: .default(Text("No")) {
                gameRecord.hands = []
                isShowingStateRestorationAlert = false
            }
        )
    }
}
