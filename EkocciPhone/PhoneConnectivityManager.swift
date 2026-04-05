import Foundation
import WatchConnectivity
import Observation

/// iPhone側の WCSession 管理
@MainActor
@Observable
final class PhoneConnectivityManager: NSObject, WCSessionDelegate {

    private(set) var currentPet: Pet?
    private(set) var isWatchReachable = false

    override init() {
        super.init()
        activateIfSupported()
    }

    private func activateIfSupported() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Send to Watch

    func sendCareAction(_ action: CareAction) {
        let dict = ConnectivityMessage.careAction(action).toDictionary()
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(dict, replyHandler: nil)
        } else {
            WCSession.default.transferUserInfo(dict)
        }
    }

    func sendShopPurchase(_ type: ShopItemType) {
        let dict = ConnectivityMessage.shopPurchase(type).toDictionary()
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(dict, replyHandler: nil)
        } else {
            WCSession.default.transferUserInfo(dict)
        }
    }

    func sendSettingsUpdate(sound: Bool, notifications: Bool, pauseLimit: Int) {
        let dict = ConnectivityMessage.settingsUpdate(
            soundEnabled: sound,
            notificationsEnabled: notifications,
            pauseLimitMinutes: pauseLimit
        ).toDictionary()
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(dict, replyHandler: nil)
        } else {
            WCSession.default.transferUserInfo(dict)
        }
    }

    // MARK: - WCSessionDelegate

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        let reachable = session.isReachable
        let pet = Self.decodePet(from: session.receivedApplicationContext)
        Task { @MainActor in
            isWatchReachable = reachable
            if let pet { currentPet = pet }
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        let reachable = session.isReachable
        Task { @MainActor in
            isWatchReachable = reachable
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        let pet = Self.decodePet(from: applicationContext)
        Task { @MainActor in
            if let pet { currentPet = pet }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        let pet = Self.decodePet(from: message)
        Task { @MainActor in
            if let pet { currentPet = pet }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        let pet = Self.decodePet(from: userInfo)
        Task { @MainActor in
            if let pet { currentPet = pet }
        }
    }

    // MARK: - Decode (nonisolated, Sendable result)

    private nonisolated static func decodePet(from dict: [String: Any]) -> Pet? {
        guard let msg = ConnectivityMessage.from(dict),
              case .petStateUpdate(let pet) = msg else { return nil }
        return pet
    }
}
