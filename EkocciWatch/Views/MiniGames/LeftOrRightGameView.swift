import SwiftUI

/// ミニゲーム: どっち? (Left or Right)
struct LeftOrRightGameView: View {
    @Environment(GameManager.self) private var game
    @Environment(\.dismiss) private var dismiss

    @State private var round = 0
    @State private var wins = 0
    @State private var phase: GamePhase = .ready
    @State private var correctAnswer: Direction = .left
    @State private var playerChoice: Direction?

    private let totalRounds = 5
    private let winsNeeded = 3

    enum GamePhase {
        case ready, choosing, reveal, finished
    }

    enum Direction {
        case left, right
    }

    var body: some View {
        VStack(spacing: 8) {
            // スコア
            Text("ラウンド \(round + 1)/\(totalRounds)  ⭐ \(wins)")
                .font(.system(size: 12))

            Spacer()

            switch phase {
            case .ready:
                Text("どっちをむくかな?")
                    .font(.headline)
                Button("スタート") { startRound() }
                    .buttonStyle(.borderedProminent)

            case .choosing:
                Text("❓")
                    .font(.system(size: 40))

                HStack(spacing: 16) {
                    Button {
                        choose(.left)
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 36))
                    }
                    .buttonStyle(.plain)

                    Button {
                        choose(.right)
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 36))
                    }
                    .buttonStyle(.plain)
                }

            case .reveal:
                Text(correctAnswer == .left ? "⬅️" : "➡️")
                    .font(.system(size: 40))

                if let choice = playerChoice {
                    Text(choice == correctAnswer ? "⭐ あたり!" : "💨 はずれ")
                        .font(.headline)
                        .foregroundStyle(choice == correctAnswer ? .green : .red)
                }

            case .finished:
                let won = wins >= winsNeeded
                Text(won ? "🎉 かち!" : "😢 まけ...")
                    .font(.title3)

                Text("\(wins)/\(totalRounds) せいかい")
                    .font(.caption)

                Button("もどる") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("どっち?")
        .navigationBarBackButtonHidden(phase != .ready && phase != .finished)
    }

    private func startRound() {
        correctAnswer = Bool.random() ? .left : .right
        playerChoice = nil
        phase = .choosing
    }

    private func choose(_ direction: Direction) {
        playerChoice = direction
        phase = .reveal

        if direction == correctAnswer {
            wins += 1
            HapticManager.play(.fed)
        } else {
            HapticManager.play(.gameLost)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            round += 1
            if round >= totalRounds {
                finishGame()
            } else {
                startRound()
            }
        }
    }

    private func finishGame() {
        phase = .finished
        if wins >= winsNeeded {
            Task { await game.miniGameWon() }
        } else {
            Task { await game.miniGameLost() }
        }
    }
}
