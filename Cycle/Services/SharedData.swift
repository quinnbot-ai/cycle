import Foundation

enum SharedData {
    private static let suiteName = "group.com.cycleapp.shared"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    static var currentCycleDay: Int? {
        let value = defaults.integer(forKey: "currentCycleDay")
        return value > 0 ? value : nil
    }

    static var daysUntilNextPeriod: Int? {
        guard defaults.object(forKey: "daysUntilNextPeriod") != nil else { return nil }
        let value = defaults.integer(forKey: "daysUntilNextPeriod")
        return value >= 0 ? value : nil
    }

    static var nextPeriodDateString: String? {
        defaults.string(forKey: "nextPeriodDateString")
    }

    static func update(cycleDay: Int?, daysUntilPeriod: Int?, nextPeriodDateString: String?) {
        defaults.set(cycleDay ?? 0, forKey: "currentCycleDay")
        defaults.set(daysUntilPeriod ?? -1, forKey: "daysUntilNextPeriod")
        defaults.set(nextPeriodDateString, forKey: "nextPeriodDateString")
    }
}
