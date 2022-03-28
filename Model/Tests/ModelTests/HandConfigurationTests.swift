import Foundation
import Model
import XCTest

class HandConfigurationTests: XCTestCase {
    
    func testAllowsRainbows() {
        let configuration = Hand.Configuration(allowsRainbows: true)
        XCTAssertTrue(configuration.allowsRainbows, .allowsRainbows)
    }
    
    func testDisallowsRainbows() {
        let configuration = Hand.Configuration(allowsRainbows: false)
        XCTAssertFalse(configuration.allowsRainbows, .doesNotAllowRainbows)
    }
}

fileprivate extension String {
    static let allowsRainbows = "A configuration can allow rainbows"
    static let doesNotAllowRainbows = "A configuration can disallow rainbows"
}
