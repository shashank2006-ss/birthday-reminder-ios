import SwiftUI

public struct QuickSendSheet: View {
    public let person: Person
    public let onDismiss: () -> Void

    @State private var editableMessage: String
    @State private var isSending = false
    @State private var sendStatusMessage: String? = nil

    private let templates: [(label: String, text: String)] = [
        ("🎉 Classic", "Happy Birthday! Wishing you a fantastic day filled with joy, health, and success! 🎉🎂"),
        ("😂 Funny", "Happy Birthday! You're not getting older, you're just leveling up! 🎮 Cheers to another great year!"),
        ("💖 Heartfelt", "Happy Birthday! So grateful to have you in my life. Wishing you endless happiness, love, and laughter! ❤️"),
        ("✨ Short", "Happy Birthday! Have an amazing celebration today! 🥳🎈")
    ]

    public init(person: Person, onDismiss: @escaping () -> Void) {
        self.person = person
        self.onDismiss = onDismiss
        _editableMessage = State(initialValue: person.customMessage)
    }

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Contact Details Header Card
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(person.socialPlatform.themeColor.opacity(0.18))
                            .frame(width: 50, height: 50)
                        Text(person.name.prefix(1).uppercased())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(person.socialPlatform.themeColor)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(person.name)
                            .font(.title3)
                            .fontWeight(.bold)

                        Text(person.phoneNumber.isEmpty ? "No contact info" : person.phoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Label(person.socialPlatform.displayName, systemImage: person.socialPlatform.iconName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(person.socialPlatform.themeColor.opacity(0.15))
                        .foregroundColor(person.socialPlatform.themeColor)
                        .clipShape(Capsule())
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(14)

                // Quick Templates
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Templates:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(templates, id: \.label) { template in
                                Button(action: {
                                    editableMessage = template.text
                                }) {
                                    Text(template.label)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray6))
                                        .foregroundColor(.primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }

                // Message Editor
                VStack(alignment: .leading, spacing: 6) {
                    Text("Review and edit your message before sending:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextEditor(text: $editableMessage)
                        .frame(minHeight: 120, maxHeight: 180)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }

                if let status = sendStatusMessage {
                    Text(status)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Big Action Send Button
                Button(action: send) {
                    HStack(spacing: 8) {
                        Image(systemName: "paperplane.fill")
                        Text("Send via \(person.socialPlatform.displayName)")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(person.socialPlatform.themeColor)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
            }
            .padding()
            .navigationTitle("Send Birthday Wish")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
            }
        }
    }

    private func send() {
        isSending = true
        MessagingManager.shared.sendWish(for: person, messageOverride: editableMessage) { success in
            DispatchQueue.main.async {
                isSending = false
                if success {
                    BirthdayStore.shared.markWishSent(for: person)
                    onDismiss()
                } else {
                    sendStatusMessage = "Opening \(person.socialPlatform.displayName)..."
                    BirthdayStore.shared.markWishSent(for: person)
                    onDismiss()
                }
            }
        }
    }
}
