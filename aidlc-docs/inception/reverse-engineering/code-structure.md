# コード構造分析

## ビルドシステム

### XcodeGen (`project.yml`)

プロジェクトは **XcodeGen** を使用してXcodeプロジェクトを生成している。

| 設定項目 | 値 |
|---|---|
| Swift バージョン | 6.0 |
| iOS デプロイターゲット | 26.0 |
| watchOS デプロイターゲット | 26.0 |
| Xcode バージョン | 26.0 |
| デフォルト構成 | Debug |
| `ENABLE_USER_SCRIPT_SANDBOXING` | false |

### ターゲット構成

| ターゲット名 | 種類 | プラットフォーム | ソース | バンドルID |
|---|---|---|---|---|
| `EkocciWatch` | application | watchOS | `EkocciWatch/` + `Shared/` | `com.ekocci.watch` |
| `EkocciPhone` | application | iOS | `EkocciPhone/` + `Shared/` | `com.ekocci.phone` |
| `EkocciTests` | bundle.unit-test | iOS | `Tests/SharedTests/` + `Shared/` | `com.ekocci.tests` |

`Shared/` ディレクトリは全ターゲットに直接含まれており、フレームワーク分離ではなくソースコード共有方式を採用している。

## モジュール/ファイル構成

```
ekocci/ (総行数: 2,240行)
├── Shared/                          # 共有ビジネスロジック (946行)
│   ├── Models/                      # データモデル (289行)
│   │   ├── LifeStage.swift          #   82行 - ペットのライフステージ列挙
│   │   ├── PetStats.swift           #   75行 - ペットのステータス構造体
│   │   ├── CareAction.swift         #   41行 - お世話アクション列挙
│   │   └── Pet.swift                #   91行 - ペット全状態構造体
│   ├── Constants/                   # 定数 (121行)
│   │   ├── GameConfig.swift         #   75行 - ゲーム設定定数
│   │   └── HapticPatterns.swift     #   46行 - Hapticフィードバック
│   ├── Engine/                      # ゲームエンジン (455行)
│   │   ├── GameEngine.swift         #  392行 - コアシミュレーション
│   │   └── TimeManager.swift        #   63行 - 時刻管理
│   └── Persistence/                 # 永続化 (81行)
│       └── PetStore.swift           #   81行 - UserDefaultsベース永続化
├── EkocciWatch/                     # watchOSアプリ (909行)
│   ├── EkocciWatchApp.swift         #   13行 - アプリエントリポイント
│   ├── GameManager.swift            #  118行 - 状態管理 (@Observable)
│   └── Views/                       # UI (778行)
│       ├── ContentView.swift        #   18行 - ルートビュー
│       ├── MainPetView.swift        #   97行 - メインペット表示
│       ├── PetSpriteView.swift      #  168行 - スプライト描画
│       ├── MenuView.swift           #  117行 - お世話メニュー
│       ├── StatsView.swift          #   96行 - ステータス詳細
│       ├── DeathView.swift          #   49行 - 死亡画面
│       └── MiniGames/               # ミニゲーム (296行)
│           ├── MiniGameSelectionView.swift  #   21行
│           ├── LeftOrRightGameView.swift    #  126行
│           └── HighOrLowGameView.swift      #  149行
├── EkocciPhone/                     # iOSアプリ (20行)
│   └── EkocciPhoneApp.swift         #   20行 - プレースホルダー画面
└── Tests/                           # テスト (302行)
    └── SharedTests/
        ├── PetStatsTests.swift      #   77行
        ├── GameEngineTests.swift    #  176行
        └── TimeManagerTests.swift   #   49行
```

## 設計パターン

### 1. 不変状態 + 純粋関数 (最重要パターン)

`GameEngine` は全メソッドが `static func` で、入力の `Pet` を変更せず新しい `Pet` を返す純粋関数として実装されている。`PetStats` も同様に `fed()`, `snacked()` 等のメソッドが新しいインスタンスを返す。

```
GameEngine.feed(pet: Pet, at: Date) -> Pet  // 元のpetは不変
PetStats.fed() -> PetStats                  // 元のstatsは不変
```

### 2. ケースレスenum (名前空間パターン)

`GameEngine`, `TimeManager`, `GameConfig` はケースを持たない `enum` として定義されており、インスタンス化不可能な名前空間として機能する。

### 3. @Observable (SwiftUI状態管理)

`GameManager` は Swift 5.9+ の `@Observable` マクロを使用し、SwiftUI ビューとの自動的なデータバインディングを実現。`@Environment` 経由で全ビューに注入される。

### 4. Codable永続化

`Pet`, `PetStats`, `LifeStage`, `CareAction` は全て `Codable` に準拠。`PetStore` が `UserDefaults` + `JSONEncoder/Decoder` で永続化を担当。

### 5. ファサードパターン

`GameManager` は `GameEngine` の純粋関数群をラップし、副作用(永続化、Haptic再生、タイマー管理)を集約するファサードとして機能する。

### 6. Sendable準拠

全モデル型(`Pet`, `PetStats`, `LifeStage`, `CareAction`, `HapticType`)が `Sendable` に準拠しており、Swift 6の厳格な並行性チェックに対応。

## クラス/構造体/列挙型インベントリ

### 構造体 (Struct)

| 名前 | ファイル | 責務 |
|---|---|---|
| `Pet` | Pet.swift | ペットの全状態を保持。ID、ステージ、ステータス、各種フラグを含む |
| `PetStats` | PetStats.swift | おなか・ごきげん・たいじゅうの3値を管理。不変操作メソッドを提供 |
| `PetRecord` | PetStore.swift | 歴代ペットの記録(死亡後のアーカイブ用) |

### 列挙型 (Enum)

| 名前 | ファイル | 責務 |
|---|---|---|
| `LifeStage` | LifeStage.swift | ペットのライフステージ(egg -> baby -> child -> young -> adult -> senior -> dead) |
| `CareAction` | CareAction.swift | プレイヤーが実行可能なお世話アクション(8種類) |
| `GameConfig` | GameConfig.swift | ゲームバランス定数(ケースレスenum) |
| `GameEngine` | GameEngine.swift | コアシミュレーション(ケースレスenum、全メソッドstatic) |
| `TimeManager` | TimeManager.swift | リアルタイム時刻管理(ケースレスenum) |
| `HapticManager` | HapticPatterns.swift | Hapticフィードバック再生(ケースレスenum) |
| `HapticType` | HapticPatterns.swift | Hapticの種類(9ケース) |

### クラス (Class)

| 名前 | ファイル | 責務 |
|---|---|---|
| `PetStore` | PetStore.swift | UserDefaultsベースの永続化。`@unchecked Sendable` |
| `GameManager` | GameManager.swift | `@Observable` ゲーム状態管理。UIとエンジンの橋渡し |

### SwiftUIビュー (Struct: View)

| 名前 | ファイル | 責務 |
|---|---|---|
| `EkocciWatchApp` | EkocciWatchApp.swift | watchOSアプリのエントリポイント |
| `EkocciPhoneApp` | EkocciPhoneApp.swift | iOSアプリのプレースホルダー |
| `ContentView` | ContentView.swift | ステージ別の画面切り替え |
| `MainPetView` | MainPetView.swift | メインペット表示画面 |
| `PetSpriteView` | PetSpriteView.swift | ペットのスプライト描画 |
| `StatusBar` | MainPetView.swift | おなか・ごきげんのハートゲージ |
| `HeartsView` | MainPetView.swift | ハートアイコン表示 |
| `MenuView` | MenuView.swift | お世話アクションメニュー |
| `StatsView` | StatsView.swift | ステータス詳細画面 |
| `DeathView` | DeathView.swift | 死亡画面(次世代ボタン付き) |
| `MiniGameSelectionView` | MiniGameSelectionView.swift | ミニゲーム選択画面 |
| `LeftOrRightGameView` | LeftOrRightGameView.swift | 「どっち?」ミニゲーム |
| `HighOrLowGameView` | HighOrLowGameView.swift | 「おおきい?ちいさい?」ミニゲーム |
| `EggView` | PetSpriteView.swift | たまごスプライト(private) |
| `BabyView` | PetSpriteView.swift | あかちゃんスプライト(private) |
| `GenericPetView` | PetSpriteView.swift | 汎用ペットスプライト(private) |
| `DeadView` | PetSpriteView.swift | 死亡スプライト(private) |

## モジュール間の依存関係

```
EkocciWatch/
├── EkocciWatchApp ──→ GameManager
├── GameManager ──→ PetStore, GameEngine, HapticManager, Pet
├── ContentView ──→ GameManager, DeathView, MainPetView
├── MainPetView ──→ GameManager, Pet, PetStats, PetSpriteView, StatusBar, HeartsView, MenuView
├── MenuView ──→ GameManager, Pet, LifeStage, MiniGameSelectionView, StatsView
├── StatsView ──→ GameManager, Pet, PetStats, HeartsView
├── DeathView ──→ GameManager, HapticManager
├── PetSpriteView ──→ Pet, LifeStage
├── MiniGameSelectionView ──→ LeftOrRightGameView, HighOrLowGameView
├── LeftOrRightGameView ──→ GameManager, HapticManager
└── HighOrLowGameView ──→ GameManager, HapticManager

Shared/
├── GameEngine ──→ Pet, PetStats, LifeStage, TimeManager, GameConfig
├── TimeManager ──→ LifeStage, GameConfig
├── PetStore ──→ Pet, PetRecord, GameEngine
├── Pet ──→ PetStats, LifeStage
├── PetStats ──→ (依存なし)
├── LifeStage ──→ (依存なし)
├── CareAction ──→ (依存なし)
├── GameConfig ──→ (依存なし)
└── HapticManager/HapticType ──→ WatchKit (条件付き)

EkocciPhone/
└── EkocciPhoneApp ──→ (依存なし、プレースホルダー)

Tests/
├── PetStatsTests ──→ PetStats
├── GameEngineTests ──→ GameEngine, Pet, PetStats
└── TimeManagerTests ──→ TimeManager
```

### 依存の方向

```
Views → GameManager → GameEngine → Models/TimeManager/GameConfig
                    → PetStore  → GameEngine (loadAndCatchUp)
                    → HapticManager
```

UIレイヤーはビジネスロジックへの一方向依存のみ。`GameEngine` は副作用を持たない純粋関数の集合であり、テスタビリティが高い。
