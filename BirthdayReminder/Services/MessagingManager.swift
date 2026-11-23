import Foundation
import UIKit
import MessageUI

public class MessagingManager {
    public static let shared = MessagingManager()

    private init() {}

    /// Dispatches the message to the configured platform
    public func sendWish(
        for person: Person,
        messageOverride: String? = nil,
        completion: ((Bool) -> Void)? = nil
    ) {
        let message = (messageOverride ?? person.customMessage).trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneOrHandle = person.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        switch person.socialPlatform {
        case .whatsapp:
            openWhatsApp(phone: phoneOrHandle, message: message, completion: completion)
        case .sms:
            openSMS(phone: phoneOrHandle, message: message, completion: completion)
        case .telegram:
            openTelegram(recipient: phoneOrHandle, message: message, completion: completion)
        }
    }

    /// Opens WhatsApp with recipient and prefilled message
    public func openWhatsApp(phone: String, message: String, completion: ((Bool) -> Void)? = nil) {
        let cleanedPhone = cleanPhoneNumber(phone)
        guard let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion?(false)
            return
        }

        // Try native app scheme first
        let appUrlString = "whatsapp://send?phone=\(cleanedPhone)&text=\(encodedMessage)"
        let webUrlString = "https://api.whatsapp.com/send?phone=\(cleanedPhone)&text=\(encodedMessage)"

        if let appUrl = URL(string: appUrlString), UIApplication.shared.canOpenURL(appUrl) {
            UIApplication.shared.open(appUrl, options: [:]) { success in
                completion?(success)
            }
        } else if let webUrl = URL(string: webUrlString) {
            UIApplication.shared.open(webUrl, options: [:]) { success in
                completion?(success)
            }
        } else {
            completion?(false)
        }
    }

    /// Opens SMS / iMessage with prefilled recipient and message
    public func openSMS(phone: String, message: String, completion: ((Bool) -> Void)? = nil) {
        let cleanedPhone = cleanPhoneNumber(phone)
        guard let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion?(false)
            return
        }

        // iOS SMS URL scheme
        let urlString = "sms:\(cleanedPhone)&body=\(encodedMessage)"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                completion?(success)
            }
        } else {
            completion?(false)
        }
    }

    /// Opens Telegram chat with prefilled message
    public func openTelegram(recipient: String, message: String, completion: ((Bool) -> Void)? = nil) {
        let handle = recipient.replacingOccurrences(of: "@", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion?(false)
            return
        }

        let urlString: String
        if !handle.isEmpty && !handle.allSatisfy({ $0.isNumber }) {
            urlString = "tg://resolve?domain=\(handle)"
        } else {
            urlString = "tg://msg?text=\(encodedMessage)"
        }

        if let appUrl = URL(string: urlString), UIApplication.shared.canOpenURL(appUrl) {
            UIApplication.shared.open(appUrl, options: [:]) { success in
                completion?(success)
            }
        } else if let webUrl = URL(string: "https://t.me/\(handle)") {
            UIApplication.shared.open(webUrl, options: [:]) { success in
                completion?(success)
            }
        } else {
            completion?(false)
        }
    }

    /// Clean phone number to digits and leading +
    private func cleanPhoneNumber(_ phone: String) -> String {
        return phone.filter { "0123456789+".contains($0) }
    }
}
