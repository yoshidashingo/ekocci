import Foundation

/// 進化先キャラクターの解決 (純粋関数)
enum EvolutionEngine {

    /// ペットの状態から次ステージのキャラクターIDを決定
    /// hasLuckyCharm: ラッキーチャーム効果 (careMissesInStage -2 補正)
    static func resolve(pet: Pet, nextStage: LifeStage, hasLuckyCharm: Bool = false) -> String {
        let candidates = CharacterRegistry.characters(for: nextStage)

        if hasLuckyCharm {
            var luckyPet = pet
            luckyPet.careMissesInStage = max(0, pet.careMissesInStage - 2)
            for character in candidates {
                if character.condition.matches(pet: luckyPet) {
                    return character.id
                }
            }
        }

        for character in candidates {
            if character.condition.matches(pet: pet) {
                return character.id
            }
        }
        return CharacterRegistry.defaultCharacter(for: nextStage).id
    }
}
