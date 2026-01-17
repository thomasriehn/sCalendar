import Foundation
import SwiftUI

// MARK: - Localized Strings
struct LocalizedStrings {
    static var weekAbbreviation: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "KW"
        case .french: return "Sem"
        case .spanish: return "Sem"
        case .italian: return "Sett"
        case .dutch: return "Wk"
        case .portuguese: return "Sem"
        case .japanese: return "週"
        case .chinese: return "周"
        default: return "wk"
        }
    }

    static var settings: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Einstellungen"
        case .french: return "Paramètres"
        case .spanish: return "Ajustes"
        case .italian: return "Impostazioni"
        case .dutch: return "Instellingen"
        case .portuguese: return "Configurações"
        case .japanese: return "設定"
        case .chinese: return "设置"
        default: return "Settings"
        }
    }

    static var language: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Sprache"
        case .french: return "Langue"
        case .spanish: return "Idioma"
        case .italian: return "Lingua"
        case .dutch: return "Taal"
        case .portuguese: return "Idioma"
        case .japanese: return "言語"
        case .chinese: return "语言"
        default: return "Language"
        }
    }

    static var calendars: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Kalender"
        case .french: return "Calendriers"
        case .spanish: return "Calendarios"
        case .italian: return "Calendari"
        case .dutch: return "Agenda's"
        case .portuguese: return "Calendários"
        case .japanese: return "カレンダー"
        case .chinese: return "日历"
        default: return "Calendars"
        }
    }

    static var sync: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Synchronisieren"
        case .french: return "Synchronisation"
        case .spanish: return "Sincronización"
        case .italian: return "Sincronizzazione"
        case .dutch: return "Synchronisatie"
        case .portuguese: return "Sincronização"
        case .japanese: return "同期"
        case .chinese: return "同步"
        default: return "Sync"
        }
    }

    static var refreshCalendars: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Kalender aktualisieren"
        case .french: return "Actualiser les calendriers"
        case .spanish: return "Actualizar calendarios"
        case .italian: return "Aggiorna calendari"
        case .dutch: return "Agenda's vernieuwen"
        case .portuguese: return "Atualizar calendários"
        case .japanese: return "カレンダーを更新"
        case .chinese: return "刷新日历"
        default: return "Refresh Calendars"
        }
    }

    static var done: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Fertig"
        case .french: return "Terminé"
        case .spanish: return "Listo"
        case .italian: return "Fine"
        case .dutch: return "Gereed"
        case .portuguese: return "Concluído"
        case .japanese: return "完了"
        case .chinese: return "完成"
        default: return "Done"
        }
    }

    static var search: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Suchen"
        case .french: return "Rechercher"
        case .spanish: return "Buscar"
        case .italian: return "Cerca"
        case .dutch: return "Zoeken"
        case .portuguese: return "Pesquisar"
        case .japanese: return "検索"
        case .chinese: return "搜索"
        default: return "Search"
        }
    }

    static var searchEvents: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Termine suchen"
        case .french: return "Rechercher des événements"
        case .spanish: return "Buscar eventos"
        case .italian: return "Cerca eventi"
        case .dutch: return "Zoek evenementen"
        case .portuguese: return "Pesquisar eventos"
        case .japanese: return "イベントを検索"
        case .chinese: return "搜索事件"
        default: return "Search events"
        }
    }

    static var eventDetails: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Termindetails"
        case .french: return "Détails de l'événement"
        case .spanish: return "Detalles del evento"
        case .italian: return "Dettagli evento"
        case .dutch: return "Gebeurtenisdetails"
        case .portuguese: return "Detalhes do evento"
        case .japanese: return "イベント詳細"
        case .chinese: return "事件详情"
        default: return "Event Details"
        }
    }

    static var dateAndTime: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Datum & Uhrzeit"
        case .french: return "Date et heure"
        case .spanish: return "Fecha y hora"
        case .italian: return "Data e ora"
        case .dutch: return "Datum en tijd"
        case .portuguese: return "Data e hora"
        case .japanese: return "日時"
        case .chinese: return "日期和时间"
        default: return "Date & Time"
        }
    }

    static var allDay: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Ganztägig"
        case .french: return "Toute la journée"
        case .spanish: return "Todo el día"
        case .italian: return "Tutto il giorno"
        case .dutch: return "Hele dag"
        case .portuguese: return "Dia inteiro"
        case .japanese: return "終日"
        case .chinese: return "全天"
        default: return "All Day"
        }
    }

    static var location: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Ort"
        case .french: return "Lieu"
        case .spanish: return "Ubicación"
        case .italian: return "Luogo"
        case .dutch: return "Locatie"
        case .portuguese: return "Local"
        case .japanese: return "場所"
        case .chinese: return "地点"
        default: return "Location"
        }
    }

    static var notes: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Notizen"
        case .french: return "Notes"
        case .spanish: return "Notas"
        case .italian: return "Note"
        case .dutch: return "Notities"
        case .portuguese: return "Notas"
        case .japanese: return "メモ"
        case .chinese: return "备注"
        default: return "Notes"
        }
    }

    static var deleteEvent: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Termin löschen"
        case .french: return "Supprimer l'événement"
        case .spanish: return "Eliminar evento"
        case .italian: return "Elimina evento"
        case .dutch: return "Gebeurtenis verwijderen"
        case .portuguese: return "Excluir evento"
        case .japanese: return "イベントを削除"
        case .chinese: return "删除事件"
        default: return "Delete Event"
        }
    }

    static var edit: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Bearbeiten"
        case .french: return "Modifier"
        case .spanish: return "Editar"
        case .italian: return "Modifica"
        case .dutch: return "Bewerken"
        case .portuguese: return "Editar"
        case .japanese: return "編集"
        case .chinese: return "编辑"
        default: return "Edit"
        }
    }

    static var cancel: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Abbrechen"
        case .french: return "Annuler"
        case .spanish: return "Cancelar"
        case .italian: return "Annulla"
        case .dutch: return "Annuleren"
        case .portuguese: return "Cancelar"
        case .japanese: return "キャンセル"
        case .chinese: return "取消"
        default: return "Cancel"
        }
    }

    static var delete: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Löschen"
        case .french: return "Supprimer"
        case .spanish: return "Eliminar"
        case .italian: return "Elimina"
        case .dutch: return "Verwijderen"
        case .portuguese: return "Excluir"
        case .japanese: return "削除"
        case .chinese: return "删除"
        default: return "Delete"
        }
    }

    static var deleteEventConfirmation: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Möchten Sie diesen Termin wirklich löschen?"
        case .french: return "Voulez-vous vraiment supprimer cet événement?"
        case .spanish: return "¿Está seguro de que desea eliminar este evento?"
        case .italian: return "Sei sicuro di voler eliminare questo evento?"
        case .dutch: return "Weet u zeker dat u deze gebeurtenis wilt verwijderen?"
        case .portuguese: return "Tem certeza de que deseja excluir este evento?"
        case .japanese: return "このイベントを削除してもよろしいですか？"
        case .chinese: return "您确定要删除此事件吗？"
        default: return "Are you sure you want to delete this event?"
        }
    }

    static var error: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Fehler"
        case .french: return "Erreur"
        case .spanish: return "Error"
        case .italian: return "Errore"
        case .dutch: return "Fout"
        case .portuguese: return "Erro"
        case .japanese: return "エラー"
        case .chinese: return "错误"
        default: return "Error"
        }
    }

    static var ok: String {
        return "OK"
    }

    static var unknownCalendar: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Unbekannter Kalender"
        case .french: return "Calendrier inconnu"
        case .spanish: return "Calendario desconocido"
        case .italian: return "Calendario sconosciuto"
        case .dutch: return "Onbekende agenda"
        case .portuguese: return "Calendário desconhecido"
        case .japanese: return "不明なカレンダー"
        case .chinese: return "未知日历"
        default: return "Unknown Calendar"
        }
    }

    static var newEvent: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Neuer Termin"
        case .french: return "Nouvel événement"
        case .spanish: return "Nuevo evento"
        case .italian: return "Nuovo evento"
        case .dutch: return "Nieuwe gebeurtenis"
        case .portuguese: return "Novo evento"
        case .japanese: return "新規イベント"
        case .chinese: return "新建事件"
        default: return "New Event"
        }
    }

    static var editEvent: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Termin bearbeiten"
        case .french: return "Modifier l'événement"
        case .spanish: return "Editar evento"
        case .italian: return "Modifica evento"
        case .dutch: return "Gebeurtenis bewerken"
        case .portuguese: return "Editar evento"
        case .japanese: return "イベントを編集"
        case .chinese: return "编辑事件"
        default: return "Edit Event"
        }
    }

    static var title: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Titel"
        case .french: return "Titre"
        case .spanish: return "Título"
        case .italian: return "Titolo"
        case .dutch: return "Titel"
        case .portuguese: return "Título"
        case .japanese: return "タイトル"
        case .chinese: return "标题"
        default: return "Title"
        }
    }

    static var calendar: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Kalender"
        case .french: return "Calendrier"
        case .spanish: return "Calendario"
        case .italian: return "Calendario"
        case .dutch: return "Agenda"
        case .portuguese: return "Calendário"
        case .japanese: return "カレンダー"
        case .chinese: return "日历"
        default: return "Calendar"
        }
    }

    static var selectCalendar: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Kalender auswählen"
        case .french: return "Sélectionner un calendrier"
        case .spanish: return "Seleccionar calendario"
        case .italian: return "Seleziona calendario"
        case .dutch: return "Selecteer agenda"
        case .portuguese: return "Selecionar calendário"
        case .japanese: return "カレンダーを選択"
        case .chinese: return "选择日历"
        default: return "Select Calendar"
        }
    }

    static var selectDate: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Datum auswählen"
        case .french: return "Sélectionner une date"
        case .spanish: return "Seleccionar fecha"
        case .italian: return "Seleziona data"
        case .dutch: return "Selecteer datum"
        case .portuguese: return "Selecionar data"
        case .japanese: return "日付を選択"
        case .chinese: return "选择日期"
        default: return "Select Date"
        }
    }

    static var starts: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Beginnt"
        case .french: return "Début"
        case .spanish: return "Empieza"
        case .italian: return "Inizio"
        case .dutch: return "Begint"
        case .portuguese: return "Início"
        case .japanese: return "開始"
        case .chinese: return "开始"
        default: return "Starts"
        }
    }

    static var ends: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Endet"
        case .french: return "Fin"
        case .spanish: return "Termina"
        case .italian: return "Fine"
        case .dutch: return "Eindigt"
        case .portuguese: return "Término"
        case .japanese: return "終了"
        case .chinese: return "结束"
        default: return "Ends"
        }
    }

    static var save: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Sichern"
        case .french: return "Enregistrer"
        case .spanish: return "Guardar"
        case .italian: return "Salva"
        case .dutch: return "Bewaren"
        case .portuguese: return "Salvar"
        case .japanese: return "保存"
        case .chinese: return "保存"
        default: return "Save"
        }
    }

    static var add: String {
        let lang = currentLanguage
        switch lang {
        case .german: return "Hinzufügen"
        case .french: return "Ajouter"
        case .spanish: return "Añadir"
        case .italian: return "Aggiungi"
        case .dutch: return "Toevoegen"
        case .portuguese: return "Adicionar"
        case .japanese: return "追加"
        case .chinese: return "添加"
        default: return "Add"
        }
    }

    private static var currentLanguage: AppLanguage {
        let stored = UserDefaults.standard.string(forKey: "appLanguage") ?? "system"
        if stored == "system" {
            // Get system language from preferred languages
            if let preferredLang = Locale.preferredLanguages.first {
                let langCode = String(preferredLang.prefix(2))
                return AppLanguage(rawValue: langCode) ?? .english
            }
            return .english
        }
        return AppLanguage(rawValue: stored) ?? .english
    }
}

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system = "system"
    case english = "en"
    case german = "de"
    case french = "fr"
    case spanish = "es"
    case italian = "it"
    case dutch = "nl"
    case portuguese = "pt"
    case japanese = "ja"
    case chinese = "zh-Hans"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            return "System Default"
        case .english:
            return "English"
        case .german:
            return "Deutsch"
        case .french:
            return "Français"
        case .spanish:
            return "Español"
        case .italian:
            return "Italiano"
        case .dutch:
            return "Nederlands"
        case .portuguese:
            return "Português"
        case .japanese:
            return "日本語"
        case .chinese:
            return "简体中文"
        }
    }

    var locale: Locale {
        if self == .system {
            return Locale.current
        }
        return Locale(identifier: rawValue)
    }

    // Thread-safe access to current locale (reads directly from UserDefaults)
    static var currentLocale: Locale {
        let stored = UserDefaults.standard.string(forKey: "appLanguage") ?? "system"
        if stored == "system" {
            return Locale.current
        }
        let language = AppLanguage(rawValue: stored) ?? .system
        return language.locale
    }
}

@MainActor
class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var selectedLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "appLanguage")
            NSUbiquitousKeyValueStore.default.set(selectedLanguage.rawValue, forKey: "appLanguage")
            updateLocale()
        }
    }

    @Published var currentLocale: Locale

    private init() {
        // Load from iCloud first, then UserDefaults
        let stored = NSUbiquitousKeyValueStore.default.string(forKey: "appLanguage")
            ?? UserDefaults.standard.string(forKey: "appLanguage")
            ?? "system"

        let language = AppLanguage(rawValue: stored) ?? .system
        self.selectedLanguage = language
        self.currentLocale = language.locale
    }

    private func updateLocale() {
        currentLocale = selectedLanguage.locale
    }

    // Localized date formatter
    func dateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateFormat = format
        return formatter
    }

    // Common formatted strings
    func formatDate(_ date: Date, style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateStyle = style
        return formatter.string(from: date)
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    func formatDayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    func formatShortDayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    func formatMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    func formatShortMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }
}
