import SwiftUI

/// ペットダッシュボード (ホーム画面)
struct DashboardView: View {
    @Environment(PhoneGameManager.self) private var game

    var body: some View {
        NavigationStack {
            if let pet = game.pet {
                petDashboard(pet)
            } else {
                emptyState
            }
        }
    }

    private func petDashboard(_ pet: Pet) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                connectionBanner

                // ペット表示
                VStack(spacing: 8) {
                    Text(SpriteMapping.emoji(for: pet.characterId))
                        .font(.system(size: 80))
                    Text(CharacterRegistry.character(id: pet.characterId)?.name ?? pet.characterId)
                        .font(.title2.bold())
                    Text(pet.stage.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top)

                // ステータス
                HStack(spacing: 24) {
                    statItem(icon: "fork.knife", label: "おなか", value: pet.stats.hunger, max: 4, color: .orange)
                    statItem(icon: "heart.fill", label: "ごきげん", value: pet.stats.happiness, max: 4, color: .pink)
                }

                // 情報
                HStack(spacing: 24) {
                    infoItem(label: "年齢", value: "\(pet.age)さい")
                    infoItem(label: "世代", value: "第\(pet.generation)世代")
                    infoItem(label: "エコP", value: "\(pet.ecoPoints)")
                }

                // 状態インジケーター
                statusIndicators(pet)

                // クイックアクション
                if !pet.isSleeping && pet.stage != .egg && pet.stage != .dead {
                    quickActions
                }
            }
            .padding()
        }
        .navigationTitle("エコちっち")
    }

    @ViewBuilder
    private var connectionBanner: some View {
        if !game.isWatchReachable {
            HStack {
                Image(systemName: "applewatch.slash")
                Text("Watch 未接続")
            }
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.orange, in: Capsule())
        }
    }

    private func statItem(icon: String, label: String, value: Int, max: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Gauge(value: Double(value), in: 0...Double(max)) {
                EmptyView()
            }
            .gaugeStyle(.accessoryLinearCapacity)
            .tint(color)
            .frame(width: 100)
        }
    }

    private func infoItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func statusIndicators(_ pet: Pet) -> some View {
        HStack(spacing: 12) {
            if pet.isSleeping { statusBadge("💤 すやすや", color: .blue) }
            if pet.isSick { statusBadge("☠️ びょうき", color: .red) }
            if pet.isPaused { statusBadge("⏸ おあずけ中", color: .gray) }
            if pet.poopCount > 0 {
                statusBadge("💩 ×\(pet.poopCount)", color: .brown)
            }
        }
    }

    private func statusBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule())
    }

    private var quickActions: some View {
        HStack(spacing: 16) {
            Button {
                game.feedMeal()
            } label: {
                Label("ごはん", systemImage: "fork.knife")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                game.feedSnack()
            } label: {
                Label("おやつ", systemImage: "birthday.cake")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🥚")
                .font(.system(size: 60))
            Text("ペットがいません")
                .font(.headline)
            Text("Apple Watch でエコちっちを始めよう")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("エコちっち")
    }
}
