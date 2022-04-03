import SwiftUI
import Model

struct Options: Equatable {
    var handSize = Hand.Size.four
    var allowsRainbows = false
}

@main
struct HanabiTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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
                .onChange(of: options) {
                    hand.reset(
                        allowsRainbows: $0.allowsRainbows,
                        size: $0.handSize
                    )
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
