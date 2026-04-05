import Foundation

/// 隠しステータス (進化分岐に影響)
/// effort: お世話の頑張り度 (ごはん、そうじ、しつけで上昇)
/// bonding: なかよし度 (ミニゲームで上昇)
struct HiddenStats: Codable, Equatable, Sendable {
    let effort: Int    // 0-100
    let bonding: Int   // 0-100

    static let initial = HiddenStats(effort: 0, bonding: 0)

    private static let maxValue = 100
    private static let minValue = 0

    func addingEffort(_ amount: Int) -> HiddenStats {
        HiddenStats(
            effort: min(Self.maxValue, max(Self.minValue, effort + amount)),
            bonding: bonding
        )
    }

    func addingBonding(_ amount: Int) -> HiddenStats {
        HiddenStats(
            effort: effort,
            bonding: min(Self.maxValue, max(Self.minValue, bonding + amount))
        )
    }
}
