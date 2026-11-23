import Foundation
import SwiftUI

@MainActor
public class BirthdayStore: ObservableObject {
    public static let shared = BirthdayStore()

    private let defaultsKey = "saved_birthday_people_v1"

    @Published public var people: [Person] = [] {
        didSet {
            saveToStorage()
        }
    }

    public init() {
        loadFromStorage()
    }

    private func loadFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else {
            self.people = []
            return
        }
        do {
            let decoded = try JSONDecoder().decode([Person].self, from: data)
            self.people = decoded.sorted { $0.daysRemaining < $1.daysRemaining }
        } catch {
            print("Failed to decode people: \(error)")
            self.people = []
        }
    }

    private func saveToStorage() {
        do {
            let encoded = try JSONEncoder().encode(people)
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
        } catch {
            print("Failed to encode people: \(error)")
        }
    }

    public func addOrUpdate(_ person: Person) {
        if let index = people.firstIndex(where: { $0.id == person.id }) {
            people[index] = person
        } else {
            people.append(person)
        }
        people.sort { $0.daysRemaining < $1.daysRemaining }
        NotificationManager.shared.scheduleNotification(for: person)
    }

    public func delete(at offsets: IndexSet) {
        for index in offsets {
            let person = people[index]
            NotificationManager.shared.cancelNotification(for: person)
        }
        people.remove(atOffsets: offsets)
    }

    public func delete(person: Person) {
        NotificationManager.shared.cancelNotification(for: person)
        people.removeAll { $0.id == person.id }
    }

    public func toggleEnabled(for person: Person) {
        guard let index = people.firstIndex(where: { $0.id == person.id }) else { return }
        people[index].isEnabled.toggle()
        let updated = people[index]
        if updated.isEnabled {
            NotificationManager.shared.scheduleNotification(for: updated)
        } else {
            NotificationManager.shared.cancelNotification(for: updated)
        }
    }

    public func markWishSent(for person: Person) {
        guard let index = people.firstIndex(where: { $0.id == person.id }) else { return }
        let currentYear = Calendar.current.component(.year, from: Date())
        people[index].lastSentYear = currentYear
    }

    public func person(with id: UUID) -> Person? {
        return people.first { $0.id == id }
    }
}
