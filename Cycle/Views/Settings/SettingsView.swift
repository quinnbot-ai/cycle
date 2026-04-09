import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsArray: [AppSettings]
    @Query(sort: \PeriodEntry.date) private var allEntries: [PeriodEntry]

    let storeManager: StoreManager

    @State private var showingProSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingExportSheet = false
    @State private var exportURL: URL?

    private var settings: AppSettings {
        if let existing = settingsArray.first {
            return existing
        }
        let newSettings = AppSettings()
        modelContext.insert(newSettings)
        return newSettings
    }

    var body: some View {
        List {
            Section("General") {
                Picker("Prediction window", selection: Binding(
                    get: { settings.averageWindowSize },
                    set: { settings.averageWindowSize = $0 }
                )) {
                    Text("3 cycles").tag(3)
                    Text("6 cycles").tag(6)
                    Text("12 cycles").tag(12)
                }
            }

            Section("Security") {
                Toggle("App Lock (Face ID)", isOn: Binding(
                    get: { settings.passcodeEnabled },
                    set: { settings.passcodeEnabled = $0 }
                ))

                if settings.passcodeEnabled {
                    Picker("Lock after", selection: Binding(
                        get: { settings.lockDelay },
                        set: { settings.lockDelay = $0 }
                    )) {
                        ForEach(LockDelay.allCases) { delay in
                            Text(delay.label).tag(delay)
                        }
                    }
                }
            }

            Section("Notifications") {
                Toggle("Notifications", isOn: Binding(
                    get: { settings.notificationsEnabled },
                    set: { settings.notificationsEnabled = $0 }
                ))

                if settings.notificationsEnabled {
                    Stepper(
                        "Remind \(settings.periodReminderDays) days before",
                        value: Binding(
                            get: { settings.periodReminderDays },
                            set: { settings.periodReminderDays = $0 }
                        ),
                        in: 1...7
                    )
                }
            }

            Section {
                if storeManager.isPro {
                    Label("Cycle Pro unlocked", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(CycleTheme.primaryColor)
                } else {
                    Button {
                        showingProSheet = true
                    } label: {
                        HStack {
                            Label("Unlock Cycle Pro", systemImage: "star.circle.fill")
                            Spacer()
                            Text(storeManager.proProduct?.displayPrice ?? "$4.99")
                                .foregroundStyle(CycleTheme.textColor.opacity(0.5))
                        }
                    }
                }
            }

            Section("Your Data") {
                Button {
                    exportURL = ExportManager.exportURL(from: allEntries)
                    if exportURL != nil { showingExportSheet = true }
                } label: {
                    Label("Export as CSV", systemImage: "square.and.arrow.up")
                }

                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete All Data", systemImage: "trash")
                }
            }

            Section("About") {
                LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")

                Link(destination: URL(string: "https://github.com/cycleapp/cycle")!) {
                    Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                }

                LabeledContent("Privacy") {
                    Text("Your data stays on your phone. That's it.")
                        .font(CycleTheme.captionFont)
                        .foregroundStyle(CycleTheme.textColor.opacity(0.5))
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingProSheet) {
            ProUpgradeSheet(storeManager: storeManager)
        }
        .sheet(isPresented: $showingExportSheet) {
            if let url = exportURL {
                ShareSheetView(url: url)
            }
        }
        .alert("Delete All Data?", isPresented: $showingDeleteConfirmation) {
            Button("Delete Everything", role: .destructive) {
                deleteAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all your cycle data. This cannot be undone.")
        }
    }

    private func deleteAllData() {
        do {
            try modelContext.delete(model: PeriodEntry.self)
            try modelContext.delete(model: CustomSymptom.self)
        } catch {
            // Deletion failed
        }
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
