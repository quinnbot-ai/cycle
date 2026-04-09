import Foundation

enum CycleCalculator {
    private static let maxFlowGap = 2

    static func deriveCycles(from entries: [PeriodEntry]) -> [CycleInfo] {
        let flowEntries = entries.filter { $0.flowLevel.isFlow }.sorted { $0.date < $1.date }
        guard !flowEntries.isEmpty else { return [] }

        var periodStarts: [(start: Date, length: Int)] = []
        var segmentStart = flowEntries[0].date
        var segmentEnd = flowEntries[0].date
        var segmentDays = 1

        for i in 1..<flowEntries.count {
            let gap = segmentEnd.daysBetween(flowEntries[i].date)
            if gap <= maxFlowGap {
                segmentEnd = flowEntries[i].date
                segmentDays += 1
            } else {
                periodStarts.append((start: segmentStart, length: segmentDays))
                segmentStart = flowEntries[i].date
                segmentEnd = flowEntries[i].date
                segmentDays = 1
            }
        }
        periodStarts.append((start: segmentStart, length: segmentDays))

        var cycles: [CycleInfo] = []
        for i in 0..<periodStarts.count {
            let start = periodStarts[i].start
            let end: Date? = (i + 1 < periodStarts.count) ? periodStarts[i + 1].start : nil
            cycles.append(CycleInfo(
                id: UUID(),
                startDate: start,
                endDate: end,
                periodLength: periodStarts[i].length
            ))
        }
        return cycles
    }

    static func currentCycleDay(cycles: [CycleInfo]) -> Int? {
        guard let current = cycles.last, !current.isComplete else { return nil }
        return current.startDate.daysBetween(Date().startOfDay) + 1
    }
}
