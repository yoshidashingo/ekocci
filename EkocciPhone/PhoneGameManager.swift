import Foundation
import Observation

/// iPhone アプリの状態管理
@MainActor
@Observable
final class PhoneGameManager {
    let connectivity: PhoneConnectivityManager
    private let store: PetStore
    let discoveryStore: DiscoveryStore
    let shopStore: ShopStore
    let settingsStore: SettingsStore

    /// Watch からの最新 pet、またはローカルフォールバック
    private(set) var cachedPet: Pet?

    init(
        connectivity: PhoneConnectivityManager = PhoneConnectivityManager(),
        store: PetStore = PetStore(),
        discoveryStore: DiscoveryStore = DiscoveryStore(),
        shopStore: ShopStore = ShopStore(),
        settingsStore: SettingsStore = SettingsStore()
    ) {
        self.connectivity = connectivity
        self.store = store
        self.discoveryStore = discoveryStore
        self.shopStore = shopStore
        self.settingsStore = settingsStore
    }

    /// 現在のペット (Watch優先、フォールバックでローカル)
    var pet: Pet? {
        connectivity.currentPet ?? cachedPet
    }

    var isWatchReachable: Bool {
        connectivity.isWatchReachable
    }

    /// 起動時にローカルデータをロード
    func loadLocal() async {
        cachedPet = await store.loadPet()
    }

    // MARK: - Remote Care Actions

    func feedMeal() {
        connectivity.sendCareAction(.feedMeal)
    }

    func feedSnack() {
        connectivity.sendCareAction(.feedSnack)
    }

    // MARK: - Shop

    func purchaseItem(_ item: ShopItem) async -> Bool {
        guard let currentPet = pet else { return false }
        guard let updatedPet = shopStore.purchase(item: item, from: currentPet, at: .now) else { return false }
        await store.savePet(updatedPet)
        connectivity.sendShopPurchase(item.type)
        return true
    }

    // MARK: - History

    func loadHistory() async -> [PetRecord] {
        await store.loadHistory()
    }

    // MARK: - Settings

    func updateSettings() {
        connectivity.sendSettingsUpdate(
            sound: settingsStore.isSoundEnabled,
            notifications: settingsStore.isNotificationsEnabled,
            pauseLimit: settingsStore.pauseLimitMinutes
        )
    }

    func resetPet() async {
        await store.deletePet()
        cachedPet = nil
    }
}
