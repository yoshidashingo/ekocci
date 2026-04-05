import WidgetKit

/// コンプリケーション用タイムラインエントリ
struct PetTimelineEntry: TimelineEntry {
    let date: Date
    let snapshot: PetSnapshot
}

/// ペット状態のタイムラインを提供
struct PetTimelineProvider: TimelineProvider {

    private let store = PetStore()

    func placeholder(in context: Context) -> PetTimelineEntry {
        PetTimelineEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (PetTimelineEntry) -> Void) {
        Task {
            let pet = await store.loadPet() ?? Pet.newEgg(at: .now)
            let entry = PetTimelineEntry(date: .now, snapshot: .from(pet))
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PetTimelineEntry>) -> Void) {
        Task {
            let now = Date.now
            let pet = await store.loadPet() ?? Pet.newEgg(at: now)

            let snapshots = PetTimelineProviderLogic.generateEntries(pet: pet, from: now)
            let entries = snapshots.map { PetTimelineEntry(date: $0.date, snapshot: $0.snapshot) }
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}
