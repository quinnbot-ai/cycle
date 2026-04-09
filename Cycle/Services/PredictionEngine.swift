import Foundation

struct Prediction {
    let nextPeriodDate: Date
    let averageCycleLength: Double
    let fertileWindowStart: Date
    let fertileWindowEnd: Date
    let isIrregular: Bool
}

enum PredictionEngine {
    static let minimumCompletedCycles = 2
    static let irregularityThreshold: Double = 5.0

    static func predict(from cycles: [CycleInfo], windowSize: Int) -> Prediction? {
        let completed = cycles.filter { $0.isComplete }
        guard completed.count >= minimumCompletedCycles else { return nil }

        let window = Array(completed.suffix(windowSize))
        let lengths = window.compactMap { $0.length }.map(Double.init)
        guard !lengths.isEmpty else { return nil }

        let average = lengths.reduce(0, +) / Double(lengths.count)
        let variance = lengths.map { ($0 - average) * ($0 - average) }.reduce(0, +) / Double(lengths.count)
        let stdDev = variance.squareRoot()
        let isIrregular = stdDev > irregularityThreshold

        let lastStart: Date
        if let ongoing = cycles.last, !ongoing.isComplete {
            lastStart = ongoing.startDate
        } else if let lastCompleted = completed.last {
            lastStart = lastCompleted.endDate ?? lastCompleted.startDate
        } else {
            return nil
        }

        let nextPeriod = lastStart.adding(days: Int(average.rounded()))
        let fertileStart = Calendar.current.date(byAdding: .day, value: -16, to: nextPeriod)!
        let fertileEnd = Calendar.current.date(byAdding: .day, value: -12, to: nextPeriod)!

        return Prediction(
            nextPeriodDate: nextPeriod,
            averageCycleLength: average,
            fertileWindowStart: fertileStart,
            fertileWindowEnd: fertileEnd,
            isIrregular: isIrregular
        )
    }
}
