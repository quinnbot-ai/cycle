import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PeriodEntry.date, order: .forward) private var allEntries: [PeriodEntry]

    @State private var flowLevel: FlowLevel = .none
    @State private var mood: Mood = .okay
    @State private var symptoms: Set<Symptom> = []
    @State private var notes: String = ""

    private var cycles: [CycleInfo] {
        CycleCalculator.deriveCycles(from: allEntries)
    }

    private var cycleDay: Int? {
        CycleCalculator.currentCycleDay(cycles: cycles)
    }

    private var prediction: Prediction? {
        PredictionEngine.predict(from: cycles, windowSize: 6)
    }

    private var todayEntry: PeriodEntry? {
        let today = Date().startOfDay
        return allEntries.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    cycleDayHeader
                    FlowPicker(selected: $flowLevel)
                    MoodPicker(selected: $mood)
                    SymptomGrid(selected: $symptoms)
                    notesSection
                }
                .padding()
            }
            .background(CycleTheme.backgroundColor)
            .navigationTitle("Today")
            .onAppear(perform: loadTodayEntry)
            .onChange(of: flowLevel) { _, _ in saveEntry() }
            .onChange(of: mood) { _, _ in saveEntry() }
            .onChange(of: symptoms) { _, _ in saveEntry() }
        }
    }

    private var cycleDayHeader: some View {
        VStack(spacing: 8) {
            if let day = cycleDay {
                Text("Day \(day)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(CycleTheme.primaryColor)

                if let prediction {
                    let daysUntil = Date().startOfDay.daysBetween(prediction.nextPeriodDate)
                    if daysUntil > 0 {
                        Text("Next period in \(daysUntil) days")
                            .font(CycleTheme.bodyFont)
                            .foregroundStyle(CycleTheme.textColor.opacity(0.7))
                    } else {
                        Text("Period expected today")
                            .font(CycleTheme.bodyFont)
                            .foregroundStyle(CycleTheme.primaryColor)
                    }

                    if prediction.isIrregular {
                        Text("Your cycles vary a lot — predictions may be less accurate")
                            .font(CycleTheme.captionFont)
                            .foregroundStyle(CycleTheme.secondaryColor)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    Text("Not enough data for predictions yet")
                        .font(CycleTheme.captionFont)
                        .foregroundStyle(CycleTheme.textColor.opacity(0.5))
                }
            } else {
                Text("Log your period to get started")
                    .font(CycleTheme.subheaderFont)
                    .foregroundStyle(CycleTheme.textColor.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private var notesSection: some View {
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
                .onSubmit { saveEntry() }
        }
    }

    private func loadTodayEntry() {
        if let entry = todayEntry {
            flowLevel = entry.flowLevel
            mood = entry.mood
            symptoms = entry.symptoms
            notes = entry.notes ?? ""
        }
    }

    private func saveEntry() {
        let today = Date().startOfDay
        if let entry = todayEntry {
            entry.flowLevel = flowLevel
            entry.mood = mood
            entry.symptoms = symptoms
            entry.notes = notes.isEmpty ? nil : notes
            entry.updatedAt = Date()
        } else {
            let entry = PeriodEntry(
                date: today,
                flowLevel: flowLevel,
                symptoms: symptoms,
                mood: mood,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(entry)
        }
    }
}
