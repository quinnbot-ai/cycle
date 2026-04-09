import XCTest
@testable import Cycle

final class ExportManagerTests: XCTestCase {
    func testExportEmpty() {
        let csv = ExportManager.generateCSV(from: [])
        let lines = csv.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0].contains("Date"))
    }

    func testExportSingleEntry() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 15))!
        let entry = PeriodEntry(date: date, flowLevel: .heavy, symptoms: [.cramps, .headache], mood: .low, notes: "rough day")
        let csv = ExportManager.generateCSV(from: [entry])
        let lines = csv.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertEqual(lines.count, 2)
        XCTAssertTrue(lines[1].contains("Heavy"))
        XCTAssertTrue(lines[1].contains("Low"))
        XCTAssertTrue(lines[1].contains("Cramps"))
        XCTAssertTrue(lines[1].contains("rough day"))
    }

    func testExportNotesWithCommas() {
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 15))!
        let entry = PeriodEntry(date: date, flowLevel: .light, notes: "cramps, headache, and fatigue")
        let csv = ExportManager.generateCSV(from: [entry])
        XCTAssertTrue(csv.contains("\"cramps, headache, and fatigue\""))
    }
}
