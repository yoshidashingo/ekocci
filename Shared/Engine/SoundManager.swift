import Foundation
import AVFoundation
import os

private let soundLogger = Logger(subsystem: "com.ekocci", category: "SoundManager")

/// 効果音の種類
enum SoundType: String, Sendable {
    case feed = "feed"
    case clean = "clean"
    case gameWon = "game_won"
    case gameLost = "game_lost"
    case evolved = "evolved"
    case died = "died"
}

/// 効果音再生マネージャー
@MainActor
enum SoundManager {
    private static var player: AVAudioPlayer?

    /// 効果音を再生 (isSoundEnabled = false なら無視)
    static func play(_ sound: SoundType, settings: SettingsStore = SettingsStore()) {
        guard settings.isSoundEnabled else { return }
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") else { return }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            soundLogger.warning("Audio playback failed for \(sound.rawValue): \(error.localizedDescription)")
        }
    }
}
