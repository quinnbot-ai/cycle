import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var settingsArray: [AppSettings]
    @Query(sort: \PeriodEntry.date, order: .forward) private var allEntries: [PeriodEntry]

    let lockManager: AppLockManager
    let storeManager: StoreManager
    let healthKitManager: HealthKitManager

    @State private var showFirstLaunch = false

    private var settings: AppSettings? {
        settingsArray.first
    }

    var body: some View {
        ZStack {
            TabView {
                TodayView(storeManager: storeManager)
                    .tabItem {
                        Label("Today", systemImage: "circle.fill")
                    }

                CycleCalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }

                InsightsView(storeManager: storeManager)
                    .tabItem {
                        Label("Insights", systemImage: "chart.xyaxis.line")
                    }
            }
            .tint(CycleTheme.primaryColor)

            if lockManager.isLocked {
                LockScreenView(lockManager: lockManager)
            }
        }
        .onAppear {
            if settings == nil {
                showFirstLaunch = true
            } else {
                lockManager.lockOnLaunch(passcodeEnabled: settings?.passcodeEnabled ?? false)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active, let settings {
                lockManager.appWillEnterForeground(
                    lockDelay: settings.lockDelay,
                    passcodeEnabled: settings.passcodeEnabled
                )
            }
            if newPhase == .background {
                lockManager.appDidEnterBackground()
                updateWidgetData()
                updateNotifications()
            }
        }
        .sheet(isPresented: $showFirstLaunch) {
            FirstLaunchSheet()
        }
    }

    private func updateWidgetData() {
        let cycles = CycleCalculator.deriveCycles(from: allEntries)
        let cycleDay = CycleCalculator.currentCycleDay(cycles: cycles)
        let prediction = PredictionEngine.predict(from: cycles, windowSize: settings?.averageWindowSize ?? 6)

        var daysUntil: Int?
        var nextDateString: String?
        if let prediction {
            daysUntil = Date().startOfDay.daysBetween(prediction.nextPeriodDate)
            nextDateString = prediction.nextPeriodDate.shortDateString
        }

        SharedData.update(
            cycleDay: cycleDay,
            daysUntilPeriod: daysUntil,
            nextPeriodDateString: nextDateString
        )
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func updateNotifications() {
        guard let settings, settings.notificationsEnabled else {
            NotificationManager.removeAll()
            return
        }

        let cycles = CycleCalculator.deriveCycles(from: allEntries)
        let prediction = PredictionEngine.predict(from: cycles, windowSize: settings.averageWindowSize)

        if let prediction {
            NotificationManager.schedulePeriodReminder(
                nextPeriodDate: prediction.nextPeriodDate,
                daysBefore: settings.periodReminderDays
            )
        }

        if let logTime = settings.logReminderTime {
            NotificationManager.scheduleLogReminder(at: logTime)
        }
    }
}
