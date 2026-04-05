import SwiftUI

/// キャラクター詳細画面
struct CharacterDetailView: View {
    let character: CharacterDefinition
    let isDiscovered: Bool

    var body: some View {
        VStack(spacing: 20) {
            if isDiscovered {
                discoveredContent
            } else {
                undiscoveredContent
            }
        }
        .padding()
        .navigationTitle(isDiscovered ? character.name : "???")
    }

    private var discoveredContent: some View {
        VStack(spacing: 16) {
            Text(character.emoji)
                .font(.system(size: 80))

            Text(character.name)
                .font(.title.bold())

            Text(character.stage.displayName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("進化のヒント")
                    .font(.headline)
                Text(evolutionHint)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
    }

    private var undiscoveredContent: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.gray.opacity(0.15))
                    .frame(width: 120, height: 120)
                Text("?")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
            }

            Text("???")
                .font(.title.bold())
                .foregroundStyle(.secondary)

            Text("まだ出会っていません")
                .font(.subheadline)
                .foregroundStyle(.tertiary)

            Spacer()
        }
    }

    /// 進化条件のヒント (ネタバレ防止でぼかす)
    private var evolutionHint: String {
        let c = character.condition
        var hints: [String] = []

        if c.careMissRange.upperBound <= 2 {
            hints.append("よくお世話すると...")
        } else if c.careMissRange.lowerBound >= 4 {
            hints.append("お世話をサボると...")
        }

        if c.disciplineRange.lowerBound >= 75 {
            hints.append("しつけをしっかりすると...")
        } else if c.disciplineRange.upperBound <= 24 {
            hints.append("自由に育てると...")
        }

        if let w = c.weightRange, w.lowerBound >= 15 {
            hints.append("たくさん食べさせると...")
        }

        if let e = c.effortRange, e.lowerBound >= 50 {
            hints.append("こまめにお世話すると...")
        }

        if let b = c.bondingRange, b.lowerBound >= 50 {
            hints.append("たくさん遊ぶと...")
        }

        if let g = c.generationMin, g >= 3 {
            hints.append("何世代も育てると...")
        }

        return hints.isEmpty ? "いろいろなお世話を試してみよう!" : hints.joined(separator: "\n")
    }
}
