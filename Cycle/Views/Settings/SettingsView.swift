import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsArray: [AppSettings]
    @Query(sort: \PeriodEntry.date) private var allEntries: [PeriodEntry]

    let storeManager: StoreManager
    var healthKitManager: HealthKitManager?

    @State private var showingProSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingExportSheet = false
    @State private var exportURL: URL?
    @State private var healthSyncStatus: String = ""
    @State private var isHealthSyncing = false

    private var settings: AppSettings {
        settingsArray.first ?? AppSettings()
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
                    set: { newValue in
                        if newValue {
                            Task {
                                let granted = await NotificationManager.requestPermission()
                                await MainActor.run {
                                    settings.notificationsEnabled = granted
                                }
                            }
                        } else {
                            settings.notificationsEnabled = false
                            NotificationManager.removeAll()
                        }
                    }
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

            if let healthKitManager {
                Section("Health") {
                    Button {
                        isHealthSyncing = true
                        Task {
                            let authorized = await healthKitManager.requestAuthorization()
                            if authorized {
                                let existingDates = Set(allEntries.map { $0.date.startOfDay })
                                let imported = await healthKitManager.importEntries(existingDates: existingDates)
                                await MainActor.run {
                                    for entry in imported {
                                        modelContext.insert(entry)
                                    }
                                    healthSyncStatus = imported.isEmpty ? "Synced — no new entries" : "Imported \(imported.count) entries"
                                    isHealthSyncing = false
                                }
                            } else {
                                await MainActor.run {
                                    healthSyncStatus = "Authorization denied — enable in Settings > Privacy > Health"
                                    isHealthSyncing = false
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Label("Sync with Apple Health", systemImage: "heart.fill")
                            Spacer()
                            if isHealthSyncing {
                                ProgressView()
                            } else if !healthSyncStatus.isEmpty {
                                Text(healthSyncStatus)
                                    .font(CycleTheme.captionFont)
                                    .foregroundStyle(CycleTheme.textColor.opacity(0.5))
                            }
                        }
                    }
                    .disabled(isHealthSyncing || !healthKitManager.isAvailable)

                    if !healthKitManager.isAvailable {
                        Text("Apple Health is not available on this device.")
                            .font(CycleTheme.captionFont)
                            .foregroundStyle(CycleTheme.textColor.opacity(0.5))
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

            Section("Privacy & Estimates") {
                Text("Cycle data is stored on this device. When you choose to sync with Apple Health, Cycle reads menstrual-flow entries from Apple Health.")
                    .font(CycleTheme.captionFont)
                    .foregroundStyle(CycleTheme.textColor.opacity(0.5))

                Text("Period timing and fertile-window estimates use averages from your logged cycles. They are not medical advice or a contraceptive method.")
                    .font(CycleTheme.captionFont)
                    .foregroundStyle(CycleTheme.textColor.opacity(0.5))
            }

            Section("About") {
                LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")

                Link(destination: URL(string: "https://github.com/quinnbot-ai/cycle")!) {
                    Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            if settingsArray.isEmpty {
                modelContext.insert(AppSettings())
            }
        }
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
