import Foundation

/// ショップアイテム種別
enum ShopItemType: String, Codable, CaseIterable, Sendable {
    case speedBoost    // 進化速度2倍 (1時間)
    case luckyCharm    // ティアアップ確率+10%
}

/// ショップアイテム定義
struct ShopItem: Identifiable, Sendable {
    let type: ShopItemType
    let name: String
    let description: String
    let cost: Int
    let durationSeconds: TimeInterval

    var id: String { type.rawValue }

    /// MVP カタログ
    static let catalog: [ShopItem] = [
        ShopItem(
            type: .speedBoost,
            name: "スピードブースト",
            description: "進化速度が2倍になる (1時間)",
            cost: 200,
            durationSeconds: 60 * 60
        ),
        ShopItem(
            type: .luckyCharm,
            name: "ラッキーチャーム",
            description: "良いキャラに進化しやすくなる (1時間)",
            cost: 300,
            durationSeconds: 60 * 60
        ),
    ]
}
