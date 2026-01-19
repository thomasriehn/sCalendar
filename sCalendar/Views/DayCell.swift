import SwiftUI

struct DayCell: View {
    @EnvironmentObject var calendarManager: CalendarManager
    let date: Date
    let events: [CalendarEvent]
    let isLastRow: Bool
    var showMiniCalendar: Bool = false

    @State private var selectedEvent: CalendarEvent?
    @State private var showingAddEvent = false

    private var isWeekend: Bool {
        date.isWeekend
    }

    private var isToday: Bool {
        date.isToday
    }

    private var dayNumber: Int {
        date.dayOfMonth
    }

    private var dayName: String {
        date.shortDayName
    }

    private var monthAbbr: String {
        if dayNumber == 1 {
            return " / \(date.shortMonthName)"
        }
        return ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Day header
            HStack(spacing: 4) {
                Text("\(dayNumber)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(headerColor)

                Text("\(dayName)\(monthAbbr)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(headerColor)

                if isToday {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }

                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)

            // Events list
            VStack(alignment: .leading, spacing: 2) {
                ForEach(events.prefix(4)) { event in
                    EventRow(event: event, displayDate: date)
                        .onTapGesture {
                            selectedEvent = event
                        }
                }

                if events.count > 4 {
                    Text("+\(events.count - 4) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
            }

            Spacer()

            // Mini calendar in bottom right cell
            if showMiniCalendar {
                MiniMonthView()
                    .padding(4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(backgroundColor)
        .contentShape(Rectangle())
        .onTapGesture {
            showingAddEvent = true
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(preselectedDate: date)
        }
    }

    private var headerColor: Color {
        if date.dayOfWeek == 1 {
            return .red  // Sunday
        }
        return .primary  // Black for all other days
    }

    private var backgroundColor: Color {
        if isWeekend && date.dayOfWeek == 7 {
            return Color.blue.opacity(0.1)
        }
        return Color(.systemBackground)
    }
}

#Preview {
    DayCell(
        date: Date(),
        events: [],
        isLastRow: false,
        showMiniCalendar: false
    )
    .frame(height: 200)
    .environmentObject(CalendarManager())
}
