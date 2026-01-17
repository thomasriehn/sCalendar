import SwiftUI

struct MiniMonthView: View {
    @EnvironmentObject var calendarManager: CalendarManager

    private var displayedMonth: Date {
        calendarManager.currentWeekStart
    }

    private var weekStartsOnMonday: Bool {
        UserDefaults.standard.object(forKey: "weekStartsOnMonday") == nil ? true : UserDefaults.standard.bool(forKey: "weekStartsOnMonday")
    }

    private var dayLabels: [String] {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.currentLocale
        let symbols = formatter.veryShortWeekdaySymbols ?? []
        // Reorder based on week start setting
        if weekStartsOnMonday {
            // Monday first: Mon, Tue, Wed, Thu, Fri, Sat, Sun
            return Array(symbols[1...]) + [symbols[0]]
        }
        return symbols
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.currentLocale
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        let firstDay = displayedMonth.startOfMonth
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let daysCount = displayedMonth.daysInMonth()

        // Calculate offset based on week start setting
        let offset: Int
        if weekStartsOnMonday {
            // Monday = 0, Tuesday = 1, ..., Sunday = 6
            offset = (firstWeekday + 5) % 7
        } else {
            // Sunday = 0, Monday = 1, ..., Saturday = 6
            offset = firstWeekday - 1
        }

        var days: [Date?] = Array(repeating: nil, count: offset)

        for day in 0..<daysCount {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                days.append(date)
            }
        }

        // Fill remaining cells to complete the grid
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    var body: some View {
        VStack(spacing: 2) {
            // Month header
            HStack {
                Text(monthTitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(Color.blue)

            // Day labels
            HStack(spacing: 0) {
                ForEach(Array(dayLabels.enumerated()), id: \.offset) { index, day in
                    let isSunday = weekStartsOnMonday ? (index == 6) : (index == 0)
                    Text(day)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(isSunday ? .red : .primary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        DayNumber(
                            date: date,
                            isToday: date.isToday,
                            isSelected: date.isSameWeek(as: calendarManager.currentWeekStart),
                            hasEvents: !calendarManager.events(for: date).isEmpty
                        )
                        .onTapGesture {
                            calendarManager.goToDate(date)
                        }
                    } else {
                        Text("")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.blue, lineWidth: 1)
        )
    }
}

struct DayNumber: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let hasEvents: Bool

    private var textColor: Color {
        if isToday {
            return .white
        } else if date.dayOfWeek == 1 {
            return .red
        } else if isSelected {
            return .blue
        }
        return .primary
    }

    var body: some View {
        Text("\(date.dayOfMonth)")
            .font(.system(size: 10))
            .foregroundColor(textColor)
            .frame(width: 18, height: 18)
            .background(
                Group {
                    if isToday {
                        Circle().fill(Color.green)
                    } else if isSelected {
                        Circle().stroke(Color.blue, lineWidth: 1)
                    }
                }
            )
    }
}

#Preview {
    MiniMonthView()
        .frame(width: 180)
        .padding()
        .environmentObject(CalendarManager())
}
