import SwiftUI

@main
struct EkocciPhoneApp: App {
    @State private var gameManager = PhoneGameManager()

    var body: some Scene {
        WindowGroup {
            TabRootView()
                .environment(gameManager)
                .task {
                    await gameManager.loadLocal()
                }
        }
    }
}
