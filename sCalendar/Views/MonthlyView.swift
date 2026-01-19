import SwiftUI

struct MonthlyView: View {
    @EnvironmentObject var calendarManager: CalendarManager

    private var weekStartsOnMonday: Bool {
        UserDefaults.standard.object(forKey: "weekStartsOnMonday") == nil ? true : UserDefaults.standard.bool(forKey: "weekStartsOnMonday")
    }

    private var displayedMonth: Date {
        calendarManager.currentWeekStart.startOfMonth
    }

    private var dayLabels: [String] {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.currentLocale
        let symbols = formatter.shortWeekdaySymbols ?? []
        if weekStartsOnMonday {
            return Array(symbols[1...]) + [symbols[0]]
        }
        return symbols
    }

    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        let firstDay = displayedMonth
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let daysCount = displayedMonth.daysInMonth()

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
        GeometryReader { geometry in
            let headerHeight: CGFloat = 30
            let rowCount = CGFloat((daysInMonth.count + 6) / 7)
            let cellHeight = (geometry.size.height - headerHeight) / rowCount

            VStack(spacing: 0) {
                // Day labels header
                HStack(spacing: 0) {
                    ForEach(Array(dayLabels.enumerated()), id: \.offset) { index, day in
                        let isSunday = weekStartsOnMonday ? (index == 6) : (index == 0)
                        Text(day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(isSunday ? .red : .primary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: headerHeight)
                .background(Color(.systemGray6))

                // Calendar grid
                let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                        if let date = date {
                            MonthDayCell(date: date, events: calendarManager.events(for: date))
                                .frame(height: cellHeight)
                        } else {
                            Color(.systemBackground)
                                .frame(height: cellHeight)
                        }
                    }
                }
                .background(Color(.systemGray5))
            }
            .background(Color(.systemBackground))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.height < -50 {
                            calendarManager.goToDate(displayedMonth.adding(months: 1))
                        } else if value.translation.height > 50 {
                            calendarManager.goToDate(displayedMonth.adding(months: -1))
                        }
                    }
            )
        }
    }
}

struct MonthDayCell: View {
    @EnvironmentObject var calendarManager: CalendarManager
    let date: Date
    let events: [CalendarEvent]
    @State private var showingAddEvent = false

    private var isSunday: Bool {
        date.dayOfWeek == 1
    }

    private func shouldShowAsAllDay(_ event: CalendarEvent) -> Bool {
        if event.isAllDay {
            return true
        }

        let calendar = Calendar.current
        let eventStartDay = calendar.startOfDay(for: event.startDate)
        let eventEndDay = calendar.startOfDay(for: event.endDate)

        // Multi-day event: always show as all-day style bar
        return eventStartDay != eventEndDay
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("\(date.dayOfMonth)")
                    .font(.system(size: 14, weight: date.isToday ? .bold : .regular))
                    .foregroundColor(isSunday ? .red : .primary)
                    .padding(4)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 1) {
                ForEach(events.prefix(3)) { event in
                    let eventColor = calendarManager.calendarInfo(for: event)?.color ?? .blue
                    if shouldShowAsAllDay(event) {
                        Text(event.title)
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .padding(.horizontal, 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(eventColor)
                            .cornerRadius(2)
                    } else {
                        Text(event.title)
                            .font(.system(size: 9))
                            .lineLimit(1)
                            .padding(.horizontal, 2)
                            .background(eventColor.opacity(0.3))
                            .cornerRadius(2)
                    }
                }
                if events.count > 3 {
                    Text("+\(events.count - 3)")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(2)
        .background(date.isToday ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .contentShape(Rectangle())
        .onTapGesture {
            showingAddEvent = true
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(preselectedDate: date)
        }
    }
}

#Preview {
    MonthlyView()
        .environmentObject(CalendarManager())
}
