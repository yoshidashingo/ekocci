import Testing
import Foundation
@testable import EkocciShared

@Suite("Pet Model Tests")
struct PetModelTests {

    // MARK: - ファクトリ

    @Test("新しいたまごの初期値が正しい")
    func newEggDefaults() {
        let pet = Pet.newEgg(generation: 1, at: .now)

        #expect(pet.stage == .egg)
        #expect(pet.characterId == "egg")
        #expect(pet.stats == PetStats.initial)
        #expect(pet.discipline == 0)
        #expect(pet.age == 0)
        #expect(pet.generation == 1)
        #expect(pet.careMisses == 0)
        #expect(pet.isSleeping == false)
        #expect(pet.isSick == false)
        #expect(pet.poopCount == 0)
        #expect(pet.isPaused == false)
        #expect(pet.ecoPoints == 0)
    }

    @Test("世代ボーナスのエコポイント")
    func generationBonus() {
        let gen1 = Pet.newEgg(generation: 1, at: .now)
        let gen3 = Pet.newEgg(generation: 3, at: .now)
        let gen5 = Pet.newEgg(generation: 5, at: .now)

        #expect(gen1.ecoPoints == 0)
        #expect(gen3.ecoPoints == 200)
        #expect(gen5.ecoPoints == 400)
    }

    // MARK: - 寿命

    @Test("お世話ミス0で最大寿命25日")
    func maxLifespan() {
        var pet = Pet.newEgg(at: .now)
        pet.careMisses = 0

        let expectedSeconds = 25.0 * 24 * 60 * 60
        #expect(pet.maxLifespanSeconds == expectedSeconds)
    }

    @Test("お世話ミス5で寿命20日")
    func reducedLifespan() {
        var pet = Pet.newEgg(at: .now)
        pet.careMisses = 5

        let expectedSeconds = 20.0 * 24 * 60 * 60
        #expect(pet.maxLifespanSeconds == expectedSeconds)
    }

    @Test("hasReachedLifespanはおとな/シニアのみで判定")
    func lifespanOnlyForAdults() {
        var pet = Pet.newEgg(at: Date.now.addingTimeInterval(-30 * 24 * 60 * 60))
        pet.stage = .child
        #expect(pet.hasReachedLifespan(at: .now) == false)

        pet.stage = .adult
        #expect(pet.hasReachedLifespan(at: .now) == true)
    }

    // MARK: - 生存時間

    @Test("生存時間の計算")
    func aliveSeconds() {
        let birth = Date.now
        let pet = Pet.newEgg(at: birth)
        let oneDay = birth.addingTimeInterval(24 * 60 * 60)

        #expect(pet.aliveSeconds(at: oneDay) == 24 * 60 * 60)
    }
}

@Suite("LifeStage Tests")
struct LifeStageTests {

    @Test("たまごの次はあかちゃん")
    func eggNextIsBaby() {
        #expect(LifeStage.egg.next == .baby)
    }

    @Test("死亡の次はない")
    func deadHasNoNext() {
        #expect(LifeStage.dead.next == nil)
    }

    @Test("たまごとあかちゃんはミニゲーム不可")
    func cannotPlayGames() {
        #expect(LifeStage.egg.canPlayGames == false)
        #expect(LifeStage.baby.canPlayGames == false)
        #expect(LifeStage.child.canPlayGames == true)
        #expect(LifeStage.adult.canPlayGames == true)
    }

    @Test("就寝時刻が正しい")
    func bedtimeHours() {
        #expect(LifeStage.baby.bedtimeHour == 20)
        #expect(LifeStage.adult.bedtimeHour == 22)
    }

    @Test("うんち間隔が正しい")
    func poopIntervals() {
        #expect(LifeStage.baby.poopIntervalSeconds == 20 * 60)
        #expect(LifeStage.adult.poopIntervalSeconds == 3 * 60 * 60)
        #expect(LifeStage.egg.poopIntervalSeconds == .infinity)
    }

    @Test("ステージ期間が正しい")
    func stageDurations() {
        #expect(LifeStage.egg.durationSeconds == 30.0)
        #expect(LifeStage.baby.durationSeconds == 60 * 60.0)
        #expect(LifeStage.child.durationSeconds == 24 * 60 * 60.0)
        #expect(LifeStage.adult.durationSeconds == nil)
    }
}
