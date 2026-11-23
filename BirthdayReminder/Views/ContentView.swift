import SwiftUI

public struct ContentView: View {
    @StateObject private var store = BirthdayStore.shared
    @StateObject private var notificationManager = NotificationManager.shared

    @State private var selectedTab = 0
    @State private var showingAddSheet = false
    @State private var personToEdit: Person? = nil
    @State private var personToQuickSend: Person? = nil

    private var nextBirthdayText: String? {
        guard let first = store.people.first else { return nil }
        if first.daysRemaining == 0 {
            return "🎉 Today is \(first.name)'s birthday!"
        } else if first.daysRemaining == 1 {
            return "Next: \(first.name) tomorrow"
        } else {
            return "Next: \(first.name) in \(first.daysRemaining) days"
        }
    }

    public var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                UpcomingListView(
                    store: store,
                    onSend: { person in personToQuickSend = person },
                    onEdit: { person in personToEdit = person },
                    onAddFirst: { showingAddSheet = true }
                )
                .tabItem {
                    Label("Upcoming", systemImage: "list.bullet")
                }
                .tag(0)

                CalendarMonthView(
                    store: store,
                    onSelectPerson: { person in personToQuickSend = person }
                )
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)
            }
            .navigationTitle("🎂 Birthday Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("🎂 Birthday Reminder")
                            .font(.headline)
                        if let sub = nextBirthdayText {
                            Text(sub)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEditPersonSheet(
                    initialPerson: nil,
                    onSave: { newPerson in
                        showingAddSheet = false
                        store.addOrUpdate(newPerson)
                    },
                    onDismiss: { showingAddSheet = false }
                )
            }
            .sheet(item: $personToEdit) { person in
                AddEditPersonSheet(
                    initialPerson: person,
                    onSave: { updated in
                        personToEdit = nil
                        store.addOrUpdate(updated)
                    },
                    onDismiss: { personToEdit = nil }
                )
            }
            .sheet(item: $personToQuickSend) { person in
                QuickSendSheet(
                    person: person,
                    onDismiss: { personToQuickSend = nil }
                )
            }
            .onChange(of: notificationManager.pendingQuickSendPersonId) { newId in
                guard let id = newId, let person = store.person(with: id) else { return }
                personToQuickSend = person
                notificationManager.pendingQuickSendPersonId = nil
            }
        }
    }
}
