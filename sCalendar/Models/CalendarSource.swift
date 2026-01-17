import Foundation
import SwiftUI
import EventKit

struct CalendarSourceCustomization: Codable, Identifiable {
    let id: String  // EKCalendar.calendarIdentifier
    var nickname: String?
    var colorHex: String?
    var isHidden: Bool

    init(
        id: String,
        nickname: String? = nil,
        colorHex: String? = nil,
        isHidden: Bool = false
    ) {
        self.id = id
        self.nickname = nickname
        self.colorHex = colorHex
        self.isHidden = isHidden
    }
}

struct CalendarInfo: Identifiable {
    let id: String
    let ekCalendar: EKCalendar
    var customization: CalendarSourceCustomization?

    var displayName: String {
        customization?.nickname ?? ekCalendar.title
    }

    var color: Color {
        if let hex = customization?.colorHex {
            return Color(hex: hex) ?? Color(cgColor: ekCalendar.cgColor)
        }
        return Color(cgColor: ekCalendar.cgColor)
    }

    var isHidden: Bool {
        customization?.isHidden ?? false
    }

    var sourceType: String {
        switch ekCalendar.source.sourceType {
        case .local:
            return "Local"
        case .exchange:
            return "Exchange"
        case .calDAV:
            return "CalDAV"
        case .mobileMe:
            return "iCloud"
        case .birthdays:
            return "Birthdays"
        case .subscribed:
            return "Subscribed"
        @unknown default:
            return "Other"
        }
    }

    var accountName: String {
        ekCalendar.source.title
    }
}
