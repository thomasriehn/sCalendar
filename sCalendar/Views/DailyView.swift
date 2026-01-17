import SwiftUI

struct DailyView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var showingAddEvent = false

    private var currentDate: Date {
        calendarManager.currentWeekStart
    }

    private var eventsForDay: [CalendarEvent] {
        calendarManager.events(for: currentDate)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Time slots
                    ForEach(0..<24, id: \.self) { hour in
                        HStack(alignment: .top, spacing: 8) {
                            Text(String(format: "%02d:00", hour))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 50, alignment: .trailing)

                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(eventsForHour(hour)) { event in
                                    EventRow(event: event)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(minHeight: 44)
                        .padding(.horizontal, 8)

                        Divider()
                    }
                }
            }
            .background(Color(.systemBackground))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.height < -50 {
                            calendarManager.goToDate(currentDate.adding(days: 1))
                        } else if value.translation.height > 50 {
                            calendarManager.goToDate(currentDate.adding(days: -1))
                        }
                    }
            )
            .onTapGesture {
                showingAddEvent = true
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(preselectedDate: currentDate)
        }
    }

    private func eventsForHour(_ hour: Int) -> [CalendarEvent] {
        eventsForDay.filter { event in
            let eventHour = Calendar.current.component(.hour, from: event.startDate)
            return eventHour == hour
        }
    }
}

#Preview {
    DailyView()
        .environmentObject(CalendarManager())
}
