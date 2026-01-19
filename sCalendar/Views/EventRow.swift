import SwiftUI

struct EventRow: View {
    @EnvironmentObject var calendarManager: CalendarManager
    let event: CalendarEvent
    var displayDate: Date? = nil

    private var calendarInfo: CalendarInfo? {
        calendarManager.calendarInfo(for: event)
    }

    private var eventColor: Color {
        calendarInfo?.color ?? .blue
    }

    /// Determines if this event should be displayed as all-day style for the given display date
    /// Returns true if:
    /// - Event is actually all-day, OR
    /// - Event spans the entire display date (not start or end day of a multi-day timed event)
    private var shouldShowAsAllDay: Bool {
        if event.isAllDay {
            return true
        }

        guard let date = displayDate else {
            return false
        }

        let calendar = Calendar.current
        let eventStartDay = calendar.startOfDay(for: event.startDate)
        let eventEndDay = calendar.startOfDay(for: event.endDate)

        // If it's a single-day event, show with times
        if eventStartDay == eventEndDay {
            return false
        }

        // If display date is not the start day and not the end day, show as all-day
        let isStartDay = calendar.isDate(date, inSameDayAs: event.startDate)
        let isEndDay = calendar.isDate(date, inSameDayAs: event.endDate)

        return !isStartDay && !isEndDay
    }

    /// Returns the appropriate time range string for the display date
    /// - For single-day events: shows actual start-end time
    /// - For multi-day events on start day: shows start time - 24:00
    /// - For multi-day events on end day: shows 00:00 - end time
    private var displayTimeRangeString: String {
        guard let date = displayDate else {
            return event.timeRangeString
        }

        let calendar = Calendar.current
        let eventStartDay = calendar.startOfDay(for: event.startDate)
        let eventEndDay = calendar.startOfDay(for: event.endDate)

        // Single-day event - use normal time range
        if eventStartDay == eventEndDay {
            return event.timeRangeString
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let isStartDay = calendar.isDate(date, inSameDayAs: event.startDate)
        let isEndDay = calendar.isDate(date, inSameDayAs: event.endDate)

        if isStartDay {
            // Start day: show start time - 24:00
            let startTime = formatter.string(from: event.startDate)
            return "\(startTime)-24:00"
        } else if isEndDay {
            // End day: show 00:00 - end time
            let endTime = formatter.string(from: event.endDate)
            return "00:00-\(endTime)"
        }

        // Middle day (shouldn't reach here as shouldShowAsAllDay handles this)
        return event.timeRangeString
    }

    var body: some View {
        if shouldShowAsAllDay {
            allDayEventView
        } else {
            timedEventView
        }
    }

    private var allDayEventView: some View {
        Text(event.title)
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(.white)
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(eventColor)
            .cornerRadius(3)
            .padding(.horizontal, 2)
    }

    private var timedEventView: some View {
        HStack(spacing: 4) {
            Text(displayTimeRangeString)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(eventColor)

            Text(event.title)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(eventColor)

            Spacer()
        }
        .lineLimit(1)
        .padding(.horizontal, 4)
        .padding(.vertical, 1)
    }
}
