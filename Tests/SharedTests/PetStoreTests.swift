import Testing
import Foundation
@testable import EkocciShared

@Suite("PetStore Tests")
struct PetStoreTests {

    private func makeStore() -> PetStore {
        let suiteName = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        return PetStore(defaults: defaults)
    }

    // MARK: - Save & Load ラウンドトリップ

    @Test("保存したペットを読み込める")
    func saveAndLoadRoundTrip() async {
        let store = makeStore()
        let pet = Pet.newEgg(at: Date(timeIntervalSince1970: 1_000_000))

        await store.savePet(pet)
        let loaded = await store.loadPet()

        #expect(loaded != nil)
        #expect(loaded?.id == pet.id)
        #expect(loaded?.stage == pet.stage)
        #expect(loaded?.stats == pet.stats)
        #expect(loaded?.generation == pet.generation)
    }

    @Test("変更後のペットが正しく保存される")
    func saveModifiedPet() async {
        let store = makeStore()
        var pet = Pet.newEgg(at: .now)
        pet.stage = .child
        pet.stats = PetStats(hunger: 1, happiness: 2, weight: 8)
        pet.discipline = 50
        pet.poopCount = 3
        pet.isSick = true

        await store.savePet(pet)
        let loaded = await store.loadPet()

        #expect(loaded?.stage == .child)
        #expect(loaded?.stats.hunger == 1)
        #expect(loaded?.stats.happiness == 2)
        #expect(loaded?.discipline == 50)
        #expect(loaded?.poopCount == 3)
        #expect(loaded?.isSick == true)
    }

    // MARK: - 空状態

    @Test("保存前はnilを返す")
    func loadReturnsNilWhenEmpty() async {
        let store = makeStore()
        #expect(await store.loadPet() == nil)
    }

    // MARK: - 削除

    @Test("削除後はnilを返す")
    func deleteRemovesPet() async {
        let store = makeStore()
        await store.savePet(Pet.newEgg(at: .now))
        await store.deletePet()
        #expect(await store.loadPet() == nil)
    }

    // MARK: - 上書き

    @Test("保存を2回すると最新のペットが読み込まれる")
    func overwriteWithNewPet() async {
        let store = makeStore()
        let pet1 = Pet.newEgg(generation: 1, at: .now)
        let pet2 = Pet.newEgg(generation: 2, at: .now)

        await store.savePet(pet1)
        await store.savePet(pet2)
        let loaded = await store.loadPet()

        #expect(loaded?.id == pet2.id)
        #expect(loaded?.generation == 2)
    }

    // MARK: - History

    @Test("履歴が空の状態で空配列を返す")
    func emptyHistory() async {
        let store = makeStore()
        let history = await store.loadHistory()
        #expect(history.isEmpty)
    }

    @Test("死亡ペットを履歴に追加できる")
    func addToHistory() async {
        let store = makeStore()
        var pet = Pet.newEgg(at: .now)
        pet.stage = .dead
        pet.age = 15

        await store.addToHistory(pet)
        let history = await store.loadHistory()

        #expect(history.count == 1)
        #expect(history[0].id == pet.id)
        #expect(history[0].age == 15)
        #expect(history[0].generation == pet.generation)
    }

    @Test("複数ペットの履歴が蓄積される")
    func multipleHistoryEntries() async {
        let store = makeStore()

        for gen in 1...3 {
            var pet = Pet.newEgg(generation: gen, at: .now)
            pet.stage = .dead
            await store.addToHistory(pet)
        }

        let history = await store.loadHistory()
        #expect(history.count == 3)
        #expect(history[0].generation == 1)
        #expect(history[2].generation == 3)
    }

    // MARK: - loadAndCatchUp

    @Test("ペットがないとき新しいたまごを生成する")
    func loadAndCatchUpCreatesNewEgg() async {
        let store = makeStore()
        let pet = await store.loadAndCatchUp(at: .now)

        #expect(pet.stage == .egg)
        #expect(pet.generation == 1)
        #expect(await store.loadPet() != nil)
    }

    @Test("既存ペットを読み込みキャッチアップする")
    func loadAndCatchUpAdvancesTime() async {
        let store = makeStore()
        let birthDate = Date(timeIntervalSince1970: 1_000_000)
        let pet = Pet.newEgg(at: birthDate)
        await store.savePet(pet)

        let laterDate = birthDate.addingTimeInterval(45) // 30秒で孵化
        let loaded = await store.loadAndCatchUp(at: laterDate)

        #expect(loaded.stage == .baby)
    }
}
