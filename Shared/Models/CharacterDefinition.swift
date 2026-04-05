import Foundation

/// キャラクター定義
struct CharacterDefinition: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let stage: LifeStage
    let emoji: String
    let condition: EvolutionCondition
    let priority: Int   // 高い方が先に評価される
}
