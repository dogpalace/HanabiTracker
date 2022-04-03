import SwiftUI
import Model

struct ValueHint: View {
    let value: Value

    var body: some View {
        ZStack {
        Circle()
            .strokeBorder(Color.black, lineWidth: 5)
            .background {
                Circle()
                    .fill(.white)
            }

        
        
        Text("\(value.rawValue)")
                .font(.largeTitle)
            .padding()
        }
    }
}

struct ValueHint_Previews: PreviewProvider {
    static var previews: some View {
        ValueHint(value: .four)
    }
}
