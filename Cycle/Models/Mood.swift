import Foundation

enum Mood: Int, Codable, CaseIterable, Identifiable {
    case great = 4
    case good = 3
    case okay = 2
    case low = 1
    case awful = 0

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .great: "Great"
        case .good: "Good"
        case .okay: "Okay"
        case .low: "Low"
        case .awful: "Awful"
        }
    }

    var icon: String {
        switch self {
        case .great: "face.smiling.fill"
        case .good: "face.smiling"
        case .okay: "face.dashed"
        case .low: "cloud.fill"
        case .awful: "cloud.bolt.fill"
        }
    }
}
