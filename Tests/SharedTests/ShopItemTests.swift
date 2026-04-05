import Testing
import Foundation
@testable import EkocciShared

@Suite("ShopItem & ActiveEffect Tests")
struct ShopItemTests {

    @Test("カタログに2アイテムある")
    func catalogCount() {
        #expect(ShopItem.catalog.count == 2)
    }

    @Test("各アイテムにコストがある")
    func itemsHaveCost() {
        for item in ShopItem.catalog {
            #expect(item.cost > 0)
            #expect(item.durationSeconds > 0)
            #expect(!item.name.isEmpty)
        }
    }

    @Test("ActiveEffectが有効期間内はtrue")
    func effectIsActive() {
        let now = Date.now
        let effect = ActiveEffect(type: .speedBoost, activatedAt: now, durationSeconds: 3600)
        #expect(effect.isActive(at: now.addingTimeInterval(1800)))
    }

    @Test("ActiveEffectが期限切れでfalse")
    func effectExpired() {
        let now = Date.now
        let effect = ActiveEffect(type: .speedBoost, activatedAt: now, durationSeconds: 3600)
        #expect(!effect.isActive(at: now.addingTimeInterval(3601)))
    }

    @Test("残り時間の計算")
    func remainingSeconds() {
        let now = Date.now
        let effect = ActiveEffect(type: .luckyCharm, activatedAt: now, durationSeconds: 3600)
        #expect(effect.remainingSeconds(at: now.addingTimeInterval(1000)) == 2600)
    }

    @Test("残り時間は0未満にならない")
    func remainingFloor() {
        let now = Date.now
        let effect = ActiveEffect(type: .luckyCharm, activatedAt: now, durationSeconds: 100)
        #expect(effect.remainingSeconds(at: now.addingTimeInterval(200)) == 0)
    }
}
