import Foundation

public struct Person: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var name: String
    public var birthMonth: Int // 1...12
    public var birthDay: Int   // 1...31
    public var birthYear: Int? // Optional
    public var reminderHour: Int   // 0...23
    public var reminderMinute: Int // 0...59
    public var phoneNumber: String
    public var socialPlatform: SocialPlatform
    public var customMessage: String
    public var isEnabled: Bool
    public var lastSentYear: Int

    public init(
        id: UUID = UUID(),
        name: String = "",
        birthMonth: Int = 1,
        birthDay: Int = 1,
        birthYear: Int? = nil,
        reminderHour: Int = 9,
        reminderMinute: Int = 0,
        phoneNumber: String = "",
        socialPlatform: SocialPlatform = .whatsapp,
        customMessage: String = "Happy Birthday! Wishing you a fantastic day filled with joy, health, and success! 🎉🎂",
        isEnabled: Bool = true,
        lastSentYear: Int = 0
    ) {
        self.id = id
        self.name = name
        self.birthMonth = birthMonth
        self.birthDay = birthDay
        self.birthYear = birthYear
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.phoneNumber = phoneNumber
        self.socialPlatform = socialPlatform
        self.customMessage = customMessage
        self.isEnabled = isEnabled
        self.lastSentYear = lastSentYear
    }

    /// Days remaining until the next birthday (0 = Today!)
    public var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let currentYear = calendar.component(.year, from: today)

        var components = DateComponents()
        components.year = currentYear
        components.month = birthMonth
        components.day = birthDay

        guard var bdayDate = calendar.date(from: components) else { return 0 }
        if bdayDate < today {
            components.year = currentYear + 1
            bdayDate = calendar.date(from: components) ?? bdayDate
        }

        let diff = calendar.dateComponents([.day], from: today, to: bdayDate)
        return max(0, diff.day ?? 0)
    }

    /// Next exact notification trigger date
    public var nextReminderDate: Date {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)

        var components = DateComponents()
        components.year = currentYear
        components.month = birthMonth
        components.day = birthDay
        components.hour = reminderHour
        components.minute = reminderMinute
        components.second = 0

        guard var targetDate = calendar.date(from: components) else { return now }
        if targetDate <= now {
            components.year = currentYear + 1
            targetDate = calendar.date(from: components) ?? targetDate
        }
        return targetDate
    }

    /// Formatted date, e.g., "Oct 14"
    public var formattedBirthday: String {
        let formatter = DateFormatter()
        let monthName = formatter.shortMonthSymbols[max(0, min(11, birthMonth - 1))]
        return "\(monthName) \(birthDay)"
    }

    /// Formatted reminder time, e.g., "09:00 AM"
    public var formattedReminderTime: String {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = reminderHour
        components.minute = reminderMinute
        guard let date = calendar.date(from: components) else {
            return String(format: "%02d:%02d", reminderHour, reminderMinute)
        }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Calculates turning age if birthYear is known
    public var turningAge: Int? {
        guard let year = birthYear else { return nil }
        let nextYear = Calendar.current.component(.year, from: nextReminderDate)
        let age = nextYear - year
        return age > 0 ? age : nil
    }
}
