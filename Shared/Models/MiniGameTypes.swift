import Foundation

/// ミニゲームの進行フェーズ
enum MiniGamePhase: String, Sendable {
    case ready
    case playing
    case result
    case finished
}

/// ミニゲームの結果
struct MiniGameResult: Equatable, Sendable {
    let won: Bool
    let correctCount: Int
    let totalRounds: Int
    let ecoPointsEarned: Int

    static func win(correct: Int, total: Int) -> MiniGameResult {
        MiniGameResult(
            won: true,
            correctCount: correct,
            totalRounds: total,
            ecoPointsEarned: GameConfig.miniGameWinPoints
        )
    }

    static func lose(correct: Int, total: Int) -> MiniGameResult {
        MiniGameResult(
            won: false,
            correctCount: correct,
            totalRounds: total,
            ecoPointsEarned: GameConfig.miniGameLosePoints
        )
    }
}

/// ミニゲーム情報
struct MiniGameDescriptor: Identifiable, Sendable {
    let id: String
    let displayName: String
    let iconSystemName: String
}
