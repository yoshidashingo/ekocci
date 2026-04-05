# Phase 2: ミニゲーム + 進化エンジン — 実装計画

**作成日**: 2026-04-04
**ステータス**: 完了

## 概要

MiniGame プロトコル、ジャンプゲーム、22キャラクターレジストリ、EvolutionEngine、スプライトシステムを実装。

## サブフェーズ

### 2A: MiniGame Protocol + リファクタ (ステップ 1-7)
- MiniGamePhase enum、MiniGameResult struct、MiniGameDescriptor
- 既存2ゲーム (LeftOrRight, HighOrLow) のリファクタ
- GameManager.applyMiniGameResult 追加
- MiniGameSelectionView をデータ駆動に更新

### 2B: キャラクター + 進化エンジン (ステップ 8-18)
- HiddenStats (effort/bonding) — Pet モデルに追加
- EvolutionCondition — データ駆動の進化条件
- CharacterDefinition — キャラクター定義モデル
- CharacterRegistry — 22体のキャラクター登録
  - baby: 1, child: 4, young: 5, adult: 6, senior: 4, special: 2
- EvolutionEngine — 純粋関数の進化先解決
- GameEngine 統合 — resolveCharacterId → EvolutionEngine.resolve
- お世話アクションで hiddenStats 更新

### 2C: ジャンプゲーム (ステップ 19-23)
- JumpGameState — View 非依存の純粋ロジック (5障害物、タップでジャンプ)
- JumpGameView — TimelineView + Canvas ベース
- GameConfig にジャンプゲーム定数追加

### 2D: スプライトシステム (ステップ 24-27)
- SpriteMapping — characterId → emoji + tintHue + accessory
- PetSpriteView にアクセサリバッジ追加

## 成果

| 指標 | 値 |
|------|-----|
| テスト | 71 → 113 (+42) |
| スイート | 10 → 15 |
| 新規ファイル | 11 |
| 新テストファイル | 6 |
