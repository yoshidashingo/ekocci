import Foundation

/// ペットのライフステージ
enum LifeStage: String, Codable, CaseIterable, Sendable {
    case egg        // たまご
    case baby       // あかちゃん
    case child      // こども
    case young      // ヤング
    case adult      // おとな
    case senior     // シニア
    case dead       // おわり

    /// 表示名
    var displayName: String {
        switch self {
        case .egg:    return "たまご"
        case .baby:   return "あかちゃん"
        case .child:  return "こども"
        case .young:  return "ヤング"
        case .adult:  return "おとな"
        case .senior: return "シニア"
        case .dead:   return "おわり"
        }
    }

    /// 次のステージへの所要時間(秒)。nilの場合は寿命 or 死亡で終了
    var durationSeconds: TimeInterval? {
        switch self {
        case .egg:    return 30                // 30秒
        case .baby:   return 60 * 60          // 1時間
        case .child:  return 24 * 60 * 60     // 24時間
        case .young:  return 3 * 24 * 60 * 60 // 3日
        case .adult:  return nil              // 寿命まで
        case .senior: return nil              // 寿命まで
        case .dead:   return nil
        }
    }

    /// 次のステージ(通常進化パス)
    var next: LifeStage? {
        switch self {
        case .egg:    return .baby
        case .baby:   return .child
        case .child:  return .young
        case .young:  return .adult
        case .adult:  return .senior
        case .senior: return .dead
        case .dead:   return nil
        }
    }

    /// ミニゲームが可能か
    var canPlayGames: Bool {
        switch self {
        case .egg, .baby, .dead: return false
        default: return true
        }
    }

    /// 就寝時刻(時)
    var bedtimeHour: Int {
        switch self {
        case .baby:   return 20
        case .child:  return 20
        case .young:  return 21
        case .adult:  return 22
        case .senior: return 21
        default:      return 22
        }
    }

    /// 起床時刻(時)
    var wakeUpHour: Int {
        switch self {
        case .baby:   return 9
        case .child:  return 9
        case .young:  return 9
        case .adult:  return 8
        case .senior: return 8
        default:      return 9
        }
    }

    /// うんちの発生間隔(秒)
    var poopIntervalSeconds: TimeInterval {
        switch self {
        case .baby:   return 20 * 60         // 20分
        case .child:  return 60 * 60         // 1時間
        case .young:  return 90 * 60         // 1.5時間
        case .adult:  return 3 * 60 * 60     // 3時間
        case .senior: return 2 * 60 * 60     // 2時間
        default:      return .infinity
        }
    }
}
