import Foundation

/// ゲーム全体の設定定数
enum GameConfig {
    // MARK: - ステータス減衰

    /// おなかが1減るまでの時間(秒) - 通常時
    static let hungerDecayInterval: TimeInterval = 70 * 60  // 70分

    /// ごきげんが1減るまでの時間(秒) - 通常時
    static let happinessDecayInterval: TimeInterval = 50 * 60  // 50分

    /// 睡眠中の減衰倍率
    static let sleepDecayMultiplier: Double = 0.5

    // MARK: - お世話ミス

    /// 呼び出しの猶予時間(秒)
    static let careMissGracePeriod: TimeInterval = 15 * 60  // 15分

    /// うんち放置で病気になるまでの時間(秒)
    static let poopSicknessThreshold: TimeInterval = 12 * 60  // 12分

    // MARK: - 病気

    /// 病気で死亡するまでの時間(秒)
    static let sicknessDeathThreshold: TimeInterval = 18 * 60 * 60  // 18時間

    /// 治療に必要な投薬回数
    static let medicineDosesRequired: Int = 2

    // MARK: - 餓死

    /// おなか0で死亡するまでの時間(秒)
    static let starvationDeathThreshold: TimeInterval = 12 * 60 * 60  // 12時間

    // MARK: - しつけ

    /// 1回のしつけで増加する量
    static let disciplineIncrement: Int = 25

    /// しつけの最大値
    static let disciplineMax: Int = 100

    // MARK: - 一時停止

    /// 1日の最大一時停止時間(分)
    static let maxPauseMinutesPerDay: Int = 600  // 10時間

    // MARK: - うんち

    /// 画面上の最大うんち数
    static let maxPoopCount: Int = 4

    // MARK: - エコポイント

    /// ミニゲーム勝利時のポイント
    static let miniGameWinPoints: Int = 50

    /// ミニゲーム敗北時のポイント
    static let miniGameLosePoints: Int = 10

    // MARK: - ジャンプゲーム

    /// 障害物の数
    static let jumpGameObstacleCount: Int = 5

    /// 勝利に必要な回避数
    static let jumpGameWinThreshold: Int = 3

    /// 障害物の移動速度 (points/秒)
    static let jumpGameObstacleSpeed: Double = 60.0

    /// ジャンプの持続時間(秒)
    static let jumpGameJumpDuration: TimeInterval = 0.5

    /// 障害物の出現間隔(秒)
    static let jumpGameObstacleInterval: TimeInterval = 2.5

    // MARK: - 通知

    /// 1日の最大通知数
    static let maxNotificationsPerDay: Int = 3

    // MARK: - ウィジェット

    /// タイムラインエントリ数
    static let widgetTimelineEntryCount: Int = 8

    /// タイムラインエントリ間隔(秒)
    static let widgetTimelineEntryInterval: TimeInterval = 30 * 60  // 30分

    // MARK: - バックグラウンドリフレッシュ

    /// バックグラウンドリフレッシュ間隔(秒)
    static let backgroundRefreshInterval: TimeInterval = 30 * 60  // 30分

    // MARK: - CloudKit

    /// CloudKit コンテナID
    static let cloudKitContainerID = "iCloud.com.ekocci.app"

    /// CloudKit ゾーン名
    static let cloudKitZoneName = "PetZone"

    // MARK: - バッテリー

    /// バッテリー低下閾値 (自動ポーズ)
    static let batteryLowThreshold: Float = 0.10

    /// バッテリー回復閾値 (自動解除)
    static let batteryRecoverThreshold: Float = 0.15

    // MARK: - 時間

    /// 1ペット年 = 実時間(秒)
    static let secondsPerPetYear: TimeInterval = 24 * 60 * 60

    /// オフラインキャッチアップの最大時間(秒)
    static let maxCatchUpDuration: TimeInterval = 48 * 60 * 60  // 48時間
}
