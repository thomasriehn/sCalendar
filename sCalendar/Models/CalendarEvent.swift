import Foundation
import SwiftUI
import EventKit

struct CalendarEvent: Identifiable, Equatable {
    let id: String
    let ekEvent: EKEvent
    let calendarId: String

    init(ekEvent: EKEvent) {
        self.id = ekEvent.eventIdentifier ?? UUID().uuidString
        self.ekEvent = ekEvent
        self.calendarId = ekEvent.calendar.calendarIdentifier
    }

    var title: String {
        ekEvent.title ?? "Untitled"
    }

    var startDate: Date {
        ekEvent.startDate
    }

    var endDate: Date {
        ekEvent.endDate
    }

    var isAllDay: Bool {
        ekEvent.isAllDay
    }

    var location: String? {
        ekEvent.location
    }

    var notes: String? {
        ekEvent.notes
    }

    var timeRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        return "\(start)-\(end)"
    }

    var dayOfMonth: Int {
        Calendar.current.component(.day, from: startDate)
    }

    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        lhs.id == rhs.id
    }
}
