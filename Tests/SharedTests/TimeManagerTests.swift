import Testing
import Foundation
@testable import EkocciShared

@Suite("TimeManager Tests")
struct TimeManagerTests {

    private func dateAt(hour: Int, minute: Int = 0) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return Calendar.current.date(from: components)!
    }

    @Test("おとなは22時〜8時に寝ている")
    func adultSleepSchedule() {
        #expect(TimeManager.shouldBeSleeping(stage: .adult, at: dateAt(hour: 23)) == true)
        #expect(TimeManager.shouldBeSleeping(stage: .adult, at: dateAt(hour: 2)) == true)
        #expect(TimeManager.shouldBeSleeping(stage: .adult, at: dateAt(hour: 7)) == true)
        #expect(TimeManager.shouldBeSleeping(stage: .adult, at: dateAt(hour: 8)) == false)
        #expect(TimeManager.shouldBeSleeping(stage: .adult, at: dateAt(hour: 12)) == false)
        #expect(TimeManager.shouldBeSleeping(stage: .adult, at: dateAt(hour: 21)) == false)
    }

    @Test("あかちゃんは20時〜9時に寝ている")
    func babySleepSchedule() {
        #expect(TimeManager.shouldBeSleeping(stage: .baby, at: dateAt(hour: 20)) == true)
        #expect(TimeManager.shouldBeSleeping(stage: .baby, at: dateAt(hour: 8)) == true)
        #expect(TimeManager.shouldBeSleeping(stage: .baby, at: dateAt(hour: 9)) == false)
        #expect(TimeManager.shouldBeSleeping(stage: .baby, at: dateAt(hour: 15)) == false)
    }

    @Test("たまごは寝ない")
    func eggNeverSleeps() {
        #expect(TimeManager.shouldBeSleeping(stage: .egg, at: dateAt(hour: 23)) == false)
    }

    @Test("ペット年齢の計算")
    func petAgeCalculation() {
        let birth = Date.now
        let oneDay = birth.addingTimeInterval(24 * 60 * 60)
        let twoDays = birth.addingTimeInterval(48 * 60 * 60)

        #expect(TimeManager.petAge(birthDate: birth, at: birth) == 0)
        #expect(TimeManager.petAge(birthDate: birth, at: oneDay) == 1)
        #expect(TimeManager.petAge(birthDate: birth, at: twoDays) == 2)
    }
}
