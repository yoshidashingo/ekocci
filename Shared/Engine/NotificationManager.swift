import Foundation
import UserNotifications

/// 通知の種類
enum NotificationType: String, Sendable {
    case hungerLow = "hunger_low"
    case happinessLow = "happiness_low"
    case sickAlert = "sick_alert"

    var title: String {
        switch self {
        case .hungerLow: return "おなかがすいているよ!"
        case .happinessLow: return "さみしがっているよ!"
        case .sickAlert: return "びょうきだよ! くすりをあげて!"
        }
    }
}

/// お世話リマインダー通知の管理
enum NotificationManager {

    private static let dailyCountKey = "ekocci_notification_count"
    private static let lastDateKey = "ekocci_notification_date"

    // MARK: - Permission

    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    // MARK: - Schedule

    /// ペットの状態に応じて通知をスケジュール
    static func scheduleIfNeeded(for pet: Pet, defaults: UserDefaults = AppGroupConfig.sharedDefaults) {
        let dailyCount = currentDailyCount(defaults: defaults)
        let needed = notificationsNeeded(for: pet, dailyCount: dailyCount)
        guard !needed.isEmpty else { return }

        needed.forEach { scheduleLocal(type: $0) }
        // アトミックに合計を書き込む (TOCTOU防止)
        defaults.set(dailyCount + needed.count, forKey: dailyCountKey)
    }

    /// 全通知をキャンセル
    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Pure Logic (テスタブル)

    /// ペットの状態から必要な通知を判定
    static func notificationsNeeded(for pet: Pet, dailyCount: Int) -> [NotificationType] {
        guard pet.stage != .egg, pet.stage != .dead else { return [] }
        guard dailyCount < GameConfig.maxNotificationsPerDay else { return [] }

        var result: [NotificationType] = []
        let remaining = GameConfig.maxNotificationsPerDay - dailyCount

        if pet.stats.hunger == 0 && result.count < remaining {
            result.append(.hungerLow)
        }
        if pet.stats.happiness == 0 && result.count < remaining {
            result.append(.happinessLow)
        }
        if pet.isSick && result.count < remaining {
            result.append(.sickAlert)
        }

        return result
    }

    // MARK: - Daily Count

    static func currentDailyCount(defaults: UserDefaults = AppGroupConfig.sharedDefaults) -> Int {
        let today = Calendar.current.startOfDay(for: .now)
        let lastDate = defaults.object(forKey: lastDateKey) as? Date

        if let lastDate, Calendar.current.isDate(lastDate, inSameDayAs: today) {
            return defaults.integer(forKey: dailyCountKey)
        }
        // 日付が変わったらリセット
        defaults.set(0, forKey: dailyCountKey)
        defaults.set(today, forKey: lastDateKey)
        return 0
    }

    // MARK: - UNUserNotificationCenter

    private static func scheduleLocal(type: NotificationType) {
        let content = UNMutableNotificationContent()
        content.title = "エコちっち"
        content.body = type.title
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15 * 60, repeats: false)
        let request = UNNotificationRequest(
            identifier: type.rawValue,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
