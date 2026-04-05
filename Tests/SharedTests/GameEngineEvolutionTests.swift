import Testing
import Foundation
@testable import EkocciShared

@Suite("GameEngine Evolution Tests")
struct GameEngineEvolutionTests {

    private func noonToday() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        components.hour = 12
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }

    // MARK: - ステージ遷移

    @Test("あかちゃんは1時間後にこどもになる")
    func babyToChild() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .baby
        pet.characterId = "baby_default"
        pet.stageStartDate = noon
        pet.lastUpdateTime = noon
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 5)

        let after65min = noon.addingTimeInterval(65 * 60)
        let result = GameEngine.advance(pet: pet, from: noon, to: after65min)
        #expect(result.stage == .child)
        #expect(result.careMissesInStage == 0)
    }

    @Test("こどもは24時間後にヤングになる")
    func childToYoung() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .child
        // stageStartDateを25時間前に設定して即遷移させる
        pet.stageStartDate = noon.addingTimeInterval(-25 * 60 * 60)
        pet.lastUpdateTime = noon
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 10)

        let result = GameEngine.advance(pet: pet, from: noon, to: noon.addingTimeInterval(1))
        #expect(result.stage == .young)
    }

    // MARK: - キャラクターID解決 (EvolutionEngine経由)
    // 短時間のadvance()でステージ遷移 + キャラクター解決をテスト

    @Test("お世話ミス0+しつけ100%でyoung_athlete")
    func goodCareEvolution() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .child
        pet.stageStartDate = noon.addingTimeInterval(-25 * 60 * 60)
        pet.lastUpdateTime = noon
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 7)
        pet.careMissesInStage = 0
        pet.discipline = 100

        let result = GameEngine.advance(pet: pet, from: noon, to: noon.addingTimeInterval(1))
        #expect(result.stage == .young)
        // 0ミス+100%しつけ+低体重 → young_athlete
        #expect(result.characterId == "young_athlete")
    }

    @Test("お世話ミス4+しつけ50%でyoung_dreamer (フォールバック)")
    func averageCareEvolution() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .child
        pet.stageStartDate = noon.addingTimeInterval(-25 * 60 * 60)
        pet.lastUpdateTime = noon
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 10)
        pet.careMissesInStage = 4
        pet.discipline = 50

        let result = GameEngine.advance(pet: pet, from: noon, to: noon.addingTimeInterval(1))
        #expect(result.stage == .young)
        #expect(result.characterId == "young_dreamer")
    }

    @Test("お世話ミス8+しつけ0%でyoung_rebel")
    func poorCareEvolution() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .child
        pet.stageStartDate = noon.addingTimeInterval(-25 * 60 * 60)
        pet.lastUpdateTime = noon
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 10)
        pet.careMissesInStage = 8
        pet.discipline = 0

        let result = GameEngine.advance(pet: pet, from: noon, to: noon.addingTimeInterval(1))
        #expect(result.stage == .young)
        #expect(result.characterId == "young_rebel")
    }

    // MARK: - ステージ遷移でお世話ミスカウンタがリセット

    @Test("進化時にcareMissesInStageがリセットされる")
    func careMissesResetOnEvolution() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .child
        pet.stageStartDate = noon.addingTimeInterval(-25 * 60 * 60)
        pet.lastUpdateTime = noon
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 10)
        pet.careMissesInStage = 3

        let result = GameEngine.advance(pet: pet, from: noon, to: noon.addingTimeInterval(1))
        #expect(result.careMissesInStage == 0)
    }
}
