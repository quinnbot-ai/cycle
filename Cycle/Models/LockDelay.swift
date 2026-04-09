import Foundation

enum LockDelay: Int, Codable, CaseIterable, Identifiable {
    case immediately = 0
    case oneMinute = 60
    case fiveMinutes = 300

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .immediately: "Immediately"
        case .oneMinute: "After 1 minute"
        case .fiveMinutes: "After 5 minutes"
        }
    }

    var seconds: TimeInterval {
        TimeInterval(rawValue)
    }
}
