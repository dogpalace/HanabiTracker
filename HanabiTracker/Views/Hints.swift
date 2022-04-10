import SwiftUI
import Model

struct Hints: View {
    @ObservedObject var hand: Hand
    @Binding var selectedHint: Hint?
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                suitHints
                valueHints
                Spacer()
            }
            .navigationBarItems(trailing: done)
            .padding()
        }
        .padding()
    }
    
    private var done: some View {
        Button("Done") {
            isPresented = false
        }
        .font(.title)
    }
        
    private var suitHints: some View {
        HStack {
            ForEach(hand.hintableSuits, id: \.self) { suit in
                Button(action: {
                    selectedHint = .suit(suit)
                    isPresented.toggle()
                }, label: {
                    SuitHint(suit: suit)
                })
            }
        }
    }
    
    private var valueHints: some View {
        HStack {
            ForEach(hand.hintableValues, id: \.self) { value in
                Button(action: {
                    selectedHint = .value(value)
                    isPresented.toggle()
                }, label: {
                    ValueHint(value: value)
                })
            }
        }
    }
}

struct Hints_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }
    
    struct Preview: View {
        @State private var hand = Hand(
            allowsRainbows: false,
            allowsBlacks: false,
            size: .four
        )
        @State private var selectedHint: Hint?
        @State private var isPresented = true
            
        var body: some View {
            Hints(
                hand: hand,
                selectedHint: $selectedHint,
                isPresented: $isPresented
            )
        }
    }
}
