import XCTest
@testable import Cycle

final class PredictionEngineTests: XCTestCase {
    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func makeCycles(lengths: [Int], startingFrom start: Date) -> [CycleInfo] {
        var cycles: [CycleInfo] = []
        var currentStart = start
        for length in lengths {
            let end = currentStart.adding(days: length)
            cycles.append(CycleInfo(id: UUID(), startDate: currentStart, endDate: end, periodLength: 5))
            currentStart = end
        }
        cycles.append(CycleInfo(id: UUID(), startDate: currentStart, endDate: nil, periodLength: 3))
        return cycles
    }

    func testPredictionNotEnoughData() {
        let cycles = [CycleInfo(id: UUID(), startDate: date(2026, 3, 1), endDate: nil, periodLength: 4)]
        let prediction = PredictionEngine.predict(from: cycles, windowSize: 6)
        XCTAssertNil(prediction)
    }

    func testPredictionWithOneCycle() {
        let cycles = [
            CycleInfo(id: UUID(), startDate: date(2026, 2, 1), endDate: date(2026, 3, 1), periodLength: 5),
            CycleInfo(id: UUID(), startDate: date(2026, 3, 1), endDate: nil, periodLength: 3),
        ]
        let prediction = PredictionEngine.predict(from: cycles, windowSize: 6)
        XCTAssertNil(prediction)
    }

    func testPredictionBasicAverage() {
        let cycles = makeCycles(lengths: [28, 30], startingFrom: date(2026, 1, 1))
        let prediction = PredictionEngine.predict(from: cycles, windowSize: 6)
        XCTAssertNotNil(prediction)
        XCTAssertEqual(prediction!.averageCycleLength, 29.0, accuracy: 0.1)
        let expected = date(2026, 3, 29)
        XCTAssertTrue(Calendar.current.isDate(prediction!.nextPeriodDate, inSameDayAs: expected))
    }

    func testPredictionRespectsWindowSize() {
        let cycles = makeCycles(lengths: [22, 22, 30, 28], startingFrom: date(2025, 10, 1))
        let prediction = PredictionEngine.predict(from: cycles, windowSize: 2)
        XCTAssertNotNil(prediction)
        XCTAssertEqual(prediction!.averageCycleLength, 29.0, accuracy: 0.1)
    }

    func testPredictionIrregularFlag() {
        let cycles = makeCycles(lengths: [21, 35, 22, 36], startingFrom: date(2025, 8, 1))
        let prediction = PredictionEngine.predict(from: cycles, windowSize: 6)
        XCTAssertNotNil(prediction)
        XCTAssertTrue(prediction!.isIrregular)
    }

    func testPredictionRegularFlag() {
        let cycles = makeCycles(lengths: [28, 29, 28, 27], startingFrom: date(2025, 10, 1))
        let prediction = PredictionEngine.predict(from: cycles, windowSize: 6)
        XCTAssertNotNil(prediction)
        XCTAssertFalse(prediction!.isIrregular)
    }

    func testFertileWindow() {
        let cycles = makeCycles(lengths: [28, 28], startingFrom: date(2026, 1, 1))
        let prediction = PredictionEngine.predict(from: cycles, windowSize: 6)!
        let fertileStart = Calendar.current.date(byAdding: .day, value: -16, to: prediction.nextPeriodDate)!
        let fertileEnd = Calendar.current.date(byAdding: .day, value: -12, to: prediction.nextPeriodDate)!
        XCTAssertTrue(Calendar.current.isDate(prediction.fertileWindowStart, inSameDayAs: fertileStart))
        XCTAssertTrue(Calendar.current.isDate(prediction.fertileWindowEnd, inSameDayAs: fertileEnd))
    }
}
