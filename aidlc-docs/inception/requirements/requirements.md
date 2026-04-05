# 要件定義 - ekocci v2 MVP品質改善

## インテントサマリー

Reverse Engineering で特定された技術的負債を解消し、MVP を完全動作状態にする。

## 機能要件

### FR-01: テストカバレッジ 80% 達成
- GameEngine 内部ロジック (decayStats, generatePoop, checkCareMisses, checkSickness, checkDeath, checkStageTransition, resolveCharacterId) のテスト追加
- Pet モデルのテスト追加 (maxLifespanSeconds, hasReachedLifespan, newEgg)
- LifeStage プロパティのテスト追加
- PetStore の永続化ラウンドトリップテスト追加

### FR-02: GameEngine 内部ロジックの検証
- ステータス減衰が正しく動作すること (通常時 / 睡眠中の倍率)
- うんち生成が睡眠中に停止すること
- お世話ミスのカウントが猶予時間を正しく判定すること
- 病気発生条件 (うんち3個以上 + 放置時間) が正しいこと
- 死亡判定 (餓死 / 病死 / 老衰) の3パターンが正しいこと
- ステージ遷移タイミングとキャラクターID解決が正しいこと

### FR-03: PetStore エラーハンドリング改善
- JSON デコード失敗時の安全なフォールバック
- 保存失敗時のログ出力

### FR-04: ビルド成功の確認
- `swiftc -typecheck` で全 Shared コードがエラーなし
- テストが全件パスすること

## 非機能要件

### NFR-01: コード品質
- 全ファイル 800行以下
- 全関数 50行以下
- `@unchecked Sendable` の適切な使用 (PetStore のみ許容)

### NFR-02: セキュリティ
- ハードコードされた秘密情報がないこと
- UserDefaults に機密データを保存していないこと (ゲームデータのみで問題なし)

## スコープ外
- UI テスト (E2E テストは将来フェーズ)
- watchOS シミュレータでの実機テスト (環境制約)
- CloudKit 同期
- WidgetKit コンプリケーション
