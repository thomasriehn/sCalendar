import SwiftUI
import EventKit

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

                    Picker(LocalizedStrings.calendar, selection: $selectedCalendarId) {
                        Text(LocalizedStrings.selectCalendar).tag(nil as String?)
                        ForEach(writableCalendars) { calendar in
                            HStack {
                                Circle()
                                    .fill(calendar.color)
                                    .frame(width: 12, height: 12)
                                Text(calendar.displayName)
                            }
                            .tag(calendar.id as String?)
                        }
                    }
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
        } else {
            // Set default calendar
            selectedCalendarId = writableCalendars.first?.id

            // Set default times
            let calendar = Calendar.current
            if let preselected = preselectedDate {
                // Use preselected date with current time
                let now = Date()
                let hour = calendar.component(.hour, from: now)
                let roundedHour = hour + 1
                var components = calendar.dateComponents([.year, .month, .day], from: preselected)
                components.hour = roundedHour
                components.minute = 0
                startDate = calendar.date(from: components) ?? preselected
                endDate = startDate.addingTimeInterval(3600)
            } else {
                let roundedDate = calendar.date(
                    bySetting: .minute,
                    value: 0,
                    of: Date()
                ) ?? Date()
                startDate = roundedDate.addingTimeInterval(3600)
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
                        calendarId: calendarId
                    )
                } else {
                    try await calendarManager.addEvent(
                        title: title,
                        startDate: startDate,
                        endDate: endDate,
                        isAllDay: isAllDay,
                        location: location.isEmpty ? nil : location,
                        notes: notes.isEmpty ? nil : notes,
                        calendarId: calendarId
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
