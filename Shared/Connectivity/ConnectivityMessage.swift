import Foundation

/// WCSession メッセージの種類
enum ConnectivityMessageType: String, Codable, Sendable {
    case petStateUpdate
    case careAction
    case settingsUpdate
    case shopPurchase
}

/// WCSession 用メッセージのエンコード/デコード
enum ConnectivityMessage: Sendable {
    case petStateUpdate(Pet)
    case careAction(CareAction)
    case shopPurchase(ShopItemType)
    case settingsUpdate(soundEnabled: Bool, notificationsEnabled: Bool, pauseLimitMinutes: Int)

    // MARK: - Encode

    func toDictionary() -> [String: Any] {
        switch self {
        case .petStateUpdate(let pet):
            let data = (try? JSONEncoder().encode(pet)) ?? Data()
            return ["type": ConnectivityMessageType.petStateUpdate.rawValue, "payload": data]

        case .careAction(let action):
            let data = (try? JSONEncoder().encode(action)) ?? Data()
            return ["type": ConnectivityMessageType.careAction.rawValue, "payload": data]

        case .shopPurchase(let itemType):
            let data = (try? JSONEncoder().encode(itemType)) ?? Data()
            return ["type": ConnectivityMessageType.shopPurchase.rawValue, "payload": data]

        case .settingsUpdate(let sound, let notifications, let pauseLimit):
            let payload: [String: Any] = [
                "soundEnabled": sound,
                "notificationsEnabled": notifications,
                "pauseLimitMinutes": pauseLimit,
            ]
            let data = (try? JSONSerialization.data(withJSONObject: payload)) ?? Data()
            return ["type": ConnectivityMessageType.settingsUpdate.rawValue, "payload": data]
        }
    }

    // MARK: - Decode

    static func from(_ dict: [String: Any]) -> ConnectivityMessage? {
        guard let typeString = dict["type"] as? String,
              let type = ConnectivityMessageType(rawValue: typeString),
              let data = dict["payload"] as? Data else { return nil }

        switch type {
        case .petStateUpdate:
            guard let pet = try? JSONDecoder().decode(Pet.self, from: data) else { return nil }
            return .petStateUpdate(pet)

        case .careAction:
            guard let action = try? JSONDecoder().decode(CareAction.self, from: data) else { return nil }
            return .careAction(action)

        case .shopPurchase:
            guard let itemType = try? JSONDecoder().decode(ShopItemType.self, from: data) else { return nil }
            return .shopPurchase(itemType)

        case .settingsUpdate:
            guard let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let sound = payload["soundEnabled"] as? Bool,
                  let notif = payload["notificationsEnabled"] as? Bool,
                  let pause = payload["pauseLimitMinutes"] as? Int else { return nil }
            return .settingsUpdate(soundEnabled: sound, notificationsEnabled: notif, pauseLimitMinutes: pause)
        }
    }
}
