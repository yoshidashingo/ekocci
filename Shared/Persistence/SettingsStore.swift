import Foundation

/// ユーザー設定の管理
/// @unchecked Sendable: UserDefaults の個別 get/set はスレッドセーフ
final class SettingsStore: @unchecked Sendable {
    private static let soundKey = "ekocci_sound_enabled"
    private static let notificationKey = "ekocci_notifications_enabled"
    private static let pauseLimitKey = "ekocci_pause_limit_minutes"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = AppGroupConfig.sharedDefaults) {
        self.defaults = defaults
    }

    // MARK: - Sound

    var isSoundEnabled: Bool {
        get { defaults.object(forKey: Self.soundKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Self.soundKey) }
    }

    // MARK: - Notifications

    var isNotificationsEnabled: Bool {
        get { defaults.object(forKey: Self.notificationKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Self.notificationKey) }
    }

    // MARK: - Pause Limit

    var pauseLimitMinutes: Int {
        get {
            let value = defaults.integer(forKey: Self.pauseLimitKey)
            return value > 0 ? value : GameConfig.maxPauseMinutesPerDay
        }
        set { defaults.set(min(max(1, newValue), GameConfig.maxPauseMinutesPerDay), forKey: Self.pauseLimitKey) }
    }
}
