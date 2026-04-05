import SwiftUI

/// iPhone アプリのルートTabView
struct TabRootView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }

            FamilyTreeView()
                .tabItem {
                    Label("家系図", systemImage: "tree")
                }

            EncyclopediaView()
                .tabItem {
                    Label("図鑑", systemImage: "book")
                }

            ShopView()
                .tabItem {
                    Label("ショップ", systemImage: "cart")
                }

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
    }
}
