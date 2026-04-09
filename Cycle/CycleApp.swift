import SwiftUI
import SwiftData
import WidgetKit

@main
struct CycleApp: App {
    @State private var lockManager = AppLockManager()
    @State private var storeManager = StoreManager()
    @State private var healthKitManager = HealthKitManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(
                lockManager: lockManager,
                storeManager: storeManager,
                healthKitManager: healthKitManager
            )
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleScenePhase(old: oldPhase, new: newPhase)
            }
        }
        .modelContainer(for: [PeriodEntry.self, CustomSymptom.self, AppSettings.self])
    }

    private func handleScenePhase(old: ScenePhase, new: ScenePhase) {
        switch new {
        case .background:
            lockManager.appDidEnterBackground()
        case .active, .inactive:
            break
        @unknown default:
            break
        }
    }
}
