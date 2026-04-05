import Foundation
#if os(watchOS)
import WatchKit
#endif

/// Hapticフィードバック管理
enum HapticManager {
    #if os(watchOS)
    static func play(_ type: HapticType) {
        WKInterfaceDevice.current().play(type.watchHaptic)
    }
    #else
    static func play(_ type: HapticType) {
        // iOS: 将来的にUIFeedbackGeneratorを使用
    }
    #endif
}

/// Hapticの種類
enum HapticType: Sendable {
    case fed             // ごはんを食べた
    case gameWon         // ミニゲーム勝利
    case gameLost        // ミニゲーム敗北
    case disciplined     // しつけ成功
    case evolved         // 進化!
    case died            // 死亡
    case notification    // 通知
    case cleaned         // そうじ
    case healed          // 治療

    #if os(watchOS)
    var watchHaptic: WKHapticType {
        switch self {
        case .fed:          return .click
        case .gameWon:      return .success
        case .gameLost:     return .failure
        case .disciplined:  return .directionUp
        case .evolved:      return .notification
        case .died:         return .stop
        case .notification: return .notification
        case .cleaned:      return .click
        case .healed:       return .success
        }
    }
    #endif
}
