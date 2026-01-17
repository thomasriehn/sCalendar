import SwiftUI

struct WeeklyView: View {
    @EnvironmentObject var calendarManager: CalendarManager

    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 1) {
                    // 7 day cells
                    ForEach(Array(calendarManager.currentWeekDates.enumerated()), id: \.offset) { index, date in
                        DayCell(
                            date: date,
                            events: calendarManager.events(for: date),
                            isLastRow: index >= 6,
                            showMiniCalendar: false
                        )
                        .frame(minHeight: cellHeight(for: geometry, index: index))
                    }

                    // Mini calendar as 8th cell (same size as a day cell)
                    MiniMonthCell()
                        .frame(minHeight: cellHeight(for: geometry, index: 7))
                }
                .background(Color(.systemBackground))
            }
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.width < -50 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                calendarManager.goToNextWeek()
                            }
                        } else if value.translation.width > 50 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                calendarManager.goToPreviousWeek()
                            }
                        }
                    }
            )
        }
    }

    private func cellHeight(for geometry: GeometryProxy, index: Int) -> CGFloat {
        let availableHeight = geometry.size.height
        let rowCount: CGFloat = 4

        // Rows 0-1: first 4 days
        // Rows 2-3: last 3 days + mini calendar
        if index < 2 {
            return availableHeight / rowCount * 0.9
        } else if index < 4 {
            return availableHeight / rowCount * 1.1
        } else {
            return availableHeight / rowCount * 1.0
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
