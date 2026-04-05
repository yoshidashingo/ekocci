import Testing
import Foundation
@testable import EkocciShared

@Suite("Pet Lifecycle E2E Tests")
struct PetLifecycleE2ETests {

    private func noonToday() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        components.hour = 10
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }

    @Test("フルライフサイクル: たまご → 孵化 → 進化 → 死亡 → 次世代")
    func fullLifecycle() {
        let birthDate = noonToday()
        var pet = Pet.newEgg(at: birthDate)
        var now = birthDate

        // 1. たまご → あかちゃん (30秒)
        #expect(pet.stage == .egg)
        now = now.addingTimeInterval(35)
        pet = GameEngine.advance(pet: pet, from: birthDate, to: now)
        #expect(pet.stage == .baby)

        // 2. お世話ループ: ごはん
        for _ in 0..<5 {
            pet = GameEngine.feed(pet: pet, at: now)
            now = now.addingTimeInterval(10 * 60)
            pet = GameEngine.advance(pet: pet, from: pet.lastUpdateTime, to: now)
        }
        #expect(pet.hiddenStats.effort > 0, "feed should increase effort")

        // 3. あかちゃん → こども (1時間)
        now = pet.stageStartDate.addingTimeInterval(65 * 60)
        pet = GameEngine.advance(pet: pet, from: pet.lastUpdateTime, to: now)
        #expect(pet.stage == .child)

        // 4. こども → ヤング (24時間) — こまめにお世話しながら
        let childStageStart = pet.stageStartDate
        for h in stride(from: 1.0, through: 25.0, by: 1.0) {
            now = childStageStart.addingTimeInterval(h * 60 * 60)
            pet = GameEngine.advance(pet: pet, from: pet.lastUpdateTime, to: now)
            if pet.stage == .dead { break }
            pet = GameEngine.feed(pet: pet, at: now)
            pet = GameEngine.snack(pet: pet, at: now)
        }
        #expect(pet.stage == .young || pet.stage == .adult) // 時間経過で飛ぶ可能性あり

        // 5. ヤング → おとな (3日) — こまめにお世話
        if pet.stage == .young {
            let youngStageStart = pet.stageStartDate
            for h in stride(from: 6.0, through: 78.0, by: 6.0) {
                now = youngStageStart.addingTimeInterval(h * 60 * 60)
                pet = GameEngine.advance(pet: pet, from: pet.lastUpdateTime, to: now)
                if pet.stage != .young { break }
                pet = GameEngine.feed(pet: pet, at: now)
                pet = GameEngine.snack(pet: pet, at: now)
            }
        }
        #expect(pet.stage == .adult || pet.stage == .senior)

        // 6. キャラクターIDが有効なレジストリIDである
        let charDef = CharacterRegistry.character(id: pet.characterId)
        #expect(charDef != nil, "characterId '\(pet.characterId)' not in registry")

        // 7. 寿命到達 → 死亡
        now = pet.birthDate.addingTimeInterval(pet.maxLifespanSeconds + 1)
        pet = GameEngine.advance(pet: pet, from: pet.lastUpdateTime, to: now)
        #expect(pet.stage == .dead)

        // 8. 次世代
        let nextGen = GameEngine.newGeneration(from: pet, at: now)
        #expect(nextGen.stage == .egg)
        #expect(nextGen.generation == pet.generation + 1)
        #expect(nextGen.ecoPoints == (nextGen.generation - 1) * 100)
    }

    @Test("餓死パス: おなか0 → 12時間放置 → 死亡")
    func starvationDeath() {
        let birthDate = Date(timeIntervalSince1970: 1_000_000)
        var pet = Pet.newEgg(at: birthDate)

        // 孵化させる
        var now = birthDate.addingTimeInterval(35)
        pet = GameEngine.advance(pet: pet, from: birthDate, to: now)
        #expect(pet.stage == .baby)

        // 長時間放置 → おなか0 → 猶予 → 餓死
        now = now.addingTimeInterval(13 * 60 * 60) // 13時間
        pet = GameEngine.advance(pet: pet, from: pet.lastUpdateTime, to: now)
        #expect(pet.stage == .dead)
    }

    @Test("病死パス: うんち放置 → 病気 → 18時間放置 → 死亡")
    func sicknessDeath() {
        let birthDate = Date(timeIntervalSince1970: 1_000_000)
        var pet = Pet.newEgg(at: birthDate)

        // 孵化 → こどもまで進める
        var now = birthDate.addingTimeInterval(35)
        pet = GameEngine.advance(pet: pet, from: birthDate, to: now)
        pet.stage = .child
        pet.stageStartDate = now

        // うんち3個たまる状態を作る
        pet.poopCount = 3
        pet.lastPoopTime = now

        // 12分後に病気発生
        now = now.addingTimeInterval(15 * 60)
        pet = GameEngine.advance(pet: pet, from: pet.lastUpdateTime, to: now)
        #expect(pet.isSick)

        // 18時間放置 → 病死
        now = now.addingTimeInterval(19 * 60 * 60)
        pet = GameEngine.advance(pet: pet, from: pet.lastUpdateTime, to: now)
        #expect(pet.stage == .dead)
    }
}
