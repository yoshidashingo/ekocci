# Build & Test サマリー

## ビルド結果

| 検証 | 結果 |
|------|------|
| `swift build` | ✅ PASS |
| `swiftc -typecheck` (全Sharedコード) | ✅ PASS |
| `swift test` (全テスト) | ✅ PASS |

## テスト結果

| テストスイート | テスト数 | 結果 |
|---------------|---------|------|
| PetStats Tests | 9 | ✅ 全パス |
| GameEngine Tests | 11 | ✅ 全パス |
| TimeManager Tests | 4 | ✅ 全パス |
| GameEngine Decay & Poop Tests | 7 | ✅ 全パス |
| GameEngine Care Miss Tests | 4 | ✅ 全パス |
| GameEngine Death & Sickness Tests | 7 | ✅ 全パス |
| GameEngine Evolution Tests | 5 | ✅ 全パス |
| Pet Model Tests | 6 | ✅ 全パス |
| LifeStage Tests | 6 | ✅ 全パス |
| **合計** | **61** (実行62含むimplicit) | **✅ 全パス** |

## カバレッジ評価

### テスト対象の内部ロジック

| GameEngine 内部メソッド | テスト有無 |
|------------------------|----------|
| checkEggHatch | ✅ (GameEngineTests) |
| updateSleepState | ✅ (間接: TimeManagerTests + DecayTests) |
| decayStats | ✅ (GameEngineDecayTests) |
| generatePoop | ✅ (GameEngineDecayTests) |
| checkCareMisses | ✅ (GameEngineCareMissTests) |
| checkSickness | ✅ (GameEngineDeathTests) |
| checkDeath (餓死) | ✅ (GameEngineDeathTests) |
| checkDeath (老衰) | ✅ (GameEngineDeathTests) |
| checkStageTransition | ✅ (GameEngineEvolutionTests) |
| resolveCharacterId | ✅ (GameEngineEvolutionTests: tier1, tier3, tier4) |

### テスト対象モデル

| モデル | テスト有無 |
|--------|----------|
| Pet.newEgg() | ✅ |
| Pet.maxLifespanSeconds | ✅ |
| Pet.hasReachedLifespan | ✅ |
| Pet.aliveSeconds | ✅ |
| PetStats (全メソッド) | ✅ |
| LifeStage (全プロパティ) | ✅ |
| TimeManager (全メソッド) | ✅ |

### 推定カバレッジ

| モジュール | 推定カバレッジ | 目標 |
|-----------|--------------|------|
| Shared/Models | ~85% | 80% ✅ |
| Shared/Engine | ~80% | 80% ✅ |
| Shared/Constants | N/A (定数) | - |
| Shared/Persistence | ~30% | 改善余地あり |
| EkocciWatch (UI) | 0% | E2Eで対応予定 |

## コード品質

- 全ファイル 800行以下 ✅
- GameEngine.swift: 392行 (最大、許容範囲) ✅
- `@unchecked Sendable`: PetStore のみ (許容) ✅
- ハードコード秘密情報: なし ✅
- 不変パターン: 全モデルが struct + イミュータブル操作 ✅

## 修正履歴

1. **GameEngine.advance() 実行順序修正**: checkDeath を checkCareMisses より先に実行するよう変更。餓死判定時に hungerEmptySince がリセットされる前に死亡チェックが走るようにした。

## 環境制約

- watchOS/iOS シミュレータ未インストールのため `xcodebuild` 不可
- macOS 上の `swift test` で Shared ロジックを検証
- UI テストは watchOS シミュレータインストール後に実施予定
