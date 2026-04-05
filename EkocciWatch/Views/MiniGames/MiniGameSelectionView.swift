import SwiftUI

/// ミニゲーム選択画面
struct MiniGameSelectionView: View {

    private static let games: [MiniGameDescriptor] = [
        .init(id: "left_or_right", displayName: "どっち?", iconSystemName: "arrow.left.arrow.right"),
        .init(id: "high_or_low", displayName: "おおきい?ちいさい?", iconSystemName: "number"),
        .init(id: "jump", displayName: "ジャンプ!", iconSystemName: "hare"),
    ]

    var body: some View {
        List(Self.games) { game in
            NavigationLink {
                gameView(for: game.id)
            } label: {
                Label(game.displayName, systemImage: game.iconSystemName)
            }
        }
        .navigationTitle("あそぶ")
    }

    @ViewBuilder
    private func gameView(for id: String) -> some View {
        switch id {
        case "left_or_right":
            LeftOrRightGameView()
        case "high_or_low":
            HighOrLowGameView()
        case "jump":
            JumpGameView()
        default:
            Text("Coming soon...")
        }
    }
}
