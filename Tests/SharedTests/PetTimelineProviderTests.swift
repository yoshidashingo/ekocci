import Testing
import Foundation
@testable import EkocciShared

@Suite("PetTimelineProvider Tests")
struct PetTimelineProviderTests {

    @Test("エントリが指定数生成さ���る")
    func entryCount() {
        let pet = Pet.newEgg(at: .now)
        let entries = PetTimelineProviderLogic.generateEntries(pet: pet, from: .now)
        #expect(entries.count == GameConfig.widgetTimelineEntryCount)
    }

    @Test("最初のエントリは現在時刻")
    func firstEntryIsNow() {
        let now = Date.now
        let pet = Pet.newEgg(at: now)
        let entries = PetTimelineProviderLogic.generateEntries(pet: pet, from: now)
        #expect(entries[0].date == now)
    }

    @Test("エントリの間隔が正しい")
    func entryIntervals() {
        let now = Date.now
        let pet = Pet.newEgg(at: now)
        let entries = PetTimelineProviderLogic.generateEntries(pet: pet, from: now)

        for i in 1..<entries.count {
            let expected = now.addingTimeInterval(Double(i) * GameConfig.widgetTimelineEntryInterval)
            #expect(entries[i].date == expected)
        }
    }

    @Test("将来のエントリでペットが進化する")
    func futureEntriesAdvancePet() {
        let birthDate = Date.now.addingTimeInterval(-10 * 60)
        let pet = Pet.newEgg(at: birthDate)
        let entries = PetTimelineProviderLogic.generateEntries(pet: pet, from: .now)

        let laterEntry = entries[1]
        #expect(laterEntry.snapshot.stage == .baby)
    }

    @Test("スナップショットのフィールドが正しくマッピングされる")
    func snapshotFieldMapping() {
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.characterId = "child_genki"
        pet.stats = PetStats(hunger: 3, happiness: 2, weight: 8)
        pet.isSick = true

        let entries = PetTimelineProviderLogic.generateEntries(pet: pet, from: .now)
        let snapshot = entries[0].snapshot

        #expect(snapshot.characterId == "child_genki")
        #expect(snapshot.hunger == 3)
        #expect(snapshot.happiness == 2)
        #expect(snapshot.isSick == true)
    }
}
