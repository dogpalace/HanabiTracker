import SwiftUI
import Model

struct SuitHint: View {
    let suit: Suit

    var body: some View {
        Circle()
            .strokeBorder(Color.black, lineWidth: 5)
            .background {
                Circle()
                    .fill(
                        ColorSuitMap.backgroundColor(for: suit)
                    )
            }
    }
}

struct SuitHint_Previews: PreviewProvider {
    static var previews: some View {
        SuitHint(suit: .green)
    }
}
