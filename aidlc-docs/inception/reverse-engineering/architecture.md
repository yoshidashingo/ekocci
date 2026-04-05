# アーキテクチャ - ekocci (エコちっち)

## 1. システム概要

```
+---------------------------------------------------------------+
|                        ekocci Project                         |
+---------------------------------------------------------------+
|                                                               |
|  +-------------------------+  +-------------------------+     |
|  |     EkocciWatch         |  |     EkocciPhone         |     |
|  |     (watchOS App)       |  |     (iOS Companion)     |     |
|  |                         |  |                         |     |
|  | +---------------------+ |  | +---------------------+ |     |
|  | | EkocciWatchApp      | |  | | EkocciPhoneApp      | |     |
|  | | (@main entry)       | |  | | (@main entry)       | |     |
|  | +---------------------+ |  | | [placeholder only]  | |     |
|  |           |              |  | +---------------------+ |     |
|  | +---------------------+ |  +-------------------------+     |
|  | | GameManager         | |                                  |
|  | | (@Observable)       | |                                  |
|  | +---------------------+ |                                  |
|  |           |              |                                  |
|  | +---------------------+ |                                  |
|  | | Views/              | |                                  |
|  | |  ContentView        | |                                  |
|  | |  MainPetView        | |                                  |
|  | |  PetSpriteView      | |                                  |
|  | |  MenuView           | |                                  |
|  | |  StatsView           | |                                  |
|  | |  DeathView           | |                                  |
|  | |  MiniGames/          | |                                  |
|  | |   MiniGameSelection  | |                                  |
|  | |   LeftOrRightGame    | |                                  |
|  | |   HighOrLowGame      | |                                  |
|  | +---------------------+ |                                  |
|  +------------+------------+                                  |
|               |                                               |
|  +------------v--------------------------------------------+  |
|  |                    Shared Layer                          |  |
|  |                                                          |  |
|  |  +-------------+  +--------------+  +----------------+  |  |
|  |  | Models/     |  | Engine/      |  | Constants/     |  |  |
|  |  |  Pet        |  |  GameEngine  |  |  GameConfig    |  |  |
|  |  |  PetStats   |  |  TimeManager |  |  HapticPatterns|  |  |
|  |  |  LifeStage  |  +--------------+  +----------------+  |  |
|  |  |  CareAction |                                         |  |
|  |  +-------------+  +----------------+                     |  |
|  |                    | Persistence/   |                     |  |
|  |                    |  PetStore      |                     |  |
|  |                    |  PetRecord     |                     |  |
|  |                    +----------------+                     |  |
|  +----------------------------------------------------------+  |
|                                                               |
|  +----------------------------------------------------------+  |
|  |                    Tests Layer                            |  |
|  |  SharedTests/                                            |  |
|  |   PetStatsTests, GameEngineTests, TimeManagerTests       |  |
|  +----------------------------------------------------------+  |
+---------------------------------------------------------------+
```

---

## 2. データフロー

### 2.1 メインループ (30秒タイマー)

```
+-------+     tick()      +-----------+   advance()   +------------+
| Timer | --------------> | Game      | ------------> | Game       |
| (30s) |                 | Manager   |               | Engine     |
+-------+                 +-----------+               +------------+
                               |                           |
                               | pet = result              | return Pet
                               v                           |
                          +-----------+               +----+-------+
                          | SwiftUI   | <--- @Observable   |
                          | Views     |    observation     |
                          +-----------+                    |
                               |                           |
                          +-----------+                    |
                          | PetStore  | <--- savePet() ----+
                          | (persist) |
                          +-----------+
```

### 2.2 ユーザーアクションフロー

```
+------+  tap   +----------+  action()  +----------+  pure fn   +----------+
| User | -----> | MenuView | ---------> | Game     | ---------> | Game     |
+------+        +----------+            | Manager  |            | Engine   |
                                        +----------+            +----------+
                                            |   |                    |
                                            |   | savePet()          | return
                                            |   v                   | new Pet
                                            | +---------+           |
                                            | | PetStore| <---------+
                                     pet =  | +---------+
                                     result |
                                            v
                                        +----------+
                                        | SwiftUI  |
                                        | re-render|
                                        +----------+
```

### 2.3 アプリ起動フロー

```
+---------------+     +----------+     +-----------+     +----------+
| App Launch    | --> | PetStore | --> | loadPet() | --> | Has pet? |
+---------------+     +----------+     +-----------+     +----+-----+
                                                              |
                                         +--------------------+----+
                                         | YES                     | NO
                                         v                         v
                                   +-----------+           +-----------+
                                   | advance() |           | newEgg()  |
                                   | catch-up  |           +-----------+
                                   +-----------+                |
                                         |                      |
                                         v                      v
                                   +-----------+          +-----------+
                                   | savePet() |          | savePet() |
                                   +-----------+          +-----------+
                                         |                      |
                                         +----------+-----------+
                                                    |
                                                    v
                                              +-----------+
                                              | Display   |
                                              | pet view  |
                                              +-----------+
```

### 2.4 死亡 -> 次世代フロー

```
+----------+     +----------+     +-------------+     +----------+
| DeathView| --> | User tap | --> | GameManager | --> | addTo    |
| displayed|     | "next    |     | .startNext  |     | History  |
+----------+     |  egg"    |     | Generation  |     +----------+
                 +----------+     +-------------+          |
                                       |                   v
                                       |             +-----------+
                                       +-----------> | newEgg()  |
                                                     | gen + 1   |
                                                     +-----------+
                                                          |
                                                          v
                                                     +-----------+
                                                     | savePet() |
                                                     +-----------+
```

---

## 3. プラットフォームアーキテクチャ

### 3.1 ターゲット構成

```
+-------------------+     +-------------------+     +-------------------+
| EkocciWatch       |     | EkocciPhone       |     | EkocciTests       |
| (watchOS App)     |     | (iOS App)         |     | (Unit Tests)      |
| platform: watchOS |     | platform: iOS     |     | platform: iOS     |
+-------------------+     +-------------------+     +-------------------+
|  sources:         |     |  sources:         |     |  sources:         |
|   - EkocciWatch/  |     |   - EkocciPhone/  |     |   - Tests/        |
|   - Shared/       |     |   - Shared/       |     |     SharedTests/  |
+-------------------+     +-------------------+     |   - Shared/       |
                                                    +-------------------+
```

- Shared コードは各ターゲットのソースとして直接含まれる (フレームワーク/パッケージではなく、ソースレベルの共有)
- ビルドシステム: XcodeGen (`project.yml`) で管理
- Swift バージョン: 6.0
- デプロイメントターゲット: watchOS 26.0 / iOS 26.0

### 3.2 watchOS アプリ (メイン)

完全な育成ゲーム機能を提供:
- ペット表示 (アニメーション付きスプライト)
- お世話メニュー (ごはん、おやつ、あそぶ、そうじ、くすり、しつけ、でんき)
- ミニゲーム (どっち?、おおきい?ちいさい?)
- ステータス詳細表示
- 死亡/次世代フロー
- Haptic フィードバック (WKHapticType)
- 30秒ごとの自動状態更新

### 3.3 iOS コンパニオンアプリ (プレースホルダー)

現在は「Apple Watchでおせわしてね」というプレースホルダー画面のみ。将来的にステータス確認・家系図・図鑑・設定等の補助機能を提供予定。

---

## 4. 主要デザインパターン

### 4.1 純粋関数エンジン (Pure Function Engine)

GameEngine は `enum` (インスタンスなし) として実装され、全メソッドが `static` な純粋関数である。

```
入力: Pet (旧状態) + Date (時刻)
出力: Pet (新状態)
副作用: なし
```

- `advance(pet:from:to:)` - 時間経過シミュレーション
- `feed(pet:at:)`, `snack(pet:at:)`, `clean(pet:at:)` 等 - お世話アクション
- 全てのメソッドが入力の Pet を変更せず、新しい Pet を返す (不変性)

この設計により:
- テスト容易性が高い (任意の状態から任意の時刻でテスト可能)
- 並行性の問題がない
- オフラインキャッチアップが自然に実装できる

### 4.2 Observable パターン (SwiftUI State Management)

```
@Observable GameManager
    |
    +-- @State (EkocciWatchApp) で保持
    |
    +-- @Environment で各 View に注入
         |
         +-- ContentView
         +-- MainPetView
         +-- MenuView
         +-- StatsView
         +-- DeathView
         +-- MiniGame Views
```

- `GameManager` は `@Observable` マクロで宣言
- `EkocciWatchApp` が `@State` で所有し、`.environment()` で View ツリーに注入
- 各 View は `@Environment(GameManager.self)` でアクセス
- `pet` プロパティの変更が自動的に UI を再描画

### 4.3 値型モデル (Value Type Models)

全てのドメインモデルは `struct` または `enum` で、`Codable`, `Sendable` に準拠:
- `Pet` - struct (Codable, Equatable, Identifiable, Sendable)
- `PetStats` - struct (Codable, Equatable, Sendable)
- `LifeStage` - enum (Codable, CaseIterable, Sendable)
- `CareAction` - enum (Codable, CaseIterable, Sendable)

`PetStats` のメソッド (`fed()`, `snacked()`, `playedAndWon()` 等) は全て新しいインスタンスを返す不変メソッド。

### 4.4 enum 名前空間パターン

インスタンス化不要なユーティリティは `enum` で宣言し、名前空間として使用:
- `GameEngine` - ゲームロジック
- `TimeManager` - 時刻計算
- `GameConfig` - 定数定義
- `HapticManager` - Haptic 再生

### 4.5 条件付き UI パターン

View は Pet の状態に応じて動的に表示内容を切り替える:
- `ContentView`: `pet.stage == .dead` で DeathView / MainPetView を分岐
- `MenuView`: `pet.isSleeping`, `pet.poopCount > 0`, `pet.isSick`, `pet.stage.canPlayGames` 等で表示項目を制御
- `PetSpriteView`: `pet.stage` によりスプライトを切り替え

---

## 5. インテグレーションポイント

### 5.1 現在のインテグレーション

| ポイント | 説明 |
|---------|------|
| UserDefaults | PetStore が JSON エンコード/デコードでペットデータと履歴を永続化 |
| WKHapticType | watchOS の Taptic Engine フィードバック (9種類のパターン) |
| Timer | 30秒間隔のゲームループ更新 |
| Calendar | 実時間ベースの睡眠スケジュール判定 |

### 5.2 プラットフォーム分岐

HapticManager が `#if os(watchOS)` で分岐:
- watchOS: `WKInterfaceDevice.current().play()` で Haptic 再生
- iOS: 将来 `UIFeedbackGenerator` を使用予定 (現在は空実装)

### 5.3 未実装のインテグレーション (README/CLAUDE.md に記載)

| ポイント | 現状 |
|---------|------|
| WidgetKit | コンプリケーション未実装 (project.yml にターゲットなし) |
| CloudKit | データ同期未実装 |
| SpriteKit | ピクセルアートアニメーション未実装 (SwiftUI プレースホルダーで代替) |
| WatchConnectivity | Watch-iPhone 間通信未実装 |
| UserNotifications | 通知未実装 |

---

## 6. 状態管理アプローチ

### 6.1 状態の階層

```
+------------------------------------------------------------+
| UserDefaults (永続化層)                                     |
|  ekocci_current_pet: JSON encoded Pet                      |
|  ekocci_pet_history: JSON encoded [PetRecord]              |
+------------------------------------------------------------+
                    |
                    v
+------------------------------------------------------------+
| PetStore (永続化ゲートウェイ)                               |
|  loadPet() -> Pet?                                         |
|  savePet(Pet)                                              |
|  loadAndCatchUp() -> Pet                                   |
|  addToHistory(Pet)                                         |
+------------------------------------------------------------+
                    |
                    v
+------------------------------------------------------------+
| GameManager (@Observable - メモリ上の状態管理)              |
|  pet: Pet  (Single Source of Truth)                        |
|  timer: Timer? (30秒間隔)                                  |
+------------------------------------------------------------+
                    |
                    v
+------------------------------------------------------------+
| SwiftUI Views (@Environment 経由で参照)                    |
|  pet の変更を自動検知して再描画                             |
+------------------------------------------------------------+
```

### 6.2 状態更新フロー

1. **ユーザーアクション**: View -> GameManager のメソッド呼び出し
2. **純粋関数適用**: GameManager -> GameEngine の static メソッドに現在の Pet を渡す
3. **状態置換**: GameEngine が返した新しい Pet で `pet` プロパティを置換
4. **永続化**: PetStore.savePet() で UserDefaults に保存
5. **Haptic**: HapticManager.play() でフィードバック
6. **UI更新**: @Observable により SwiftUI が自動再描画

### 6.3 オフラインキャッチアップ

アプリがバックグラウンドやプロセス終了状態から復帰した場合:

1. `PetStore.loadAndCatchUp()` が呼ばれる
2. UserDefaults から最後に保存された Pet を読み込む
3. `GameEngine.advance(pet:from:to:)` で `lastUpdateTime` から現在時刻までを一括シミュレーション
4. 最大48時間分までキャッチアップ (`maxCatchUpDuration`)
5. 更新後の Pet を保存して返す

### 6.4 ミニゲームの状態管理

ミニゲーム (LeftOrRightGameView, HighOrLowGameView) はローカル `@State` で管理:
- `round`, `wins` - 進行状況
- `phase` - ゲームフェーズ (ready, choosing, reveal, finished)
- ゲーム完了時のみ `GameManager.miniGameWon/Lost()` を呼び出し、Pet の状態に反映

---

## 7. ファイル構成と責務

| ファイル | 行数 | 責務 |
|---------|------|------|
| `Shared/Models/Pet.swift` | 91行 | ペットの全状態を保持するドメインモデル |
| `Shared/Models/PetStats.swift` | 75行 | おなか・ごきげん・たいじゅうの値と変換メソッド |
| `Shared/Models/LifeStage.swift` | 82行 | 成長段階の定義と段階固有パラメータ |
| `Shared/Models/CareAction.swift` | 41行 | お世話アクションの列挙と表示情報 |
| `Shared/Engine/GameEngine.swift` | 392行 | ゲームのコアシミュレーション (純粋関数) |
| `Shared/Engine/TimeManager.swift` | 63行 | 実時間ベースの睡眠・年齢計算 |
| `Shared/Constants/GameConfig.swift` | 75行 | ゲーム全体の設定定数 |
| `Shared/Constants/HapticPatterns.swift` | 46行 | Haptic フィードバック定義 |
| `Shared/Persistence/PetStore.swift` | 82行 | UserDefaults ベースの永続化 |
| `EkocciWatch/EkocciWatchApp.swift` | 13行 | watchOS アプリエントリーポイント |
| `EkocciWatch/GameManager.swift` | 118行 | ゲーム状態管理 (@Observable) |
| `EkocciWatch/Views/ContentView.swift` | 18行 | ルーティング (死亡/通常の分岐) |
| `EkocciWatch/Views/MainPetView.swift` | 97行 | メイン画面 (ペット表示 + ステータスバー) |
| `EkocciWatch/Views/PetSpriteView.swift` | 168行 | ペットスプライト描画 (プレースホルダー) |
| `EkocciWatch/Views/MenuView.swift` | 117行 | お世話アクションメニュー |
| `EkocciWatch/Views/StatsView.swift` | 96行 | ステータス詳細画面 |
| `EkocciWatch/Views/DeathView.swift` | 49行 | 死亡画面と次世代ボタン |
| `EkocciWatch/Views/MiniGames/MiniGameSelectionView.swift` | 21行 | ミニゲーム選択画面 |
| `EkocciWatch/Views/MiniGames/LeftOrRightGameView.swift` | 126行 | どっち? ミニゲーム |
| `EkocciWatch/Views/MiniGames/HighOrLowGameView.swift` | 149行 | おおきい?ちいさい? ミニゲーム |
| `EkocciPhone/EkocciPhoneApp.swift` | 20行 | iOS プレースホルダー |
| `Tests/SharedTests/PetStatsTests.swift` | 77行 | PetStats 単体テスト |
| `Tests/SharedTests/GameEngineTests.swift` | 176行 | GameEngine 単体テスト |
| `Tests/SharedTests/TimeManagerTests.swift` | 49行 | TimeManager 単体テスト |
