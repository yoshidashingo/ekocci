# 依存関係

## モジュール構成

プロジェクトは 4 つのターゲットと 1 つの共有コード領域で構成される。

| ターゲット | タイプ | プラットフォーム |
|-----------|--------|---------------|
| EkocciWatch | application | watchOS |
| EkocciPhone | application | iOS |
| EkocciTests | bundle.unit-test | iOS |
| Shared | ソースディレクトリ (ターゲットではない) | 共有 |

## 内部依存関係

### ソースの包含関係 (project.yml 定義)

| ターゲット | 含むソース |
|-----------|-----------|
| EkocciWatch | `EkocciWatch/` + `Shared/` |
| EkocciPhone | `EkocciPhone/` + `Shared/` |
| EkocciTests | `Tests/SharedTests/` + `Shared/` |

> **注記**: Shared は独立した Swift Package やフレームワークターゲットではなく、各ターゲットにソースファイルとして直接組み込まれる構成である。

### Shared 内部の依存グラフ

```
Shared/
├── Models/
│   ├── LifeStage.swift      ← 依存なし (独立)
│   ├── PetStats.swift        ← 依存なし (独立)
│   ├── CareAction.swift      ← 依存なし (独立)
│   └── Pet.swift             ← LifeStage, PetStats に依存
│
├── Constants/
│   ├── GameConfig.swift      ← 依存なし (独立)
│   └── HapticPatterns.swift  ← WatchKit (条件付き)
│
├── Engine/
│   ├── TimeManager.swift     ← LifeStage, GameConfig に依存
│   └── GameEngine.swift      ← Pet, PetStats, LifeStage, TimeManager, GameConfig に依存
│
└── Persistence/
    └── PetStore.swift        ← Pet, GameEngine に依存
```

### EkocciWatch 内部の依存グラフ

```
EkocciWatch/
├── EkocciWatchApp.swift     ← GameManager, ContentView
├── GameManager.swift        ← Pet, GameEngine, PetStore, HapticManager
└── Views/
    ├── ContentView.swift    ← GameManager, DeathView, MainPetView
    ├── MainPetView.swift    ← GameManager, Pet, PetStats, PetSpriteView,
    │                           StatusBar, HeartsView, MenuView
    ├── PetSpriteView.swift  ← Pet, LifeStage
    ├── MenuView.swift       ← GameManager, Pet, MiniGameSelectionView, StatsView
    ├── StatsView.swift      ← GameManager, Pet, PetStats, HeartsView
    ├── DeathView.swift      ← GameManager, HapticManager
    └── MiniGames/
        ├── MiniGameSelectionView.swift  ← LeftOrRightGameView, HighOrLowGameView
        ├── LeftOrRightGameView.swift    ← GameManager, HapticManager
        └── HighOrLowGameView.swift      ← GameManager, HapticManager
```

### EkocciPhone の依存

```
EkocciPhone/
└── EkocciPhoneApp.swift     ← SwiftUI のみ (Shared コードを使用していない)
```

> **注記**: EkocciPhone は project.yml で Shared をソースとして含むが、現状の EkocciPhoneApp.swift は Shared のコードを一切 import/使用していない。プレースホルダー状態。

## 全体依存グラフ (ASCII)

```
┌─────────────────────────────────────────────────────────┐
│                    EkocciWatch (watchOS App)             │
│                                                         │
│  EkocciWatchApp ──► GameManager ──┬──► GameEngine       │
│       │                │          │       │              │
│       ▼                ▼          │       ▼              │
│  ContentView      PetStore        │  TimeManager        │
│       │               │          │       │              │
│       ▼               ▼          │       ▼              │
│  MainPetView    UserDefaults     │  GameConfig          │
│  DeathView                       │                      │
│  MenuView                        │                      │
│  StatsView                       ▼                      │
│  MiniGames              HapticManager ──► WatchKit      │
│                                                         │
│              ┌─── Shared (組み込み) ───┐                │
│              │  Models:               │                  │
│              │    Pet ──► PetStats    │                  │
│              │         ──► LifeStage  │                  │
│              │    CareAction          │                  │
│              │  Constants:            │                  │
│              │    GameConfig          │                  │
│              │    HapticPatterns      │                  │
│              │  Engine:               │                  │
│              │    GameEngine          │                  │
│              │    TimeManager         │                  │
│              │  Persistence:          │                  │
│              │    PetStore            │                  │
│              └────────────────────────┘                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                 EkocciPhone (iOS App)                    │
│                                                         │
│  EkocciPhoneApp (プレースホルダー)                       │
│  ※ Shared を含むが現状未使用                             │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                  EkocciTests (Unit Tests)                │
│                                                         │
│  PetStatsTests ──► PetStats                             │
│  GameEngineTests ──► GameEngine, Pet, PetStats          │
│  TimeManagerTests ──► TimeManager                       │
└─────────────────────────────────────────────────────────┘
```

## 外部依存関係 (フレームワーク/SDK)

| フレームワーク | 使用ファイル | 種類 |
|---------------|-------------|------|
| Foundation | 全 Swift ファイル | Apple 標準 |
| SwiftUI | 全 View ファイル, App エントリポイント | Apple 標準 |
| Observation | GameManager.swift | Apple 標準 (iOS 17+ / watchOS 10+) |
| WatchKit | HapticPatterns.swift (`#if os(watchOS)`) | Apple 標準 (watchOS 専用) |
| Testing | テストファイル 3 件 | Apple 標準 (Swift Testing) |

## サードパーティパッケージ

**なし。** 本プロジェクトは外部のサードパーティライブラリに一切依存していない。全ての機能は Apple 標準フレームワークのみで実装されている。

## 未使用だが計画中の依存

CLAUDE.md に記載されているが、現時点でコード内には存在しない:

| フレームワーク | 計画用途 |
|---------------|---------|
| WidgetKit | watchOS コンプリケーション |
| CloudKit | データ同期 |
| SpriteKit | ペットアニメーション |

## 依存関係の特徴と課題

1. **Shared の組み込み方式**: SPM パッケージやフレームワークターゲットではなく、ソースファイルの直接組み込みで共有。ビルド時間やモジュール境界の明確さに影響する可能性がある。

2. **GameEngine の中央集約**: GameEngine が全モデルと TimeManager、GameConfig に依存しており、ロジックの中心点となっている。純粋関数設計のため変更の影響は制御されているが、ファイルサイズが大きい (393行)。

3. **PetStore の GameEngine 依存**: 永続化層 (PetStore) がビジネスロジック層 (GameEngine) を直接呼び出している (`loadAndCatchUp` メソッド)。レイヤー間の依存方向が逆転している。

4. **テストの限定的カバレッジ**: テストは Shared のみを対象としており、EkocciWatch の Views や GameManager にはテストが存在しない。
