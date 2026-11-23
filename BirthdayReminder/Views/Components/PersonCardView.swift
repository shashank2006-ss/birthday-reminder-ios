import SwiftUI

public struct PersonCardView: View {
    public let person: Person
    public let onSend: () -> Void
    public let onEdit: () -> Void
    public let onDelete: () -> Void
    public let onToggleEnabled: () -> Void

    public init(
        person: Person,
        onSend: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onToggleEnabled: @escaping () -> Void
    ) {
        self.person = person
        self.onSend = onSend
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onToggleEnabled = onToggleEnabled
    }

    private var isToday: Bool { person.daysRemaining == 0 }
    private var isTomorrow: Bool { person.daysRemaining == 1 }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row: Avatar, Name, Age, Days Remaining
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(person.socialPlatform.themeColor.opacity(0.18))
                        .frame(width: 48, height: 48)
                    Text(person.name.prefix(1).uppercased())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(person.socialPlatform.themeColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(person.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(1)

                        if !person.isEnabled {
                            Image(systemName: "bell.slash.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack(spacing: 6) {
                        Text(person.formattedBirthday)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let age = person.turningAge {
                            Text("• Turns \(age)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)
                        }
                    }
                }

                Spacer()

                // Days Remaining Pill
                Text(countdownLabel)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(countdownBackground)
                    .foregroundColor(countdownTextColor)
                    .clipShape(Capsule())
            }

            // Tags Row: Reminder Time & Social Platform
            HStack(spacing: 8) {
                Label(person.formattedReminderTime, systemImage: "alarm.fill")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)

                Label(person.socialPlatform.displayName, systemImage: person.socialPlatform.iconName)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(person.socialPlatform.themeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(person.socialPlatform.themeColor.opacity(0.12))
                    .cornerRadius(6)
            }

            // Message Preview
            Text("\"\(person.customMessage)\"")
                .font(.footnote)
                .foregroundColor(.secondary)
                .italic()
                .lineLimit(2)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            // Action Row
            HStack {
                Button(action: onSend) {
                    HStack(spacing: 6) {
                        Image(systemName: "paperplane.fill")
                            .font(.caption)
                        Text("Send Wish")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(person.socialPlatform.themeColor)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                Button(action: onToggleEnabled) {
                    Image(systemName: person.isEnabled ? "bell.fill" : "bell.slash.fill")
                        .foregroundColor(person.isEnabled ? .accentColor : .gray)
                        .padding(8)
                }

                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.secondary)
                        .padding(8)
                }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.8))
                        .padding(8)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isToday ? Color.accentColor.opacity(0.08) : Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isToday ? Color.accentColor.opacity(0.3) : Color(.systemGray5), lineWidth: 1)
        )
    }

    private var countdownLabel: String {
        if isToday {
            return "Today! 🎉"
        } else if isTomorrow {
            return "Tomorrow"
        } else {
            return "In \(person.daysRemaining) days"
        }
    }

    private var countdownBackground: Color {
        if isToday {
            return Color.red
        } else if isTomorrow {
            return Color.orange
        } else {
            return Color(.systemGray5)
        }
    }

    private var countdownTextColor: Color {
        if isToday || isTomorrow {
            return .white
        } else {
            return .primary
        }
    }
}
