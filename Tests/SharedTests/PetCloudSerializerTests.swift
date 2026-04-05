import Testing
import Foundation
import CloudKit
@testable import EkocciShared

@Suite("PetCloudSerializer Tests")
struct PetCloudSerializerTests {

    private let zoneID = CKRecordZone.ID(zoneName: "TestZone", ownerName: CKCurrentUserDefaultName)

    @Test("Petをラウンドトリップでエンコード/デコードできる")
    func roundTrip() {
        var pet = Pet.newEgg(at: Date(timeIntervalSince1970: 1_000_000))
        pet.stage = .child
        pet.characterId = "child_genki"
        pet.stats = PetStats(hunger: 3, happiness: 2, weight: 8)
        pet.discipline = 75

        let record = PetCloudSerializer.toRecord(pet: pet, zoneID: zoneID)
        let decoded = PetCloudSerializer.fromRecord(record)

        #expect(decoded != nil)
        #expect(decoded?.id == pet.id)
        #expect(decoded?.stage == .child)
        #expect(decoded?.characterId == "child_genki")
        #expect(decoded?.stats.hunger == 3)
        #expect(decoded?.discipline == 75)
    }

    @Test("空のレコードからはnilを返す")
    func emptyRecordReturnsNil() {
        let record = CKRecord(recordType: "Pet")
        #expect(PetCloudSerializer.fromRecord(record) == nil)
    }

    @Test("コンフリクト解決: 新しい方を採用")
    func conflictResolutionPicksNewer() {
        let older = Date(timeIntervalSince1970: 1_000_000)
        let newer = Date(timeIntervalSince1970: 2_000_000)

        var localPet = Pet.newEgg(at: older)
        localPet.lastUpdateTime = older

        var remotePet = Pet.newEgg(at: newer)
        remotePet.lastUpdateTime = newer

        let resolved = PetCloudSerializer.resolveConflict(local: localPet, remote: remotePet)
        #expect(resolved.id == remotePet.id)
    }

    @Test("コンフリクト解決: ローカルが新しければローカルを維持")
    func conflictResolutionKeepsLocal() {
        let newer = Date(timeIntervalSince1970: 2_000_000)
        let older = Date(timeIntervalSince1970: 1_000_000)

        var localPet = Pet.newEgg(at: newer)
        localPet.lastUpdateTime = newer

        var remotePet = Pet.newEgg(at: older)
        remotePet.lastUpdateTime = older

        let resolved = PetCloudSerializer.resolveConflict(local: localPet, remote: remotePet)
        #expect(resolved.id == localPet.id)
    }
}
