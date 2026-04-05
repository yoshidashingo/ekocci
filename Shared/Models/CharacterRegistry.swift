import Foundation

/// 全キャラクター定義のレジストリ (22体)
enum CharacterRegistry {

    // MARK: - Public API

    /// 全キャラクター
    static let allCharacters: [CharacterDefinition] = baby + child + young + adult + senior + special

    /// 指定ステージのキャラクター (priority降順)
    static func characters(for stage: LifeStage) -> [CharacterDefinition] {
        allCharacters
            .filter { $0.stage == stage }
            .sorted { $0.priority > $1.priority }
    }

    /// ID でキャラクター検索
    static func character(id: String) -> CharacterDefinition? {
        allCharacters.first { $0.id == id }
    }

    /// フォールバック: ステージのデフォルトキャラクター
    static func defaultCharacter(for stage: LifeStage) -> CharacterDefinition {
        characters(for: stage).last ?? CharacterDefinition(
            id: "\(stage.rawValue)_default",
            name: "???",
            stage: stage,
            emoji: "❓",
            condition: .any,
            priority: 0
        )
    }

    // MARK: - Baby (1体)

    private static let baby: [CharacterDefinition] = [
        .init(id: "baby_default", name: "ベビっち", stage: .baby,
              emoji: "🐣", condition: .any, priority: 0),
    ]

    // MARK: - Child (4体)

    private static let child: [CharacterDefinition] = [
        .init(id: "child_genki", name: "ゲンキっち", stage: .child,
              emoji: "⭐️",
              condition: .init(careMissRange: 0...1, disciplineRange: 50...100,
                               weightRange: nil, effortRange: nil, bondingRange: nil, generationMin: nil),
              priority: 30),
        .init(id: "child_shy", name: "シャイっち", stage: .child,
              emoji: "🌸",
              condition: .init(careMissRange: 0...2, disciplineRange: 25...74,
                               weightRange: nil, effortRange: nil, bondingRange: nil, generationMin: nil),
              priority: 20),
        .init(id: "child_rebel", name: "ヤンチャっち", stage: .child,
              emoji: "🔥",
              condition: .init(careMissRange: 0...3, disciplineRange: 0...24,
                               weightRange: nil, effortRange: nil, bondingRange: nil, generationMin: nil),
              priority: 10),
        .init(id: "child_lazy", name: "ノンビっち", stage: .child,
              emoji: "💤",
              condition: .any,
              priority: 0),
    ]

    // MARK: - Young (5体)

    private static let young: [CharacterDefinition] = [
        .init(id: "young_athlete", name: "スポーっち", stage: .young,
              emoji: "🏃",
              condition: .init(careMissRange: 0...1, disciplineRange: 75...100,
                               weightRange: 5...8, effortRange: nil, bondingRange: nil, generationMin: nil),
              priority: 40),
        .init(id: "young_scholar", name: "ガクっち", stage: .young,
              emoji: "📚",
              condition: .init(careMissRange: 0...1, disciplineRange: 50...100,
                               weightRange: nil, effortRange: 30...100, bondingRange: nil, generationMin: nil),
              priority: 30),
        .init(id: "young_artist", name: "アートっち", stage: .young,
              emoji: "🎨",
              condition: .init(careMissRange: 0...2, disciplineRange: 25...74,
                               weightRange: nil, effortRange: nil, bondingRange: 30...100, generationMin: nil),
              priority: 20),
        .init(id: "young_rebel", name: "ツッパっち", stage: .young,
              emoji: "⚡️",
              condition: .init(careMissRange: 3...999, disciplineRange: 0...49,
                               weightRange: nil, effortRange: nil, bondingRange: nil, generationMin: nil),
              priority: 10),
        .init(id: "young_dreamer", name: "ユメっち", stage: .young,
              emoji: "🌙",
              condition: .any,
              priority: 0),
    ]

    // MARK: - Adult (6体)

    private static let adult: [CharacterDefinition] = [
        .init(id: "adult_wise", name: "モノシっち", stage: .adult,
              emoji: "🦉",
              condition: .init(careMissRange: 0...1, disciplineRange: 75...100,
                               weightRange: nil, effortRange: 50...100, bondingRange: nil, generationMin: nil),
              priority: 50),
        .init(id: "adult_strong", name: "マッスっち", stage: .adult,
              emoji: "💪",
              condition: .init(careMissRange: 0...2, disciplineRange: 50...100,
                               weightRange: 8...20, effortRange: nil, bondingRange: nil, generationMin: nil),
              priority: 40),
        .init(id: "adult_gentle", name: "ヤサシっち", stage: .adult,
              emoji: "🌿",
              condition: .init(careMissRange: 0...2, disciplineRange: 25...74,
                               weightRange: nil, effortRange: nil, bondingRange: 50...100, generationMin: nil),
              priority: 30),
        .init(id: "adult_gourmet", name: "グルメっち", stage: .adult,
              emoji: "🍳",
              condition: .init(careMissRange: 0...999, disciplineRange: 0...100,
                               weightRange: 15...99, effortRange: nil, bondingRange: nil, generationMin: nil),
              priority: 20),
        .init(id: "adult_wild", name: "ワイルっち", stage: .adult,
              emoji: "🐺",
              condition: .init(careMissRange: 4...999, disciplineRange: 0...49,
                               weightRange: nil, effortRange: nil, bondingRange: nil, generationMin: nil),
              priority: 10),
        .init(id: "adult_mystic", name: "フシギっち", stage: .adult,
              emoji: "🔮",
              condition: .any,
              priority: 0),
    ]

    // MARK: - Senior (4体)

    private static let senior: [CharacterDefinition] = [
        .init(id: "senior_sage", name: "センセっち", stage: .senior,
              emoji: "🎓",
              condition: .init(careMissRange: 0...2, disciplineRange: 75...100,
                               weightRange: nil, effortRange: 60...100, bondingRange: nil, generationMin: nil),
              priority: 30),
        .init(id: "senior_jolly", name: "ニコニっち", stage: .senior,
              emoji: "😊",
              condition: .init(careMissRange: 0...3, disciplineRange: 25...100,
                               weightRange: nil, effortRange: nil, bondingRange: 60...100, generationMin: nil),
              priority: 20),
        .init(id: "senior_hermit", name: "ヤマオっち", stage: .senior,
              emoji: "🏔️",
              condition: .init(careMissRange: 4...999, disciplineRange: 0...100,
                               weightRange: nil, effortRange: nil, bondingRange: nil, generationMin: nil),
              priority: 10),
        .init(id: "senior_legend", name: "レジェっち", stage: .senior,
              emoji: "👑",
              condition: .any,
              priority: 0),
    ]

    // MARK: - Special (2体)

    private static let special: [CharacterDefinition] = [
        .init(id: "adult_eco_master", name: "エコマスっち", stage: .adult,
              emoji: "🌍",
              condition: .init(careMissRange: 0...1, disciplineRange: 75...100,
                               weightRange: nil, effortRange: 70...100, bondingRange: 70...100, generationMin: nil),
              priority: 100),
        .init(id: "senior_eternal", name: "エターっち", stage: .senior,
              emoji: "✨",
              condition: .init(careMissRange: 0...2, disciplineRange: 50...100,
                               weightRange: nil, effortRange: 50...100, bondingRange: 50...100, generationMin: 3),
              priority: 100),
    ]
}
