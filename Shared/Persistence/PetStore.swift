import Foundation
import os

private let logger = Logger(subsystem: "com.ekocci", category: "PetStore")

/// ペットデータの永続化 (actor でスレッドセーフ)
actor PetStore {
    private static let petKey = "ekocci_current_pet"
    private static let historyKey = "ekocci_pet_history"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = AppGroupConfig.sharedDefaults) {
        self.defaults = defaults
    }

    /// .standard から App Group への一回限りマイグレーション (初回ロード時に呼ぶ)
    func migrateFromStandardIfNeeded() {
        let standard = UserDefaults.standard
        guard defaults !== standard,
              defaults.data(forKey: Self.petKey) == nil,
              let data = standard.data(forKey: Self.petKey) else { return }
        defaults.set(data, forKey: Self.petKey)
        if let history = standard.data(forKey: Self.historyKey) {
            defaults.set(history, forKey: Self.historyKey)
        }
        standard.removeObject(forKey: Self.petKey)
        standard.removeObject(forKey: Self.historyKey)
    }

    // MARK: - Current Pet

    func loadPet() -> Pet? {
        guard let data = defaults.data(forKey: Self.petKey) else { return nil }
        do {
            return try JSONDecoder().decode(Pet.self, from: data)
        } catch {
            logger.error("Failed to decode pet: \(error.localizedDescription)")
            return nil
        }
    }

    func savePet(_ pet: Pet) {
        do {
            let data = try JSONEncoder().encode(pet)
            defaults.set(data, forKey: Self.petKey)
        } catch {
            logger.error("Failed to encode pet: \(error.localizedDescription)")
        }
    }

    func deletePet() {
        defaults.removeObject(forKey: Self.petKey)
    }

    // MARK: - History

    func loadHistory() -> [PetRecord] {
        guard let data = defaults.data(forKey: Self.historyKey) else { return [] }
        do {
            return try JSONDecoder().decode([PetRecord].self, from: data)
        } catch {
            logger.error("Failed to decode history: \(error.localizedDescription)")
            return []
        }
    }

    func addToHistory(_ pet: Pet) {
        var history = loadHistory()
        let record = PetRecord(
            id: pet.id,
            characterId: pet.characterId,
            generation: pet.generation,
            age: pet.age,
            birthDate: pet.birthDate,
            deathDate: .now
        )
        history.append(record)
        do {
            let data = try JSONEncoder().encode(history)
            defaults.set(data, forKey: Self.historyKey)
        } catch {
            logger.error("Failed to encode history: \(error.localizedDescription)")
        }
    }

    // MARK: - Launch Flow

    func loadAndCatchUp(at date: Date = .now) -> Pet {
        migrateFromStandardIfNeeded()
        if let pet = loadPet() {
            let updated = GameEngine.advance(pet: pet, from: pet.lastUpdateTime, to: date)
            savePet(updated)
            return updated
        }
        let newPet = Pet.newEgg(at: date)
        savePet(newPet)
        return newPet
    }
}

/// 歴代ペットの記録
struct PetRecord: Codable, Identifiable, Sendable {
    let id: UUID
    let characterId: String
    let generation: Int
    let age: Int
    let birthDate: Date
    let deathDate: Date
}
