import Foundation

/// ゲームのコアシミュレーション
/// 純粋関数: 旧状態 + 経過時間 → 新状態 (副作用なし)
enum GameEngine {

    // MARK: - メインループ

    /// 時間を進めてペットの状態を更新する
    /// - Parameters:
    ///   - pet: 現在のペット状態
    ///   - from: 前回更新時刻
    ///   - to: 現在時刻
    /// - Returns: 更新後のペット状態
    static func advance(pet: Pet, from: Date, to: Date) -> Pet {
        guard pet.stage != .dead else { return pet }
        guard to > from else { return pet }

        // 日付変更でポーズ使用時間リセット
        var current = pet
        current = resetPauseDailyIfNeeded(pet: current, at: to)

        // 一時停止中: 上限チェック → 超過なら自動解除
        if current.isPaused {
            if current.pauseMinutesUsedToday >= GameConfig.maxPauseMinutesPerDay {
                current = unpause(pet: current, at: to)
            } else {
                current.lastUpdateTime = to
                return current
            }
        }

        // 最大キャッチアップ時間でクランプ
        let clampedFrom = max(from, to.addingTimeInterval(-GameConfig.maxCatchUpDuration))
        let elapsed = to.timeIntervalSince(clampedFrom)

        var result = current

        // 1. たまごの孵化チェック
        if result.stage == .egg {
            result = checkEggHatch(pet: result, from: clampedFrom, to: to)
            if result.stage == .egg {
                result.lastUpdateTime = to
                return result
            }
        }

        // 2. 睡眠状態の更新
        result = updateSleepState(pet: result, at: to)

        // 3. ステータス減衰
        result = decayStats(pet: result, elapsed: elapsed)

        // 4. うんち生成
        result = generatePoop(pet: result, from: clampedFrom, to: to)

        // 5. 死亡チェック (お世話ミスリセット前に判定)
        result = checkDeath(pet: result, at: to)

        // 6. お世話ミスチェック
        result = checkCareMisses(pet: result, at: to)

        // 7. 病気チェック (うんち放置)
        result = checkSickness(pet: result, at: to)

        // 8. ステージ進化チェック
        if result.stage != .dead {
            let shopStore = ShopStore()
            let hasSpeedBoost = shopStore.hasActiveEffect(.speedBoost, at: to)
            let hasLuckyCharm = shopStore.hasActiveEffect(.luckyCharm, at: to)
            result = checkStageTransition(pet: result, at: to, hasSpeedBoost: hasSpeedBoost, hasLuckyCharm: hasLuckyCharm)
        }

        // 9. 年齢更新
        result.age = TimeManager.petAge(birthDate: result.birthDate, at: to)

        result.lastUpdateTime = to
        return result
    }

    // MARK: - お世話アクション

    /// ごはんを食べさせる
    static func feed(pet: Pet, at date: Date) -> Pet {
        guard pet.stage != .egg, pet.stage != .dead, !pet.isSleeping else { return pet }
        var result = pet
        result.stats = result.stats.fed()
        result.hiddenStats = result.hiddenStats.addingEffort(1)
        if result.stats.hunger > 0 {
            result.hungerEmptySince = nil
        }
        result.lastUpdateTime = date
        return result
    }

    /// おやつを食べさせる
    static func snack(pet: Pet, at date: Date) -> Pet {
        guard pet.stage != .egg, pet.stage != .dead, !pet.isSleeping else { return pet }
        var result = pet
        result.stats = result.stats.snacked()
        if result.stats.happiness > 0 {
            result.happinessEmptySince = nil
        }
        result.lastUpdateTime = date
        return result
    }

    /// トイレそうじ
    static func clean(pet: Pet, at date: Date) -> Pet {
        guard pet.poopCount > 0 else { return pet }
        var result = pet
        result.poopCount = 0
        result.hiddenStats = result.hiddenStats.addingEffort(1)
        result.lastUpdateTime = date
        return result
    }

    /// くすりを投与
    static func giveMedicine(pet: Pet, at date: Date) -> Pet {
        guard pet.isSick else { return pet }
        var result = pet
        result.medicineDosesNeeded -= 1
        if result.medicineDosesNeeded <= 0 {
            result.isSick = false
            result.medicineDosesNeeded = 0
        }
        result.lastUpdateTime = date
        return result
    }

    /// しつけ
    static func discipline(pet: Pet, at date: Date) -> Pet {
        guard pet.stage != .egg, pet.stage != .dead, !pet.isSleeping else { return pet }
        var result = pet
        result.discipline = min(
            result.discipline + GameConfig.disciplineIncrement,
            GameConfig.disciplineMax
        )
        result.hiddenStats = result.hiddenStats.addingEffort(2)
        result.lastUpdateTime = date
        return result
    }

    /// でんきを消す
    static func turnLightOff(pet: Pet, at date: Date) -> Pet {
        guard pet.isSleeping, !pet.isLightOff else { return pet }
        var result = pet
        result.isLightOff = true
        result.sleepWithoutLightSince = nil
        result.lastUpdateTime = date
        return result
    }

    /// でんきをつける
    static func turnLightOn(pet: Pet, at date: Date) -> Pet {
        guard pet.isLightOff else { return pet }
        var result = pet
        result.isLightOff = false
        result.lastUpdateTime = date
        return result
    }

    /// ミニゲーム勝利
    static func miniGameWon(pet: Pet, at date: Date) -> Pet {
        var result = pet
        result.stats = result.stats.playedAndWon()
        result.ecoPoints += GameConfig.miniGameWinPoints
        result.hiddenStats = result.hiddenStats.addingBonding(2)
        if result.stats.happiness > 0 {
            result.happinessEmptySince = nil
        }
        result.lastUpdateTime = date
        return result
    }

    /// ミニゲーム敗北
    static func miniGameLost(pet: Pet, at date: Date) -> Pet {
        var result = pet
        result.ecoPoints += GameConfig.miniGameLosePoints
        result.hiddenStats = result.hiddenStats.addingBonding(1)
        result.lastUpdateTime = date
        return result
    }

    /// 一時停止の開始
    static func pause(pet: Pet, at date: Date) -> Pet {
        guard !pet.isPaused else { return pet }
        guard pet.pauseMinutesUsedToday < GameConfig.maxPauseMinutesPerDay else { return pet }
        var result = pet
        result.isPaused = true
        result.pauseStartDate = date
        result.lastUpdateTime = date
        return result
    }

    /// 一時停止の解除
    static func unpause(pet: Pet, at date: Date) -> Pet {
        guard pet.isPaused, let pauseStart = pet.pauseStartDate else { return pet }
        var result = pet
        let pausedMinutes = Int(date.timeIntervalSince(pauseStart) / 60)
        result.isPaused = false
        result.pauseMinutesUsedToday += pausedMinutes
        result.pauseStartDate = nil
        result.lastUpdateTime = date
        return result
    }

    /// 次世代のたまごを生成
    static func newGeneration(from pet: Pet, at date: Date) -> Pet {
        Pet.newEgg(generation: pet.generation + 1, at: date)
    }

    // MARK: - 内部ロジック

    private static func checkEggHatch(pet: Pet, from: Date, to: Date) -> Pet {
        guard pet.stage == .egg else { return pet }
        guard let duration = LifeStage.egg.durationSeconds else { return pet }

        let elapsed = to.timeIntervalSince(pet.stageStartDate)
        if elapsed >= duration {
            var result = pet
            result.stage = .baby
            result.characterId = "baby_default"
            result.stageStartDate = pet.stageStartDate.addingTimeInterval(duration)
            result.careMissesInStage = 0
            return result
        }
        return pet
    }

    private static func updateSleepState(pet: Pet, at date: Date) -> Pet {
        let shouldSleep = TimeManager.shouldBeSleeping(stage: pet.stage, at: date)
        guard shouldSleep != pet.isSleeping else { return pet }

        var result = pet
        if shouldSleep {
            // 寝た
            result.isSleeping = true
            result.sleepWithoutLightSince = date
        } else {
            // 起きた
            result.isSleeping = false
            result.isLightOff = false
            result.sleepWithoutLightSince = nil
        }
        return result
    }

    private static func decayStats(pet: Pet, elapsed: TimeInterval) -> Pet {
        guard pet.stage != .egg, pet.stage != .dead else { return pet }

        let multiplier = pet.isSleeping ? GameConfig.sleepDecayMultiplier : 1.0
        let hungerInterval = GameConfig.hungerDecayInterval / multiplier
        let happinessInterval = GameConfig.happinessDecayInterval / multiplier

        let hungerLoss = Int(elapsed / hungerInterval)
        let happinessLoss = Int(elapsed / happinessInterval)

        var result = pet

        for _ in 0..<hungerLoss {
            result.stats = result.stats.hungerDecayed()
        }
        for _ in 0..<happinessLoss {
            result.stats = result.stats.happinessDecayed()
        }

        // おなかが0になった時刻を記録
        if result.stats.isHungry && result.hungerEmptySince == nil {
            result.hungerEmptySince = result.lastUpdateTime
        } else if !result.stats.isHungry {
            result.hungerEmptySince = nil
        }

        // ごきげんが0になった時刻を記録
        if result.stats.isUnhappy && result.happinessEmptySince == nil {
            result.happinessEmptySince = result.lastUpdateTime
        } else if !result.stats.isUnhappy {
            result.happinessEmptySince = nil
        }

        return result
    }

    private static func generatePoop(pet: Pet, from: Date, to: Date) -> Pet {
        guard pet.stage != .egg, pet.stage != .dead else { return pet }
        guard !pet.isSleeping else { return pet }
        guard pet.poopCount < GameConfig.maxPoopCount else { return pet }

        let interval = pet.stage.poopIntervalSeconds
        let lastPoop = pet.lastPoopTime ?? from

        let timeSinceLastPoop = to.timeIntervalSince(lastPoop)
        let newPoops = Int(timeSinceLastPoop / interval)

        guard newPoops > 0 else { return pet }

        var result = pet
        result.poopCount = min(result.poopCount + newPoops, GameConfig.maxPoopCount)
        result.lastPoopTime = lastPoop.addingTimeInterval(Double(newPoops) * interval)
        return result
    }

    private static func checkCareMisses(pet: Pet, at date: Date) -> Pet {
        var result = pet
        let grace = GameConfig.careMissGracePeriod

        // おなか0の猶予切れ
        if let since = result.hungerEmptySince,
           date.timeIntervalSince(since) >= grace {
            result.careMisses += 1
            result.careMissesInStage += 1
            result.hungerEmptySince = date // 次の猶予開始
        }

        // ごきげん0の猶予切れ
        if let since = result.happinessEmptySince,
           date.timeIntervalSince(since) >= grace {
            result.careMisses += 1
            result.careMissesInStage += 1
            result.happinessEmptySince = date
        }

        // 消灯忘れ
        if let since = result.sleepWithoutLightSince,
           date.timeIntervalSince(since) >= grace {
            result.careMisses += 1
            result.careMissesInStage += 1
            result.sleepWithoutLightSince = date
        }

        return result
    }

    private static func checkSickness(pet: Pet, at date: Date) -> Pet {
        guard !pet.isSick else { return pet }
        guard pet.poopCount >= 3 else { return pet } // うんち3個以上で病気リスク

        var result = pet
        if let lastPoop = result.lastPoopTime,
           date.timeIntervalSince(lastPoop) >= GameConfig.poopSicknessThreshold {
            result.isSick = true
            result.medicineDosesNeeded = GameConfig.medicineDosesRequired
        }
        return result
    }

    private static func checkDeath(pet: Pet, at date: Date) -> Pet {
        var result = pet

        // 餓死チェック
        if let since = result.hungerEmptySince,
           date.timeIntervalSince(since) >= GameConfig.starvationDeathThreshold {
            result.stage = .dead
            result.characterId = "dead"
            return result
        }

        // 病死チェック
        if result.isSick,
           date.timeIntervalSince(result.lastUpdateTime) >= GameConfig.sicknessDeathThreshold {
            result.stage = .dead
            result.characterId = "dead"
            return result
        }

        // 老衰チェック
        if result.hasReachedLifespan(at: date) {
            result.stage = .dead
            result.characterId = "dead"
            return result
        }

        return result
    }

    private static func checkStageTransition(
        pet: Pet, at date: Date,
        hasSpeedBoost: Bool, hasLuckyCharm: Bool
    ) -> Pet {
        guard let duration = pet.stage.durationSeconds else { return pet }
        guard let nextStage = pet.stage.next else { return pet }

        let speedMultiplier: Double = hasSpeedBoost ? 0.5 : 1.0
        let effectiveDuration = duration * speedMultiplier

        let elapsed = date.timeIntervalSince(pet.stageStartDate)
        guard elapsed >= effectiveDuration else { return pet }

        var result = pet
        result.stage = nextStage
        result.stageStartDate = date
        result.characterId = EvolutionEngine.resolve(pet: result, nextStage: nextStage, hasLuckyCharm: hasLuckyCharm)
        result.careMissesInStage = 0
        return result
    }

    /// 日付が変わったらポーズ使用時間をリセット
    private static func resetPauseDailyIfNeeded(pet: Pet, at date: Date) -> Pet {
        let calendar = Calendar.current
        if !calendar.isDate(pet.lastUpdateTime, inSameDayAs: date) {
            var result = pet
            result.pauseMinutesUsedToday = 0
            return result
        }
        return pet
    }
}
