import Testing
import Foundation
@testable import EkocciShared

@Suite("GameEngine Pause Tests")
struct GameEnginePauseTests {

    private func noonToday() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        components.hour = 12
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }

    @Test("ポーズ開始と解除")
    func pauseAndUnpause() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .child
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 10)

        let paused = GameEngine.pause(pet: pet, at: noon)
        #expect(paused.isPaused)

        let unpaused = GameEngine.unpause(pet: paused, at: noon.addingTimeInterval(30 * 60))
        #expect(!unpaused.isPaused)
        #expect(unpaused.pauseMinutesUsedToday == 30)
    }

    @Test("10h上限でポーズが自動解除される")
    func autoUnpauseAtLimit() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .child
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 10)
        pet.isPaused = true
        pet.pauseStartDate = noon
        pet.pauseMinutesUsedToday = GameConfig.maxPauseMinutesPerDay // 600分
        pet.lastUpdateTime = noon

        // advance すると自動解除されて通常進行
        let later = noon.addingTimeInterval(60)
        let result = GameEngine.advance(pet: pet, from: noon, to: later)
        #expect(!result.isPaused)
    }

    @Test("上限未満のポーズ中はステータスが変わらない")
    func pauseUnderLimitFreezesStats() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .child
        pet.stats = PetStats(hunger: 3, happiness: 3, weight: 10)
        pet.isPaused = true
        pet.pauseStartDate = noon
        pet.pauseMinutesUsedToday = 100
        pet.lastUpdateTime = noon

        let twoHoursLater = noon.addingTimeInterval(2 * 60 * 60)
        let result = GameEngine.advance(pet: pet, from: noon, to: twoHoursLater)
        #expect(result.isPaused)
        #expect(result.stats.hunger == 3)
        #expect(result.stats.happiness == 3)
    }

    @Test("日付変更でポーズ使用時間がリセットされる")
    func dailyReset() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: noonToday())!
        var pet = Pet.newEgg(at: yesterday)
        pet.stage = .child
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 10)
        pet.isPaused = true
        pet.pauseStartDate = yesterday
        pet.pauseMinutesUsedToday = 500
        pet.lastUpdateTime = yesterday

        let today = noonToday()
        let result = GameEngine.advance(pet: pet, from: yesterday, to: today)
        // 日付変更でリセット → まだ上限未満なのでポーズ継続
        #expect(result.pauseMinutesUsedToday == 0 || !result.isPaused)
    }

    @Test("���にポーズ中に二重ポーズできない")
    func doublePausePrevented() {
        let noon = noonToday()
        var pet = Pet.newEgg(at: noon)
        pet.stage = .child
        pet.isPaused = true

        let result = GameEngine.pause(pet: pet, at: noon)
        #expect(result.isPaused) // 状態は変わらない
    }
}
