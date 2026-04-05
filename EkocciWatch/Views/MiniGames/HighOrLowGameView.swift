import SwiftUI

/// ミニゲーム: おおきい? ちいさい? (High or Low)
struct HighOrLowGameView: View {
    @Environment(GameManager.self) private var game
    @Environment(\.dismiss) private var dismiss

    @State private var round = 0
    @State private var wins = 0
    @State private var phase: GamePhase = .ready
    @State private var currentNumber = 5
    @State private var nextNumber = 5
    @State private var playerChoice: Choice?

    private let totalRounds = 5
    private let winsNeeded = 3

    enum GamePhase {
        case ready, choosing, reveal, finished
    }

    enum Choice {
        case high, low
    }

    var body: some View {
        VStack(spacing: 8) {
            // スコア
            Text("ラウンド \(round + 1)/\(totalRounds)  ⭐ \(wins)")
                .font(.system(size: 12))

            Spacer()

            switch phase {
            case .ready:
                Text("つぎのかずは?")
                    .font(.headline)
                Button("スタート") { startRound() }
                    .buttonStyle(.borderedProminent)

            case .choosing:
                Text("\(currentNumber)")
                    .font(.system(size: 50, weight: .bold, design: .rounded))

                HStack(spacing: 16) {
                    Button {
                        choose(.low)
                    } label: {
                        VStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 30))
                            Text("ちいさい")
                                .font(.system(size: 10))
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                        choose(.high)
                    } label: {
                        VStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 30))
                            Text("おおきい")
                                .font(.system(size: 10))
                        }
                    }
                    .buttonStyle(.plain)
                }

            case .reveal:
                VStack(spacing: 4) {
                    Text("\(currentNumber) → \(nextNumber)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))

                    if let choice = playerChoice {
                        let correct = isCorrect(choice: choice)
                        Text(correct ? "⭐ あたり!" : "💨 はずれ")
                            .font(.headline)
                            .foregroundStyle(correct ? .green : .red)
                    }
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
        .navigationTitle("おおきい?ちいさい?")
        .navigationBarBackButtonHidden(phase != .ready && phase != .finished)
    }

    private func startRound() {
        currentNumber = nextNumber == 0 ? Int.random(in: 1...9) : nextNumber
        // 同じ数字にならないようにする
        repeat {
            nextNumber = Int.random(in: 1...9)
        } while nextNumber == currentNumber
        playerChoice = nil
        phase = .choosing
    }

    private func choose(_ choice: Choice) {
        playerChoice = choice
        phase = .reveal

        if isCorrect(choice: choice) {
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

    private func isCorrect(choice: Choice) -> Bool {
        switch choice {
        case .high: return nextNumber > currentNumber
        case .low:  return nextNumber < currentNumber
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
