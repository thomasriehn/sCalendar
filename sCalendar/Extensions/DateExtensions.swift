import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var startOfWeek: Date {
        var calendar = Calendar.current
        // Read directly from UserDefaults to avoid actor isolation issues
        let weekStartsOnMonday = UserDefaults.standard.object(forKey: "weekStartsOnMonday") == nil ? true : UserDefaults.standard.bool(forKey: "weekStartsOnMonday")
        calendar.firstWeekday = weekStartsOnMonday ? 2 : 1 // 2 = Monday, 1 = Sunday
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }

    var endOfWeek: Date {
        var components = DateComponents()
        components.day = 6
        return Calendar.current.date(byAdding: components, to: startOfWeek)!.endOfDay
    }

    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }

    var weekOfYear: Int {
        Calendar.current.component(.weekOfYear, from: self)
    }

    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: self)
    }

    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }

    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }

    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.currentLocale
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }

    var shortMonthName: String {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.currentLocale
        formatter.dateFormat = "MMM"
        return formatter.string(from: self).uppercased()
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    func isSameWeek(as other: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: other, toGranularity: .weekOfYear)
    }

    func isSameMonth(as other: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: other, toGranularity: .month)
    }

    func daysInMonth() -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: self)!
        return range.count
    }

    func firstDayOfMonthWeekday() -> Int {
        Calendar.current.component(.weekday, from: startOfMonth)
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self)!
    }

    func adding(weeks: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self)!
    }

    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self)!
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isWeekend: Bool {
        let weekday = Calendar.current.component(.weekday, from: self)
        return weekday == 1 || weekday == 7
    }
}

extension Calendar {
    func datesInWeek(containing date: Date) -> [Date] {
        let startOfWeek = date.startOfWeek
        return (0..<7).compactMap { day in
            self.date(byAdding: .day, value: day, to: startOfWeek)
        }
    }

    func datesInMonth(containing date: Date) -> [Date] {
        let startOfMonth = date.startOfMonth
        let daysInMonth = date.daysInMonth()
        return (0..<daysInMonth).compactMap { day in
            self.date(byAdding: .day, value: day, to: startOfMonth)
        }
    }
}
