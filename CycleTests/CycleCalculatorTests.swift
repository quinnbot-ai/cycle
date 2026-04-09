import XCTest
@testable import Cycle

final class CycleCalculatorTests: XCTestCase {
    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func entries(flowDays: [(Int, Int, Int, FlowLevel)]) -> [PeriodEntry] {
        flowDays.map { (y, m, d, flow) in
            PeriodEntry(date: date(y, m, d), flowLevel: flow)
        }.sorted { $0.date < $1.date }
    }

    func testDeriveCyclesEmpty() {
        let cycles = CycleCalculator.deriveCycles(from: [])
        XCTAssertTrue(cycles.isEmpty)
    }

    func testDeriveCyclesOnePeriod() {
        let e = entries(flowDays: [
            (2026, 3, 1, .medium),
            (2026, 3, 2, .heavy),
            (2026, 3, 3, .light),
            (2026, 3, 4, .spotting),
        ])
        let cycles = CycleCalculator.deriveCycles(from: e)
        XCTAssertEqual(cycles.count, 1)
        XCTAssertFalse(cycles[0].isComplete)
        XCTAssertEqual(cycles[0].periodLength, 4)
    }

    func testDeriveCyclesTwoPeriods() {
        let e = entries(flowDays: [
            (2026, 2, 1, .medium),
            (2026, 2, 2, .heavy),
            (2026, 2, 3, .light),
            (2026, 3, 1, .medium),
            (2026, 3, 2, .heavy),
        ])
        let cycles = CycleCalculator.deriveCycles(from: e)
        XCTAssertEqual(cycles.count, 2)
        XCTAssertTrue(cycles[0].isComplete)
        XCTAssertEqual(cycles[0].length, 28)
        XCTAssertEqual(cycles[0].periodLength, 3)
        XCTAssertFalse(cycles[1].isComplete)
        XCTAssertEqual(cycles[1].periodLength, 2)
    }

    func testDeriveCyclesSkipsNoneFlowDays() {
        let e = entries(flowDays: [
            (2026, 2, 1, .medium),
            (2026, 2, 2, .light),
            (2026, 2, 15, .none),
            (2026, 3, 1, .medium),
        ])
        let cycles = CycleCalculator.deriveCycles(from: e)
        XCTAssertEqual(cycles.count, 2)
        XCTAssertEqual(cycles[0].periodLength, 2)
    }

    func testDeriveCyclesConsecutiveFlowGap() {
        let e = entries(flowDays: [
            (2026, 2, 1, .medium),
            (2026, 2, 2, .light),
            (2026, 2, 10, .medium),
            (2026, 2, 11, .light),
        ])
        let cycles = CycleCalculator.deriveCycles(from: e)
        XCTAssertEqual(cycles.count, 2)
    }

    func testCurrentCycleDayNoData() {
        let result = CycleCalculator.currentCycleDay(cycles: [])
        XCTAssertNil(result)
    }

    func testCurrentCycleDay() {
        let start = Calendar.current.date(byAdding: .day, value: -13, to: Date())!.startOfDay
        let cycle = CycleInfo(id: UUID(), startDate: start, endDate: nil, periodLength: 4)
        let result = CycleCalculator.currentCycleDay(cycles: [cycle])
        XCTAssertEqual(result, 14)
    }
}
