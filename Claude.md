# sCalendar - iOS Calendar App

## Project Overview
A native iOS calendar app built with SwiftUI that integrates with the system calendar (EventKit). The app supports multiple calendar views, multi-language localization, and iCloud sync for settings.

## Bundle ID
`com.sCalendar.app`

## Key Features
- **View Modes**: Daily, Weekly, Monthly, Yearly views with seamless switching
- **Weekly View Layout**: Left column (days 1-4), Right column (days 5-7 + mini calendar)
- **Recurring Events**: Support for daily, weekly, monthly, yearly recurrence
- **Event Alerts**: Reminders at time of event, 5/15/30 min, 1/2 hours, 1 day, 1 week before
- **Default Calendar**: Configurable default calendar for new events in Settings
- **Week Start Setting**: Choose between Monday or Sunday as first day of week
- **Multi-language Support**: 9 languages (English, German, French, Spanish, Italian, Dutch, Portuguese, Japanese, Chinese)
- **iCloud Sync**: Settings and calendar customizations sync via iCloud
- **Swipe Navigation**: Vertical swipe to navigate between time periods

## Project Structure
```
sCalendar/
├── sCalendarApp.swift          # App entry point
├── ContentView.swift           # Main view with navigation and view mode switching
├── Info.plist                  # App configuration
├── Models/
│   ├── CalendarEvent.swift     # Event model wrapping EKEvent
│   ├── CalendarInfo.swift      # Calendar info model
│   └── CalendarSourceCustomization.swift
├── Services/
│   ├── CalendarManager.swift   # EventKit integration, CRUD operations
│   ├── AppSettings.swift       # Settings + LocalizedStrings
│   └── CloudKitManager.swift   # iCloud sync
├── Views/
│   ├── WeeklyView.swift        # 2-column weekly layout
│   ├── DailyView.swift         # Hourly timeline view
│   ├── MonthlyView.swift       # Month grid view
│   ├── YearlyView.swift        # 12-month overview
│   ├── DayCell.swift           # Individual day cell component
│   ├── EventRow.swift          # Event display (timed/all-day/multi-day)
│   ├── MiniMonthView.swift     # Mini calendar widget
│   ├── AddEventView.swift      # Create/edit event form
│   ├── EventDetailView.swift   # Event details display
│   ├── SettingsView.swift      # App settings
│   └── CalendarSourceView.swift # Calendar customization
└── Extensions/
    ├── DateExtensions.swift    # Date helper methods
    └── ColorExtensions.swift   # Color utilities
```

## Build & Upload Commands
```bash
# Build for simulator
xcodebuild -scheme sCalendar -destination 'id=71A51C99-4D78-46D3-BA72-0ABCF2D4F117' build

# Increment build number
agvtool new-version -all <number>

# Archive for App Store
xcodebuild -scheme sCalendar -archivePath /tmp/sCalendar.xcarchive archive

# Upload to TestFlight
xcodebuild -exportArchive -archivePath /tmp/sCalendar.xcarchive -exportPath /tmp/sCalendar-export -exportOptionsPlist /tmp/ExportOptions.plist
```

## Available Simulators
- iPhone 15 Pro: `71A51C99-4D78-46D3-BA72-0ABCF2D4F117`
- iPhone 15 Pro Max: `B5B3F09E-C3E0-4A3A-94DB-DFC3B9F3683B`
- iPhone 11 Pro Max: `9F32EDE2-EC52-49CA-BADF-3A568D6C8B3F`
- iPhone 14: `C275F2FA-CBBB-4D1F-ACA1-268AC0F3A6D9`

## Localization
All user-facing strings are in `AppSettings.swift` via the `LocalizedStrings` struct. Each string has translations for:
- English (default)
- German (de)
- French (fr)
- Spanish (es)
- Italian (it)
- Dutch (nl)
- Portuguese (pt)
- Japanese (ja)
- Chinese Simplified (zh-Hans)

## Settings Storage
- `UserDefaults` for local storage
- `NSUbiquitousKeyValueStore` for iCloud sync
- Keys: `appLanguage`, `weekStartsOnMonday`, `defaultCalendarId`

## GitHub
- Repository: https://github.com/thomasriehn/sCalendar
- Privacy Policy: https://thomasriehn.github.io/sCalendar/privacy.html

## Recent Changes (Build 15)
1. Added view modes (daily, weekly, monthly, yearly)
2. New weekly layout with left/right columns
3. Default calendar setting
4. Recurring events support (daily, weekly, monthly, yearly)
5. Event alerts/reminders (at time, 5/15/30 min, 1/2 hours, 1 day, 1 week before)
6. Calendar color picker in event creation
7. Equal-sized cells in monthly/yearly views
8. Multi-day timed events display on all days they span
9. Colored bar style for all days of multi-day events (start, middle, end)
10. Time range display on partial days (start: "HH:mm-24:00", end: "00:00-HH:mm") with gray background
11. App icon resized to fill canvas without white border
