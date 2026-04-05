import SwiftUI

/// メインのペット表示画面
struct MainPetView: View {
    @Environment(GameManager.self) private var game
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @State private var showMenu = false
    @State private var toast: String?

    private var pet: Pet { game.pet }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 4) {
                    StatusBar(pet: pet)

                    PetSpriteView(pet: pet)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    if !isLuminanceReduced {
                        if pet.poopCount > 0 {
                            HStack(spacing: 2) {
                                ForEach(0..<pet.poopCount, id: \.self) { _ in
                                    Text("💩")
                                        .font(.system(size: 10))
                                }
                            }
                        }

                        if pet.isSick {
                            Text("☠️ びょうき")
                                .font(.system(size: 11))
                                .foregroundStyle(.red)
                        }
                    }
                }

                // トースト表示
                if let toast {
                    toastView(toast)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: toast)
            .toolbar {
                if !isLuminanceReduced {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("🥚 \(pet.age)さい")
                            .font(.system(size: 11))
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showMenu = true
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                    }
                }
            }
            .sheet(isPresented: $showMenu) {
                MenuView()
            }
            .onChange(of: game.lastAction) { _, action in
                guard let action else { return }
                showToast(action)
            }
        }
    }

    private func toastView(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 4)
    }

    private func showToast(_ action: String) {
        toast = action
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            toast = nil
        }
    }
}

// MARK: - ステータスバー

struct StatusBar: View {
    let pet: Pet

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 1) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 9))
                HeartsView(filled: pet.stats.hunger, total: PetStats.maxHearts)
            }

            HStack(spacing: 1) {
                Image(systemName: "face.smiling")
                    .font(.system(size: 9))
                HeartsView(filled: pet.stats.happiness, total: PetStats.maxHearts)
            }
        }
        .font(.system(size: 10))
    }
}

// MARK: - ハートゲージ

struct HeartsView: View {
    let filled: Int
    let total: Int

    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<total, id: \.self) { index in
                Image(systemName: index < filled ? "heart.fill" : "heart")
                    .font(.system(size: 8))
                    .foregroundStyle(index < filled ? .red : .gray)
            }
        }
    }
}
