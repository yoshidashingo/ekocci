import Testing
import Foundation
@testable import EkocciShared

@Suite("GameEngine Tests")
struct GameEngineTests {

    private func makeDate(_ string: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)!
    }

    // MARK: - たまご孵化

    @Test("たまごは30秒後に孵化する")
    func eggHatches() {
        let birthDate = Date.now
        let pet = Pet.newEgg(at: birthDate)
        let after35sec = birthDate.addingTimeInterval(35)

        let result = GameEngine.advance(pet: pet, from: birthDate, to: after35sec)
        #expect(result.stage == .baby)
    }

    @Test("たまごは30秒前には孵化しない")
    func eggDoesNotHatchEarly() {
        let birthDate = Date.now
        let pet = Pet.newEgg(at: birthDate)
        let after20sec = birthDate.addingTimeInterval(20)

        let result = GameEngine.advance(pet: pet, from: birthDate, to: after20sec)
        #expect(result.stage == .egg)
    }

    // MARK: - ごはん

    @Test("ごはんを食べさせるとおなかが増える")
    func feedIncreaseHunger() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.stats = PetStats(hunger: 2, happiness: 3, weight: 10)

        let result = GameEngine.feed(pet: pet, at: .now)
        #expect(result.stats.hunger == 3)
        #expect(result.stats.weight == 11)
    }

    @Test("寝ているときはごはんを食べられない")
    func cannotFeedWhileSleeping() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.isSleeping = true
        pet.stats = PetStats(hunger: 2, happiness: 3, weight: 10)

        let result = GameEngine.feed(pet: pet, at: .now)
        #expect(result.stats.hunger == 2)
    }

    // MARK: - そうじ

    @Test("そうじでうんちが消える")
    func cleanRemovesPoop() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.poopCount = 3

        let result = GameEngine.clean(pet: pet, at: .now)
        #expect(result.poopCount == 0)
    }

    // MARK: - くすり

    @Test("くすりで病気が治る")
    func medicineHeals() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.isSick = true
        pet.medicineDosesNeeded = 2

        let dose1 = GameEngine.giveMedicine(pet: pet, at: .now)
        #expect(dose1.isSick == true)
        #expect(dose1.medicineDosesNeeded == 1)

        let dose2 = GameEngine.giveMedicine(pet: dose1, at: .now)
        #expect(dose2.isSick == false)
        #expect(dose2.medicineDosesNeeded == 0)
    }

    // MARK: - しつけ

    @Test("しつけでメーターが25%増える")
    func disciplineIncreases() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.discipline = 25

        let result = GameEngine.discipline(pet: pet, at: .now)
        #expect(result.discipline == 50)
    }

    @Test("しつけは100%を超えない")
    func disciplineCapped() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.discipline = 100

        let result = GameEngine.discipline(pet: pet, at: .now)
        #expect(result.discipline == 100)
    }

    // MARK: - でんき

    @Test("寝ているときにでんきを消せる")
    func lightOff() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.isSleeping = true
        pet.isLightOff = false

        let result = GameEngine.turnLightOff(pet: pet, at: .now)
        #expect(result.isLightOff == true)
    }

    // MARK: - 一時停止

    @Test("一時停止中はステータスが変わらない")
    func pauseFreezesStats() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.stats = PetStats(hunger: 3, happiness: 3, weight: 10)
        pet.isPaused = true

        let twoHoursLater = Date.now.addingTimeInterval(2 * 60 * 60)
        let result = GameEngine.advance(pet: pet, from: .now, to: twoHoursLater)
        #expect(result.stats.hunger == 3)
        #expect(result.stats.happiness == 3)
    }

    // MARK: - 死亡

    @Test("死亡状態ではadvanceしても変わらない")
    func deadPetDoesNotChange() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .dead

        let result = GameEngine.advance(pet: pet, from: .now, to: .now.addingTimeInterval(3600))
        #expect(result.stage == .dead)
    }

    // MARK: - ミニゲーム

    @Test("ミニゲーム勝利でエコポイント獲得")
    func miniGameWinPoints() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.ecoPoints = 100

        let result = GameEngine.miniGameWon(pet: pet, at: .now)
        #expect(result.ecoPoints == 150)
        #expect(result.stats.happiness == PetStats.maxHearts) // 初期値は満タンなのでキャップ
    }

    // MARK: - 次世代

    @Test("次世代はgeneration+1で初期化される")
    func nextGeneration() {
        var pet = Pet.newEgg(at: .now)
        pet.generation = 3
        pet.stage = .dead

        let next = GameEngine.newGeneration(from: pet, at: .now)
        #expect(next.generation == 4)
        #expect(next.stage == .egg)
        #expect(next.ecoPoints == 300) // (4-1) * 100
    }
}
