import SwiftUI

struct ContentView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var showingSettings = false
    @State private var showingAddEvent = false
    @State private var showingSearch = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            WeeklyView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.white)
                        }
                    }

                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 0) {
                            Text(calendarManager.currentWeekTitle)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(LocalizedStrings.weekAbbreviation + " \(calendarManager.currentWeekNumber)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: { showingAddEvent = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }

                        Button(action: { calendarManager.goToToday() }) {
                            Image(systemName: "calendar")
                                .foregroundColor(.white)
                        }

                        Button(action: { showingSearch = true }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                        }
                    }
                }
                .toolbarBackground(Color.blue, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView()
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(searchText: $searchText)
        }
        .task {
            await calendarManager.loadData()
        }
    }
}

struct SearchView: View {
    @Binding var searchText: String
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) var dismiss

    var filteredEvents: [CalendarEvent] {
        if searchText.isEmpty {
            return []
        }
        return calendarManager.allEvents.filter { event in
            event.title.localizedCaseInsensitiveContains(searchText) ||
            (event.location?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredEvents, id: \.id) { event in
                SearchResultRow(event: event)
            }
            .searchable(text: $searchText, prompt: LocalizedStrings.searchEvents)
            .navigationTitle(LocalizedStrings.search)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStrings.done) { dismiss() }
                }
            }
        }
    }
}

struct SearchResultRow: View {
    @EnvironmentObject var calendarManager: CalendarManager
    let event: CalendarEvent
    @State private var showingDetail = false

    private var calendarInfo: CalendarInfo? {
        calendarManager.calendarInfo(for: event)
    }

    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack(spacing: 8) {
                Circle()
                    .fill(calendarInfo?.color ?? .blue)
                    .frame(width: 10, height: 10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.body)
                        .foregroundColor(.primary)

                    Text(formatEventDate())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingDetail) {
            EventDetailView(event: event)
        }
    }

    private func formatEventDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.currentLocale
        formatter.dateFormat = "EEE, MMM d - HH:mm"
        return formatter.string(from: event.startDate)
    }
}

#Preview {
    ContentView()
        .environmentObject(CalendarManager())
}
