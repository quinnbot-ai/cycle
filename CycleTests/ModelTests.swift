import XCTest
@testable import Cycle

final class ModelTests: XCTestCase {
    func testFlowLevelIsFlow() {
        XCTAssertFalse(FlowLevel.none.isFlow)
        XCTAssertTrue(FlowLevel.spotting.isFlow)
        XCTAssertTrue(FlowLevel.light.isFlow)
        XCTAssertTrue(FlowLevel.medium.isFlow)
        XCTAssertTrue(FlowLevel.heavy.isFlow)
    }

    func testPeriodEntryDateNormalized() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 15, hour: 14))!
        let entry = PeriodEntry(date: date, flowLevel: .medium)
        let components = Calendar.current.dateComponents([.hour, .minute], from: entry.date)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
    }

    func testPeriodEntrySymptomsRoundTrip() {
        let entry = PeriodEntry(date: Date(), symptoms: [.cramps, .headache, .bloating])
        XCTAssertEqual(entry.symptoms, [.cramps, .headache, .bloating])
    }

    func testPeriodEntryMoodRoundTrip() {
        let entry = PeriodEntry(date: Date(), mood: .great)
        XCTAssertEqual(entry.mood, .great)
    }

    func testCycleInfoLength() {
        let start = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        let end = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 29))!
        let cycle = CycleInfo(id: UUID(), startDate: start, endDate: end, periodLength: 5)
        XCTAssertEqual(cycle.length, 28)
        XCTAssertTrue(cycle.isComplete)
    }

    func testCycleInfoOngoing() {
        let start = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        let cycle = CycleInfo(id: UUID(), startDate: start, endDate: nil, periodLength: 5)
        XCTAssertNil(cycle.length)
        XCTAssertFalse(cycle.isComplete)
    }

    func testAppSettingsDefaults() {
        let settings = AppSettings()
        XCTAssertEqual(settings.averageWindowSize, 6)
        XCTAssertFalse(settings.passcodeEnabled)
        XCTAssertEqual(settings.lockDelay, .immediately)
        XCTAssertFalse(settings.notificationsEnabled)
        XCTAssertEqual(settings.periodReminderDays, 2)
        XCTAssertNil(settings.logReminderTime)
    }
}
