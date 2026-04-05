import Testing
import Foundation
@testable import EkocciShared

@Suite("PetSnapshot Tests")
struct PetSnapshotTests {

    @Test("Petからスナップショットを生成できる")
    func fromPet() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.characterId = "child_genki"
        pet.stats = PetStats(hunger: 3, happiness: 2, weight: 8)
        pet.isSick = true
        pet.isSleeping = false

        let snapshot = PetSnapshot.from(pet)
        #expect(snapshot.characterId == "child_genki")
        #expect(snapshot.characterName == "ゲンキっち")
        #expect(snapshot.stage == .child)
        #expect(snapshot.hunger == 3)
        #expect(snapshot.happiness == 2)
        #expect(snapshot.isSick == true)
        #expect(snapshot.isSleeping == false)
    }

    @Test("絵文字がSpriteMappingと一致する")
    func emojiFromMapping() {
        var pet = Pet.newEgg(at: .now)
        pet.characterId = "adult_eco_master"
        let snapshot = PetSnapshot.from(pet)
        #expect(snapshot.emoji == "🌍")
    }

    @Test("不明なcharacterIdでもfallbackで動作する")
    func unknownCharacterId() {
        var pet = Pet.newEgg(at: .now)
        pet.characterId = "unknown_char"
        let snapshot = PetSnapshot.from(pet)
        #expect(snapshot.characterName == "unknown_char")
        #expect(!snapshot.emoji.isEmpty)
    }

    @Test("プレースホルダーが正しい")
    func placeholder() {
        let ph = PetSnapshot.placeholder
        #expect(ph.stage == .egg)
        #expect(ph.hunger == 4)
        #expect(ph.happiness == 4)
    }
}
