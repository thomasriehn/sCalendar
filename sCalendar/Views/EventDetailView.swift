import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) var dismiss

    let event: CalendarEvent

    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingError = false
    @State private var errorMessage = ""

    private var calendarInfo: CalendarInfo? {
        calendarManager.calendarInfo(for: event)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle()
                                .fill(calendarInfo?.color ?? .blue)
                                .frame(width: 12, height: 12)

                            Text(calendarInfo?.displayName ?? LocalizedStrings.unknownCalendar)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Text(event.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                }

                Section(LocalizedStrings.dateAndTime) {
                    if event.isAllDay {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            Text(LocalizedStrings.allDay)
                        }

                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                            Text(formatDateRange())
                        }
                    } else {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                            Text(formatDate(event.startDate))
                        }

                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            Text("\(formatTime(event.startDate)) - \(formatTime(event.endDate))")
                        }
                    }
                }

                if let location = event.location, !location.isEmpty {
                    Section(LocalizedStrings.location) {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.secondary)
                            Text(location)
                        }
                    }
                }

                if let notes = event.notes, !notes.isEmpty {
                    Section(LocalizedStrings.notes) {
                        Text(notes)
                    }
                }

                Section {
                    Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                        HStack {
                            Spacer()
                            Image(systemName: "trash")
                            Text(LocalizedStrings.deleteEvent)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(LocalizedStrings.eventDetails)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStrings.done) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStrings.edit) { showingEditSheet = true }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                AddEventView(editingEvent: event)
            }
            .alert(LocalizedStrings.deleteEvent, isPresented: $showingDeleteConfirmation) {
                Button(LocalizedStrings.cancel, role: .cancel) { }
                Button(LocalizedStrings.delete, role: .destructive) { deleteEvent() }
            } message: {
                Text(LocalizedStrings.deleteEventConfirmation)
            }
            .alert(LocalizedStrings.error, isPresented: $showingError) {
                Button(LocalizedStrings.ok) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.currentLocale
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.currentLocale
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func formatDateRange() -> String {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.currentLocale
        formatter.dateStyle = .medium

        if event.startDate.isSameDay(as: event.endDate) {
            return formatter.string(from: event.startDate)
        } else {
            return "\(formatter.string(from: event.startDate)) - \(formatter.string(from: event.endDate))"
        }
    }

    private func deleteEvent() {
        Task {
            do {
                try await calendarManager.deleteEvent(event)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}
