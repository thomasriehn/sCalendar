import SwiftUI
import EventKit

struct CalendarSourceView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) var dismiss

    let calendar: CalendarInfo

    @State private var nickname: String = ""
    @State private var selectedColor: Color = .blue
    @State private var useCustomColor: Bool = false
    @State private var isHidden: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Calendar Info") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(calendar.ekCalendar.title)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Account")
                        Spacer()
                        Text(calendar.accountName)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Type")
                        Spacer()
                        Text(calendar.sourceType)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Customization") {
                    TextField("Nickname (optional)", text: $nickname)

                    Toggle("Use Custom Color", isOn: $useCustomColor)

                    if useCustomColor {
                        ColorPickerGrid(selectedColor: $selectedColor)
                    } else {
                        HStack {
                            Text("Calendar Color")
                            Spacer()
                            Circle()
                                .fill(Color(cgColor: calendar.ekCalendar.cgColor))
                                .frame(width: 24, height: 24)
                        }
                    }
                }

                Section("Visibility") {
                    Toggle("Hide this calendar", isOn: $isHidden)

                    if isHidden {
                        Text("Events from this calendar will not be shown in the weekly view.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                }
            }
            .onAppear(perform: loadData)
        }
    }

    private func loadData() {
        nickname = calendar.customization?.nickname ?? ""
        isHidden = calendar.customization?.isHidden ?? false

        if let colorHex = calendar.customization?.colorHex,
           let customColor = Color(hex: colorHex) {
            selectedColor = customColor
            useCustomColor = true
        } else {
            selectedColor = Color(cgColor: calendar.ekCalendar.cgColor)
            useCustomColor = false
        }
    }

    private func save() {
        Task {
            await calendarManager.updateCustomization(
                for: calendar.id,
                nickname: nickname.isEmpty ? nil : nickname,
                colorHex: useCustomColor ? selectedColor.toHex() : nil,
                isHidden: isHidden
            )
            dismiss()
        }
    }
}

struct ColorPickerGrid: View {
    @Binding var selectedColor: Color

    let colors = Color.calendarColors

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                    )
                    .onTapGesture {
                        selectedColor = color
                    }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CalendarSourceView(calendar: CalendarInfo(
        id: "test",
        ekCalendar: EKEventStore().defaultCalendarForNewEvents!,
        customization: nil
    ))
    .environmentObject(CalendarManager())
}
