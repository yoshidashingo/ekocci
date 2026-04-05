import Foundation

/// キャラクターIDからビジュアル情報への変換
enum SpriteMapping {

    /// スプライト情報
    struct SpriteInfo: Equatable, Sendable {
        let emoji: String
        let tintHue: Double?       // nil = デフォルト色, 0-1 = 色相シフト
        let accessory: String?     // nil = なし, 絵文字アクセサリ
    }

    /// characterId → SpriteInfo
    static func spriteInfo(for characterId: String) -> SpriteInfo {
        mapping[characterId] ?? fallback(for: characterId)
    }

    /// characterId → 表示用絵文字
    static func emoji(for characterId: String) -> String {
        spriteInfo(for: characterId).emoji
    }

    // MARK: - Mapping Table

    private static let mapping: [String: SpriteInfo] = [
        // Baby
        "baby_default":      .init(emoji: "🐣", tintHue: nil, accessory: nil),

        // Child
        "child_genki":       .init(emoji: "⭐️", tintHue: 0.08, accessory: nil),        // やや黄色
        "child_shy":         .init(emoji: "🌸", tintHue: 0.95, accessory: nil),        // ピンク
        "child_rebel":       .init(emoji: "🔥", tintHue: 0.0, accessory: nil),         // 赤
        "child_lazy":        .init(emoji: "💤", tintHue: 0.6, accessory: nil),         // 青

        // Young
        "young_athlete":     .init(emoji: "🏃", tintHue: 0.08, accessory: "🏅"),
        "young_scholar":     .init(emoji: "📚", tintHue: 0.55, accessory: "🎓"),
        "young_artist":      .init(emoji: "🎨", tintHue: 0.8, accessory: "🖌️"),
        "young_rebel":       .init(emoji: "⚡️", tintHue: 0.0, accessory: "😤"),
        "young_dreamer":     .init(emoji: "🌙", tintHue: 0.7, accessory: "💭"),

        // Adult
        "adult_eco_master":  .init(emoji: "🌍", tintHue: 0.33, accessory: "🌱"),      // 緑
        "adult_wise":        .init(emoji: "🦉", tintHue: 0.12, accessory: "📖"),
        "adult_strong":      .init(emoji: "💪", tintHue: 0.05, accessory: "🏋️"),
        "adult_gentle":      .init(emoji: "🌿", tintHue: 0.38, accessory: "🍀"),
        "adult_gourmet":     .init(emoji: "🍳", tintHue: 0.08, accessory: "🍴"),
        "adult_wild":        .init(emoji: "🐺", tintHue: 0.0, accessory: "💥"),
        "adult_mystic":      .init(emoji: "🔮", tintHue: 0.75, accessory: "✨"),

        // Senior
        "senior_eternal":    .init(emoji: "✨", tintHue: 0.15, accessory: "👑"),
        "senior_sage":       .init(emoji: "🎓", tintHue: 0.12, accessory: "📜"),
        "senior_jolly":      .init(emoji: "😊", tintHue: 0.08, accessory: "🎵"),
        "senior_hermit":     .init(emoji: "🏔️", tintHue: 0.55, accessory: "🍃"),
        "senior_legend":     .init(emoji: "👑", tintHue: 0.15, accessory: "⭐️"),
    ]

    /// フォールバック: ステージ名からデフォルト情報を返す
    private static func fallback(for characterId: String) -> SpriteInfo {
        if characterId.hasPrefix("baby") {
            return .init(emoji: "🐣", tintHue: nil, accessory: nil)
        } else if characterId.hasPrefix("child") {
            return .init(emoji: "🐥", tintHue: nil, accessory: nil)
        } else if characterId.hasPrefix("young") {
            return .init(emoji: "🐤", tintHue: nil, accessory: nil)
        } else if characterId.hasPrefix("adult") {
            return .init(emoji: "🐔", tintHue: nil, accessory: nil)
        } else if characterId.hasPrefix("senior") {
            return .init(emoji: "🦉", tintHue: nil, accessory: nil)
        }
        return .init(emoji: "❓", tintHue: nil, accessory: nil)
    }
}
