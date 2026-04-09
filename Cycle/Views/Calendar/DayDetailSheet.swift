import SwiftUI
import SwiftData

struct DayDetailSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let date: Date
    let existingEntry: PeriodEntry?

    @State private var flowLevel: FlowLevel
    @State private var mood: Mood
    @State private var symptoms: Set<Symptom>
    @State private var notes: String

    init(date: Date, existingEntry: PeriodEntry?) {
        self.date = date
        self.existingEntry = existingEntry
        _flowLevel = State(initialValue: existingEntry?.flowLevel ?? .none)
        _mood = State(initialValue: existingEntry?.mood ?? .okay)
        _symptoms = State(initialValue: existingEntry?.symptoms ?? [])
        _notes = State(initialValue: existingEntry?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text(date.shortDateString)
                        .font(CycleTheme.headerFont)
                        .foregroundStyle(CycleTheme.textColor)

                    FlowPicker(selected: $flowLevel)
                    MoodPicker(selected: $mood)
                    SymptomGrid(selected: $symptoms)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(CycleTheme.subheaderFont)
                            .foregroundStyle(CycleTheme.textColor)
                        TextField("Add a note...", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(CycleTheme.textColor.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: CycleTheme.cornerRadius))
                    }
                }
                .padding()
            }
            .background(CycleTheme.backgroundColor)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func save() {
        if let entry = existingEntry {
            entry.flowLevel = flowLevel
            entry.mood = mood
            entry.symptoms = symptoms
            entry.notes = notes.isEmpty ? nil : notes
            entry.updatedAt = Date()
        } else {
            let entry = PeriodEntry(
                date: date,
                flowLevel: flowLevel,
                symptoms: symptoms,
                mood: mood,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(entry)
        }
    }
}
