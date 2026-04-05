import Foundation

/// コンプリケーション用の軽量ペットデータ
struct PetSnapshot: Sendable, Equatable {
    let characterId: String
    let characterName: String
    let stage: LifeStage
    let hunger: Int
    let happiness: Int
    let isSick: Bool
    let isSleeping: Bool

    /// 表示用絵文字
    var emoji: String {
        SpriteMapping.emoji(for: characterId)
    }

    /// Pet から生成
    static func from(_ pet: Pet) -> PetSnapshot {
        let charDef = CharacterRegistry.character(id: pet.characterId)
        return PetSnapshot(
            characterId: pet.characterId,
            characterName: charDef?.name ?? pet.characterId,
            stage: pet.stage,
            hunger: pet.stats.hunger,
            happiness: pet.stats.happiness,
            isSick: pet.isSick,
            isSleeping: pet.isSleeping
        )
    }

    /// プレースホルダー
    static let placeholder = PetSnapshot(
        characterId: "egg",
        characterName: "たまご",
        stage: .egg,
        hunger: 4,
        happiness: 4,
        isSick: false,
        isSleeping: false
    )
}
