import SwiftUI
import Model

struct OptionsEnvironmentKey: EnvironmentKey {
    static var defaultValue: Binding<Options> {
        var options = Options()
        
        return Binding {
            options
        } set: {
            options = $0
        }
    }
}

extension EnvironmentValues {
    var options: Binding<Options> {
        get {
            self[OptionsEnvironmentKey.self]
        }
        set {
            self[OptionsEnvironmentKey.self] = newValue
        }
    }
}
