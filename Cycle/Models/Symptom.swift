import Foundation

enum Symptom: String, Codable, CaseIterable, Identifiable {
    case cramps
    case headache
    case bloating
    case fatigue
    case acne
    case backPain
    case nausea
    case breastTenderness
    case insomnia
    case moodSwings
    case cravings
    case dizziness

    var id: String { rawValue }

    var label: String {
        switch self {
        case .cramps: "Cramps"
        case .headache: "Headache"
        case .bloating: "Bloating"
        case .fatigue: "Fatigue"
        case .acne: "Acne"
        case .backPain: "Back pain"
        case .nausea: "Nausea"
        case .breastTenderness: "Breast tenderness"
        case .insomnia: "Insomnia"
        case .moodSwings: "Mood swings"
        case .cravings: "Cravings"
        case .dizziness: "Dizziness"
        }
    }

    var icon: String {
        switch self {
        case .cramps: "bolt.fill"
        case .headache: "brain.head.profile"
        case .bloating: "circle.fill"
        case .fatigue: "battery.25"
        case .acne: "face.dashed"
        case .backPain: "figure.walk"
        case .nausea: "stomach"
        case .breastTenderness: "heart.fill"
        case .insomnia: "moon.fill"
        case .moodSwings: "theatermasks.fill"
        case .cravings: "fork.knife"
        case .dizziness: "tornado"
        }
    }
}
