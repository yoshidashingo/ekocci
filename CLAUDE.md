# CLAUDE.md — ekocci (エコちっち)

Apple Watchで育てるバーチャルペット育成ゲーム。Swift / SwiftUI / watchOS 11+ / iOS 18+。

## Tech Stack

- **言語**: Swift
- **UI**: SwiftUI (watchOS + iOS)
- **ターゲット**: watchOS 11+ (メイン), iOS 18+ (コンパニオン)
- **フレームワーク**: WidgetKit, CloudKit, SpriteKit
- **ビルド**: Xcode 16+

## ディレクトリ構造

```
ekocci/
├── EkocciWatch/          # watchOSアプリ (メイン)
│   ├── Views/            # SwiftUI Views
│   └── EkocciWatchApp.swift
├── EkocciPhone/          # iOSコンパニオンアプリ
├── EkocciWatchWidget/    # WidgetKit コンプリケーション
├── Shared/               # 共有コード (Models, Engine, Constants, Persistence)
│   ├── Models/           # Pet, PetStats, LifeStage, CareAction
│   ├── Engine/           # GameEngine, TimeManager
│   ├── Constants/        # GameConfig, HapticPatterns
│   └── Persistence/      # PetStore
├── Tests/                # テスト
├── Assets.xcassets/      # アセット
├── .steering/            # AI-DLC ワークフロールール
│   ├── aws-aidlc-rules/core-workflow.md
│   └── aws-aidlc-rule-details/
└── aidlc-docs/           # AI-DLC 生成ドキュメント (git管理)
```

---

## 開発ワークフロー

### 基本方針

**AI-DLC (`.steering/aws-aidlc-rules/core-workflow.md`) をベースワークフローとする。**
ただし AI-DLC だけに閉じず、インストール済みプラグインの優れた機能を積極的に採用し、TDDベースで開発を進める。

### AI-DLC ルール詳細のパス解決

core-workflow.md の「Rule Details Loading」セクションに従い、本プロジェクトでは以下のパスを使用:

```
.steering/aws-aidlc-rule-details/
```

### フェーズ別ツール選定

AI-DLC のフェーズごとに、最適なプラグイン/スキルを割り当てる。

#### INCEPTION PHASE (計画・設計)

| AI-DLCステージ | 補完ツール | 理由 |
|---------------|-----------|------|
| Workspace Detection | AI-DLC そのまま | — |
| Reverse Engineering | AI-DLC そのまま | — |
| Requirements Analysis | AI-DLC + **Superpowers:brainstorming** | 要件の創造的探索にbrainstormingを併用 |
| User Stories | AI-DLC そのまま | — |
| Workflow Planning | **Superpowers:writing-plans** | レビューチェックポイント付きの計画策定。AI-DLCのworkflow planningと統合 |
| Application Design | AI-DLC + **ECC:architect** (agent) | SwiftUI アーキテクチャの判断に architect agent を併用 |
| Units Generation | AI-DLC そのまま | — |

#### CONSTRUCTION PHASE (設計・実装)

| AI-DLCステージ | 補完ツール | 理由 |
|---------------|-----------|------|
| Functional Design | AI-DLC + **ECC:swiftui-patterns** (skill) | SwiftUI の状態管理・View設計パターンを参照 |
| NFR Requirements | AI-DLC そのまま | — |
| NFR Design | AI-DLC + **ECC:swift-concurrency-6-2** (skill) | Swift 6.2 concurrency パターンを参照 |
| Infrastructure Design | AI-DLC そのまま (将来: Deploy on AWS) | — |
| Code Generation | **TDD ベース** (後述) | AI-DLCのcode-gen計画に従いつつ、TDDで実装 |
| Build and Test | AI-DLC + **ECC:build-error-resolver** (agent) | ビルドエラー時に自動投入 |

#### コードレビュー (全ステージ共通)

| タイミング | ツール | 理由 |
|-----------|-------|------|
| コード変更後 (随時) | **ECC:code-reviewer** (agent) | 汎用コードレビュー |
| Swift コード | **ECC:swiftui-patterns** + **swift-protocol-di-testing** (skills) | Swift 専門知識の補完 |
| セキュリティ敏感コード | **ECC:security-reviewer** (agent) | OWASP Top 10, データ保護 |
| フェーズ完了時 | **Superpowers:requesting-code-review** (skill) | プラン全体との整合性チェック |

### TDD ワークフロー (MUST)

**全ての機能実装は TDD で行う。** AI-DLC の Code Generation ステージ内で以下を実行:

```
1. RED   — テストを先に書く (失敗を確認)
2. GREEN — 最小限の実装でテストを通す
3. IMPROVE — リファクタリング (テストは常にグリーン)
```

| 役割 | ツール |
|------|-------|
| TDD ガイド | **ECC:tdd-guide** (agent) — 先にテストを書くことを強制 |
| TDD ワークフロー | **Superpowers:test-driven-development** (skill) — RED→GREEN→IMPROVE サイクル管理 |
| テストカバレッジ | 80% 以上を維持 |

### デバッグ

| 状況 | ツール |
|------|-------|
| ビルドエラー | **ECC:build-error-resolver** (agent) — 最小差分で修正 |
| ロジックバグ | **Superpowers:systematic-debugging** (skill) — 体系的な原因分析 |
| セカンドオピニオン | **Codex:codex-rescue** — 行き詰まり時の別視点 |

### 検証・完了

| タイミング | ツール |
|-----------|-------|
| 作業完了宣言前 | **Superpowers:verification-before-completion** (skill) — 漏れがないか最終チェック |
| ブランチ完了時 | **Superpowers:finishing-a-development-branch** (skill) |

### Git ワークフロー

| 操作 | ルール |
|------|-------|
| コミットメッセージ | `<type>: <description>` (feat, fix, refactor, docs, test, chore, perf, ci) |
| ブランチ戦略 | **Superpowers:using-git-worktrees** で feature ブランチを隔離 |
| PR 作成 | フルコミット履歴を分析、テストプラン付き |

---

## Swift / SwiftUI 固有ルール

### 参照すべき ECC スキル

| スキル | 用途 |
|--------|------|
| **swiftui-patterns** | @Observable, @State, @Environment, View 構成 |
| **swift-concurrency-6-2** | Swift 6.2 の Approachable Concurrency, actor |
| **swift-actor-persistence** | actor ベースのスレッドセーフなデータ永続化 |
| **swift-protocol-di-testing** | Protocol ベースの DI でテスタビリティ確保 |
| **liquid-glass-design** | iOS 26 Liquid Glass (将来の UI 更新用) |
| **foundation-models-on-device** | オンデバイス LLM (将来のAI機能用) |

### コーディング規約

- **不変性優先**: struct + let をデフォルト。class / var は必要な場合のみ
- **SwiftUI State Management**: `@Observable` マクロ + `@State` / `@Environment`
- **エラーハンドリング**: Swift の `Result` / `throws` を活用。エラーは握りつぶさない
- **ファイルサイズ**: 1ファイル 200-400行目安、800行上限
- **関数サイズ**: 50行以内
- **命名**: Swift API Design Guidelines に準拠

### watchOS 固有の注意点

- インタラクションは 5-15秒 で完結させる
- バッテリー消費を最小化 (バックグラウンド処理は控えめに)
- Digital Crown / Taptic Engine を活用
- コンプリケーション更新は WidgetKit Timeline で制御
- Always-On Display 対応: アニメーション停止、省電力描画

---

## プラグイン使い分け早見表

| 状況 | 使うもの |
|------|---------|
| 新機能の計画 | AI-DLC inception + **Superpowers:writing-plans** |
| 要件のブレスト | **Superpowers:brainstorming** |
| アーキテクチャ判断 | **ECC:architect** agent |
| テスト先行で実装 | **ECC:tdd-guide** agent + **Superpowers:test-driven-development** |
| コード書いた後 | **ECC:code-reviewer** agent |
| ビルド失敗 | **ECC:build-error-resolver** agent |
| バグ調査 | **Superpowers:systematic-debugging** |
| 行き詰まり | **Codex:codex-rescue** |
| 完了チェック | **Superpowers:verification-before-completion** |
| PR 準備 | **Superpowers:finishing-a-development-branch** |
| Swift パターン確認 | **ECC:swiftui-patterns** / **swift-concurrency-6-2** etc. |
| ライブラリ使い方 | **ECC:docs-lookup** (Context7 MCP) |

---

## やらないこと

- AI-DLC だけで全ワークフローを完結させない (優れたスキルがあれば採用する)
- テストなしでコードを書かない (TDD 必須)
- 800行超のファイルを作らない
- watchOS 以外のプラットフォーム対応 (v1 スコープ外)
- バックエンド API (v1 スコープ外。CloudKit のみ)
