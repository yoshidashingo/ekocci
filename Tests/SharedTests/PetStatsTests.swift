import Testing
@testable import EkocciShared

@Suite("PetStats Tests")
struct PetStatsTests {

    @Test("初期値が正しい")
    func initialValues() {
        let stats = PetStats.initial
        #expect(stats.hunger == 4)
        #expect(stats.happiness == 4)
        #expect(stats.weight == 5)
    }

    @Test("ごはんでおなか+1, たいじゅう+1")
    func feedMeal() {
        let stats = PetStats(hunger: 2, happiness: 3, weight: 10)
        let result = stats.fed()
        #expect(result.hunger == 3)
        #expect(result.happiness == 3)
        #expect(result.weight == 11)
    }

    @Test("ごはんはおなか上限を超えない")
    func feedMealCapped() {
        let stats = PetStats(hunger: 4, happiness: 3, weight: 10)
        let result = stats.fed()
        #expect(result.hunger == 4)
        #expect(result.weight == 11)
    }

    @Test("おやつでごきげん+1, たいじゅう+2")
    func feedSnack() {
        let stats = PetStats(hunger: 3, happiness: 1, weight: 10)
        let result = stats.snacked()
        #expect(result.hunger == 3)
        #expect(result.happiness == 2)
        #expect(result.weight == 12)
    }

    @Test("ミニゲーム勝利でごきげん+1, たいじゅう-1")
    func playAndWin() {
        let stats = PetStats(hunger: 3, happiness: 2, weight: 10)
        let result = stats.playedAndWon()
        #expect(result.happiness == 3)
        #expect(result.weight == 9)
    }

    @Test("たいじゅうは最低値を下回らない")
    func weightFloor() {
        let stats = PetStats(hunger: 3, happiness: 2, weight: 5)
        let result = stats.playedAndWon()
        #expect(result.weight == 5)
    }

    @Test("おなか減衰")
    func hungerDecay() {
        let stats = PetStats(hunger: 3, happiness: 4, weight: 10)
        let result = stats.hungerDecayed()
        #expect(result.hunger == 2)
    }

    @Test("おなかは0未満にならない")
    func hungerFloor() {
        let stats = PetStats(hunger: 0, happiness: 4, weight: 10)
        let result = stats.hungerDecayed()
        #expect(result.hunger == 0)
    }

    @Test("イミュータブル: 元のstatsが変わらない")
    func immutability() {
        let original = PetStats(hunger: 2, happiness: 3, weight: 10)
        let _ = original.fed()
        #expect(original.hunger == 2)
        #expect(original.weight == 10)
    }
}
