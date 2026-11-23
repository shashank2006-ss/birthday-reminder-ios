import SwiftUI

public enum SocialPlatform: String, Codable, CaseIterable, Identifiable {
    case whatsapp = "WhatsApp"
    case sms = "SMS / iMessage"
    case telegram = "Telegram"

    public var id: String { rawValue }

    public var displayName: String { rawValue }

    public var iconName: String {
        switch self {
        case .whatsapp:
            return "message.badge.filled.fill"
        case .sms:
            return "message.fill"
        case .telegram:
            return "paperplane.fill"
        }
    }

    public var themeColor: Color {
        switch self {
        case .whatsapp:
            return Color(red: 0.15, green: 0.83, blue: 0.40) // WhatsApp Green #25D366
        case .sms:
            return Color(red: 0.20, green: 0.50, blue: 0.98) // iMessage Blue
        case .telegram:
            return Color(red: 0.00, green: 0.53, blue: 0.80) // Telegram Blue #0088CC
        }
    }
}
