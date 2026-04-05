import Foundation
import Observation
import WidgetKit

/// ゲーム全体の状態管理
@MainActor
@Observable
final class GameManager {
    private(set) var pet: Pet
    private(set) var lastAction: String?
    private let store: PetStore
    private let connectivity: WatchConnectivityManager
    private let discoveryStore: DiscoveryStore
    private var timerTask: Task<Void, Never>?

    init(store: PetStore = PetStore(), discoveryStore: DiscoveryStore = DiscoveryStore()) {
        self.store = store
        self.discoveryStore = discoveryStore
        self.connectivity = WatchConnectivityManager(store: store)
        // 同期初期化: デフォルトのたまごで開始、onActivate で async ロード
        self.pet = Pet.newEgg(at: .now)
        setupConnectivity()
    }

    private func setupConnectivity() {
        connectivity.onCareAction = { [weak self] action in
            Task { @MainActor in
                await self?.handleRemoteCareAction(action)
            }
        }
        connectivity.onShopPurchase = { [weak self] itemType in
            Task { @MainActor in
                await self?.handleRemoteShopPurchase(itemType)
            }
        }
    }

    // MARK: - Lifecycle

    func onActivate() {
        Task {
            pet = await store.loadAndCatchUp()
            discoveryStore.discover(pet.characterId)
            startTimer()
        }
    }

    func onDeactivate() {
        Task { await savePetAndSync() }
        stopTimer()
    }

    // MARK: - タイマー

    private func startTimer() {
        stopTimer()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled else { break }
                await self?.tick()
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func tick() async {
        let now = Date.now
        pet = GameEngine.advance(pet: pet, from: pet.lastUpdateTime, to: now)
        await savePetAndSync()
    }

    // MARK: - お世話アクション

    func feedMeal() async {
        pet = GameEngine.feed(pet: pet, at: .now)
        lastAction = "🍔 ごはん!"
        await savePetAndSync()
        HapticManager.play(.fed)
    }

    func feedSnack() async {
        pet = GameEngine.snack(pet: pet, at: .now)
        lastAction = "🍰 おやつ!"
        await savePetAndSync()
        HapticManager.play(.fed)
    }

    func clean() async {
        pet = GameEngine.clean(pet: pet, at: .now)
        lastAction = "✨ そうじ!"
        await savePetAndSync()
        HapticManager.play(.cleaned)
    }

    func giveMedicine() async {
        pet = GameEngine.giveMedicine(pet: pet, at: .now)
        lastAction = "💊 くすり!"
        await savePetAndSync()
        HapticManager.play(.healed)
    }

    func discipline() async {
        pet = GameEngine.discipline(pet: pet, at: .now)
        lastAction = "✋ しつけ! \(pet.discipline)%"
        await savePetAndSync()
        HapticManager.play(.disciplined)
    }

    func toggleLight() async {
        if pet.isLightOff {
            pet = GameEngine.turnLightOn(pet: pet, at: .now)
            lastAction = "💡 でんき つけた"
        } else {
            pet = GameEngine.turnLightOff(pet: pet, at: .now)
            lastAction = "🌙 でんき けした"
        }
        await savePetAndSync()
    }

    func miniGameWon() async {
        pet = GameEngine.miniGameWon(pet: pet, at: .now)
        lastAction = "🎉 かち! +50P"
        await savePetAndSync()
        HapticManager.play(.gameWon)
    }

    func miniGameLost() async {
        pet = GameEngine.miniGameLost(pet: pet, at: .now)
        await savePetAndSync()
        HapticManager.play(.gameLost)
    }

    func applyMiniGameResult(_ result: MiniGameResult) async {
        if result.won {
            await miniGameWon()
        } else {
            await miniGameLost()
        }
    }

    func togglePause() async {
        if pet.isPaused {
            pet = GameEngine.unpause(pet: pet, at: .now)
        } else {
            pet = GameEngine.pause(pet: pet, at: .now)
        }
        await savePetAndSync()
    }

    func startNextGeneration() async {
        await store.addToHistory(pet)
        pet = GameEngine.newGeneration(from: pet, at: .now)
        await savePetAndSync()
    }

    // MARK: - Remote Actions (from iPhone)

    private func handleRemoteCareAction(_ action: CareAction) async {
        switch action {
        case .feedMeal: await feedMeal()
        case .feedSnack: await feedSnack()
        case .clean: await clean()
        case .medicine: await giveMedicine()
        case .discipline: await discipline()
        case .lightOff: await toggleLight()
        case .lightOn: await toggleLight()
        case .play: break
        }
    }

    private func handleRemoteShopPurchase(_ type: ShopItemType) async {
        guard let item = ShopItem.catalog.first(where: { $0.type == type }) else { return }
        let shopStore = ShopStore()
        guard let updated = shopStore.purchase(item: item, from: pet, at: .now) else { return }
        pet = updated
        await savePetAndSync()
    }

    // MARK: - Widget + Connectivity 連携

    private func savePetAndSync() async {
        await store.savePet(pet)
        discoveryStore.discover(pet.characterId)
        WidgetCenter.shared.reloadTimelines(ofKind: "EkocciPetWidget")
        connectivity.sendPetState(pet)
    }
}
