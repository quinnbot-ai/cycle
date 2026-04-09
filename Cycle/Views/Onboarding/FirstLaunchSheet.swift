import SwiftUI
import SwiftData

struct FirstLaunchSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var lastPeriodDate = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(CycleTheme.primaryColor)

                    Text("Welcome to Cycle")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(CycleTheme.textColor)

                    Text("When did your last period start?")
                        .font(CycleTheme.bodyFont)
                        .foregroundStyle(CycleTheme.textColor.opacity(0.7))
                }

                DatePicker(
                    "Last period start",
                    selection: $lastPeriodDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(CycleTheme.primaryColor)
                .padding(.horizontal)

                Spacer()

                Button {
                    saveInitialEntry()
                    dismiss()
                } label: {
                    Text("Get Started")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .foregroundStyle(.white)
                .background(CycleTheme.primaryColor)
                .clipShape(RoundedRectangle(cornerRadius: CycleTheme.cornerRadius))
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(CycleTheme.backgroundColor)
            .interactiveDismissDisabled()
        }
    }

    private func saveInitialEntry() {
        let entry = PeriodEntry(date: lastPeriodDate, flowLevel: .medium)
        modelContext.insert(entry)

        let settings = AppSettings()
        modelContext.insert(settings)
    }
}
