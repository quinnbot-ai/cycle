import Foundation
import SwiftData

@Model
final class PeriodEntry {
    var id: UUID
    @Attribute(.unique) var date: Date
    var flowLevelRaw: Int
    var symptomsRaw: [String]
    var moodRaw: Int
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    var flowLevel: FlowLevel {
        get { FlowLevel(rawValue: flowLevelRaw) ?? .none }
        set { flowLevelRaw = newValue.rawValue }
    }

    var symptoms: Set<Symptom> {
        get { Set(symptomsRaw.compactMap { Symptom(rawValue: $0) }) }
        set { symptomsRaw = newValue.map(\.rawValue).sorted() }
    }

    var mood: Mood {
        get { Mood(rawValue: moodRaw) ?? .okay }
        set { moodRaw = newValue.rawValue }
    }

    init(
        date: Date,
        flowLevel: FlowLevel = .none,
        symptoms: Set<Symptom> = [],
        mood: Mood = .okay,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.date = date.startOfDay
        self.flowLevelRaw = flowLevel.rawValue
        self.symptomsRaw = symptoms.map(\.rawValue).sorted()
        self.moodRaw = mood.rawValue
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
