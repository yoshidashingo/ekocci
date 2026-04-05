import Foundation

/// ペットのステータス
struct PetStats: Codable, Equatable, Sendable {
    /// おなか (0〜4)
    var hunger: Int

    /// ごきげん (0〜4)
    var happiness: Int

    /// たいじゅう (グラム)
    var weight: Int

    static let maxHearts = 4
    static let minWeight = 5

    static let initial = PetStats(hunger: 4, happiness: 4, weight: 5)

    /// おなかが満タンか
    var isHungerFull: Bool { hunger >= Self.maxHearts }

    /// ごきげんが満タンか
    var isHappinessFull: Bool { happiness >= Self.maxHearts }

    /// おなかが空か
    var isHungry: Bool { hunger <= 0 }

    /// ごきげんが空か
    var isUnhappy: Bool { happiness <= 0 }

    /// ごはんを食べた結果を返す
    func fed() -> PetStats {
        PetStats(
            hunger: min(hunger + 1, Self.maxHearts),
            happiness: happiness,
            weight: weight + 1
        )
    }

    /// おやつを食べた結果を返す
    func snacked() -> PetStats {
        PetStats(
            hunger: hunger,
            happiness: min(happiness + 1, Self.maxHearts),
            weight: weight + 2
        )
    }

    /// ミニゲームに勝った結果を返す
    func playedAndWon() -> PetStats {
        PetStats(
            hunger: hunger,
            happiness: min(happiness + 1, Self.maxHearts),
            weight: max(weight - 1, Self.minWeight)
        )
    }

    /// おなかが1減った結果を返す
    func hungerDecayed() -> PetStats {
        PetStats(
            hunger: max(hunger - 1, 0),
            happiness: happiness,
            weight: weight
        )
    }

    /// ごきげんが1減った結果を返す
    func happinessDecayed() -> PetStats {
        PetStats(
            hunger: hunger,
            happiness: max(happiness - 1, 0),
            weight: weight
        )
    }
}
