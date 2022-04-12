import SwiftUI
import Model

struct GameOptions: View {
    @Environment(\.options) private var options: Binding<Options>
    @Binding var isPresented: Bool

    init(isPresented: Binding<Bool>) {
        _isPresented = isPresented
        
        UISegmentedControl.appearance().setTitleTextAttributes(
            [
                .font: UIFont.preferredFont(forTextStyle: .title3)
            ],
            for: .normal
        )
    }
    
    var body: some View {
        NavigationView {
            VStack {
                handSizeSelection
                rainbowsSelection
                blacksSelection
            }
            .padding()
            .navigationBarItems(trailing: done)
        }
        .padding()
    }
    
    private var rainbowsSelection: some View {
        HStack {
            Toggle("Allows 🌈s", isOn: options.allowsRainbows)
                .font(.title2)
        }
    }
    
    private var blacksSelection: some View {
        HStack {
            Toggle("Allows black cards", isOn: options.allowsBlacks)
                .font(.title2)
        }
    }
    
    private var done: some View {
        Button("Done") {
            isPresented = false
        }
        .font(.title)
    }
    
    private var handSizeSelection: some View {
        HStack {
            Text("Hand Size")
                .font(.title2)
            Spacer()
            Picker("Hand size", selection: options.handSize) {
                ForEach(Hand.Size.allCases, id: \.self) {
                    Text(String(describing: $0))
                }
            }
            .font(.title2)
            .pickerStyle(.segmented)
        }
    }
}

struct GameOptions_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
            .previewInterfaceOrientation(.landscapeLeft)
    }
    
    struct Preview: View {
        @State var handSize: Hand.Size = .four
        @State var allowsRainbows = false
        @State var isPresented = true
        
        var body: some View {
            GameOptions(isPresented: $isPresented)
        }
    }

}
