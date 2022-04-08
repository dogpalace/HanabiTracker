import SwiftUI

/** Codable and RawRepresentable as a json-encoded String so that it can be used
 with the SceneStorage property wrapper */
public final class GameRecord: ObservableObject, Codable, RawRepresentable {
    @Published public var hands = [Hand]()
    
    public init(hands: [Hand] = []) {
        self.hands = hands
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hands = try container.decode([Hand].self, forKey: .hands)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hands, forKey: .hands)
    }
    
    private enum CodingKeys: CodingKey {
        case hands
    }
        
    public convenience init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(GameRecord.self, from: data)
        else {
            return nil
        }
        
        self.init(hands: result.hands)
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let encoded = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        
        return encoded
    }
}
