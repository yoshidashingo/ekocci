import Foundation

/// プレイヤーが実行できるお世話アクション
enum CareAction: String, Codable, CaseIterable, Sendable {
    case feedMeal       // ごはん
    case feedSnack      // おやつ
    case play           // あそぶ
    case clean          // トイレそうじ
    case medicine       // くすり
    case discipline     // しつけ
    case lightOff       // でんきを消す
    case lightOn        // でんきをつける

    /// メニュー表示名
    var displayName: String {
        switch self {
        case .feedMeal:   return "ごはん"
        case .feedSnack:  return "おやつ"
        case .play:       return "あそぶ"
        case .clean:      return "そうじ"
        case .medicine:   return "くすり"
        case .discipline: return "しつけ"
        case .lightOff:   return "でんき けす"
        case .lightOn:    return "でんき つける"
        }
    }

    /// メニューアイコン(SF Symbols)
    var iconName: String {
        switch self {
        case .feedMeal:   return "fork.knife"
        case .feedSnack:  return "birthday.cake"
        case .play:       return "gamecontroller"
        case .clean:      return "sparkles"
        case .medicine:   return "cross.case"
        case .discipline: return "hand.raised"
        case .lightOff:   return "lightbulb.slash"
        case .lightOn:    return "lightbulb"
        }
    }
}
