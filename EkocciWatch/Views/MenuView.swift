import SwiftUI

/// お世話アクションメニュー
struct MenuView: View {
    @Environment(GameManager.self) private var game
    @Environment(\.dismiss) private var dismiss

    private var pet: Pet { game.pet }

    var body: some View {
        List {
            foodSection
            playSection
            cleanSection
            medicineSection
            disciplineSection
            lightSection
            statsSection
            pauseSection
        }
        .navigationTitle("おせわ")
    }

    // MARK: - Sections

    private var foodSection: some View {
        Section {
            Button {
                Task { await game.feedMeal() }
                dismiss()
            } label: {
                Label("ごはん", systemImage: "fork.knife")
            }
            .disabled(pet.isSleeping || pet.stage == .egg)

            Button {
                Task { await game.feedSnack() }
                dismiss()
            } label: {
                Label("おやつ", systemImage: "birthday.cake")
            }
            .disabled(pet.isSleeping || pet.stage == .egg)
        }
    }

    @ViewBuilder
    private var playSection: some View {
        if pet.stage.canPlayGames {
            Section {
                NavigationLink {
                    MiniGameSelectionView()
                } label: {
                    Label("あそぶ", systemImage: "gamecontroller")
                }
                .disabled(pet.isSleeping)
            }
        }
    }

    @ViewBuilder
    private var cleanSection: some View {
        if pet.poopCount > 0 {
            Section {
                Button {
                    Task { await game.clean() }
                    dismiss()
                } label: {
                    Label("そうじ (\(pet.poopCount))", systemImage: "sparkles")
                }
            }
        }
    }

    @ViewBuilder
    private var medicineSection: some View {
        if pet.isSick {
            Section {
                Button {
                    Task { await game.giveMedicine() }
                    dismiss()
                } label: {
                    Label("くすり", systemImage: "cross.case")
                }
            }
        }
    }

    private var disciplineSection: some View {
        Section {
            Button {
                Task { await game.discipline() }
                dismiss()
            } label: {
                Label("しつけ (\(pet.discipline)%)", systemImage: "hand.raised")
            }
            .disabled(pet.isSleeping || pet.stage == .egg)
        }
    }

    @ViewBuilder
    private var lightSection: some View {
        if pet.isSleeping {
            Section {
                Button {
                    Task { await game.toggleLight() }
                    dismiss()
                } label: {
                    Label(
                        pet.isLightOff ? "でんき つける" : "でんき けす",
                        systemImage: pet.isLightOff ? "lightbulb" : "lightbulb.slash"
                    )
                }
            }
        }
    }

    private var statsSection: some View {
        Section {
            NavigationLink {
                StatsView()
            } label: {
                Label("ステータス", systemImage: "chart.bar")
            }
        }
    }

    private var pauseSection: some View {
        Section {
            Button {
                Task { await game.togglePause() }
                dismiss()
            } label: {
                Label(
                    pet.isPaused ? "おあずけ かいじょ" : "おあずけ",
                    systemImage: pet.isPaused ? "play.circle" : "pause.circle"
                )
            }
        }
    }
}
