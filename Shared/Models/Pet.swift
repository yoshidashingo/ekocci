import Foundation

/// ペットの全状態
struct Pet: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var stage: LifeStage
    var characterId: String
    var stats: PetStats
    var discipline: Int             // 0, 25, 50, 75, 100
    var age: Int                    // ペット年齢 (1 = 実時間24時間)
    var generation: Int
    var birthDate: Date
    var stageStartDate: Date        // 現ステージ開始時刻
    var careMisses: Int
    var careMissesInStage: Int      // 現ステージ内のお世話ミス

    var isSleeping: Bool
    var isLightOff: Bool
    var isSick: Bool
    var medicineDosesNeeded: Int    // 治療に必要な残り投薬回数
    var poopCount: Int              // 0〜4
    var lastPoopTime: Date?

    var isPaused: Bool
    var pauseMinutesUsedToday: Int
    var pauseStartDate: Date?

    var ecoPoints: Int
    var hiddenStats: HiddenStats
    var lastUpdateTime: Date

    // MARK: - お世話ミスの猶予追跡

    /// おなか0になった時刻 (nil = おなかは空でない)
    var hungerEmptySince: Date?
    /// ごきげん0になった時刻
    var happinessEmptySince: Date?
    /// 消灯せずに寝始めた時刻
    var sleepWithoutLightSince: Date?

    /// 最大寿命(秒) - お世話ミス数で短縮
    var maxLifespanSeconds: TimeInterval {
        let baseDays = 25.0
        let penaltyPerMiss = 1.0 // 1ミスにつき1日短縮
        let days = max(7.0, baseDays - Double(careMisses) * penaltyPerMiss)
        return days * 24 * 60 * 60
    }

    /// 生存時間(秒)
    func aliveSeconds(at date: Date) -> TimeInterval {
        date.timeIntervalSince(birthDate)
    }

    /// 寿命に達したか
    func hasReachedLifespan(at date: Date) -> Bool {
        guard stage == .adult || stage == .senior else { return false }
        return aliveSeconds(at: date) >= maxLifespanSeconds
    }

    // MARK: - Factory

    /// 新しいたまごを生成
    static func newEgg(generation: Int = 1, at date: Date = .now) -> Pet {
        Pet(
            id: UUID(),
            stage: .egg,
            characterId: "egg",
            stats: PetStats.initial,
            discipline: 0,
            age: 0,
            generation: generation,
            birthDate: date,
            stageStartDate: date,
            careMisses: 0,
            careMissesInStage: 0,
            isSleeping: false,
            isLightOff: false,
            isSick: false,
            medicineDosesNeeded: 0,
            poopCount: 0,
            lastPoopTime: nil,
            isPaused: false,
            pauseMinutesUsedToday: 0,
            pauseStartDate: nil,
            ecoPoints: max(0, (generation - 1) * 100),
            hiddenStats: .initial,
            lastUpdateTime: date,
            hungerEmptySince: nil,
            happinessEmptySince: nil,
            sleepWithoutLightSince: nil
        )
    }
}
