import Testing
import Foundation
@testable import EkocciShared

@Suite("ShopStore Tests")
struct ShopStoreTests {

    private func makeStore() -> ShopStore {
        let defaults = UserDefaults(suiteName: "test.shop.\(UUID().uuidString)")!
        return ShopStore(defaults: defaults)
    }

    private func makePet(ecoPoints: Int) -> Pet {
        var pet = Pet.newEgg(at: .now)
        pet.ecoPoints = ecoPoints
        return pet
    }

    @Test("十分なポイントで購入できる")
    func purchaseWithEnoughPoints() {
        let store = makeStore()
        let item = ShopItem.catalog[0] // speedBoost, 200pts
        let pet = makePet(ecoPoints: 500)

        let result = store.purchase(item: item, from: pet, at: .now)
        #expect(result != nil)
        #expect(result?.ecoPoints == 300)
    }

    @Test("ポイント不足で購入できない")
    func purchaseWithInsufficientPoints() {
        let store = makeStore()
        let item = ShopItem.catalog[0]
        let pet = makePet(ecoPoints: 50)

        #expect(store.purchase(item: item, from: pet, at: .now) == nil)
    }

    @Test("同じ効果がアクティブ中は購入できない")
    func cannotPurchaseDuplicate() {
        let store = makeStore()
        let item = ShopItem.catalog[0]
        let pet = makePet(ecoPoints: 1000)

        let pet2 = store.purchase(item: item, from: pet, at: .now)!
        #expect(store.purchase(item: item, from: pet2, at: .now) == nil)
    }

    @Test("期限切れ効果は除外される")
    func expiredEffectsPruned() {
        let store = makeStore()
        let item = ShopItem.catalog[0] // 1 hour duration
        let pet = makePet(ecoPoints: 500)
        let now = Date.now

        let _ = store.purchase(item: item, from: pet, at: now)
        #expect(store.hasActiveEffect(.speedBoost, at: now))

        let twoHoursLater = now.addingTimeInterval(2 * 60 * 60)
        #expect(!store.hasActiveEffect(.speedBoost, at: twoHoursLater))
    }

    @Test("アクティブ効果一覧が正しい")
    func activeEffectsList() {
        let store = makeStore()
        let pet = makePet(ecoPoints: 1000)

        let pet2 = store.purchase(item: ShopItem.catalog[0], from: pet, at: .now)!
        let _ = store.purchase(item: ShopItem.catalog[1], from: pet2, at: .now)

        let effects = store.activeEffects(at: .now)
        #expect(effects.count == 2)
    }
}
