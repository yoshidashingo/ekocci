import Foundation

/// 有効中のショップ効果
struct ActiveEffect: Codable, Equatable, Sendable {
    let type: ShopItemType
    let activatedAt: Date
    let durationSeconds: TimeInterval

    /// 指定時刻で有効か
    func isActive(at date: Date) -> Bool {
        date.timeIntervalSince(activatedAt) < durationSeconds
    }

    /// 残り時間(秒) — 0以下は期限切れ
    func remainingSeconds(at date: Date) -> TimeInterval {
        max(0, durationSeconds - date.timeIntervalSince(activatedAt))
    }
}
