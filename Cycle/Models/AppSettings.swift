import Foundation
import SwiftData

@Model
final class AppSettings {
    var averageWindowSize: Int
    var passcodeEnabled: Bool
    var lockDelayRaw: Int
    var notificationsEnabled: Bool
    var periodReminderDays: Int
    var logReminderTime: Date?

    var lockDelay: LockDelay {
        get { LockDelay(rawValue: lockDelayRaw) ?? .immediately }
        set { lockDelayRaw = newValue.rawValue }
    }

    init() {
        self.averageWindowSize = 6
        self.passcodeEnabled = false
        self.lockDelayRaw = LockDelay.immediately.rawValue
        self.notificationsEnabled = false
        self.periodReminderDays = 2
        self.logReminderTime = nil
    }
}
