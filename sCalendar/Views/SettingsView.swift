import SwiftUI
import EventKit

struct SettingsView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @StateObject private var appSettings = AppSettings.shared
    @Environment(\.dismiss) var dismiss
    @State private var calendarToEdit: CalendarInfo?

    private var groupedCalendars: [String: [CalendarInfo]] {
        Dictionary(grouping: calendarManager.calendars) { $0.accountName }
    }

    var body: some View {
        NavigationStack {
            List {
                Section(LocalizedStrings.language) {
                    Picker(LocalizedStrings.language, selection: $appSettings.selectedLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                }

                if calendarManager.authorizationStatus == .denied {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calendar Access Required")
                                .font(.headline)
                            Text("Please enable calendar access in Settings to see your calendars.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Button("Open Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 8)
                    }
                } else {
                    Section(LocalizedStrings.calendars) {
                        ForEach(groupedCalendars.keys.sorted(), id: \.self) { accountName in
                            if let calendars = groupedCalendars[accountName] {
                                Section(header: Text(accountName)) {
                                    ForEach(calendars) { calendar in
                                        CalendarRow(calendar: calendar)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                calendarToEdit = calendar
                                            }
                                    }
                                }
                            }
                        }
                    }

                    Section(LocalizedStrings.sync) {
                        Button(action: refreshCalendars) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text(LocalizedStrings.refreshCalendars)
                                Spacer()
                                if calendarManager.isLoading {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(calendarManager.isLoading)
                    }
                }
            }
            .navigationTitle(LocalizedStrings.settings)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStrings.done) { dismiss() }
                }
            }
            .sheet(item: $calendarToEdit) { calendar in
                CalendarSourceView(calendar: calendar)
            }
        }
    }

    private func refreshCalendars() {
        Task {
            await calendarManager.loadData()
        }
    }
}

struct CalendarRow: View {
    let calendar: CalendarInfo

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(calendar.color)
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(calendar.displayName)
                    .font(.body)

                Text(calendar.sourceType)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if calendar.isHidden {
                Image(systemName: "eye.slash")
                    .foregroundColor(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
        .environmentObject(CalendarManager())
}
