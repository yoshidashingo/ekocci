import Testing
import Foundation
@testable import EkocciShared

@Suite("DiscoveryStore Tests")
struct DiscoveryStoreTests {

    private func makeStore() -> DiscoveryStore {
        let defaults = UserDefaults(suiteName: "test.discovery.\(UUID().uuidString)")!
        return DiscoveryStore(defaults: defaults)
    }

    @Test("初期状態は空")
    func emptyByDefault() {
        let store = makeStore()
        #expect(store.discoveredCount() == 0)
        #expect(store.allDiscovered().isEmpty)
    }

    @Test("キャラクターを発見できる")
    func discoverCharacter() {
        let store = makeStore()
        store.discover("child_genki")
        #expect(store.isDiscovered("child_genki"))
        #expect(store.discoveredCount() == 1)
    }

    @Test("同じキャラクターを二重登録しない")
    func noDuplicates() {
        let store = makeStore()
        store.discover("child_genki")
        store.discover("child_genki")
        #expect(store.discoveredCount() == 1)
    }

    @Test("複数キャラクターを発見できる")
    func multipleDiscoveries() {
        let store = makeStore()
        store.discover("child_genki")
        store.discover("adult_wise")
        store.discover("senior_sage")
        #expect(store.discoveredCount() == 3)
        #expect(store.isDiscovered("adult_wise"))
    }

    @Test("未発見キャラクターはfalse")
    func undiscoveredIsFalse() {
        let store = makeStore()
        #expect(!store.isDiscovered("nonexistent"))
    }
}
