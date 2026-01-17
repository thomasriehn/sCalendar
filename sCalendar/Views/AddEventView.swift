import SwiftUI
import EventKit

enum RecurrenceOption: String, CaseIterable, Identifiable {
    case none
    case daily
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return LocalizedStrings.recurrenceNone
        case .daily: return LocalizedStrings.recurrenceDaily
        case .weekly: return LocalizedStrings.recurrenceWeekly
        case .monthly: return LocalizedStrings.recurrenceMonthly
        case .yearly: return LocalizedStrings.recurrenceYearly
        }
    }

    var ekRecurrenceFrequency: EKRecurrenceFrequency? {
        switch self {
        case .none: return nil
        case .daily: return .daily
        case .weekly: return .weekly
        case .monthly: return .monthly
        case .yearly: return .yearly
        }
    }

    static func from(ekRecurrenceRule: EKRecurrenceRule?) -> RecurrenceOption {
        guard let rule = ekRecurrenceRule else { return .none }
        switch rule.frequency {
        case .daily: return .daily
        case .weekly: return .weekly
        case .monthly: return .monthly
        case .yearly: return .yearly
        @unknown default: return .none
        }
    }
}

struct AddEventView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) var dismiss

    var editingEvent: CalendarEvent?
    var preselectedDate: Date?

    @State private var title: String = ""
    @State private var isAllDay: Bool = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600)
    @State private var location: String = ""
    @State private var notes: String = ""
    @State private var selectedCalendarId: String?
    @State private var recurrence: RecurrenceOption = .none
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""

    private var isEditing: Bool {
        editingEvent != nil
    }

    private var canSave: Bool {
        !title.isEmpty && selectedCalendarId != nil && endDate > startDate
    }

    private var writableCalendars: [CalendarInfo] {
        calendarManager.calendars.filter { $0.ekCalendar.allowsContentModifications }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(LocalizedStrings.title, text: $title)

                    Picker(selection: $selectedCalendarId) {
                        Text(LocalizedStrings.selectCalendar).tag(nil as String?)
                        ForEach(writableCalendars) { calendar in
                            Label {
                                Text(calendar.displayName)
                            } icon: {
                                Circle()
                                    .fill(calendar.color)
                                    .frame(width: 12, height: 12)
                            }
                            .tag(calendar.id as String?)
                        }
                    } label: {
                        HStack {
                            Text(LocalizedStrings.calendar)
                            Spacer()
                            if let calendarId = selectedCalendarId,
                               let calendar = writableCalendars.first(where: { $0.id == calendarId }) {
                                Circle()
                                    .fill(calendar.color)
                                    .frame(width: 12, height: 12)
                            }
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section {
                    Toggle(LocalizedStrings.allDay, isOn: $isAllDay)

                    DatePicker(
                        LocalizedStrings.starts,
                        selection: $startDate,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )

                    DatePicker(
                        LocalizedStrings.ends,
                        selection: $endDate,
                        in: startDate...,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )

                    Picker(LocalizedStrings.recurrence, selection: $recurrence) {
                        ForEach(RecurrenceOption.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                }

                Section {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.secondary)
                        TextField(LocalizedStrings.location, text: $location)
                    }
                }

                Section(LocalizedStrings.notes) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(isEditing ? LocalizedStrings.editEvent : LocalizedStrings.newEvent)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStrings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? LocalizedStrings.save : LocalizedStrings.add) { saveEvent() }
                        .disabled(!canSave)
                }
            }
            .onAppear(perform: loadEventData)
            .onChange(of: startDate) { _, newValue in
                if endDate <= newValue {
                    endDate = newValue.addingTimeInterval(3600)
                }
            }
            .onChange(of: isAllDay) { _, newValue in
                if newValue {
                    startDate = startDate.startOfDay
                    endDate = startDate.endOfDay
                }
            }
            .alert(LocalizedStrings.error, isPresented: $showingError) {
                Button(LocalizedStrings.ok) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func loadEventData() {
        if let event = editingEvent {
            title = event.title
            isAllDay = event.isAllDay
            startDate = event.startDate
            endDate = event.endDate
            location = event.location ?? ""
            notes = event.notes ?? ""
            selectedCalendarId = event.calendarId
            recurrence = RecurrenceOption.from(ekRecurrenceRule: event.ekEvent.recurrenceRules?.first)
        } else {
            // Set default calendar from settings, or first writable calendar
            let defaultId = UserDefaults.standard.string(forKey: "defaultCalendarId")
            if let defaultId = defaultId, writableCalendars.contains(where: { $0.id == defaultId }) {
                selectedCalendarId = defaultId
            } else {
                selectedCalendarId = writableCalendars.first?.id
            }

            // Set default times
            let calendar = Calendar.current
            if let preselected = preselectedDate {
                // Use preselected date with default start time of 10am
                var components = calendar.dateComponents([.year, .month, .day], from: preselected)
                components.hour = 10
                components.minute = 0
                startDate = calendar.date(from: components) ?? preselected
                endDate = startDate.addingTimeInterval(3600)
            } else {
                // Default to today at 10am
                var components = calendar.dateComponents([.year, .month, .day], from: Date())
                components.hour = 10
                components.minute = 0
                startDate = calendar.date(from: components) ?? Date()
                endDate = startDate.addingTimeInterval(3600)
            }
        }
    }

    private func saveEvent() {
        guard let calendarId = selectedCalendarId else { return }

        Task {
            do {
                if let existingEvent = editingEvent {
                    try await calendarManager.updateEvent(
                        existingEvent,
                        title: title,
                        startDate: startDate,
                        endDate: endDate,
                        isAllDay: isAllDay,
                        location: location.isEmpty ? nil : location,
                        notes: notes.isEmpty ? nil : notes,
                        calendarId: calendarId,
                        recurrenceFrequency: recurrence.ekRecurrenceFrequency
                    )
                } else {
                    try await calendarManager.addEvent(
                        title: title,
                        startDate: startDate,
                        endDate: endDate,
                        isAllDay: isAllDay,
                        location: location.isEmpty ? nil : location,
                        notes: notes.isEmpty ? nil : notes,
                        calendarId: calendarId,
                        recurrenceFrequency: recurrence.ekRecurrenceFrequency
                    )
                }
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

#Preview {
    AddEventView()
        .environmentObject(CalendarManager())
}
