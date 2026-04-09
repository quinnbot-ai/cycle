import Foundation
import UserNotifications

enum NotificationManager {
    static let periodReminderID = "com.cycleapp.period-reminder"
    static let logReminderID = "com.cycleapp.log-reminder"

    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func schedulePeriodReminder(nextPeriodDate: Date, daysBefore: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [periodReminderID])

        let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: nextPeriodDate)!
        guard triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Period coming up"
        content.body = daysBefore == 1
            ? "Your period is expected tomorrow."
            : "Your period is expected in \(daysBefore) days."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)
        var triggerComponents = components
        triggerComponents.hour = 9

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: periodReminderID, content: content, trigger: trigger)
        center.add(request)
    }

    static func scheduleLogReminder(at time: Date) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [logReminderID])

        let content = UNMutableNotificationContent()
        content.title = "Log your day"
        content.body = "Take a moment to log how you're feeling."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: logReminderID, content: content, trigger: trigger)
        center.add(request)
    }

    static func removeAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [periodReminderID, logReminderID]
        )
    }
}
