import SwiftUI
import WidgetKit

// MARK: - Rectangular (ペット絵文字 + ステータスバー)

struct RectangularComplicationView: View {
    let entry: PetTimelineEntry

    var body: some View {
        HStack(spacing: 6) {
            Text(entry.snapshot.emoji)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.snapshot.characterName)
                    .font(.caption2)
                    .lineLimit(1)

                Gauge(value: Double(entry.snapshot.hunger), in: 0...4) {
                    EmptyView()
                } currentValueLabel: {
                    EmptyView()
                } minimumValueLabel: {
                    Text("🍔")
                        .font(.system(size: 8))
                } maximumValueLabel: {
                    EmptyView()
                }
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(.orange)

                Gauge(value: Double(entry.snapshot.happiness), in: 0...4) {
                    EmptyView()
                } currentValueLabel: {
                    EmptyView()
                } minimumValueLabel: {
                    Text("♥")
                        .font(.system(size: 8))
                } maximumValueLabel: {
                    EmptyView()
                }
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(.pink)
            }
        }
    }
}

// MARK: - Circular (絵文字 + ステージ)

struct CircularComplicationView: View {
    let entry: PetTimelineEntry

    var body: some View {
        VStack(spacing: 1) {
            Text(entry.snapshot.emoji)
                .font(.title3)

            if entry.snapshot.isSick {
                Text("💊")
                    .font(.caption2)
            }
        }
    }
}

// MARK: - Inline (テキスト一行)

struct InlineComplicationView: View {
    let entry: PetTimelineEntry

    var body: some View {
        let snapshot = entry.snapshot
        Text("\(snapshot.emoji) \(snapshot.characterName) ♥\(snapshot.happiness) 🍔\(snapshot.hunger)")
    }
}

// MARK: - Corner (絵文字のみ)

struct CornerComplicationView: View {
    let entry: PetTimelineEntry

    var body: some View {
        Text(entry.snapshot.emoji)
            .font(.title3)
            .widgetLabel {
                Text(entry.snapshot.characterName)
            }
    }
}
