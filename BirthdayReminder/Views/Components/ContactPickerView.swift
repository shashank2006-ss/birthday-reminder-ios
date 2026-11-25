import SwiftUI
import ContactsUI

public class ContactPickerLauncher: NSObject, CNContactPickerDelegate {
    public static let shared = ContactPickerLauncher()

    private var onSelect: ((String, String, DateComponents?) -> Void)?

    private override init() {
        super.init()
    }

    public func present(onSelect: @escaping (String, String, DateComponents?) -> Void) {
        self.onSelect = onSelect

        DispatchQueue.main.async {
            guard let topVC = Self.getTopViewController() else { return }
            let picker = CNContactPickerViewController()
            picker.delegate = self
            picker.displayedPropertyKeys = [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactPhoneNumbersKey,
                CNContactBirthdayKey
            ]
            topVC.present(picker, animated: true)
        }
    }

    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let fullName = [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(separator: " ")
        let phone = contact.phoneNumbers.first?.value.stringValue ?? ""
        let birthday = contact.birthday

        onSelect?(fullName, phone, birthday)
        onSelect = nil
    }

    public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        onSelect = nil
    }

    private static func getTopViewController(base: UIViewController? = nil) -> UIViewController? {
        let root: UIViewController? = base ?? {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            return scenes.flatMap { $0.windows }.first { $0.isKeyWindow }?.rootViewController
        }()

        if let nav = root as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController {
            return getTopViewController(base: tab.selectedViewController)
        }
        if let presented = root?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return root
    }
}
