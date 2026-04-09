import Foundation

struct CycleInfo: Identifiable, Equatable {
    let id: UUID
    let startDate: Date
    let endDate: Date?
    let periodLength: Int

    var length: Int? {
        guard let endDate else { return nil }
        return startDate.daysBetween(endDate)
    }

    var isComplete: Bool {
        endDate != nil
    }
}
