import SwiftUI

/// ジャンプゲーム: タップで障害物を飛び越える
struct JumpGameView: View {
    @Environment(GameManager.self) private var game
    @Environment(\.dismiss) private var dismiss

    @State private var state = JumpGameState.start()
    @State private var countdown = 3

    private let groundY: CGFloat = 0.75
    private let playerX: CGFloat = 0.15

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 地面
                Rectangle()
                    .fill(.green.opacity(0.3))
                    .frame(height: geo.size.height * 0.15)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.85)

                if countdown > 0 {
                    countdownView
                } else if state.phase == .result {
                    resultView
                } else {
                    gameView(in: geo)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onTapGesture {
            if countdown <= 0 && state.phase == .playing {
                state.jump()
            }
        }
        .task {
            await startCountdown()
        }
        .navigationBarBackButtonHidden(state.phase == .playing)
    }

    // MARK: - Subviews

    private var countdownView: some View {
        Text("\(countdown)")
            .font(.system(size: 48, weight: .bold))
            .foregroundStyle(.primary)
    }

    @ViewBuilder
    private var resultView: some View {
        VStack(spacing: 8) {
            Text(state.won ? "かち! 🎉" : "まけ… 😢")
                .font(.headline)
            Text("\(state.score)/\(GameConfig.jumpGameObstacleCount) かいひ")
                .font(.caption)
            Button("もどる") {
                Task { await game.applyMiniGameResult(state.toResult()) }
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func gameView(in geo: GeometryProxy) -> some View {
        let w = geo.size.width
        let h = geo.size.height

        return TimelineView(.animation) { timeline in
            Canvas { context, size in
                // プレイヤー
                let py = groundY - CGFloat(state.playerY) * 0.3
                let playerRect = CGRect(
                    x: w * playerX - 10,
                    y: h * py - 20,
                    width: 20,
                    height: 20
                )
                context.fill(
                    Path(ellipseIn: playerRect),
                    with: .color(.blue)
                )

                // 障害物
                for obstacle in state.obstacles {
                    let ox = CGFloat(obstacle.positionX) * w
                    guard ox > -20 && ox < w + 20 else { continue }
                    let obstacleRect = CGRect(
                        x: ox - 8,
                        y: h * groundY - 16,
                        width: 16,
                        height: 16
                    )
                    let color: Color = obstacle.hitPlayer ? .red.opacity(0.3) :
                                       obstacle.passed ? .green.opacity(0.3) : .red
                    context.fill(
                        Path(roundedRect: obstacleRect, cornerRadius: 3),
                        with: .color(color)
                    )
                }
            }
            .onChange(of: timeline.date) { _, _ in
                state.tick(dt: 1.0 / 60.0)
            }
        }
    }

    // MARK: - Logic

    private func startCountdown() async {
        for i in (1...3).reversed() {
            countdown = i
            try? await Task.sleep(for: .seconds(1))
        }
        countdown = 0
    }
}
