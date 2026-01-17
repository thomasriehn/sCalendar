import SwiftUI

struct YearlyView: View {
    @EnvironmentObject var calendarManager: CalendarManager

    private var currentYear: Int {
        Calendar.current.component(.year, from: calendarManager.currentWeekStart)
    }

    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 8
            let padding: CGFloat = 8
            let columns = 3
            let rows = 4
            let totalHorizontalSpacing = CGFloat(columns - 1) * spacing + padding * 2
            let totalVerticalSpacing = CGFloat(rows - 1) * spacing + padding * 2
            let cellWidth = (geometry.size.width - totalHorizontalSpacing) / CGFloat(columns)
            let cellHeight = (geometry.size.height - totalVerticalSpacing) / CGFloat(rows)

            VStack(spacing: spacing) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<columns, id: \.self) { col in
                            let month = row * columns + col + 1
                            YearMonthCell(year: currentYear, month: month)
                                .frame(width: cellWidth, height: cellHeight)
                        }
                    }
                }
            }
            .padding(padding)
            .background(Color(.systemBackground))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.height < -50 {
                            goToYear(currentYear + 1)
                        } else if value.translation.height > 50 {
                            goToYear(currentYear - 1)
                        }
                    }
            )
        }
    }

    private func goToYear(_ year: Int) {
        var components = DateComponents()
        components.year = year
        components.month = 1
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            calendarManager.goToDate(date)
        }
    }
}

struct YearMonthCell: View {
    @EnvironmentObject var calendarManager: CalendarManager
    let year: Int
    let month: Int

    private var weekStartsOnMonday: Bool {
        UserDefaults.standard.object(forKey: "weekStartsOnMonday") == nil ? true : UserDefaults.standard.bool(forKey: "weekStartsOnMonday")
    }

    private var monthDate: Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }

    private var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.currentLocale
        formatter.dateFormat = "MMM"
        return formatter.string(from: monthDate)
    }

    private var dayLabels: [String] {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.currentLocale
        let symbols = formatter.veryShortWeekdaySymbols ?? []
        if weekStartsOnMonday {
            return Array(symbols[1...]) + [symbols[0]]
        }
        return symbols
    }

    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        let firstDay = monthDate
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let daysCount = monthDate.daysInMonth()

        let offset: Int
        if weekStartsOnMonday {
            offset = (firstWeekday + 5) % 7
        } else {
            offset = firstWeekday - 1
        }

        var days: [Date?] = Array(repeating: nil, count: offset)

        for day in 0..<daysCount {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                days.append(date)
            }
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    var body: some View {
        VStack(spacing: 2) {
            // Month name
            Text(monthName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.blue)

            // Day labels
            HStack(spacing: 0) {
                ForEach(Array(dayLabels.enumerated()), id: \.offset) { index, day in
                    let isSunday = weekStartsOnMonday ? (index == 6) : (index == 0)
                    Text(day)
                        .font(.system(size: 7))
                        .foregroundColor(isSunday ? .red : .secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Days grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        YearDayCell(date: date)
                    } else {
                        Text("")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 8))
                    }
                }
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .cornerRadius(4)
    }
}

struct YearDayCell: View {
    @EnvironmentObject var calendarManager: CalendarManager
    let date: Date

    private var hasEvents: Bool {
        !calendarManager.events(for: date).isEmpty
    }

    private var isSunday: Bool {
        date.dayOfWeek == 1
    }

    var body: some View {
        Text("\(date.dayOfMonth)")
            .font(.system(size: 8, weight: hasEvents ? .bold : .regular))
            .foregroundColor(isSunday ? .red : (date.isToday ? .blue : .primary))
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    YearlyView()
        .environmentObject(CalendarManager())
}
