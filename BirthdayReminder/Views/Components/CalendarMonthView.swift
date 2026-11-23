import SwiftUI

public struct CalendarMonthView: View {
    @ObservedObject var store: BirthdayStore
    public let onSelectPerson: (Person) -> Void

    @State private var monthOffset: Int = 0
    @State private var selectedDay: Int = Calendar.current.component(.day, from: Date())

    private var currentCalendar: Calendar { Calendar.current }

    private var targetMonthDate: Date {
        currentCalendar.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }

    private var targetMonth: Int {
        currentCalendar.component(.month, from: targetMonthDate)
    }

    private var targetYear: Int {
        currentCalendar.component(.year, from: targetMonthDate)
    }

    private var monthName: String {
        let formatter = DateFormatter()
        return formatter.monthSymbols[max(0, min(11, targetMonth - 1))]
    }

    private var birthdaysInTargetMonth: [Person] {
        store.people.filter { $0.birthMonth == targetMonth }
    }

    private var birthdaysOnSelectedDay: [Person] {
        birthdaysInTargetMonth.filter { $0.birthDay == selectedDay }
    }

    public init(store: BirthdayStore, onSelectPerson: @escaping (Person) -> Void) {
        self.store = store
        self.onSelectPerson = onSelectPerson
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Calendar Card
                VStack(spacing: 12) {
                    // Header: Month Navigation
                    HStack {
                        Button(action: { monthOffset -= 1 }) {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(8)
                        }

                        Spacer()

                        Text("\(monthName) \(String(targetYear))")
                            .font(.title3)
                            .fontWeight(.bold)

                        Spacer()

                        Button(action: { monthOffset += 1 }) {
                            Image(systemName: "chevron.right")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(8)
                        }
                    }

                    // Weekday Labels
                    let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                    HStack {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    // Days Grid
                    let daysGrid = generateDaysGrid()
                    VStack(spacing: 6) {
                        ForEach(0..<daysGrid.count, id: \.self) { row in
                            HStack(spacing: 4) {
                                ForEach(0..<7, id: \.self) { col in
                                    let day = daysGrid[row][col]
                                    if day > 0 {
                                        dayCell(day: day)
                                    } else {
                                        Color.clear
                                            .frame(maxWidth: .infinity, minHeight: 38)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(18)
                .padding(.horizontal)

                // Selected Day Birthdays Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Birthdays on \(monthName) \(selectedDay)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    if birthdaysOnSelectedDay.isEmpty {
                        Text("No birthdays scheduled on this day.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 4)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(birthdaysOnSelectedDay) { person in
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(person.name)
                                            .font(.subheadline)
                                            .fontWeight(.bold)

                                        HStack(spacing: 6) {
                                            Label(person.formattedReminderTime, systemImage: "alarm.fill")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)

                                            Label(person.socialPlatform.displayName, systemImage: person.socialPlatform.iconName)
                                                .font(.caption2)
                                                .foregroundColor(person.socialPlatform.themeColor)
                                        }
                                    }

                                    Spacer()

                                    Button(action: { onSelectPerson(person) }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "paperplane.fill")
                                                .font(.caption2)
                                            Text("Send Wish")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(person.socialPlatform.themeColor)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(.vertical)
        }
    }

    @ViewBuilder
    private func dayCell(day: Int) -> some View {
        let isSelected = selectedDay == day
        let peopleOnThisDay = birthdaysInTargetMonth.filter { $0.birthDay == day }
        let hasBirthdays = !peopleOnThisDay.isEmpty

        Button(action: { selectedDay = day }) {
            VStack(spacing: 2) {
                Text("\(day)")
                    .font(.caption)
                    .fontWeight(isSelected || hasBirthdays ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : (hasBirthdays ? .accentColor : .primary))

                if hasBirthdays {
                    Circle()
                        .fill(isSelected ? .white : Color.orange)
                        .frame(width: 5, height: 5)
                } else {
                    Spacer().frame(height: 5)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 38)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : (hasBirthdays ? Color.orange.opacity(0.12) : Color.clear))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func generateDaysGrid() -> [[Int]] {
        var grid: [[Int]] = []
        guard let firstDayOfMonth = currentCalendar.date(from: DateComponents(year: targetYear, month: targetMonth, day: 1)),
              let range = currentCalendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return grid
        }

        let firstWeekday = currentCalendar.component(.weekday, from: firstDayOfMonth) // 1 (Sun) - 7 (Sat)
        let totalDays = range.count

        var currentWeek = Array(repeating: 0, count: 7)
        var dayCounter = 1

        for col in (firstWeekday - 1)..<7 {
            currentWeek[col] = dayCounter
            dayCounter += 1
        }
        grid.append(currentWeek)

        while dayCounter <= totalDays {
            var week = Array(repeating: 0, count: 7)
            for col in 0..<7 {
                if dayCounter <= totalDays {
                    week[col] = dayCounter
                    dayCounter += 1
                }
            }
            grid.append(week)
        }

        return grid
    }
}
