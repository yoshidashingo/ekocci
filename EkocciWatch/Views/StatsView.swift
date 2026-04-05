import SwiftUI

/// ステータス詳細画面
struct StatsView: View {
    @Environment(GameManager.self) private var game

    private var pet: Pet { game.pet }

    var body: some View {
        List {
            Section("きほん") {
                HStack {
                    Text("なまえ")
                    Spacer()
                    Text(stageDisplayName)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("ねんれい")
                    Spacer()
                    Text("\(pet.age)さい")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("せだい")
                    Spacer()
                    Text("だい\(pet.generation)だい")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("たいじゅう")
                    Spacer()
                    Text("\(pet.stats.weight)g")
                        .foregroundStyle(.secondary)
                }
            }

            Section("ステータス") {
                HStack {
                    Text("おなか")
                    Spacer()
                    HeartsView(filled: pet.stats.hunger, total: PetStats.maxHearts)
                }
                HStack {
                    Text("ごきげん")
                    Spacer()
                    HeartsView(filled: pet.stats.happiness, total: PetStats.maxHearts)
                }
                HStack {
                    Text("しつけ")
                    Spacer()
                    Text("\(pet.discipline)%")
                        .foregroundStyle(.secondary)
                }
            }

            Section("そのほか") {
                HStack {
                    Text("エコポイント")
                    Spacer()
                    Text("\(pet.ecoPoints)pt")
                        .foregroundStyle(.secondary)
                }
                if pet.isSick {
                    HStack {
                        Text("じょうたい")
                        Spacer()
                        Text("☠️ びょうき")
                            .foregroundStyle(.red)
                    }
                }
                if pet.isPaused {
                    HStack {
                        Text("じょうたい")
                        Spacer()
                        Text("⏸ おあずけちゅう")
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .navigationTitle("ステータス")
    }

    private var stageDisplayName: String {
        switch pet.stage {
        case .egg:    return "たまご"
        case .baby:   return "あかちゃん"
        case .child:  return "こども"
        case .young:  return "ヤング"
        case .adult:  return "おとな"
        case .senior: return "シニア"
        case .dead:   return "..."
        }
    }
}
