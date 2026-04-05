# Phase 4: iOS コンパニオンアプリ — 実装計画

**作成日**: 2026-04-05
**ステータス**: 完了

## 概要

iPhone コンパニオンアプリ — WatchConnectivity 同期、ダッシュボード、家系図、キャラクター図鑑、ショップ、設定画面。

## 設計方針

- **Watch が唯一のペット状態ソース** — Phone は Watch にコマンドを送り、状態を受け取る
- Phone は UserDefaults 直接読み取りをフォールバックとして使用
- Shop は ecoPoints 消費でアイテム2種 (スピードブースト、ラッキーチャーム)

## サブフェーズ

### 4a: 共有データ層 (ステップ 1-6)
- ShopItem / ActiveEffect — ショップアイテムモデル
- ConnectivityMessage — WCSession 用エンコード/デコード
- DiscoveryStore — キャラクター発見状態追跡
- ShopStore — 購入・アクティブ効果管理
- SettingsStore — サウンド、通知、ポーズ上限

### 4b: WatchConnectivity (ステップ 7-9)
- WatchConnectivityManager (Watch 側)
  - applicationContext で petState 送信
  - careAction / shopPurchase / settingsUpdate 受信
- PhoneConnectivityManager (iPhone 側)
  - sendMessage / transferUserInfo でコマンド送信
  - petStateUpdate 受信 → currentPet 更新
  - Swift 6 Sendability 対応: nonisolated で Sendable な値にデコードしてから MainActor へ
- GameManager 統合 — savePetAndSync() で Widget + Connectivity 同時通知

### 4c: iPhone 状態管理 (ステップ 10)
- PhoneGameManager — @MainActor @Observable
  - pet: Watch優先、UserDefaults フォールバック
  - feedMeal/feedSnack → sendCareAction
  - purchaseItem → ShopStore + sendShopPurchase

### 4d: iPhone Views (ステップ 11-17)
- TabRootView — 5タブ (ホーム、家系図、図鑑、ショップ、設定)
- DashboardView — ペット表示 + ステータスゲージ + クイックアクション + Watch接続状態
- FamilyTreeView — PetRecord 履歴を世代別表示
- EncyclopediaView — 22キャラ LazyVGrid、発見/未発見表示
- CharacterDetailView — 進化条件ヒント (ネタバレ防止)
- ShopView — カタログ + アクティブ効果 + 購入
- SettingsView — Form (サウンド、通知、ポーズ上限、リセット)

### 4e: App Shell (ステップ 18-19)
- EkocciPhoneApp — PhoneGameManager + TabRootView
- LifeStage.displayName 追加

## 成果

| 指標 | 値 |
|------|-----|
| テスト | 130 → 155 (+25) |
| スイート | 18 → 23 |
| 新規ファイル | 18 |
| 修正ファイル | 2 |
| iPhone 画面 | 7 (タブ含む) |
