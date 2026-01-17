import Foundation

actor CloudKitManager {
    static let shared = CloudKitManager()

    private let container: NSUbiquitousKeyValueStore

    private let customizationsKey = "calendarCustomizations"
    private let settingsKey = "appSettings"

    private init() {
        container = NSUbiquitousKeyValueStore.default
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: container,
            queue: .main
        ) { _ in
            NSUbiquitousKeyValueStore.default.synchronize()
        }
        container.synchronize()
    }

    func saveCustomizations(_ customizations: [CalendarSourceCustomization]) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(customizations)
        container.set(data, forKey: customizationsKey)
        container.synchronize()
    }

    func loadCustomizations() async throws -> [CalendarSourceCustomization] {
        guard let data = container.data(forKey: customizationsKey) else {
            return []
        }
        let decoder = JSONDecoder()
        return try decoder.decode([CalendarSourceCustomization].self, from: data)
    }

    func saveSettings(_ settings: CloudSettings) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(settings)
        container.set(data, forKey: settingsKey)
        container.synchronize()
    }

    func loadSettings() async throws -> CloudSettings {
        guard let data = container.data(forKey: settingsKey) else {
            return CloudSettings()
        }
        let decoder = JSONDecoder()
        return try decoder.decode(CloudSettings.self, from: data)
    }

    func clearAllData() async {
        container.removeObject(forKey: customizationsKey)
        container.removeObject(forKey: settingsKey)
        container.synchronize()
    }
}

struct CloudSettings: Codable {
    var defaultCalendarId: String?
    var showWeekNumbers: Bool = true
    var startWeekOnMonday: Bool = false

    init(
        defaultCalendarId: String? = nil,
        showWeekNumbers: Bool = true,
        startWeekOnMonday: Bool = false
    ) {
        self.defaultCalendarId = defaultCalendarId
        self.showWeekNumbers = showWeekNumbers
        self.startWeekOnMonday = startWeekOnMonday
    }
}
