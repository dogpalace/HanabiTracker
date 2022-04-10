import XCTest
@testable import Model

class GameRecordTests: XCTestCase {
    
    let hands = [
        Hand(allowsRainbows: true, allowsBlacks: true, size: .four),
        Hand(allowsRainbows: true, allowsBlacks: false, size: .five)
    ]
    lazy var record = GameRecord(hands: hands)
    
    func testCodability() throws {
        let encoded = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(GameRecord.self, from: encoded)
        
        XCTAssertEqual(
            record.hands,
            decoded.hands,
            .isCodable
        )
    }
    
    func testRawRepresentation() throws {
        
        let rawValue = "{\"hands\":[{\"size\":4,\"cards\":[{\"hintableValues\":[5,1,4,3,2],\"hintableSuits\":[{\"white\":{}},{\"blue\":{}},{\"green\":{}},{\"red\":{}},{\"yellow\":{}}],\"uuid\":\"66FE1349-F871-4072-877B-43C285BB4C18\",\"hintedSuits\":[]},{\"hintableValues\":[4,2,1,3,5],\"hintableSuits\":[{\"white\":{}},{\"red\":{}},{\"blue\":{}},{\"yellow\":{}},{\"green\":{}}],\"uuid\":\"CFDAF7E0-787D-4849-A793-903237FA1F9D\",\"hintedSuits\":[]},{\"hintableValues\":[2,3,4,1,5],\"hintableSuits\":[{\"red\":{}},{\"green\":{}},{\"white\":{}},{\"yellow\":{}},{\"blue\":{}}],\"uuid\":\"F51A2969-6A2E-4180-A35C-BD03D9DA50DD\",\"hintedSuits\":[]},{\"hintableValues\":[3,4,1,2,5],\"hintableSuits\":[{\"white\":{}},{\"red\":{}},{\"yellow\":{}},{\"blue\":{}},{\"green\":{}}],\"uuid\":\"5D92D989-831C-4F01-885F-0E1C85A11F5B\",\"hintedSuits\":[]}],\"allowsRainbows\":true,\"allowsBlacks\":true,\"selectedCards\":{\"indexes\":[]}},{\"size\":5,\"cards\":[{\"hintableValues\":[3,5,1,2,4],\"hintableSuits\":[{\"white\":{}},{\"red\":{}},{\"blue\":{}},{\"yellow\":{}},{\"green\":{}}],\"uuid\":\"032E8BF1-F3A0-4ADE-8C17-FADE849C6BEE\",\"hintedSuits\":[]},{\"hintableValues\":[2,4,3,1,5],\"hintableSuits\":[{\"red\":{}},{\"yellow\":{}},{\"green\":{}},{\"blue\":{}},{\"white\":{}}],\"uuid\":\"1CE62B58-99C0-4D19-A3CB-B5C1E6993665\",\"hintedSuits\":[]},{\"hintableValues\":[1,4,3,2,5],\"hintableSuits\":[{\"white\":{}},{\"blue\":{}},{\"yellow\":{}},{\"green\":{}},{\"red\":{}}],\"uuid\":\"024CA673-3AF6-44D6-BF9C-802E860107B8\",\"hintedSuits\":[]},{\"hintableValues\":[1,3,4,2,5],\"hintableSuits\":[{\"white\":{}},{\"blue\":{}},{\"red\":{}},{\"green\":{}},{\"yellow\":{}}],\"uuid\":\"4BD98318-6C5F-4004-BA3E-136F07CC1B33\",\"hintedSuits\":[]},{\"hintableValues\":[5,1,2,4,3],\"hintableSuits\":[{\"yellow\":{}},{\"red\":{}},{\"white\":{}},{\"blue\":{}},{\"green\":{}}],\"uuid\":\"1DBB72E0-D4E6-49AB-A0BF-F770592087F3\",\"hintedSuits\":[]}],\"allowsRainbows\":true,\"allowsBlacks\":false,\"selectedCards\":{\"indexes\":[]}}]}"

        let data = try XCTUnwrap(rawValue.data(using: .utf8))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data))
        
        XCTAssertTrue(
            JSONSerialization.isValidJSONObject(object),
            .canBeRepresentedAsJSON
        )
        XCTAssertEqual(
            GameRecord(rawValue: rawValue)?.hands,
            record.hands,
            .canBeCreatedFromJSON
        )
    }
}

fileprivate extension String {
    static let isCodable = "Should be encodable and decodable"
    static let canBeRepresentedAsJSON = "Hand should be representable as a json-encoded string"
    static let canBeCreatedFromJSON = "Hand should be creatable from a json-encoded string"
}
