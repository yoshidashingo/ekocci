import Foundation

/// ショップ購入・アクティブ効果の管理
/// @unchecked Sendable: UserDefaults の個別 get/set はスレッドセーフ
final class ShopStore: @unchecked Sendable {
    private static let key = "ekocci_active_effects"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = AppGroupConfig.sharedDefaults) {
        self.defaults = defaults
    }

    /// アイテム購入 — ecoPoints不足または同効果アクティブ時はnilを返す
    func purchase(item: ShopItem, from pet: Pet, at date: Date) -> Pet? {
        guard pet.ecoPoints >= item.cost else { return nil }
        guard !hasActiveEffect(item.type, at: date) else { return nil }

        let effect = ActiveEffect(
            type: item.type,
            activatedAt: date,
            durationSeconds: item.durationSeconds
        )
        var effects = activeEffects(at: date)
        effects.append(effect)
        save(effects)

        var updatedPet = pet
        updatedPet.ecoPoints -= item.cost
        return updatedPet
    }

    /// 有効な効果一覧 (期限切れは除外)
    func activeEffects(at date: Date) -> [ActiveEffect] {
        let all = loadAll()
        let active = all.filter { $0.isActive(at: date) }
        if active.count != all.count {
            save(active) // 期限切れを除去
        }
        return active
    }

    /// 指定効果がアクティブか
    func hasActiveEffect(_ type: ShopItemType, at date: Date) -> Bool {
        activeEffects(at: date).contains { $0.type == type }
    }

    private func loadAll() -> [ActiveEffect] {
        guard let data = defaults.data(forKey: Self.key) else { return [] }
        return (try? JSONDecoder().decode([ActiveEffect].self, from: data)) ?? []
    }

    private func save(_ effects: [ActiveEffect]) {
        guard let data = try? JSONEncoder().encode(effects) else { return }
        defaults.set(data, forKey: Self.key)
    }
}
