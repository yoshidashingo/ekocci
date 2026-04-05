# Phase 3: WidgetKit + AOD + Background Refresh — 実装計画

**作成日**: 2026-04-04
**ステータス**: 完了 (Red Team レビュー修正済み)

## 概要

WidgetKit 4種コンプリケーション、Always-On Display、バックグラウンドリフレッシュ、通知を実装。

## サブフェーズ

### 3A: 共有データ層 (ステップ 1-4)
- AppGroupConfig — `group.com.ekocci.shared`
- PetStore を App Group UserDefaults に移行 (マイグレーション付き)
- PetSnapshot — コンプリケーション用軽量モデル

### 3B: WidgetKit コンプリケーション (ステップ 5-10)
- EkocciWatchWidget ターゲット (project.yml)
- PetTimelineProvider + PetTimelineProviderLogic (テスタブル分離)
- 4種 ComplicationViews: Rectangular, Circular, Inline, Corner
- GameManager → savePetAndReloadWidget でリアルタイム更新

### 3C: Always-On Display (ステップ 11-13)
- PetSpriteView — isLuminanceReduced で静的表示 (アニメ停止、絵文字+ステータス)
- MainPetView — AOD 時はうんち/病気/ツールバー非表示

### 3D: Background App Refresh (ステップ 14-16)
- BackgroundRefreshScheduler — 30分間隔スケジュール + handleRefresh
- EkocciWatchApp — `.backgroundTask(.appRefresh)` ハンドラ

### 3E: 通知 (ステップ 17-19)
- NotificationManager — おなか/ごきげん/病気リマインダー
- 日3回制限 (maxNotificationsPerDay)
- 15分遅延トリガー (フォアグラウンド中の即時発火防止)

## Red Team レビュー修正

| 指摘 | 対応 |
|------|------|
| 通知 TOCTOU 競合 (HIGH) | アトミック書き込みに修正 |
| GameManager @MainActor 欠如 (MEDIUM→HIGH) | @MainActor 追加 |
| AppGroup フォールバック (MEDIUM) | assertionFailure 追加 |
| PetStore エンコードエラー (HIGH) | os.Logger でログ出力 |
| 通知5秒トリガー (LOW) | 15分に変更 |

## 成果

| 指標 | 値 |
|------|-----|
| テスト | 113 → 130 (+17) |
| スイート | 15 → 18 |
| 新規ファイル | 8 |
| 修正ファイル | 7 |
