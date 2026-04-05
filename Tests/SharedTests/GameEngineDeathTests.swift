import Testing
import Foundation
@testable import EkocciShared

@Suite("GameEngine Death & Sickness Tests")
struct GameEngineDeathTests {

    private func noonToday() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        components.hour = 12
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }

    // MARK: - 病気

    @Test("うんち3個以上 + 放置時間で病気になる")
    func sicknessFromPoop() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .child
        pet.stageStartDate = noon
        pet.lastUpdateTime = noon
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 10)
        pet.poopCount = 3
        pet.lastPoopTime = noon.addingTimeInterval(-13 * 60)

        let result = GameEngine.advance(pet: pet, from: noon, to: noon.addingTimeInterval(1))
        #expect(result.isSick == true)
        #expect(result.medicineDosesNeeded == GameConfig.medicineDosesRequired)
    }

    @Test("うんち2個以下では病気にならない")
    func noSicknessWithFewPoop() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .child
        pet.stageStartDate = noon
        pet.lastUpdateTime = noon
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 10)
        pet.poopCount = 2
        pet.lastPoopTime = noon.addingTimeInterval(-13 * 60)

        let result = GameEngine.advance(pet: pet, from: noon, to: noon.addingTimeInterval(1))
        #expect(result.isSick == false)
    }

    // MARK: - 餓死

    @Test("おなか0を長時間放置すると死亡する")
    func starvationDeath() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .adult
        pet.stageStartDate = noon
        pet.lastUpdateTime = noon
        pet.stats = PetStats(hunger: 0, happiness: 4, weight: 10)
        // 13時間前からおなか0
        pet.hungerEmptySince = noon.addingTimeInterval(-13 * 60 * 60)

        // advance with minimal time to just trigger death check
        let result = GameEngine.advance(pet: pet, from: noon, to: noon.addingTimeInterval(1))
        #expect(result.stage == .dead)
    }

    @Test("おなか0でも12時間以内なら死なない")
    func noStarvationWithinThreshold() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .adult
        pet.stageStartDate = noon
        pet.lastUpdateTime = noon
        pet.stats = PetStats(hunger: 0, happiness: 4, weight: 10)
        pet.hungerEmptySince = noon.addingTimeInterval(-11 * 60 * 60)

        let result = GameEngine.advance(pet: pet, from: noon, to: noon.addingTimeInterval(1))
        #expect(result.stage != .dead)
    }

    // MARK: - 老衰

    @Test("寿命に達すると死亡する")
    func oldAgeDeath() {
        let birthDate = Date.now.addingTimeInterval(-26 * 24 * 60 * 60)
        var pet = Pet.newEgg(at: birthDate)
        pet.stage = .adult
        pet.stageStartDate = birthDate
        pet.lastUpdateTime = .now.addingTimeInterval(-1)
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 10)
        pet.careMisses = 0

        let result = GameEngine.advance(pet: pet, from: pet.lastUpdateTime, to: .now)
        #expect(result.stage == .dead)
    }

    @Test("お世話ミスが多いと寿命が短くなる")
    func careMissesReduceLifespan() {
        let pet = Pet.newEgg(at: .now)
        let petWith0Misses = pet
        var petWith10Misses = pet
        petWith10Misses.careMisses = 10

        #expect(petWith0Misses.maxLifespanSeconds > petWith10Misses.maxLifespanSeconds)
    }

    @Test("最低寿命は7日")
    func minimumLifespan() {
        var pet = Pet.newEgg(at: .now)
        pet.careMisses = 100

        let minDays = 7.0
        #expect(pet.maxLifespanSeconds == minDays * 24 * 60 * 60)
    }
}
