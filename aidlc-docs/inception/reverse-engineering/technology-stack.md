# 技術スタック

## 言語

| 項目 | 詳細 |
|------|------|
| 言語 | Swift 6.0 (`SWIFT_VERSION: "6.0"` in project.yml) |
| 並行性モデル | Swift 6 strict concurrency (Sendable 準拠を全モデルに適用) |

### 使用している Swift 言語機能

| 機能 | 使用箇所 | 説明 |
|------|---------|------|
| `Sendable` | LifeStage, PetStats, Pet, CareAction, HapticType, PetRecord | スレッド安全なデータ転送のための準拠 |
| `@unchecked Sendable` | PetStore | UserDefaults ベースの永続化クラスに手動で適用 |
| `@Observable` (Observation フレームワーク) | GameManager | SwiftUI の状態管理マクロ |
| `@State` | EkocciWatchApp, 各 View | SwiftUI の View ローカル状態 |
| `@Environment` | ContentView, MenuView, StatsView 他 | GameManager の環境注入 |
| `@ViewBuilder` | PetSpriteView | 条件分岐による View 構築 |
| `CaseIterable` | LifeStage, CareAction | enum の全ケース列挙 |
| `Codable` | Pet, PetStats, LifeStage, CareAction, PetRecord | JSON シリアライゼーション |
| `Identifiable` | Pet, PetRecord | SwiftUI リスト表示用 |
| 値型 (struct/enum) 中心設計 | Models, Engine, Constants | 不変性優先の設計方針 |
| `#if os(watchOS)` | HapticPatterns.swift | プラットフォーム条件分岐コンパイル |

## フレームワーク

| フレームワーク | 使用状況 | 説明 |
|---------------|---------|------|
| SwiftUI | 全 UI | watchOS/iOS 両方の View 層 |
| WatchKit | HapticPatterns.swift | `WKInterfaceDevice` による Haptic フィードバック |
| Foundation | 全モジュール | Date, Calendar, Timer, JSONEncoder/Decoder, UserDefaults |
| Observation | GameManager | `@Observable` マクロによる状態監視 |
| SpriteKit | 未使用 (CLAUDE.md で言及) | 将来的な使用が計画されている |
| WidgetKit | 未使用 (CLAUDE.md で言及) | コンプリケーション用に計画されている |
| CloudKit | 未使用 (CLAUDE.md で言及) | データ同期用に計画されている |

## ビルドツール

| ツール | バージョン/設定 | 説明 |
|--------|---------------|------|
| xcodegen | project.yml で定義 | Xcode プロジェクト生成 |
| Xcode | 26.0 (`xcodeVersion: "26.0"` in project.yml) | ビルド環境。CLAUDE.md では「Xcode 16+」と記載されているが、project.yml は 26.0 を指定 |
| ENABLE_USER_SCRIPT_SANDBOXING | false | ユーザースクリプトサンドボックス無効化 |

## テスティング

| 項目 | 詳細 |
|------|------|
| テストフレームワーク | Swift Testing (`import Testing`) |
| テストマクロ | `@Test`, `@Suite` |
| アサーション | `#expect` |
| テストターゲット | `EkocciTests` (platform: iOS) |
| テスト対象ソース | `Tests/SharedTests/` + `Shared/` |
| テストファイル数 | 3 ファイル (PetStatsTests, GameEngineTests, TimeManagerTests) |

### テストパターン

- `@Suite("スイート名")` によるテストグループ化
- `@Test("テスト説明")` による個別テスト定義
- `#expect(条件)` によるアサーション
- `@testable import EkocciShared` によるモジュールアクセス
- ヘルパーメソッド (`makeDate`, `dateAt`) によるテストデータ生成

## プラットフォーム SDK

| プラットフォーム | デプロイメントターゲット | 役割 |
|---------------|----------------------|------|
| watchOS | 26.0 | メインアプリ (ペット育成の主要インターフェース) |
| iOS | 26.0 | コンパニオンアプリ (現状はプレースホルダー) |

> **注記**: CLAUDE.md では「watchOS 11+」「iOS 18+」と記載されているが、project.yml の実際の設定は両方とも 26.0 である。

## 開発ツール (CLAUDE.md 記載)

### AI-DLC ワークフロー連携ツール

| カテゴリ | ツール | 用途 |
|---------|-------|------|
| 計画 | AI-DLC + Superpowers:writing-plans | 実装計画の策定 |
| ブレスト | Superpowers:brainstorming | 要件の創造的探索 |
| アーキテクチャ | ECC:architect (agent) | SwiftUI アーキテクチャ判断 |
| TDD | ECC:tdd-guide (agent) | テスト先行の強制 |
| コードレビュー | ECC:code-reviewer (agent) | 汎用コードレビュー |
| セキュリティ | ECC:security-reviewer (agent) | OWASP Top 10, データ保護 |
| ビルドエラー | ECC:build-error-resolver (agent) | ビルドエラー自動修正 |
| デバッグ | Superpowers:systematic-debugging | 体系的な原因分析 |
| 完了検証 | Superpowers:verification-before-completion | 最終チェック |

### Swift 固有スキル

| スキル | 用途 |
|--------|------|
| swiftui-patterns | @Observable, @State, @Environment, View 構成 |
| swift-concurrency-6-2 | Swift 6.2 の Approachable Concurrency, actor |
| swift-actor-persistence | actor ベースのスレッドセーフなデータ永続化 |
| swift-protocol-di-testing | Protocol ベースの DI でテスタビリティ確保 |
| liquid-glass-design | iOS 26 Liquid Glass (将来の UI 更新用) |
| foundation-models-on-device | オンデバイス LLM (将来の AI 機能用) |
