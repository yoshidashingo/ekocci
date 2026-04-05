import Testing
import Foundation
@testable import EkocciShared

@Suite("ConnectivityMessage Tests")
struct ConnectivityMessageTests {

    @Test("petStateUpdateのラウンドトリップ")
    func petStateRoundTrip() {
        let pet = Pet.newEgg(at: Date(timeIntervalSince1970: 1_000_000))
        let msg = ConnectivityMessage.petStateUpdate(pet)
        let dict = msg.toDictionary()
        let decoded = ConnectivityMessage.from(dict)

        if case .petStateUpdate(let decodedPet) = decoded {
            #expect(decodedPet.id == pet.id)
            #expect(decodedPet.stage == pet.stage)
        } else {
            #expect(Bool(false), "Expected petStateUpdate")
        }
    }

    @Test("careActionのラウンドトリップ")
    func careActionRoundTrip() {
        let msg = ConnectivityMessage.careAction(.feedMeal)
        let dict = msg.toDictionary()
        let decoded = ConnectivityMessage.from(dict)

        if case .careAction(let action) = decoded {
            #expect(action == .feedMeal)
        } else {
            #expect(Bool(false), "Expected careAction")
        }
    }

    @Test("shopPurchaseのラウンドトリップ")
    func shopPurchaseRoundTrip() {
        let msg = ConnectivityMessage.shopPurchase(.speedBoost)
        let dict = msg.toDictionary()
        let decoded = ConnectivityMessage.from(dict)

        if case .shopPurchase(let itemType) = decoded {
            #expect(itemType == .speedBoost)
        } else {
            #expect(Bool(false), "Expected shopPurchase")
        }
    }

    @Test("settingsUpdateのラウンドトリップ")
    func settingsRoundTrip() {
        let msg = ConnectivityMessage.settingsUpdate(
            soundEnabled: false, notificationsEnabled: true, pauseLimitMinutes: 480
        )
        let dict = msg.toDictionary()
        let decoded = ConnectivityMessage.from(dict)

        if case .settingsUpdate(let sound, let notif, let pause) = decoded {
            #expect(sound == false)
            #expect(notif == true)
            #expect(pause == 480)
        } else {
            #expect(Bool(false), "Expected settingsUpdate")
        }
    }

    @Test("不正なデータでnilを返す")
    func invalidDataReturnsNil() {
        #expect(ConnectivityMessage.from([:]) == nil)
        #expect(ConnectivityMessage.from(["type": "invalid"]) == nil)
        #expect(ConnectivityMessage.from(["type": "petStateUpdate", "payload": Data()]) == nil)
    }
}
