import SwiftUI
import Model

struct Options: Equatable {
    var handSize = Hand.Size.four
    var allowsRainbows = false
}

class GameRecord: ObservableObject {
    @Published var hands = [Hand]()
}

@main
struct HanabiTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var gameRecord = GameRecord()
    @StateObject private var hand: Hand
    @State private var options: Options
    
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
    
    var body: some Scene {
        WindowGroup {
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
                    // Store the initial hand
                    guard gameRecord.hands.isEmpty else { return }
                    
                    gameRecord.hands.append(Hand.createDeepCopy(of: hand))
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.landscape

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        AppDelegate.orientationLock
    }
}
