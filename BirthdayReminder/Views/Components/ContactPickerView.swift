import SwiftUI
import ContactsUI

public struct ContactPickerView: UIViewControllerRepresentable {
    public var onSelectContact: (String, String, DateComponents?) -> Void
    public var onDismiss: () -> Void

    public init(
        onSelectContact: @escaping (String, String, DateComponents?) -> Void,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.onSelectContact = onSelectContact
        self.onDismiss = onDismiss
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.displayedPropertyKeys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactBirthdayKey
        ]
        return picker
    }

    public func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    public class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPickerView

        init(_ parent: ContactPickerView) {
            self.parent = parent
        }

        public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let fullName = [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(separator: " ")
            let phone = contact.phoneNumbers.first?.value.stringValue ?? ""
            let birthday = contact.birthday
            parent.onSelectContact(fullName, phone, birthday)
        }

        public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.onDismiss()
        }
    }
}
