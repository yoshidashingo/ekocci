import SwiftUI

/// キャラクター図鑑
struct EncyclopediaView: View {
    @Environment(PhoneGameManager.self) private var game

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    private let stages: [LifeStage] = [.baby, .child, .young, .adult, .senior]

    var body: some View {
        NavigationStack {
            let discovered = game.discoveryStore.allDiscovered()
            let total = CharacterRegistry.allCharacters.count

            ScrollView {
                ForEach(stages, id: \.self) { stage in
                    let chars = CharacterRegistry.characters(for: stage)
                    if !chars.isEmpty {
                        Section {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(chars, id: \.id) { char in
                                    let isFound = discovered.contains(char.id)
                                    NavigationLink {
                                        CharacterDetailView(character: char, isDiscovered: isFound)
                                    } label: {
                                        characterCell(char, isDiscovered: isFound)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        } header: {
                            Text(stage.displayName)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("\(discovered.count)/\(total) 発見")
        }
    }

    private func characterCell(_ char: CharacterDefinition, isDiscovered: Bool) -> some View {
        VStack(spacing: 4) {
            if isDiscovered {
                Text(char.emoji)
                    .font(.title)
            } else {
                ZStack {
                    Circle()
                        .fill(.gray.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Text("?")
                        .font(.title2)
                        .foregroundStyle(.gray)
                }
            }
            Text(isDiscovered ? char.name : "???")
                .font(.caption2)
                .lineLimit(1)
                .foregroundStyle(isDiscovered ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
