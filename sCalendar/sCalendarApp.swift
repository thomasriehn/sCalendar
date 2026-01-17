import SwiftUI

@main
struct sCalendarApp: App {
    @StateObject private var calendarManager = CalendarManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(calendarManager)
        }
    }
}
