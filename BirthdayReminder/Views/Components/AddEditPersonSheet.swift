import SwiftUI

public struct AddEditPersonSheet: View {
    public let initialPerson: Person?
    public let onSave: (Person) -> Void
    public let onDismiss: () -> Void

    @State private var name: String
    @State private var birthdayDate: Date
    @State private var includesBirthYear: Bool
    @State private var birthYear: Int?
    @State private var reminderTime: Date
    @State private var socialPlatform: SocialPlatform
    @State private var phoneNumber: String
    @State private var customMessage: String
    @State private var errorMessage: String? = nil

    private let templates: [(label: String, text: String)] = [
        ("🎉 Classic", "Happy Birthday! Wishing you a fantastic day filled with joy, health, and success! 🎉🎂"),
        ("😂 Funny", "Happy Birthday! You're not getting older, you're just leveling up! 🎮 Cheers to another great year!"),
        ("💖 Heartfelt", "Happy Birthday! So grateful to have you in my life. Wishing you endless happiness, love, and laughter! ❤️"),
        ("✨ Short", "Happy Birthday! Have an amazing celebration today! 🥳🎈")
    ]

    public init(
        initialPerson: Person?,
        onSave: @escaping (Person) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.initialPerson = initialPerson
        self.onSave = onSave
        self.onDismiss = onDismiss

        _name = State(initialValue: initialPerson?.name ?? "")
        _socialPlatform = State(initialValue: initialPerson?.socialPlatform ?? .whatsapp)
        _phoneNumber = State(initialValue: initialPerson?.phoneNumber ?? "")
        _customMessage = State(initialValue: initialPerson?.customMessage ?? "Happy Birthday! Wishing you a fantastic day filled with joy, health, and success! 🎉🎂")

        let calendar = Calendar.current
        var bdayComp = DateComponents()
        bdayComp.year = initialPerson?.birthYear ?? calendar.component(.year, from: Date())
        bdayComp.month = initialPerson?.birthMonth ?? calendar.component(.month, from: Date())
        bdayComp.day = initialPerson?.birthDay ?? calendar.component(.day, from: Date())
        _birthdayDate = State(initialValue: calendar.date(from: bdayComp) ?? Date())
        _includesBirthYear = State(initialValue: initialPerson?.birthYear != nil)
        _birthYear = State(initialValue: initialPerson?.birthYear)

        var timeComp = DateComponents()
        timeComp.hour = initialPerson?.reminderHour ?? 9
        timeComp.minute = initialPerson?.reminderMinute ?? 0
        _reminderTime = State(initialValue: calendar.date(from: timeComp) ?? Date())
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Contact Info")) {
                    TextField("Full Name", text: $name)

                    Picker("Platform", selection: $socialPlatform) {
                        ForEach(SocialPlatform.allCases) { platform in
                            Label(platform.displayName, systemImage: platform.iconName)
                                .tag(platform)
                        }
                    }

                    TextField(
                        socialPlatform == .telegram ? "Telegram Username (e.g. @john)" : "Phone Number (with Country Code)",
                        text: $phoneNumber
                    )
                    .keyboardType(socialPlatform == .telegram ? .default : .phonePad)
                }

                Section(header: Text("Birthday Date")) {
                    DatePicker(
                        "Date of Birth",
                        selection: $birthdayDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)

                    Toggle("Include Birth Year (Calculate Age)", isOn: $includesBirthYear)
                }

                Section(header: Text("Reminder & Send Time")) {
                    DatePicker(
                        "Exact Notification Time",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                }

                Section(header: Text("Personalized Birthday Wish")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(templates, id: \.label) { template in
                                Button(action: {
                                    customMessage = template.text
                                }) {
                                    Text(template.label)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }

                    TextEditor(text: $customMessage)
                        .frame(minHeight: 100)
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(initialPerson == nil ? "Add Birthday" : "Edit Birthday")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMsg = customMessage.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter the person's name."
            return
        }
        guard !trimmedPhone.isEmpty else {
            errorMessage = "Please enter their phone number or Telegram handle."
            return
        }
        guard !trimmedMsg.isEmpty else {
            errorMessage = "Please enter a birthday wish message."
            return
        }

        let calendar = Calendar.current
        let month = calendar.component(.month, from: birthdayDate)
        let day = calendar.component(.day, from: birthdayDate)
        let year = includesBirthYear ? calendar.component(.year, from: birthdayDate) : nil

        let hour = calendar.component(.hour, from: reminderTime)
        let minute = calendar.component(.minute, from: reminderTime)

        var personToSave = initialPerson ?? Person()
        personToSave.name = trimmedName
        personToSave.birthMonth = month
        personToSave.birthDay = day
        personToSave.birthYear = year
        personToSave.reminderHour = hour
        personToSave.reminderMinute = minute
        personToSave.socialPlatform = socialPlatform
        personToSave.phoneNumber = trimmedPhone
        personToSave.customMessage = trimmedMsg

        onSave(personToSave)
    }
}
