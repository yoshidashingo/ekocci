import Testing
import Foundation
@testable import EkocciShared

@Suite("SettingsStore Tests")
struct SettingsStoreTests {

    private func makeStore() -> SettingsStore {
        let defaults = UserDefaults(suiteName: "test.settings.\(UUID().uuidString)")!
        return SettingsStore(defaults: defaults)
    }

    @Test("デフォルト値が正しい")
    func defaultValues() {
        let store = makeStore()
        #expect(store.isSoundEnabled == true)
        #expect(store.isNotificationsEnabled == true)
        #expect(store.pauseLimitMinutes == GameConfig.maxPauseMinutesPerDay)
    }

    @Test("サウンド設定の読み書き")
    func soundToggle() {
        let store = makeStore()
        store.isSoundEnabled = false
        #expect(store.isSoundEnabled == false)
        store.isSoundEnabled = true
        #expect(store.isSoundEnabled == true)
    }

    @Test("通知設定の読み書き")
    func notificationToggle() {
        let store = makeStore()
        store.isNotificationsEnabled = false
        #expect(store.isNotificationsEnabled == false)
    }

    @Test("一時停止上限の読み書き")
    func pauseLimit() {
        let store = makeStore()
        store.pauseLimitMinutes = 480
        #expect(store.pauseLimitMinutes == 480)
    }
}
