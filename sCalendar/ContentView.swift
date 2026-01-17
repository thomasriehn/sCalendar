import SwiftUI

struct ContentView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var showingSettings = false
    @State private var showingAddEvent = false
    @State private var showingSearch = false
    @State private var showingMonthPicker = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            WeeklyView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.white)
                        }
                    }

                    ToolbarItem(placement: .principal) {
                        Button(action: { showingMonthPicker = true }) {
                            VStack(spacing: 0) {
                                HStack(spacing: 4) {
                                    Text(calendarManager.currentWeekTitle)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Text(LocalizedStrings.weekAbbreviation + " \(calendarManager.currentWeekNumber)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
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
        .sheet(isPresented: $showingMonthPicker) {
            MonthYearPickerView()
        }
        .task {
            await calendarManager.loadData()
        }
    }
}

struct MonthYearPickerView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedMonth: Int = 1
    @State private var selectedYear: Int = 2026

    private let months: [String] = {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.currentLocale
        return formatter.monthSymbols ?? []
    }()

    private var years: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 10)...(currentYear + 10))
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 0) {
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(months[month - 1]).tag(month)
                        }
                    }
                    .pickerStyle(.wheel)

                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .padding()
            }
            .navigationTitle(LocalizedStrings.selectDate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStrings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStrings.done) {
                        goToSelectedDate()
                        dismiss()
                    }
                }
            }
            .onAppear {
                let calendar = Calendar.current
                selectedMonth = calendar.component(.month, from: calendarManager.currentWeekStart)
                selectedYear = calendar.component(.year, from: calendarManager.currentWeekStart)
            }
        }
        .presentationDetents([.medium])
    }

    private func goToSelectedDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            calendarManager.goToDate(date)
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
