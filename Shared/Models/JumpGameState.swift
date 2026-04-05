import Foundation

/// ジャンプゲームの状態 (View非依存、純粋ロジック)
struct JumpGameState: Sendable {

    /// 障害物の状態
    struct Obstacle: Sendable {
        let spawnTime: TimeInterval   // ゲーム開始からの出現時刻
        var positionX: Double         // 画面右端=1.0, 左端=0.0
        var passed: Bool              // プレイヤーを通過した
        var hitPlayer: Bool           // プレイヤーに衝突した
    }

    private(set) var phase: MiniGamePhase
    private(set) var obstacles: [Obstacle]
    private(set) var isJumping: Bool
    private(set) var jumpTimeRemaining: TimeInterval
    private(set) var elapsedTime: TimeInterval
    private(set) var score: Int         // 回避成功数
    private(set) var missCount: Int     // 衝突数

    /// ゲーム開始
    static func start() -> JumpGameState {
        let obstacles = (0..<GameConfig.jumpGameObstacleCount).map { i in
            Obstacle(
                spawnTime: Double(i) * GameConfig.jumpGameObstacleInterval + 1.0,
                positionX: 1.2,
                passed: false,
                hitPlayer: false
            )
        }
        return JumpGameState(
            phase: .playing,
            obstacles: obstacles,
            isJumping: false,
            jumpTimeRemaining: 0,
            elapsedTime: 0,
            score: 0,
            missCount: 0
        )
    }

    /// プレイヤーの縦位置 (0.0 = 地面, 1.0 = 最高点)
    var playerY: Double {
        guard isJumping else { return 0 }
        let halfDuration = GameConfig.jumpGameJumpDuration / 2
        let elapsed = GameConfig.jumpGameJumpDuration - jumpTimeRemaining
        // 放物線: 0 → 1 → 0
        let t = elapsed / halfDuration
        if t <= 1.0 {
            return t
        } else {
            return 2.0 - t
        }
    }

    /// プレイヤーが空中にいるか (衝突判定用)
    var isInAir: Bool {
        playerY > 0.3
    }

    /// ジャンプ
    mutating func jump() {
        guard phase == .playing, !isJumping else { return }
        isJumping = true
        jumpTimeRemaining = GameConfig.jumpGameJumpDuration
    }

    /// フレーム更新
    mutating func tick(dt: TimeInterval) {
        guard phase == .playing else { return }

        elapsedTime += dt

        // ジャンプ更新
        if isJumping {
            jumpTimeRemaining -= dt
            if jumpTimeRemaining <= 0 {
                isJumping = false
                jumpTimeRemaining = 0
            }
        }

        // 障害物更新
        let speed = GameConfig.jumpGameObstacleSpeed / 100.0  // 正規化速度
        for i in obstacles.indices {
            guard elapsedTime >= obstacles[i].spawnTime else { continue }

            let timeSinceSpawn = elapsedTime - obstacles[i].spawnTime
            obstacles[i].positionX = 1.2 - timeSinceSpawn * speed

            // 衝突判定 (プレイヤー位置 = 0.15)
            let playerZone = 0.1...0.2
            if !obstacles[i].passed && !obstacles[i].hitPlayer
                && playerZone.contains(obstacles[i].positionX) {
                if isInAir {
                    obstacles[i].passed = true
                    score += 1
                } else {
                    obstacles[i].hitPlayer = true
                    missCount += 1
                }
            }
        }

        // 全障害物が通過 or 衝突で終了判定
        let allProcessed = obstacles.allSatisfy { $0.passed || $0.hitPlayer || $0.positionX < -0.2 }
        if allProcessed {
            phase = .result
        }
    }

    /// 勝敗判定
    var won: Bool {
        score >= GameConfig.jumpGameWinThreshold
    }

    /// MiniGameResult を生成
    func toResult() -> MiniGameResult {
        if won {
            return .win(correct: score, total: GameConfig.jumpGameObstacleCount)
        } else {
            return .lose(correct: score, total: GameConfig.jumpGameObstacleCount)
        }
    }
}
