import SwiftUI

/// エコショップ
struct ShopView: View {
    @Environment(PhoneGameManager.self) private var game
    @State private var showPurchaseResult = false
    @State private var purchaseSuccess = false

    var body: some View {
        NavigationStack {
            List {
                activeEffectsSection
                catalogSection
            }
            .navigationTitle("エコショップ")
            .alert(purchaseSuccess ? "購入しました!" : "ポイント不足です", isPresented: $showPurchaseResult) {
                Button("OK") {}
            }
        }
    }

    @ViewBuilder
    private var activeEffectsSection: some View {
        let effects = game.shopStore.activeEffects(at: .now)
        if !effects.isEmpty {
            Section("アクティブ効果") {
                ForEach(effects, id: \.type) { effect in
                    HStack {
                        Text(effectEmoji(effect.type))
                        Text(effectName(effect.type))
                        Spacer()
                        Text(formatRemaining(effect.remainingSeconds(at: .now)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var catalogSection: some View {
        Section("アイテム") {
            ForEach(ShopItem.catalog) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.headline)
                        Text(item.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        Task {
                            purchaseSuccess = await game.purchaseItem(item)
                            showPurchaseResult = true
                        }
                    } label: {
                        Text("\(item.cost) P")
                            .font(.caption.bold())
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canPurchase(item))
                }
            }
        }
    }

    private func canPurchase(_ item: ShopItem) -> Bool {
        guard let pet = game.pet else { return false }
        return pet.ecoPoints >= item.cost
            && !game.shopStore.hasActiveEffect(item.type, at: .now)
    }

    private func effectEmoji(_ type: ShopItemType) -> String {
        switch type {
        case .speedBoost: return "⚡️"
        case .luckyCharm: return "🍀"
        }
    }

    private func effectName(_ type: ShopItemType) -> String {
        switch type {
        case .speedBoost: return "スピードブースト"
        case .luckyCharm: return "ラッキーチャーム"
        }
    }

    private func formatRemaining(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        return "あと\(mins)分"
    }
}
