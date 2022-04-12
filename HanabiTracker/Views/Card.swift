import SwiftUI
import Model

struct Card: View {
    var card: Model.Card
    var inferredSuit: Suit?
    var hintableSuits: [Suit]
    let isBlack: Bool
    let isRainbow: Bool
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            suitInformation.padding(.top)
            valueInformation.padding(.bottom)
        }
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .systemFill))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    isSelected ? Color.accentColor : .clear,
                    lineWidth: 2
                )
        }
    }
    
    private var valueInformation: some View {
        Group {
            if let value = inferredValue {
                Text("\(value.rawValue)")
            } else {
                Text(valueString)
            }
        }
        .font(.title2)
        .foregroundColor(.primary)
    }
    
    private var inferredValue: Value? {
        if let value = card.value {
            return value
        }
        if card.hintableValues.count == 1 {
            return card.hintableValues.first
        }
        return nil
    }
    
    private var valueString: String {
        Value.allCases
            .filter { card.hintableValues.contains($0) }
            .map { "\($0.rawValue)" }
            .joined(separator: " ")
    }
    
    @ViewBuilder
    private var suitInformation: some View {
        if isRainbow { rainbowIndicator }
        else if isBlack { blackIndicator }
        else if let suit = inferredSuit { suitView(for: suit).padding() }
        else {
            VStack(spacing: 4) {
                ForEach(Suit.allCases, id: \.self) { suit in
                    suitView(for: suit)
                }
            }
        }
    }
    
    private var rainbowIndicator: some View {
        ZStack {
            Color.white
            Text("🌈")
                .font(.largeTitle)
        }
        .clipShape(Circle())
        .padding()
    }
    
    private var blackIndicator: some View {
        ZStack {
            Color.black
            Image(systemName: "checkmark")
                .foregroundColor(.white)
        }
        .clipShape(Circle())
        .padding()
    }
    
    private func suitView(for suit: Suit) -> some View {
        ZStack {
            ColorSuitMap.backgroundColor(for: suit)
            image(for: suit)
                .foregroundColor(.black)
        }
        .clipShape(Circle())
    }
    
    private func image(for suit: Suit) -> Image {
        if card.hintedSuits.contains(suit) || suit == inferredSuit {
            return Image(systemName: "checkmark")
        } else if hintableSuits.contains(suit) {
            return Image(systemName: "questionmark")
        } else {
            return Image(systemName: "xmark")
        }
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Preview(
                hintableSuits: [.green, .red, .white],
                hintableValues: [.one, .three],
                isRainbow: true
            )
            Preview(
                isRainbow: false
            )
            Preview(
                isRainbow: false
            )
            Preview(
                hintableValues: [.five],
                isRainbow: false
            )
        }
        .previewLayout(.sizeThatFits)
        Preview(
            isRainbow: false
        )
            .colorScheme(.dark)
            .previewLayout(.sizeThatFits)
        
    }
    
    struct Preview: View {
        var card = Model.Card(hintableValues: [.three, .four])
        var hintableSuits = [Suit]()
        var hintableValues = Value.allCases
        let isBlack: Bool
        let isRainbow: Bool
        
        init(
            hintableSuits: [Suit] = [],
            hintableValues: [Value] = Value.allCases,
            isBlack: Bool = false,
            isRainbow: Bool
        ) {
            self.hintableSuits = hintableSuits
            self.hintableValues = hintableValues
            self.isBlack = isBlack
            self.isRainbow = isRainbow
            
            card = Model.Card(hintableValues: Set(hintableValues))
        }
        
        var body: some View {
            Card(
                card: card,
                hintableSuits: hintableSuits,
                isBlack: isBlack,
                isRainbow: isRainbow,
                isSelected: false
            )
        }
    }
}
