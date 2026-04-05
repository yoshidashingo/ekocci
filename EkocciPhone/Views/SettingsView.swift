import SwiftUI

/// 設定画面
struct SettingsView: View {
    @Environment(PhoneGameManager.self) private var game
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                soundSection
                notificationSection
                pauseSection
                dangerSection
                aboutSection
            }
            .navigationTitle("設定")
            .confirmationDialog("ペットをリセット", isPresented: $showResetConfirmation) {
                Button("リセットする", role: .destructive) {
                    Task { await game.resetPet() }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("現在のペットが消えます。この操作は取り消せません。")
            }
        }
    }

    private var soundSection: some View {
        Section("サウンド") {
            Toggle("効果音", isOn: Binding(
                get: { game.settingsStore.isSoundEnabled },
                set: {
                    game.settingsStore.isSoundEnabled = $0
                    game.updateSettings()
                }
            ))
        }
    }

    private var notificationSection: some View {
        Section("通知") {
            Toggle("お世話リマインダー", isOn: Binding(
                get: { game.settingsStore.isNotificationsEnabled },
                set: {
                    game.settingsStore.isNotificationsEnabled = $0
                    game.updateSettings()
                }
            ))
        }
    }

    private var pauseSection: some View {
        Section("おあずけ") {
            Picker("1日の上限", selection: Binding(
                get: { game.settingsStore.pauseLimitMinutes },
                set: {
                    game.settingsStore.pauseLimitMinutes = $0
                    game.updateSettings()
                }
            )) {
                Text("5時間").tag(300)
                Text("8時間").tag(480)
                Text("10時間").tag(600)
                Text("12時間").tag(720)
            }
        }
    }

    private var dangerSection: some View {
        Section {
            Button("ペットをリセット", role: .destructive) {
                showResetConfirmation = true
            }
        }
    }

    private var aboutSection: some View {
        Section("アプリ情報") {
            HStack {
                Text("バージョン")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
