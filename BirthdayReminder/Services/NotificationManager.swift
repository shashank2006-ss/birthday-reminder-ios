import Foundation
import UserNotifications
import Combine

public class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()

    public static let categoryId = "BIRTHDAY_CATEGORY"
    public static let actionSendNow = "ACTION_SEND_NOW"
    public static let actionEdit = "ACTION_EDIT_MESSAGE"

    @Published public var pendingQuickSendPersonId: UUID? = nil
    @Published public var shouldAutoSendPending: Bool = false

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        registerCategories()
    }

    public func requestAuthorization(completion: @escaping (Bool) -> Void = { _ in }) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    private func registerCategories() {
        let sendAction = UNNotificationAction(
            identifier: Self.actionSendNow,
            title: "🚀 Send Wish Now",
            options: [.foreground]
        )

        let editAction = UNNotificationAction(
            identifier: Self.actionEdit,
            title: "✏️ Edit & Send",
            options: [.foreground]
        )

        let category = UNNotificationCategory(
            identifier: Self.categoryId,
            actions: [sendAction, editAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    public func scheduleNotification(for person: Person) {
        guard person.isEnabled else {
            cancelNotification(for: person)
            return
        }

        let center = UNUserNotificationCenter.current()
        let identifier = person.id.uuidString

        let content = UNMutableNotificationContent()
        let ageStr = person.turningAge.map { " (Turns \($0))" } ?? ""
        content.title = "🎉 Today is \(person.name)'s Birthday!\(ageStr)"
        content.body = person.customMessage
        content.sound = .default
        content.categoryIdentifier = Self.categoryId
        content.userInfo = [
            "personId": person.id.uuidString,
            "platform": person.socialPlatform.rawValue
        ]

        var dateComponents = DateComponents()
        dateComponents.month = person.birthMonth
        dateComponents.day = person.birthDay
        dateComponents.hour = person.reminderHour
        dateComponents.minute = person.reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification for \(person.name): \(error)")
            } else {
                print("Successfully scheduled birthday alarm for \(person.name) at \(person.formattedReminderTime) on \(person.formattedBirthday)")
            }
        }
    }

    public func cancelNotification(for person: Person) {
        let identifier = person.id.uuidString
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    public func rescheduleAll(people: [Person]) {
        for person in people {
            scheduleNotification(for: person)
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner and play sound even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let idString = userInfo["personId"] as? String, let uuid = UUID(uuidString: idString) {
            DispatchQueue.main.async {
                self.pendingQuickSendPersonId = uuid
                if response.actionIdentifier == Self.actionSendNow {
                    self.shouldAutoSendPending = true
                } else {
                    self.shouldAutoSendPending = false
                }
            }
        }
        completionHandler()
    }
}
