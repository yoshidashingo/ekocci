import Foundation
#if os(watchOS)
import WatchKit
#endif

/// バックグラウンドリフレッシュのスケジュールと実行
enum BackgroundRefreshScheduler {

    /// 次回のバックグラウンドリフレッシュをスケジュール
    static func scheduleNext() {
        #if os(watchOS)
        let preferredDate = Date.now.addingTimeInterval(GameConfig.backgroundRefreshInterval)
        WKApplication.shared().scheduleBackgroundRefresh(
            withPreferredDate: preferredDate,
            userInfo: nil
        ) { _ in }
        #endif
    }

    /// バックグラウンドリフレッシュ実行 (テスタブル)
    static func handleRefresh(store: PetStore, at date: Date = .now) async -> Pet {
        await store.loadAndCatchUp(at: date)
    }
}
