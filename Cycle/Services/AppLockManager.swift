import Foundation
import LocalAuthentication
import Observation

@MainActor @Observable
final class AppLockManager {
    var isLocked = false
    private var lastBackgroundDate: Date?

    func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            isLocked = false
            return true
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Unlock Cycle"
            )
            if success {
                isLocked = false
            }
            return success
        } catch {
            return false
        }
    }

    func appDidEnterBackground() {
        lastBackgroundDate = Date()
    }

    func appWillEnterForeground(lockDelay: LockDelay, passcodeEnabled: Bool) {
        guard passcodeEnabled else { return }
        guard let lastBackground = lastBackgroundDate else {
            isLocked = true
            return
        }
        let elapsed = Date().timeIntervalSince(lastBackground)
        if elapsed >= lockDelay.seconds {
            isLocked = true
        }
    }

    func lockOnLaunch(passcodeEnabled: Bool) {
        if passcodeEnabled {
            isLocked = true
        }
    }
}
