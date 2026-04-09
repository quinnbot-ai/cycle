import XCTest
@testable import Cycle

final class DateCycleTests: XCTestCase {
    func testStartOfDay() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 15, hour: 14, minute: 30))!
        let start = date.startOfDay
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: start)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testDaysBetween() {
        let march1 = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        let march29 = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 29))!
        XCTAssertEqual(march1.daysBetween(march29), 28)
    }

    func testDaysBetweenSameDay() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        XCTAssertEqual(date.daysBetween(date), 0)
    }

    func testAddingDays() {
        let march1 = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        let result = march1.adding(days: 28)
        let components = Calendar.current.dateComponents([.month, .day], from: result)
        XCTAssertEqual(components.month, 3)
        XCTAssertEqual(components.day, 29)
    }

    func testDayOfMonth() {
        let march15 = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 15))!
        XCTAssertEqual(march15.dayOfMonth, 15)
    }
}
