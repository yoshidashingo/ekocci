# Phase 5: CloudKit + ポリッシュ — 実装計画

**作成日**: 2026-04-05
**ステータス**: 承認済み、実装開始前

## 概要

ekocci v1 の最終フェーズ。CloudKit 同期、効果音、スリープモード強化、E2E テスト、パフォーマンス検証を実施する。

## サブフェーズ A: PetStore Actor + CloudKit 同期 (5 ステップ)

### 1. PetStore を actor に変換
- **ファイル**: `Shared/Persistence/PetStore.swift`
- `@unchecked Sendable` → `actor PetStore`
- 全呼び出し元を `await` に更新
- 既存テストを async 化

### 2. PetCloudSerializer 作成
- **ファイル**: `Shared/Persistence/PetCloudSerializer.swift`
- Pet ↔ CKRecord の純粋関数変換
- テスト: ラウンドトリップ、不正データ処理

### 3. CloudKitSyncManager 作成
- **ファイル**: `Shared/Persistence/CloudKitSyncManager.swift`
- CKContainer ラッパー actor
- upload / download / resolveConflict (last-write-wins)
- テスト: conflict resolution (protocol mock で CK 呼び出しを分離)

### 4. CloudKit を PetStore に統合
- save 時に fire-and-forget で upload
- `syncFromCloud()` で remote → local マージ

### 5. GameConfig に CloudKit 定数追加
- `cloudKitContainerID = "iCloud.com.ekocci.app"`
- `cloudKitZoneName = "PetZone"`

## サブフェーズ B: 効果音 (3 ステップ)

### 6. SoundManager 作成
- **ファイル**: `Shared/Engine/SoundManager.swift`
- AVAudioPlayer ベース、SettingsStore.isSoundEnabled チェック
- SoundType enum: .feed, .clean, .gameWon, .gameLost, .evolved, .died

### 7. オーディオアセット追加
- プレースホルダー WAV (各100KB以下)

### 8. GameManager に統合
- HapticManager.play() と並行して SoundManager.play() 追加

## サブフェーズ C: スリープ/ポーズ強化 (3 ステップ)

### 9. 10h/日ポーズ制限の強制
- **ファイル**: `Shared/Engine/GameEngine.swift`
- advance() 内で pauseMinutesUsedToday >= max の場合は自動解除
- 日付変更でリセット
- テスト: `GameEnginePauseTests.swift`

### 10. バッテリー低下自動ポーズ
- **ファイル**: `EkocciWatch/GameManager.swift`
- バッテリー10%以下で自動ポーズ、15%以上で自動解除

### 11. GameConfig に閾値追加
- `batteryLowThreshold = 0.10`
- `batteryRecoverThreshold = 0.15`

## サブフェーズ D: E2E + パフォーマンス (4 ステップ)

### 12. ライフサイクル E2E テスト
- **ファイル**: `Tests/SharedTests/PetLifecycleE2ETests.swift`
- たまご → 孵化 → お世話 → 進化 → 死亡 → 次世代

### 13. お世話放置 → 死亡 E2E テスト
- 餓死パス、病死パス

### 14. パフォーマンス計測
- **ファイル**: `Tests/SharedTests/GameEnginePerformanceTests.swift`
- 48h キャッチアップが 100ms 以下であることを確認

### 15. decayStats 最適化 (必要時のみ)
- ループ → 直接演算に変換

## ファイルサマリー

| アクション | パス |
|-----------|------|
| NEW | `Shared/Persistence/PetCloudSerializer.swift` |
| NEW | `Shared/Persistence/CloudKitSyncManager.swift` |
| NEW | `Shared/Engine/SoundManager.swift` |
| NEW | `Tests/SharedTests/PetCloudSerializerTests.swift` |
| NEW | `Tests/SharedTests/CloudKitSyncManagerTests.swift` |
| NEW | `Tests/SharedTests/SoundManagerTests.swift` |
| NEW | `Tests/SharedTests/GameEnginePauseTests.swift` |
| NEW | `Tests/SharedTests/PetLifecycleE2ETests.swift` |
| NEW | `Tests/SharedTests/GameEnginePerformanceTests.swift` |
| MOD | `Shared/Persistence/PetStore.swift` (actor化 + CloudKit) |
| MOD | `Shared/Engine/GameEngine.swift` (ポーズ制限) |
| MOD | `Shared/Constants/GameConfig.swift` |
| MOD | `EkocciWatch/GameManager.swift` (Sound + Battery + CloudKit) |
| MOD | `EkocciPhone/PhoneGameManager.swift` (actor await) |
| MOD | `EkocciWatch/WatchConnectivityManager.swift` (actor await) |

## 成功基準

- [ ] CloudKit 経由でペットデータが同期される
- [ ] conflict resolution は lastUpdateTime の新しい方を採用
- [ ] 効果音が isSoundEnabled に応じて再生される
- [ ] ポーズは 10h/日で自動解除、日替わりでリセット
- [ ] バッテリー低下で自動ポーズ (watchOS)
- [ ] E2E テストがフルライフサイクルをカバー
- [ ] 48h キャッチアップが <100ms
- [ ] 全 ~180 テスト パス
- [ ] 800行超のファイルなし

## リスク

| リスク | 対策 |
|--------|------|
| CloudKit 利用不可 (iCloud未サイン等) | CloudKitSyncManager はオプショナル。ローカルが常に source of truth |
| PetStore actor 化で呼び出し元が壊れる | ステップ1で最初に対応、全テスト通過を確認 |
| watchOS 音声再生制限 | 1秒以下の CAF ファイル使用。失敗時は no-op |
