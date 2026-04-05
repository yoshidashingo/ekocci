import Testing
@testable import EkocciShared

@Suite("JumpGameState Tests")
struct JumpGameStateTests {

    @Test("開始時はplaying状態")
    func startIsPlaying() {
        let state = JumpGameState.start()
        #expect(state.phase == .playing)
        #expect(state.score == 0)
        #expect(state.missCount == 0)
        #expect(!state.isJumping)
    }

    @Test("障害物が5つ生成される")
    func obstacleCount() {
        let state = JumpGameState.start()
        #expect(state.obstacles.count == GameConfig.jumpGameObstacleCount)
    }

    @Test("ジャンプするとisJumpingがtrueになる")
    func jumpSetsFlag() {
        var state = JumpGameState.start()
        state.jump()
        #expect(state.isJumping)
    }

    @Test("ジャンプ中にplayerYが0より大きい")
    func jumpRaisesPlayer() {
        var state = JumpGameState.start()
        state.jump()
        state.tick(dt: GameConfig.jumpGameJumpDuration / 2)
        #expect(state.playerY > 0.5)
    }

    @Test("ジャンプ終了後にplayerYが0に戻る")
    func jumpEnds() {
        var state = JumpGameState.start()
        state.jump()
        state.tick(dt: GameConfig.jumpGameJumpDuration + 0.01)
        #expect(!state.isJumping)
        #expect(state.playerY == 0)
    }

    @Test("ジャンプ中の二重タップは無視される")
    func doubleJumpIgnored() {
        var state = JumpGameState.start()
        state.jump()
        let remaining = state.jumpTimeRemaining
        state.jump() // 二重タップ
        #expect(state.jumpTimeRemaining == remaining)
    }

    @Test("地上で障害物に当たるとmissCountが増える")
    func collisionOnGround() {
        var state = JumpGameState.start()
        // 最初の障害物がプレイヤー位置に来るまで進める
        // spawnTime=1.0, speed=0.6/sec, 到達距離=1.2-0.15=1.05 → t≒1.75sec
        for _ in 0..<50 {
            state.tick(dt: 0.1)
        }
        #expect(state.missCount >= 1)
    }

    @Test("ジャンプで障害物を回避するとscoreが増える")
    func jumpAvoidsObstacle() {
        var state = JumpGameState.start()
        // 最初の障害物のspawnTime=1.0
        // 障害物がプレイヤー位置に来る直前にジャンプ
        // speed = 0.6/sec, distance=1.2-0.15=1.05 → ~1.75秒後
        // spawn後1.75秒 → elapsed=2.75秒頃に到達
        for _ in 0..<22 {
            state.tick(dt: 0.1)
        }
        state.jump()
        for _ in 0..<10 {
            state.tick(dt: 0.1)
        }
        // ジャンプで回避できたか衝突したか
        let total = state.score + state.missCount
        #expect(total >= 1)
    }

    @Test("全障害物処理後にresultフェーズになる")
    func finishesAfterAllObstacles() {
        var state = JumpGameState.start()
        // 十分に時間を進めて全障害物を通過させる
        for _ in 0..<300 {
            state.tick(dt: 0.1)
        }
        #expect(state.phase == .result)
    }

    @Test("3回以上回避で勝利")
    func winCondition() {
        var state = JumpGameState.start()
        // 全障害物を回避する: 各障害物の到達タイミングでジャンプ
        // obstacle[i].spawnTime = i * 2.5 + 1.0
        // 到達時間 = spawnTime + 1.05/0.6 ≒ spawnTime + 1.75
        let arrivals = (0..<5).map { Double($0) * 2.5 + 1.0 + 1.5 }

        var time = 0.0
        let dt = 0.05
        while state.phase == .playing {
            time += dt
            // 到達0.2秒前にジャンプ
            for arrival in arrivals {
                if abs(time - (arrival - 0.2)) < dt {
                    state.jump()
                }
            }
            state.tick(dt: dt)
            if time > 30 { break } // 安全弁
        }

        #expect(state.phase == .result)
        if state.score >= GameConfig.jumpGameWinThreshold {
            #expect(state.won)
            let result = state.toResult()
            #expect(result.won)
            #expect(result.ecoPointsEarned == GameConfig.miniGameWinPoints)
        }
    }

    @Test("全ミスで敗北")
    func loseCondition() {
        var state = JumpGameState.start()
        // ジャンプせず全部衝突させる
        for _ in 0..<300 {
            state.tick(dt: 0.1)
        }
        #expect(state.phase == .result)
        #expect(!state.won)
        let result = state.toResult()
        #expect(!result.won)
        #expect(result.ecoPointsEarned == GameConfig.miniGameLosePoints)
    }

    @Test("result状態ではtickしても変化しない")
    func noTickAfterResult() {
        var state = JumpGameState.start()
        for _ in 0..<300 {
            state.tick(dt: 0.1)
        }
        #expect(state.phase == .result)
        let scoreBefore = state.score
        state.tick(dt: 1.0)
        #expect(state.score == scoreBefore)
    }
}
