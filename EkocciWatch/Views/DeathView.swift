import SwiftUI

/// 死亡画面
struct DeathView: View {
    @Environment(GameManager.self) private var game
    @State private var angelOffset: CGFloat = 0
    @State private var showButton = false

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            // 天使アニメーション
            Text("👼")
                .font(.system(size: 50))
                .offset(y: angelOffset)
                .onAppear {
                    withAnimation(.easeOut(duration: 2)) {
                        angelOffset = -30
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { showButton = true }
                    }
                }

            Text("\(game.pet.age)さい")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("だい\(game.pet.generation)だい")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            if showButton {
                Button {
                    HapticManager.play(.notification)
                    Task { await game.startNextGeneration() }
                } label: {
                    Label("つぎのたまご", systemImage: "egg")
                }
                .buttonStyle(.borderedProminent)
                .transition(.opacity)
            }
        }
        .padding()
    }
}
