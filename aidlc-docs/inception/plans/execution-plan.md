# 実行計画 - ekocci v2 品質改善

## フェーズ構成

```
+-------------------+     +-------------------+     +-------------------+
| INCEPTION         | --> | CONSTRUCTION      | --> | BUILD & TEST      |
| (完了)            |     | Code Generation   |     | 検証              |
+-------------------+     +-------------------+     +-------------------+
| [x] Workspace Det |     | [ ] テスト追加     |     | [ ] 型チェック     |
| [x] Rev. Eng.     |     | [ ] コード改善     |     | [ ] テスト実行     |
| [x] Requirements  |     |                   |     | [ ] カバレッジ確認  |
| [x] Workflow Plan  |     |                   |     |                   |
+-------------------+     +-------------------+     +-------------------+
```

## スキップするステージと理由

| ステージ | 判定 | 理由 |
|---------|------|------|
| User Stories | SKIP | テスト補強タスク。ユーザーストーリー不要 |
| Application Design | SKIP | 既存設計を変更しない |
| Units Generation | SKIP | 単一ユニット (Shared) の改善のみ |
| Functional Design | SKIP | 既存ビジネスロジックの検証のみ |
| NFR Requirements | SKIP | 既存 NFR を変更しない |
| NFR Design | SKIP | 既存設計を変更しない |
| Infrastructure Design | SKIP | インフラ変更なし |

## 実行するステージ

### Stage 1: Code Generation (テスト追加 + コード改善)

- [ ] GameEngine 内部ロジックテスト追加 (decayStats, generatePoop, checkCareMisses, checkSickness, checkDeath, checkStageTransition)
- [ ] Pet モデルテスト追加
- [ ] LifeStage テスト追加
- [ ] PetStore テスト追加
- [ ] PetStore エラーハンドリング改善
- [ ] MenuView body 関数のリファクタリング (50行超過対応)

### Stage 2: Build and Test

- [ ] swiftc -typecheck 全ファイル通過
- [ ] テスト全件パス
- [ ] カバレッジ 80% 達成確認

## リスク評価

| リスク | 深刻度 | 対策 |
|--------|--------|------|
| watchOS シミュレータ未インストール | 高 | swiftc -typecheck + macOS テスト実行で検証 |
| GameEngine 内部メソッドが private | 中 | internal に変更 or テストから advance() 経由でテスト |
| Swift Testing フレームワークの CLI 実行 | 中 | swift test または xctest で実行 |
