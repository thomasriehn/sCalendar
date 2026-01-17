import SwiftUI

struct EventRow: View {
    @EnvironmentObject var calendarManager: CalendarManager
    let event: CalendarEvent

    private var calendarInfo: CalendarInfo? {
        calendarManager.calendarInfo(for: event)
    }

    private var eventColor: Color {
        calendarInfo?.color ?? .blue
    }

    var body: some View {
        if event.isAllDay {
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
            Text(event.timeRangeString)
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
