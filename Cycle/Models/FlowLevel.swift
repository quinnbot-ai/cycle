import SwiftUI

enum FlowLevel: Int, Codable, CaseIterable, Identifiable {
    case none = 0
    case spotting = 1
    case light = 2
    case medium = 3
    case heavy = 4

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .none: "None"
        case .spotting: "Spotting"
        case .light: "Light"
        case .medium: "Medium"
        case .heavy: "Heavy"
        }
    }

    var icon: String {
        switch self {
        case .none: "drop"
        case .spotting: "drop.fill"
        case .light: "drop.fill"
        case .medium: "drop.fill"
        case .heavy: "drop.fill"
        }
    }

    var isFlow: Bool {
        self != .none
    }
}
