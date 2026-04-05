import Foundation

/// キャラクター発見状態の管理
/// @unchecked Sendable: UserDefaults の個別 get/set はスレッドセーフ
final class DiscoveryStore: @unchecked Sendable {
    private static let key = "ekocci_discovered_characters"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = AppGroupConfig.sharedDefaults) {
        self.defaults = defaults
    }

    /// キャラクターを発見済みにする
    func discover(_ characterId: String) {
        var discovered = allDiscovered()
        discovered.insert(characterId)
        save(discovered)
    }

    /// 発見済みか判定
    func isDiscovered(_ characterId: String) -> Bool {
        allDiscovered().contains(characterId)
    }

    /// 全発見済みキャラクターID
    func allDiscovered() -> Set<String> {
        guard let array = defaults.stringArray(forKey: Self.key) else { return [] }
        return Set(array)
    }

    /// 発見数
    func discoveredCount() -> Int {
        allDiscovered().count
    }

    private func save(_ discovered: Set<String>) {
        defaults.set(Array(discovered).sorted(), forKey: Self.key)
    }
}
