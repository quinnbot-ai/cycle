import XCTest
@testable import Cycle

final class SharedDataTests: XCTestCase {
    func testMissingCountdownValueIsUnknown() {
        let defaults = SharedData.defaults
        let key = "daysUntilNextPeriod"
        let originalValue = defaults.object(forKey: key)

        defaults.removeObject(forKey: key)
        defer {
            if let originalValue {
                defaults.set(originalValue, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }

        XCTAssertNil(SharedData.daysUntilNextPeriod)
    }
}
