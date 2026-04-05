import Foundation

/// タイムラインエントリ (WidgetKit非依存)
struct PetTimelineSnapshot: Sendable {
    let date: Date
    let snapshot: PetSnapshot
}

/// タイムライン生成ロジック (テスタブル、WidgetKit非依存)
enum PetTimelineProviderLogic {

    /// 将来のペット状態を予測してタイムラインエントリを生成
    static func generateEntries(pet: Pet, from startDate: Date) -> [PetTimelineSnapshot] {
        var entries: [PetTimelineSnapshot] = []
        var currentPet = pet

        for i in 0..<GameConfig.widgetTimelineEntryCount {
            let entryDate = startDate.addingTimeInterval(
                Double(i) * GameConfig.widgetTimelineEntryInterval
            )

            if i > 0 {
                let previousDate = startDate.addingTimeInterval(
                    Double(i - 1) * GameConfig.widgetTimelineEntryInterval
                )
                currentPet = GameEngine.advance(pet: currentPet, from: previousDate, to: entryDate)
            }

            entries.append(PetTimelineSnapshot(
                date: entryDate,
                snapshot: .from(currentPet)
            ))
        }

        return entries
    }
}
