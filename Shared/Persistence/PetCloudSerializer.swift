import Foundation
import CloudKit
import os

private let cloudLogger = Logger(subsystem: "com.ekocci", category: "CloudSerializer")

/// Pet ↔ CKRecord の変換 (純粋関数)
enum PetCloudSerializer {

    private static let recordType = "Pet"

    /// Pet → CKRecord
    static func toRecord(pet: Pet, zoneID: CKRecordZone.ID) -> CKRecord {
        let recordID = CKRecord.ID(recordName: pet.id.uuidString, zoneID: zoneID)
        let record = CKRecord(recordType: recordType, recordID: recordID)

        if let data = try? JSONEncoder().encode(pet) {
            record["petData"] = data as NSData
        }
        record["lastUpdateTime"] = pet.lastUpdateTime as NSDate
        record["generation"] = pet.generation as NSNumber

        return record
    }

    /// CKRecord → Pet
    static func fromRecord(_ record: CKRecord) -> Pet? {
        guard let data = record["petData"] as? Data else { return nil }
        do {
            return try JSONDecoder().decode(Pet.self, from: data)
        } catch {
            cloudLogger.error("Failed to decode pet from CloudKit: \(error.localizedDescription)")
            return nil
        }
    }

    /// コンフリクト解決: generation優先、同世代ならlastUpdateTimeが新しい方を採用
    static func resolveConflict(local: Pet, remote: Pet) -> Pet {
        if remote.generation != local.generation {
            return remote.generation > local.generation ? remote : local
        }
        return remote.lastUpdateTime > local.lastUpdateTime ? remote : local
    }
}
