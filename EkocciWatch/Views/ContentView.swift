import SwiftUI

/// メインコンテンツビュー: ペットの状態に応じて画面を切り替え
struct ContentView: View {
    @Environment(GameManager.self) private var game

    var body: some View {
        Group {
            switch game.pet.stage {
            case .dead:
                DeathView()
            default:
                MainPetView()
            }
        }
        .onAppear { game.onActivate() }
    }
}
