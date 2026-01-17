import SwiftUI

struct WeeklyView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]

    var body: some View {
        GeometryReader { geometry in
            LazyVGrid(columns: columns, spacing: 1) {
                // 7 day cells
                ForEach(Array(calendarManager.currentWeekDates.enumerated()), id: \.offset) { index, date in
                    DayCell(
                        date: date,
                        events: calendarManager.events(for: date),
                        isLastRow: index >= 6,
                        showMiniCalendar: false
                    )
                    .frame(height: cellHeight(for: geometry, index: index))
                }

                // Mini calendar as 8th cell (same size as a day cell)
                MiniMonthCell()
                    .frame(height: cellHeight(for: geometry, index: 7))
            }
            .background(Color(.systemBackground))
            .offset(y: dragOffset)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        isDragging = true
                        // Apply resistance to make it feel natural
                        dragOffset = value.translation.height * 0.5
                    }
                    .onEnded { value in
                        isDragging = false
                        let threshold: CGFloat = 50

                        if value.translation.height < -threshold {
                            // Swipe up - go to next week
                            withAnimation(.easeOut(duration: 0.2)) {
                                dragOffset = -geometry.size.height
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                calendarManager.goToNextWeek()
                                dragOffset = 0
                            }
                        } else if value.translation.height > threshold {
                            // Swipe down - go to previous week
                            withAnimation(.easeOut(duration: 0.2)) {
                                dragOffset = geometry.size.height
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                calendarManager.goToPreviousWeek()
                                dragOffset = 0
                            }
                        } else {
                            // Snap back
                            withAnimation(.easeOut(duration: 0.2)) {
                                dragOffset = 0
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
