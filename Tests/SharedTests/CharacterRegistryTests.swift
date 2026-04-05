import Testing
@testable import EkocciShared

@Suite("CharacterRegistry Tests")
struct CharacterRegistryTests {

    @Test("全キャラクターは22体")
    func totalCount() {
        #expect(CharacterRegistry.allCharacters.count == 22)
    }

    @Test("IDに重複がない")
    func uniqueIds() {
        let ids = CharacterRegistry.allCharacters.map(\.id)
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count)
    }

    @Test("各進化ステージにキャラクターがある",
          arguments: [LifeStage.baby, .child, .young, .adult, .senior])
    func stageHasCharacters(stage: LifeStage) {
        let chars = CharacterRegistry.characters(for: stage)
        #expect(!chars.isEmpty)
    }

    @Test("egg と dead にはキャラクターがない",
          arguments: [LifeStage.egg, .dead])
    func noCharactersForEggDead(stage: LifeStage) {
        #expect(CharacterRegistry.characters(for: stage).isEmpty)
    }

    @Test("IDで検索できる")
    func lookupById() {
        let char = CharacterRegistry.character(id: "child_genki")
        #expect(char != nil)
        #expect(char?.name == "ゲンキっち")
    }

    @Test("存在しないIDはnilを返す")
    func lookupMissing() {
        #expect(CharacterRegistry.character(id: "nonexistent") == nil)
    }

    @Test("デフォルトキャラクターがステージごとに返る",
          arguments: [LifeStage.baby, .child, .young, .adult, .senior])
    func defaultCharacterExists(stage: LifeStage) {
        let def = CharacterRegistry.defaultCharacter(for: stage)
        #expect(def.stage == stage)
    }

    @Test("priority降順でソートされている")
    func sortedByPriority() {
        let chars = CharacterRegistry.characters(for: .adult)
        for i in 0..<(chars.count - 1) {
            #expect(chars[i].priority >= chars[i + 1].priority)
        }
    }

    @Test("完全お世話ペットはどのステージでも最高tierに進化する")
    func perfectCareResolvesTopTier() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.careMissesInStage = 0
        pet.discipline = 100
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 7)
        pet.hiddenStats = HiddenStats(effort: 80, bonding: 80)

        #expect(EvolutionEngine.resolve(pet: pet, nextStage: .child) == "child_genki")
        #expect(EvolutionEngine.resolve(pet: pet, nextStage: .young) == "young_athlete")
    }

    @Test("お世話放置ペットは低tierに進化する")
    func neglectedPetResolvesLowTier() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.careMissesInStage = 6
        pet.discipline = 0
        pet.stats = PetStats(hunger: 0, happiness: 0, weight: 5)
        pet.hiddenStats = HiddenStats(effort: 0, bonding: 0)

        let childResult = EvolutionEngine.resolve(pet: pet, nextStage: .child)
        #expect(childResult == "child_lazy")

        let youngResult = EvolutionEngine.resolve(pet: pet, nextStage: .young)
        #expect(youngResult == "young_rebel")
    }

    @Test("高体重+低しつけペットはグルメっちに進化する")
    func heavyPetBecomesGourmet() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .young
        pet.careMissesInStage = 3
        pet.discipline = 20
        pet.stats = PetStats(hunger: 4, happiness: 4, weight: 18)
        pet.hiddenStats = HiddenStats(effort: 20, bonding: 20)

        #expect(EvolutionEngine.resolve(pet: pet, nextStage: .adult) == "adult_gourmet")
    }

    @Test("世代3+でエターっちに進化できる")
    func generation3UnlocksEternal() {
        var pet = Pet.newEgg(generation: 3, at: .now)
        pet.stage = .adult
        pet.careMissesInStage = 0
        pet.discipline = 75
        pet.hiddenStats = HiddenStats(effort: 60, bonding: 60)

        #expect(EvolutionEngine.resolve(pet: pet, nextStage: .senior) == "senior_eternal")
    }

    @Test("世代2ではエターっちに進化しない")
    func generation2NoEternal() {
        var pet = Pet.newEgg(generation: 2, at: .now)
        pet.stage = .adult
        pet.careMissesInStage = 0
        pet.discipline = 75
        pet.hiddenStats = HiddenStats(effort: 60, bonding: 60)

        #expect(EvolutionEngine.resolve(pet: pet, nextStage: .senior) != "senior_eternal")
    }

    @Test("エコマスっちは高effort+高bondingで解放される")
    func ecoMasterRequiresBoth() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .young
        pet.careMissesInStage = 0
        pet.discipline = 100
        pet.hiddenStats = HiddenStats(effort: 80, bonding: 80)

        #expect(EvolutionEngine.resolve(pet: pet, nextStage: .adult) == "adult_eco_master")
    }
}
