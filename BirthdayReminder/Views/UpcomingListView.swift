import SwiftUI

public struct UpcomingListView: View {
    @ObservedObject var store: BirthdayStore
    public let onSend: (Person) -> Void
    public let onEdit: (Person) -> Void
    public let onAddFirst: () -> Void

    @State private var searchText = ""

    private var filteredPeople: [Person] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return store.people
        } else {
            return store.people.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.phoneNumber.localizedCaseInsensitiveContains(searchText) ||
                $0.formattedBirthday.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    public init(
        store: BirthdayStore,
        onSend: @escaping (Person) -> Void,
        onEdit: @escaping (Person) -> Void,
        onAddFirst: @escaping () -> Void
    ) {
        self.store = store
        self.onSend = onSend
        self.onEdit = onEdit
        self.onAddFirst = onAddFirst
    }

    public var body: some View {
        VStack(spacing: 0) {
            if store.people.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(filteredPeople) { person in
                        PersonCardView(
                            person: person,
                            onSend: { onSend(person) },
                            onEdit: { onEdit(person) },
                            onDelete: { store.delete(person: person) },
                            onToggleEnabled: { store.toggleEnabled(for: person) }
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.delete(person: person)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                onEdit(person)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.orange)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                store.toggleEnabled(for: person)
                            } label: {
                                Label(person.isEnabled ? "Mute" : "Unmute", systemImage: person.isEnabled ? "bell.slash" : "bell")
                            }
                            .tint(.purple)
                        }
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search name, phone, or date...")
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "gift.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor.opacity(0.8))

            Text("No Birthdays Added Yet")
                .font(.title2)
                .fontWeight(.bold)

            Text("Add friends and family to automatically receive notifications and send personalized wishes via WhatsApp, SMS, or Telegram.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: onAddFirst) {
                Label("Add First Birthday", systemImage: "plus.circle.fill")
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 8)

            Spacer()
        }
    }
}
