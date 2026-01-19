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

    /// Determines if this is a multi-day event
    private var isMultiDayEvent: Bool {
        let calendar = Calendar.current
        let eventStartDay = calendar.startOfDay(for: event.startDate)
        let eventEndDay = calendar.startOfDay(for: event.endDate)
        return eventStartDay != eventEndDay
    }

    /// Determines if this event should be displayed as all-day style (colored bar)
    /// Returns true if:
    /// - Event is actually all-day, OR
    /// - Event is a multi-day event (on any day)
    private var shouldShowAsAllDay: Bool {
        if event.isAllDay {
            return true
        }
        return isMultiDayEvent
    }

    /// For multi-day timed events, determines if this is a partial day (start or end)
    private var isPartialDay: Bool {
        guard !event.isAllDay, isMultiDayEvent, let date = displayDate else {
            return false
        }

        let calendar = Calendar.current
        let isStartDay = calendar.isDate(date, inSameDayAs: event.startDate)
        let isEndDay = calendar.isDate(date, inSameDayAs: event.endDate)

        return isStartDay || isEndDay
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
        HStack(spacing: 0) {
            Text(event.title)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)

            if isPartialDay {
                Text(displayTimeRangeString)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
            }

            Spacer(minLength: 0)
        }
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
