import Testing
import Foundation
@testable import EkocciShared

@Suite("GameEngine Performance Tests")
struct GameEnginePerformanceTests {

    @Test("48時間キャッチアップが100ms以内で完了する")
    func catchUpPerformance() {
        let birthDate = Date(timeIntervalSince1970: 1_000_000)
        var pet = Pet.newEgg(at: birthDate)
        // 孵化済みにする
        pet.stage = .child
        pet.characterId = "child_genki"
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 10)
        pet.stageStartDate = birthDate
        pet.lastUpdateTime = birthDate

        let fortyEightHoursLater = birthDate.addingTimeInterval(48 * 60 * 60)

        let clock = ContinuousClock()
        let elapsed = clock.measure {
            let _ = GameEngine.advance(pet: pet, from: birthDate, to: fortyEightHoursLater)
        }

        // 100ms 以内であること
        #expect(elapsed < .milliseconds(100), "48h catch-up took \(elapsed)")
    }

    @Test("1週間キャッチアップ(クランプ48h)も100ms以内")
    func weekCatchUpPerformance() {
        let birthDate = Date(timeIntervalSince1970: 1_000_000)
        var pet = Pet.newEgg(at: birthDate)
        pet.stage = .adult
        pet.characterId = "adult_wise"
        pet.stats = PetStats(hunger: 2, happiness: 2, weight: 10)
        pet.stageStartDate = birthDate
        pet.lastUpdateTime = birthDate

        let oneWeekLater = birthDate.addingTimeInterval(7 * 24 * 60 * 60)

        let clock = ContinuousClock()
        let elapsed = clock.measure {
            let _ = GameEngine.advance(pet: pet, from: birthDate, to: oneWeekLater)
        }

        #expect(elapsed < .milliseconds(100), "1-week catch-up took \(elapsed)")
    }
}
