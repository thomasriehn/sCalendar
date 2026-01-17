import Foundation
import SwiftUI
import EventKit
import Combine

@MainActor
class CalendarManager: ObservableObject {
    @Published var calendars: [CalendarInfo] = []
    @Published var events: [CalendarEvent] = []
    @Published var currentWeekStart: Date = Date().startOfWeek
    @Published var customizations: [String: CalendarSourceCustomization] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined

    private let eventStore = EKEventStore()

    var currentWeekTitle: String {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.currentLocale
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentWeekStart)
    }

    var currentWeekNumber: Int {
        currentWeekStart.weekOfYear
    }

    var currentWeekDates: [Date] {
        Calendar.current.datesInWeek(containing: currentWeekStart)
    }

    var visibleCalendars: [CalendarInfo] {
        calendars.filter { !$0.isHidden }
    }

    var allEvents: [CalendarEvent] {
        events.sorted { $0.startDate < $1.startDate }
    }

    // MARK: - Initialization

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        // Load customizations from iCloud
        do {
            let saved = try await CloudKitManager.shared.loadCustomizations()
            customizations = Dictionary(uniqueKeysWithValues: saved.map { ($0.id, $0) })
        } catch {
            print("Failed to load customizations: \(error)")
        }

        // Request calendar access
        await requestCalendarAccess()
    }

    func requestCalendarAccess() async {
        do {
            let granted: Bool
            if #available(iOS 17.0, *) {
                granted = try await eventStore.requestFullAccessToEvents()
            } else {
                granted = try await eventStore.requestAccess(to: .event)
            }

            if granted {
                authorizationStatus = .fullAccess
                loadCalendars()
                await fetchEvents()
            } else {
                authorizationStatus = .denied
                errorMessage = "Calendar access denied. Please enable in Settings."
            }
        } catch {
            errorMessage = "Failed to request calendar access: \(error.localizedDescription)"
        }
    }

    private func loadCalendars() {
        let ekCalendars = eventStore.calendars(for: .event)
        calendars = ekCalendars.map { ekCal in
            CalendarInfo(
                id: ekCal.calendarIdentifier,
                ekCalendar: ekCal,
                customization: customizations[ekCal.calendarIdentifier]
            )
        }.sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }

    // MARK: - Event Fetching

    func fetchEvents() async {
        let visibleCalendarIds = Set(visibleCalendars.map { $0.id })
        let ekCalendars = eventStore.calendars(for: .event).filter { visibleCalendarIds.contains($0.calendarIdentifier) }

        guard !ekCalendars.isEmpty else {
            events = []
            return
        }

        // Fetch events for 3 months range
        let startDate = currentWeekStart.adding(months: -1)
        let endDate = currentWeekStart.adding(months: 2)

        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: ekCalendars
        )

        let ekEvents = eventStore.events(matching: predicate)
        events = ekEvents.map { CalendarEvent(ekEvent: $0) }
    }

    // MARK: - Week Navigation

    func goToNextWeek() {
        currentWeekStart = currentWeekStart.adding(weeks: 1)
        Task { await fetchEvents() }
    }

    func goToPreviousWeek() {
        currentWeekStart = currentWeekStart.adding(weeks: -1)
        Task { await fetchEvents() }
    }

    func goToToday() {
        currentWeekStart = Date().startOfWeek
        Task { await fetchEvents() }
    }

    func goToDate(_ date: Date) {
        currentWeekStart = date.startOfWeek
        Task { await fetchEvents() }
    }

    // MARK: - Calendar Customization

    func updateCustomization(for calendarId: String, nickname: String?, colorHex: String?, isHidden: Bool) async {
        let customization = CalendarSourceCustomization(
            id: calendarId,
            nickname: nickname,
            colorHex: colorHex,
            isHidden: isHidden
        )
        customizations[calendarId] = customization

        // Update calendar info
        if let index = calendars.firstIndex(where: { $0.id == calendarId }) {
            calendars[index].customization = customization
        }

        // Save to iCloud
        await saveCustomizations()

        // Refresh events if visibility changed
        if isHidden {
            await fetchEvents()
        }
    }

    private func saveCustomizations() async {
        do {
            try await CloudKitManager.shared.saveCustomizations(Array(customizations.values))
        } catch {
            errorMessage = "Failed to save customizations: \(error.localizedDescription)"
        }
    }

    func calendarInfo(for event: CalendarEvent) -> CalendarInfo? {
        calendars.first { $0.id == event.calendarId }
    }

    // MARK: - Event Queries

    func events(for date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        return events.filter { event in
            if event.isAllDay {
                let eventStart = calendar.startOfDay(for: event.startDate)
                let eventEnd = calendar.startOfDay(for: event.endDate)
                let checkDate = calendar.startOfDay(for: date)
                return checkDate >= eventStart && checkDate <= eventEnd
            } else {
                return calendar.isDate(event.startDate, inSameDayAs: date)
            }
        }.sorted { $0.startDate < $1.startDate }
    }

    // MARK: - Event CRUD Operations

    func addEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool,
        location: String?,
        notes: String?,
        calendarId: String,
        recurrenceFrequency: EKRecurrenceFrequency? = nil
    ) async throws {
        guard let ekCalendar = eventStore.calendar(withIdentifier: calendarId) else {
            throw CalendarError.calendarNotFound
        }

        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.title = title
        ekEvent.startDate = startDate
        ekEvent.endDate = endDate
        ekEvent.isAllDay = isAllDay
        ekEvent.location = location
        ekEvent.notes = notes
        ekEvent.calendar = ekCalendar

        if let frequency = recurrenceFrequency {
            let recurrenceRule = EKRecurrenceRule(
                recurrenceWith: frequency,
                interval: 1,
                end: nil
            )
            ekEvent.addRecurrenceRule(recurrenceRule)
        }

        try eventStore.save(ekEvent, span: .thisEvent)
        await fetchEvents()
    }

    func updateEvent(_ event: CalendarEvent, title: String, startDate: Date, endDate: Date, isAllDay: Bool, location: String?, notes: String?, calendarId: String, recurrenceFrequency: EKRecurrenceFrequency? = nil) async throws {
        guard let ekEvent = eventStore.event(withIdentifier: event.id) else {
            throw CalendarError.eventNotFound
        }

        if let newCalendar = eventStore.calendar(withIdentifier: calendarId) {
            ekEvent.calendar = newCalendar
        }

        ekEvent.title = title
        ekEvent.startDate = startDate
        ekEvent.endDate = endDate
        ekEvent.isAllDay = isAllDay
        ekEvent.location = location
        ekEvent.notes = notes

        // Remove existing recurrence rules
        if let existingRules = ekEvent.recurrenceRules {
            for rule in existingRules {
                ekEvent.removeRecurrenceRule(rule)
            }
        }

        // Add new recurrence rule if specified
        if let frequency = recurrenceFrequency {
            let recurrenceRule = EKRecurrenceRule(
                recurrenceWith: frequency,
                interval: 1,
                end: nil
            )
            ekEvent.addRecurrenceRule(recurrenceRule)
        }

        try eventStore.save(ekEvent, span: .futureEvents)
        await fetchEvents()
    }

    func deleteEvent(_ event: CalendarEvent) async throws {
        guard let ekEvent = eventStore.event(withIdentifier: event.id) else {
            throw CalendarError.eventNotFound
        }

        try eventStore.remove(ekEvent, span: .thisEvent)
        await fetchEvents()
    }
}

enum CalendarError: LocalizedError {
    case calendarNotFound
    case eventNotFound
    case accessDenied

    var errorDescription: String? {
        switch self {
        case .calendarNotFound:
            return "Calendar not found"
        case .eventNotFound:
            return "Event not found"
        case .accessDenied:
            return "Calendar access denied"
        }
    }
}
