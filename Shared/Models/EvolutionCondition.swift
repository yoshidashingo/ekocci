import Foundation

/// 進化条件: キャラクター選択の判定ルール
struct EvolutionCondition: Codable, Equatable, Sendable {
    let careMissRange: ClosedRange<Int>
    let disciplineRange: ClosedRange<Int>
    let weightRange: ClosedRange<Int>?
    let effortRange: ClosedRange<Int>?
    let bondingRange: ClosedRange<Int>?
    let generationMin: Int?

    /// デフォルトは全条件を満たす (フォールバック用)
    static let any = EvolutionCondition(
        careMissRange: 0...999,
        disciplineRange: 0...100,
        weightRange: nil,
        effortRange: nil,
        bondingRange: nil,
        generationMin: nil
    )

    /// ペットが条件を満たすか判定
    func matches(pet: Pet) -> Bool {
        guard careMissRange.contains(pet.careMissesInStage) else { return false }
        guard disciplineRange.contains(pet.discipline) else { return false }

        if let weightRange, !weightRange.contains(pet.stats.weight) {
            return false
        }
        if let effortRange, !effortRange.contains(pet.hiddenStats.effort) {
            return false
        }
        if let bondingRange, !bondingRange.contains(pet.hiddenStats.bonding) {
            return false
        }
        if let generationMin, pet.generation < generationMin {
            return false
        }
        return true
    }
}
