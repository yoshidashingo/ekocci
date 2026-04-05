# コード品質評価

## 概要

| 指標 | 値 |
|------|-----|
| Swift ファイル総数 | 24 ファイル |
| 総行数 | 2,240 行 |
| プロダクションコード | 1,938 行 (21 ファイル) |
| テストコード | 302 行 (3 ファイル) |
| テスト/プロダクション比率 | 15.6% |

## テストカバレッジ評価

### テストが存在するモジュール

| テストファイル | 対象 | テスト数 | カバー範囲 |
|---------------|------|---------|-----------|
| PetStatsTests.swift (77行) | PetStats | 8 テスト | 初期値、fed、snacked、playedAndWon、hungerDecayed、上限/下限チェック、不変性 |
| GameEngineTests.swift (176行) | GameEngine | 12 テスト | 孵化、ごはん、そうじ、くすり、しつけ、でんき、一時停止、死亡、ミニゲーム、次世代 |
| TimeManagerTests.swift (49行) | TimeManager | 4 テスト | 大人の睡眠スケジュール、赤ちゃんの睡眠スケジュール、たまごの睡眠、ペット年齢計算 |

### テストが存在しないモジュール

| モジュール/ファイル | 行数 | テストの必要性 | 優先度 |
|-------------------|------|--------------|--------|
| **GameManager.swift** | 118行 | **高** -- ビジネスロジックの統合層。お世話アクション、タイマー、ライフサイクル管理 | 高 |
| **PetStore.swift** | 81行 | **高** -- 永続化ロジック、loadAndCatchUp のキャッチアップ動作 | 高 |
| **Pet.swift** | 91行 | **中** -- maxLifespanSeconds、hasReachedLifespan、newEgg ファクトリ | 中 |
| **LifeStage.swift** | 82行 | **中** -- 各プロパティの境界値テスト | 中 |
| **GameConfig.swift** | 75行 | **低** -- 定数のみ | 低 |
| **CareAction.swift** | 41行 | **低** -- 定数的な enum | 低 |
| **HapticPatterns.swift** | 46行 | **低** -- プラットフォーム固有の定数マッピング | 低 |
| **View ファイル全体** | 861行 | **低~中** -- UI テストは E2E で対応が望ましい | 低 |

### GameEngine の未テスト内部ロジック

GameEngine のテストは主要な公開メソッドをカバーしているが、以下の内部ロジックのテストが不足している:

- `decayStats` -- 減衰ロジック (睡眠中の倍率変更を含む)
- `generatePoop` -- うんち生成タイミング
- `checkCareMisses` -- 猶予時間経過後のお世話ミスカウント
- `checkSickness` -- うんち放置による病気発生
- `checkDeath` -- 餓死、病死、老衰の3パターン
- `checkStageTransition` -- ステージ進化とキャラクター ID 解決
- `resolveCharacterId` -- ティア分けロジック

### カバレッジ評価

**推定テストカバレッジ: 30-40% (目標 80% に未達)**

Shared/Engine と Shared/Models の一部はテストされているが、永続化層、UI 層、統合レイヤーにテストがなく、GameEngine の内部ロジックも網羅できていない。

## コード品質メトリクス

### ファイルサイズ

| ファイル | 行数 | 評価 |
|---------|------|------|
| GameEngine.swift | 392行 | 許容範囲内 (200-400行の目安上限) |
| GameEngineTests.swift | 176行 | 良好 |
| PetSpriteView.swift | 168行 | 良好 |
| HighOrLowGameView.swift | 149行 | 良好 |
| LeftOrRightGameView.swift | 126行 | 良好 |
| GameManager.swift | 118行 | 良好 |
| MenuView.swift | 117行 | 良好 |

全ファイルが 800行上限を大きく下回っており、ファイルサイズの規約に適合している。

### 関数サイズ

| 関数 | ファイル | 行数 | 評価 |
|------|---------|------|------|
| `GameEngine.advance()` | GameEngine.swift | 36行 | 良好 (50行以内) |
| `body` (MainPetView) | MainPetView.swift | 37行 | 良好 |
| `body` (GenericPetView) | PetSpriteView.swift | 33行 | 良好 |
| `body` (MenuView) | MenuView.swift | 65行 | **注意** -- 50行をやや超過。Section 分割でインラインが長い |

ほとんどの関数は 50行以内に収まっており、規約に概ね適合している。

### 設計パターンの評価

| パターン | 実装状況 | 評価 |
|---------|---------|------|
| 不変性 (struct + let) | PetStats の全メソッドが新インスタンスを返す | 優秀 |
| 純粋関数 | GameEngine が `enum` + `static func` で副作用なし | 優秀 |
| 値型中心 | Models は全て struct / enum | 優秀 |
| ファクトリパターン | `Pet.newEgg()` | 良好 |
| 状態管理 | `@Observable` + `@Environment` | 良好 |

## CLAUDE.md コーディング規約への適合性

### 適合している項目

| 規約 | 評価 | 根拠 |
|------|------|------|
| 不変性優先: struct + let をデフォルト | 適合 | PetStats, Pet, PetRecord は全て struct。GameEngine は純粋関数 |
| SwiftUI State Management | 適合 | `@Observable` + `@State` + `@Environment` を正しく使用 |
| ファイルサイズ 800行上限 | 適合 | 最大ファイルが 392行 |
| 関数サイズ 50行以内 | 概ね適合 | MenuView.body のみやや超過 |
| watchOS インタラクション 5-15秒 | 適合 | ミニゲームは 5 ラウンド制で短時間完結 |
| TDD 必須 | 部分的適合 | テストは存在するがカバレッジ不足 |

### 適合していない項目

| 規約 | 評価 | 根拠 |
|------|------|------|
| テストカバレッジ 80% 以上 | **不適合** | 推定 30-40%。View 層、永続化層にテストなし |
| エラーハンドリング: エラーは握りつぶさない | **不適合** | PetStore で `try?` による無言の失敗が複数箇所 |
| Swift の Result / throws を活用 | **不適合** | PetStore の load/save にエラーハンドリングなし |
| Digital Crown / Taptic Engine を活用 | **部分的** | Haptic は実装済み。Digital Crown は未実装 |
| コンプリケーション更新 | **未実装** | WidgetKit 未導入 |
| Always-On Display 対応 | **未実装** | AOD 対応コードなし |

## 技術的負債インベントリ

### 高優先度

| ID | 項目 | 影響 | ファイル |
|----|------|------|---------|
| TD-01 | PetStore のエラーハンドリング欠如 | データ喪失リスク。`try?` でエンコード/デコード失敗を無視 | PetStore.swift L19, L25, L39, L54 |
| TD-02 | PetStore の `@unchecked Sendable` | Swift 6 の concurrency 安全性を手動で回避。実際のスレッドセーフティが保証されていない | PetStore.swift L5 |
| TD-03 | テストカバレッジ不足 | リグレッションの検出困難。内部ロジック (減衰、うんち、病気、死亡) のテストが欠如 | Tests/ |
| TD-04 | PetStore が GameEngine に直接依存 | 永続化層がビジネスロジック層を呼び出す依存方向の逆転 | PetStore.swift L63 |

### 中優先度

| ID | 項目 | 影響 | ファイル |
|----|------|------|---------|
| TD-05 | Pet の var フィールド過多 | Pet struct に 23 個の var プロパティ。不変性の原則からすると変更ポイントが多い | Pet.swift |
| TD-06 | GameManager の Timer 管理 | `Timer.scheduledTimer` を使用。watchOS では `ExtendedRuntimeSession` やバックグラウンドタスクが推奨 | GameManager.swift L34 |
| TD-07 | DispatchQueue.main.asyncAfter の使用 | ミニゲームで `DispatchQueue.main.asyncAfter` を使用。Swift の構造化並行性 (Task.sleep) が推奨 | LeftOrRightGameView.swift L108, HighOrLowGameView.swift L125 |
| TD-08 | DeathView の DispatchQueue.main.asyncAfter | 同上。Swift 6 の並行性パターンに未準拠 | DeathView.swift L22 |
| TD-09 | iOS コンパニオンアプリが空 | Shared コードを含むが未使用。不要なビルド時間 | EkocciPhoneApp.swift |

### 低優先度

| ID | 項目 | 影響 | ファイル |
|----|------|------|---------|
| TD-10 | HapticManager の iOS 実装が空 | iOS 側の Haptic フィードバックが未実装 (コメントのみ) | HapticPatterns.swift L14-16 |
| TD-11 | hardcoded 文字列 | ペットの表示名、アイコン名がコード内にハードコード | CareAction.swift, StatsView.swift |
| TD-12 | Localization 未対応 | 全ての UI 文字列が日本語ハードコード。多言語対応不可 | 全 View ファイル |
| TD-13 | テストターゲットが iOS プラットフォーム | watchOS がメインターゲットだが、テストは iOS で実行 | project.yml L48 |

## セキュリティ評価

### ハードコードされた秘密情報

**問題なし。** API キー、パスワード、トークン等のハードコードは検出されなかった。

### データ永続化

| 項目 | 評価 | 詳細 |
|------|------|------|
| UserDefaults 使用 | **注意** | PetStore が UserDefaults でペットデータを保存。ゲームデータのため秘密情報ではないが、改ざんが容易 |
| Keychain 未使用 | **該当なし** | 現時点で秘密情報を扱っていないため問題なし |

### 入力バリデーション

| 項目 | 評価 | 詳細 |
|------|------|------|
| ステータス値の境界チェック | 適切 | PetStats で `min`/`max` による上下限クランプを実施 |
| Date バリデーション | 適切 | GameEngine.advance で `to > from` ガードあり |
| キャッチアップ時間の上限 | 適切 | `maxCatchUpDuration` (48時間) でクランプ |
| UserDefaults からのデコード | **不十分** | `try?` で失敗を無視。不正データの検出・リカバリなし |

### 外部データの信頼

| 項目 | 評価 | 詳細 |
|------|------|------|
| CloudKit (将来) | **未実装** | 実装時にはサーバーデータのバリデーションが必要 |
| ネットワーク通信 | **該当なし** | 現時点でネットワーク通信なし |

## ギャップと改善領域

### 即時対応が推奨される項目

1. **PetStore のエラーハンドリング追加** -- `try?` を `do-catch` に変更し、エラーログ出力またはフォールバック処理を実装
2. **GameEngine 内部ロジックのテスト追加** -- decayStats, generatePoop, checkCareMisses, checkSickness, checkDeath の各ロジックに対するユニットテスト
3. **PetStore のテスト追加** -- UserDefaults のモック注入によるテスト (既に DI 対応済み: `init(defaults:)`)

### 中期的に取り組むべき項目

4. **PetStore を actor 化** -- `@unchecked Sendable` を除去し、actor ベースの永続化に移行 (skill: swift-actor-persistence 参照)
5. **PetStore と GameEngine の依存分離** -- `loadAndCatchUp` のキャッチアップロジックを呼び出し元 (GameManager) に移動
6. **DispatchQueue.main.asyncAfter の置換** -- `Task { try await Task.sleep(for:) }` に移行
7. **Protocol ベースの DI 導入** -- PetStore を Protocol 化してテスタビリティを向上 (skill: swift-protocol-di-testing 参照)
8. **Pet の構造分割検討** -- 23 個の var プロパティを意味のあるサブ構造体に分割 (例: SleepState, PauseState, HealthState)

### 将来的に取り組むべき項目

9. **WidgetKit コンプリケーション実装**
10. **Always-On Display 対応**
11. **Digital Crown インタラクション追加**
12. **CloudKit によるデータ同期**
13. **ローカライゼーション対応**
14. **GameManager の View テスト / スナップショットテスト**
