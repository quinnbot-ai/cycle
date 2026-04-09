import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    func daysBetween(_ other: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: self)
        let end = calendar.startOfDay(for: other)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self)!
    }

    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self)!
    }

    private static let monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    var monthYearString: String {
        Self.monthYearFormatter.string(from: self)
    }

    var shortDateString: String {
        Self.shortDateFormatter.string(from: self)
    }

    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}
