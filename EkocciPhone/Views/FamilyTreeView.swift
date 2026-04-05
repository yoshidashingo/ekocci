import SwiftUI

/// 家系図 (歴代ペット一覧)
struct FamilyTreeView: View {
    @Environment(PhoneGameManager.self) private var game
    @State private var history: [PetRecord] = []

    var body: some View {
        NavigationStack {
            if history.isEmpty {
                emptyState
            } else {
                petList(history)
            }
        }
        .task {
            history = await game.loadHistory()
        }
    }

    private func petList(_ history: [PetRecord]) -> some View {
        let grouped = Dictionary(grouping: history) { $0.generation }
        let sortedGenerations = grouped.keys.sorted()

        return List {
            ForEach(sortedGenerations, id: \.self) { gen in
                Section("第\(gen)世代") {
                    ForEach(grouped[gen]!, id: \.id) { record in
                        petRow(record)
                    }
                }
            }
        }
        .navigationTitle("家系図")
    }

    private func petRow(_ record: PetRecord) -> some View {
        HStack(spacing: 12) {
            Text(SpriteMapping.emoji(for: record.characterId))
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(CharacterRegistry.character(id: record.characterId)?.name ?? record.characterId)
                    .font(.headline)
                Text("\(record.age)さいで旅立ち")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(record.deathDate, style: .date)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🌳")
                .font(.system(size: 60))
            Text("まだ歴史がありません")
                .font(.headline)
            Text("ペットを育てると家系図が増えます")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("家系図")
    }
}
