import SwiftUI

struct WeeklyView: View {
    @EnvironmentObject var calendarManager: CalendarManager

    var body: some View {
        GeometryReader { geometry in
            let cellHeight = geometry.size.height / 4
            let weekDates = calendarManager.currentWeekDates

            HStack(spacing: 1) {
                // Left column: Days 1-4
                VStack(spacing: 1) {
                    ForEach(0..<4, id: \.self) { index in
                        DayCell(
                            date: weekDates[index],
                            events: calendarManager.events(for: weekDates[index]),
                            isLastRow: index == 3,
                            showMiniCalendar: false
                        )
                        .frame(height: cellHeight)
                    }
                }

                // Right column: Days 5-7 + Mini calendar
                VStack(spacing: 1) {
                    ForEach(4..<7, id: \.self) { index in
                        DayCell(
                            date: weekDates[index],
                            events: calendarManager.events(for: weekDates[index]),
                            isLastRow: false,
                            showMiniCalendar: false
                        )
                        .frame(height: cellHeight)
                    }
                    MiniMonthCell()
                        .frame(height: cellHeight)
                }
            }
            .background(Color(.systemBackground))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.height < -50 {
                            calendarManager.goToNextWeek()
                        } else if value.translation.height > 50 {
                            calendarManager.goToPreviousWeek()
                        }
                    }
            )
        }
    }
}

struct MiniMonthCell: View {
    var body: some View {
        VStack {
            MiniMonthView()
                .padding(8)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    WeeklyView()
        .environmentObject(CalendarManager())
}
