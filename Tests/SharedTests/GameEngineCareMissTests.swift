import Testing
import Foundation
@testable import EkocciShared

@Suite("GameEngine Care Miss Tests")
struct GameEngineCareMissTests {

    // MARK: - お世話ミス

    @Test("おなか0を15分以上放置するとお世話ミス")
    func hungerCareMiss() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.stageStartDate = .now
        pet.stats = PetStats(hunger: 0, happiness: 4, weight: 10)
        pet.hungerEmptySince = .now
        pet.careMisses = 0
        pet.careMissesInStage = 0

        // 猶予時間 (15分) 経過
        let after16min = Date.now.addingTimeInterval(16 * 60)
        let result = GameEngine.advance(pet: pet, from: .now, to: after16min)
        #expect(result.careMisses >= 1)
    }

    @Test("おなか0でも15分以内ならお世話ミスにならない")
    func hungerGracePeriod() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.stageStartDate = .now
        pet.stats = PetStats(hunger: 0, happiness: 4, weight: 10)
        pet.hungerEmptySince = .now
        pet.careMisses = 0

        let after10min = Date.now.addingTimeInterval(10 * 60)
        let result = GameEngine.advance(pet: pet, from: .now, to: after10min)
        #expect(result.careMisses == 0)
    }

    @Test("ごきげん0を15分以上放置するとお世話ミス")
    func happinessCareMiss() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.stageStartDate = .now
        pet.stats = PetStats(hunger: 4, happiness: 0, weight: 10)
        pet.happinessEmptySince = .now
        pet.careMisses = 0
        pet.careMissesInStage = 0

        let after16min = Date.now.addingTimeInterval(16 * 60)
        let result = GameEngine.advance(pet: pet, from: .now, to: after16min)
        #expect(result.careMisses >= 1)
    }

    @Test("ごはんを食べさせるとhungerEmptySinceがリセットされる")
    func feedResetsGracePeriod() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.stats = PetStats(hunger: 0, happiness: 4, weight: 10)
        pet.hungerEmptySince = .now

        let fed = GameEngine.feed(pet: pet, at: .now)
        #expect(fed.hungerEmptySince == nil)
    }
}
