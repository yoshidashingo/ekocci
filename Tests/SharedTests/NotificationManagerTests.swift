import Testing
import Foundation
@testable import EkocciShared

@Suite("NotificationManager Tests")
struct NotificationManagerTests {

    // MARK: - notificationsNeeded (純粋ロジック)

    @Test("おなか0で空腹通知が必要")
    func hungerLowNotification() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.stats = PetStats(hunger: 0, happiness: 3, weight: 8)

        let needed = NotificationManager.notificationsNeeded(for: pet, dailyCount: 0)
        #expect(needed.contains(.hungerLow))
    }

    @Test("ごきげん0でさみしい通知が必要")
    func happinessLowNotification() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.stats = PetStats(hunger: 3, happiness: 0, weight: 8)

        let needed = NotificationManager.notificationsNeeded(for: pet, dailyCount: 0)
        #expect(needed.contains(.happinessLow))
    }

    @Test("病気で病気通知が必要")
    func sickNotification() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.isSick = true

        let needed = NotificationManager.notificationsNeeded(for: pet, dailyCount: 0)
        #expect(needed.contains(.sickAlert))
    }

    @Test("健康なペットには通知不要")
    func healthyPetNoNotification() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.stats = PetStats(hunger: 3, happiness: 3, weight: 8)

        let needed = NotificationManager.notificationsNeeded(for: pet, dailyCount: 0)
        #expect(needed.isEmpty)
    }

    @Test("日3回上限で通知が止まる")
    func dailyLimitReached() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.stats = PetStats(hunger: 0, happiness: 0, weight: 8)
        pet.isSick = true

        let needed = NotificationManager.notificationsNeeded(for: pet, dailyCount: 3)
        #expect(needed.isEmpty)
    }

    @Test("残り1枠なら1通のみ")
    func partialLimit() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.stats = PetStats(hunger: 0, happiness: 0, weight: 8)

        let needed = NotificationManager.notificationsNeeded(for: pet, dailyCount: 2)
        #expect(needed.count == 1)
    }

    @Test("たまごには通知不要")
    func eggNoNotification() {
        let pet = Pet.newEgg(at: .now)
        let needed = NotificationManager.notificationsNeeded(for: pet, dailyCount: 0)
        #expect(needed.isEmpty)
    }

    @Test("死亡ペットには通知不要")
    func deadNoNotification() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .dead
        pet.stats = PetStats(hunger: 0, happiness: 0, weight: 5)

        let needed = NotificationManager.notificationsNeeded(for: pet, dailyCount: 0)
        #expect(needed.isEmpty)
    }
}
