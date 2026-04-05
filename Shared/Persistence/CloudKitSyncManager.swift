import Foundation
import CloudKit
import os

private let logger = Logger(subsystem: "com.ekocci", category: "CloudKitSync")

/// CloudKit 同期マネージャー
actor CloudKitSyncManager {

    private let container: CKContainer
    private let zoneID: CKRecordZone.ID
    private var zoneCreated = false

    init(containerID: String = GameConfig.cloudKitContainerID) {
        self.container = CKContainer(identifier: containerID)
        self.zoneID = CKRecordZone.ID(zoneName: GameConfig.cloudKitZoneName, ownerName: CKCurrentUserDefaultName)
    }

    // MARK: - Upload (fire-and-forget)

    func upload(pet: Pet) async {
        do {
            let database = container.privateCloudDatabase
            try await ensureZoneExists(database: database)
            let record = PetCloudSerializer.toRecord(pet: pet, zoneID: zoneID)
            _ = try await database.save(record)
            logger.info("CloudKit upload succeeded for pet \(pet.id)")
        } catch {
            logger.error("CloudKit upload failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Download

    func download() async -> Pet? {
        do {
            let database = container.privateCloudDatabase
            let query = CKQuery(recordType: "Pet", predicate: NSPredicate(value: true))
            query.sortDescriptors = [NSSortDescriptor(key: "lastUpdateTime", ascending: false)]
            let (results, _) = try await database.records(matching: query, inZoneWith: zoneID, resultsLimit: 1)
            guard let (_, result) = results.first,
                  let record = try? result.get() else { return nil }
            return PetCloudSerializer.fromRecord(record)
        } catch {
            logger.error("CloudKit download failed: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Sync (download + conflict resolution)

    func sync(localPet: Pet) async -> Pet {
        guard let remotePet = await download() else { return localPet }
        let resolved = PetCloudSerializer.resolveConflict(local: localPet, remote: remotePet)
        if resolved.id == remotePet.id && resolved.id != localPet.id {
            logger.info("CloudKit sync: remote pet is newer, using remote")
        }
        return resolved
    }

    // MARK: - Zone

    private func ensureZoneExists(database: CKDatabase) async throws {
        guard !zoneCreated else { return }
        let zone = CKRecordZone(zoneID: zoneID)
        _ = try await database.save(zone)
        zoneCreated = true
    }
}
