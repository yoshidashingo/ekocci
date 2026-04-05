# コンポーネントインベントリ

## 全型一覧

| 名前 | 種別 | ファイル | 行数 | 用途 | 依存先 |
|---|---|---|---|---|---|
| `LifeStage` | enum | Shared/Models/LifeStage.swift | 82 | ペットのライフステージ定義。egg/baby/child/young/adult/senior/deadの7段階。各ステージの持続時間、睡眠時間、うんち間隔を提供 | なし |
| `PetStats` | struct | Shared/Models/PetStats.swift | 75 | おなか(hunger)、ごきげん(happiness)、たいじゅう(weight)の3値管理。不変操作メソッド群を提供 | なし |
| `CareAction` | enum | Shared/Models/CareAction.swift | 41 | プレイヤーが実行可能な8種類のお世話アクション。表示名とSF Symbolsアイコン名を提供 | なし |
| `Pet` | struct | Shared/Models/Pet.swift | 91 | ペットの全状態を保持する主要データモデル。ステージ、ステータス、しつけ、年齢、病気、睡眠、一時停止等の全フラグを含む | `PetStats`, `LifeStage` |
| `PetRecord` | struct | Shared/Persistence/PetStore.swift | 9 | 死亡したペットの履歴記録。ID、キャラクターID、世代、年齢、誕生日、死亡日を保持 | なし |
| `GameConfig` | enum | Shared/Constants/GameConfig.swift | 75 | ゲームバランス定数の名前空間。ステータス減衰間隔、お世話ミス猶予時間、病気/餓死閾値、しつけ/エコポイント等の全数値定数 | なし |
| `GameEngine` | enum | Shared/Engine/GameEngine.swift | 392 | コアシミュレーションエンジン。純粋関数のみで構成。時間経過による状態更新、お世話アクション適用、死亡判定等 | `Pet`, `PetStats`, `LifeStage`, `TimeManager`, `GameConfig` |
| `TimeManager` | enum | Shared/Engine/TimeManager.swift | 63 | リアルタイム時刻管理。睡眠判定、次回起床/就寝時刻算出、ペット年齢計算 | `LifeStage`, `GameConfig` |
| `HapticManager` | enum | Shared/Constants/HapticPatterns.swift | 17 | Hapticフィードバック再生。watchOSではWKInterfaceDevice、iOSは将来実装 | `HapticType`, `WatchKit`(条件付き) |
| `HapticType` | enum | Shared/Constants/HapticPatterns.swift | 29 | Hapticの種類定義。fed/gameWon/gameLost/disciplined/evolved/died/notification/cleaned/healedの9種 | `WatchKit`(条件付き) |
| `PetStore` | class | Shared/Persistence/PetStore.swift | 72 | UserDefaultsベースの永続化。ペットの読み書き、履歴管理、起動時キャッチアップ処理 | `Pet`, `PetRecord`, `GameEngine` |
| `GameManager` | class | EkocciWatch/GameManager.swift | 118 | @Observableゲーム状態管理。UIとGameEngineの橋渡し。タイマー管理、副作用(永続化/Haptic)の集約 | `Pet`, `PetStore`, `GameEngine`, `HapticManager` |
| `EkocciWatchApp` | struct (App) | EkocciWatch/EkocciWatchApp.swift | 13 | watchOSアプリのエントリポイント。GameManagerをEnvironmentに注入 | `GameManager` |
| `EkocciPhoneApp` | struct (App) | EkocciPhone/EkocciPhoneApp.swift | 20 | iOSアプリのプレースホルダー。Apple Watchへの誘導メッセージを表示 | なし |
| `ContentView` | struct (View) | EkocciWatch/Views/ContentView.swift | 18 | ルートビュー。ペットのステージに応じてDeathViewまたはMainPetViewを切り替え | `GameManager` |
| `MainPetView` | struct (View) | EkocciWatch/Views/MainPetView.swift | 55 | メインペット表示画面。ステータスバー、スプライト、うんち/病気インジケーター、メニューシートを含む | `GameManager`, `Pet`, `PetSpriteView`, `StatusBar`, `MenuView` |
| `StatusBar` | struct (View) | EkocciWatch/Views/MainPetView.swift | 21 | おなかとごきげんのハートゲージ表示 | `Pet`, `PetStats`, `HeartsView` |
| `HeartsView` | struct (View) | EkocciWatch/Views/MainPetView.swift | 14 | 塗り/空のハートアイコン行を描画する汎用ゲージ | なし |
| `PetSpriteView` | struct (View) | EkocciWatch/Views/PetSpriteView.swift | 61 | ペットのスプライト描画。ステージ別の見た目切り替え、バウンスアニメーション、睡眠表示 | `Pet`, `LifeStage` |
| `EggView` | struct (View) | EkocciWatch/Views/PetSpriteView.swift | 14 | たまごスプライト。揺れアニメーション付き (private) | なし |
| `BabyView` | struct (View) | EkocciWatch/Views/PetSpriteView.swift | 17 | あかちゃんスプライト。白い丸と体 (private) | なし |
| `GenericPetView` | struct (View) | EkocciWatch/Views/PetSpriteView.swift | 62 | 汎用ペットスプライト。ステージとisSickに応じてサイズ・色を変更 (private) | `LifeStage` |
| `DeadView` (sprite) | struct (View) | EkocciWatch/Views/PetSpriteView.swift | 6 | 死亡スプライト。天使絵文字 (private) | なし |
| `MenuView` | struct (View) | EkocciWatch/Views/MenuView.swift | 117 | お世話アクションメニュー。List形式で条件付き表示のSection群 | `GameManager`, `Pet`, `LifeStage`, `StatsView`, `MiniGameSelectionView` |
| `StatsView` | struct (View) | EkocciWatch/Views/StatsView.swift | 96 | ステータス詳細画面。基本情報、ステータス、その他のSection | `GameManager`, `Pet`, `PetStats`, `HeartsView` |
| `DeathView` | struct (View) | EkocciWatch/Views/DeathView.swift | 49 | 死亡画面。天使アニメーション後に「つぎのたまご」ボタンを表示 | `GameManager`, `HapticManager` |
| `MiniGameSelectionView` | struct (View) | EkocciWatch/Views/MiniGames/MiniGameSelectionView.swift | 21 | ミニゲーム選択画面。2種類のゲームへのNavigationLink | `LeftOrRightGameView`, `HighOrLowGameView` |
| `LeftOrRightGameView` | struct (View) | EkocciWatch/Views/MiniGames/LeftOrRightGameView.swift | 126 | 「どっち?」ミニゲーム。5ラウンド3勝制の左右当てゲーム | `GameManager`, `HapticManager` |
| `LeftOrRightGameView.GamePhase` | enum (nested) | EkocciWatch/Views/MiniGames/LeftOrRightGameView.swift | 3 | ゲームの進行フェーズ: ready/choosing/reveal/finished | なし |
| `LeftOrRightGameView.Direction` | enum (nested) | EkocciWatch/Views/MiniGames/LeftOrRightGameView.swift | 3 | 方向: left/right | なし |
| `HighOrLowGameView` | struct (View) | EkocciWatch/Views/MiniGames/HighOrLowGameView.swift | 149 | 「おおきい?ちいさい?」ミニゲーム。5ラウンド3勝制の数値比較ゲーム | `GameManager`, `HapticManager` |
| `HighOrLowGameView.GamePhase` | enum (nested) | EkocciWatch/Views/MiniGames/HighOrLowGameView.swift | 3 | ゲームの進行フェーズ: ready/choosing/reveal/finished | なし |
| `HighOrLowGameView.Choice` | enum (nested) | EkocciWatch/Views/MiniGames/HighOrLowGameView.swift | 3 | 選択: high/low | なし |

## テスト

| 名前 | 種別 | ファイル | 行数 | テスト対象 | テスト数 |
|---|---|---|---|---|---|
| `PetStatsTests` | struct (@Suite) | Tests/SharedTests/PetStatsTests.swift | 77 | `PetStats` | 8 |
| `GameEngineTests` | struct (@Suite) | Tests/SharedTests/GameEngineTests.swift | 176 | `GameEngine` | 12 |
| `TimeManagerTests` | struct (@Suite) | Tests/SharedTests/TimeManagerTests.swift | 49 | `TimeManager` | 4 |

## 統計

| カテゴリ | ファイル数 | 総行数 |
|---|---|---|
| Shared/Models | 4 | 289 |
| Shared/Constants | 2 | 121 |
| Shared/Engine | 2 | 455 |
| Shared/Persistence | 1 | 81 |
| EkocciWatch (非View) | 2 | 131 |
| EkocciWatch/Views | 9 | 778 |
| EkocciPhone | 1 | 20 |
| Tests | 3 | 302 |
| **合計** | **24** | **2,240** |

## プロトコル準拠

| 型 | 準拠プロトコル |
|---|---|
| `LifeStage` | `String`, `Codable`, `CaseIterable`, `Sendable` |
| `PetStats` | `Codable`, `Equatable`, `Sendable` |
| `CareAction` | `String`, `Codable`, `CaseIterable`, `Sendable` |
| `Pet` | `Codable`, `Equatable`, `Identifiable`, `Sendable` |
| `PetRecord` | `Codable`, `Identifiable`, `Sendable` |
| `PetStore` | `@unchecked Sendable` |
| `HapticType` | `Sendable` |
