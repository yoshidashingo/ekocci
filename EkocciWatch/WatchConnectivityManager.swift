import Foundation
import WatchConnectivity

/// Watch側の WCSession 管理
final class WatchConnectivityManager: NSObject, WCSessionDelegate, @unchecked Sendable {

    private let store: PetStore
    private let discoveryStore: DiscoveryStore
    private let shopStore: ShopStore
    private let settingsStore: SettingsStore

    /// GameManager への care action コールバック
    var onCareAction: ((CareAction) -> Void)?
    /// GameManager への shop purchase コールバック
    var onShopPurchase: ((ShopItemType) -> Void)?

    init(
        store: PetStore = PetStore(),
        discoveryStore: DiscoveryStore = DiscoveryStore(),
        shopStore: ShopStore = ShopStore(),
        settingsStore: SettingsStore = SettingsStore()
    ) {
        self.store = store
        self.discoveryStore = discoveryStore
        self.shopStore = shopStore
        self.settingsStore = settingsStore
        super.init()
        activateIfSupported()
    }

    private func activateIfSupported() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Send

    /// ペット状態を iPhone に送信
    func sendPetState(_ pet: Pet) {
        guard WCSession.default.activationState == .activated else { return }
        let dict = ConnectivityMessage.petStateUpdate(pet).toDictionary()
        try? WCSession.default.updateApplicationContext(dict)
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleIncoming(message)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        handleIncoming(applicationContext)
    }

    private func handleIncoming(_ dict: [String: Any]) {
        guard let msg = ConnectivityMessage.from(dict) else { return }

        switch msg {
        case .careAction(let action):
            onCareAction?(action)

        case .shopPurchase(let itemType):
            onShopPurchase?(itemType)

        case .settingsUpdate(let sound, let notif, let pause):
            settingsStore.isSoundEnabled = sound
            settingsStore.isNotificationsEnabled = notif
            settingsStore.pauseLimitMinutes = pause

        case .petStateUpdate:
            break // Watch は受け取らない
        }
    }
}
