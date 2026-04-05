import SwiftUI
import WidgetKit

@main
struct EkocciWatchApp: App {
    @State private var gameManager = GameManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(gameManager)
                .onAppear {
                    NotificationManager.requestPermission()
                    BackgroundRefreshScheduler.scheduleNext()
                }
        }
        .backgroundTask(.appRefresh("petRefresh")) {
            let store = PetStore()
            let pet = await BackgroundRefreshScheduler.handleRefresh(store: store)
            NotificationManager.scheduleIfNeeded(for: pet)
            WidgetCenter.shared.reloadTimelines(ofKind: "EkocciPetWidget")
            BackgroundRefreshScheduler.scheduleNext()
        }
    }
}
