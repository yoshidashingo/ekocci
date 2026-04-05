# API ドキュメント

## GameEngine

ゲームのコアシミュレーションエンジン。ケースレス `enum` で全メソッドが `static`。純粋関数のみで構成され、副作用を持たない。

### メインループ

#### `advance(pet:from:to:) -> Pet`

```swift
static func advance(pet: Pet, from: Date, to: Date) -> Pet
```

時間を進めてペットの状態を更新する。以下の処理を順番に実行する。

| パラメータ | 型 | 説明 |
|---|---|---|
| `pet` | `Pet` | 現在のペット状態 |
| `from` | `Date` | 前回更新時刻 |
| `to` | `Date` | 現在時刻 |
| **戻り値** | `Pet` | 更新後のペット状態 |

**処理順序:**

1. **ガード**: `stage == .dead` なら即返却。`to <= from` なら即返却。`isPaused` なら `lastUpdateTime` のみ更新して返却
2. **最大キャッチアップ**: `from` を `to - maxCatchUpDuration(48時間)` でクランプ
3. **たまご孵化チェック**: `checkEggHatch`
4. **睡眠状態更新**: `updateSleepState`
5. **ステータス減衰**: `decayStats`
6. **うんち生成**: `generatePoop`
7. **お世話ミスチェック**: `checkCareMisses`
8. **病気チェック**: `checkSickness`
9. **死亡チェック**: `checkDeath`
10. **ステージ進化チェック**: `checkStageTransition`
11. **年齢更新**: `TimeManager.petAge` で計算

---

### お世話アクション

#### `feed(pet:at:) -> Pet`

```swift
static func feed(pet: Pet, at date: Date) -> Pet
```

ごはんを食べさせる。

| パラメータ | 型 | 説明 |
|---|---|---|
| `pet` | `Pet` | 現在のペット状態 |
| `date` | `Date` | 実行時刻 |
| **戻り値** | `Pet` | 更新後のペット状態 |

**ガード条件**: `stage != .egg`, `stage != .dead`, `!isSleeping` のいずれかに違反すると元のペットを返す。

**効果**: `stats.fed()` を適用 (おなか+1, たいじゅう+1)。おなかが0以上なら `hungerEmptySince` をクリア。

---

#### `snack(pet:at:) -> Pet`

```swift
static func snack(pet: Pet, at date: Date) -> Pet
```

おやつを食べさせる。

**ガード条件**: `feed` と同じ。

**効果**: `stats.snacked()` を適用 (ごきげん+1, たいじゅう+2)。ごきげんが0以上なら `happinessEmptySince` をクリア。

---

#### `clean(pet:at:) -> Pet`

```swift
static func clean(pet: Pet, at date: Date) -> Pet
```

トイレそうじ。

**ガード条件**: `poopCount > 0` でない場合は元のペットを返す。

**効果**: `poopCount` を0にリセット。

---

#### `giveMedicine(pet:at:) -> Pet`

```swift
static func giveMedicine(pet: Pet, at date: Date) -> Pet
```

くすりを投与する。

**ガード条件**: `isSick` でない場合は元のペットを返す。

**効果**: `medicineDosesNeeded` を1減算。0以下になったら `isSick = false`, `medicineDosesNeeded = 0`。治療には2回の投薬が必要(`GameConfig.medicineDosesRequired`)。

---

#### `discipline(pet:at:) -> Pet`

```swift
static func discipline(pet: Pet, at date: Date) -> Pet
```

しつけ。

**ガード条件**: `stage != .egg`, `stage != .dead`, `!isSleeping`。

**効果**: `discipline` を `+25`(`GameConfig.disciplineIncrement`)。上限は `100`(`GameConfig.disciplineMax`)。

---

#### `turnLightOff(pet:at:) -> Pet`

```swift
static func turnLightOff(pet: Pet, at date: Date) -> Pet
```

でんきを消す。

**ガード条件**: `isSleeping && !isLightOff` でない場合は元のペットを返す。

**効果**: `isLightOff = true`, `sleepWithoutLightSince = nil`(お世話ミスタイマーをクリア)。

---

#### `turnLightOn(pet:at:) -> Pet`

```swift
static func turnLightOn(pet: Pet, at date: Date) -> Pet
```

でんきをつける。

**ガード条件**: `isLightOff` でない場合は元のペットを返す。

**効果**: `isLightOff = false`。

---

#### `miniGameWon(pet:at:) -> Pet`

```swift
static func miniGameWon(pet: Pet, at date: Date) -> Pet
```

ミニゲーム勝利。

**効果**: `stats.playedAndWon()` を適用 (ごきげん+1, たいじゅう-1)。`ecoPoints += 50`(`GameConfig.miniGameWinPoints`)。ごきげんが0以上なら `happinessEmptySince` をクリア。

---

#### `miniGameLost(pet:at:) -> Pet`

```swift
static func miniGameLost(pet: Pet, at date: Date) -> Pet
```

ミニゲーム敗北。

**効果**: `ecoPoints += 10`(`GameConfig.miniGameLosePoints`)。ステータス変更なし。

---

#### `pause(pet:at:) -> Pet`

```swift
static func pause(pet: Pet, at date: Date) -> Pet
```

一時停止の開始。

**ガード条件**: 既にポーズ中、または `pauseMinutesUsedToday >= maxPauseMinutesPerDay(600分)` なら元のペットを返す。

**効果**: `isPaused = true`, `pauseStartDate = date`。

---

#### `unpause(pet:at:) -> Pet`

```swift
static func unpause(pet: Pet, at date: Date) -> Pet
```

一時停止の解除。

**ガード条件**: ポーズ中でない、または `pauseStartDate` が `nil` なら元のペットを返す。

**効果**: `isPaused = false`。ポーズ経過分数を `pauseMinutesUsedToday` に加算。`pauseStartDate = nil`。

---

#### `newGeneration(from:at:) -> Pet`

```swift
static func newGeneration(from pet: Pet, at date: Date) -> Pet
```

次世代のたまごを生成。

**効果**: `Pet.newEgg(generation: pet.generation + 1, at: date)` を返す。

---

### 内部ロジック (private)

#### `checkEggHatch(pet:from:to:) -> Pet`

たまごの孵化判定。`stageStartDate` から `LifeStage.egg.durationSeconds` (5分) 経過したら `.baby` に進化。`characterId` を `"baby_default"` に設定。

#### `updateSleepState(pet:at:) -> Pet`

`TimeManager.shouldBeSleeping` で睡眠判定。寝始めたら `isSleeping = true`, `sleepWithoutLightSince = date`。起きたら `isSleeping = false`, `isLightOff = false`, `sleepWithoutLightSince = nil`。

#### `decayStats(pet:elapsed:) -> Pet`

経過時間に基づくステータス減衰。睡眠中は減衰速度が0.5倍(`sleepDecayMultiplier`)。おなか減衰間隔70分、ごきげん減衰間隔50分。減衰発生時に `hungerEmptySince` / `happinessEmptySince` を記録。

#### `generatePoop(pet:from:to:) -> Pet`

ステージ毎のうんち間隔に基づいてうんちを生成。上限4個(`maxPoopCount`)。睡眠中は生成しない。

#### `checkCareMisses(pet:at:) -> Pet`

お世話ミスの判定。猶予時間は15分(`careMissGracePeriod`)。以下の3条件で `careMisses` と `careMissesInStage` をインクリメント:
- おなか0の猶予切れ
- ごきげん0の猶予切れ
- 消灯忘れの猶予切れ

#### `checkSickness(pet:at:) -> Pet`

うんち3個以上かつ最後のうんちから12分(`poopSicknessThreshold`)経過で `isSick = true`, `medicineDosesNeeded = 2`。

#### `checkDeath(pet:at:) -> Pet`

3つの死亡条件をチェック:
1. **餓死**: `hungerEmptySince` から12時間(`starvationDeathThreshold`)経過
2. **病死**: `isSick` かつ `lastUpdateTime` から18時間(`sicknessDeathThreshold`)経過
3. **老衰**: `hasReachedLifespan(at:)` が `true`

#### `checkStageTransition(pet:at:) -> Pet`

ステージの持続時間が経過したら次のステージに進化。`resolveCharacterId` でキャラクターIDを決定。

#### `resolveCharacterId(stage:careMissesInStage:discipline:) -> String`

お世話品質に基づくキャラクターID決定。4段階のティア:

| 条件 | ティア |
|---|---|
| ミス0-1 かつ しつけ75以上 | 1 |
| ミス0-2 | 2 |
| ミス3-5 | 3 |
| それ以外 | 4 |

戻り値フォーマット: `"{stage.rawValue}_tier{tier}"` (例: `"adult_tier1"`)

---

## GameManager

`@Observable` クラス。UIからのアクションを受け取り、`GameEngine` の純粋関数を呼び出し、副作用(永続化、Haptic)を実行する。

### ライフサイクル

#### `onActivate()`

```swift
func onActivate()
```

アプリがアクティブになった時に呼び出す。`store.loadAndCatchUp()` でペットを復元し、30秒間隔のタイマーを開始。

#### `onDeactivate()`

```swift
func onDeactivate()
```

アプリがバックグラウンドに行った時に呼び出す。ペットを保存し、タイマーを停止。

### お世話アクション

| メソッド | 内部呼び出し | Haptic |
|---|---|---|
| `feedMeal()` | `GameEngine.feed` | `.fed` |
| `feedSnack()` | `GameEngine.snack` | `.fed` |
| `clean()` | `GameEngine.clean` | `.cleaned` |
| `giveMedicine()` | `GameEngine.giveMedicine` | `.healed` |
| `discipline()` | `GameEngine.discipline` | `.disciplined` |
| `toggleLight()` | `GameEngine.turnLightOff` または `turnLightOn` | なし |
| `miniGameWon()` | `GameEngine.miniGameWon` | `.gameWon` |
| `miniGameLost()` | `GameEngine.miniGameLost` | `.gameLost` |
| `togglePause()` | `GameEngine.pause` または `unpause` | なし |
| `startNextGeneration()` | `store.addToHistory` + `GameEngine.newGeneration` | なし |

全メソッドは実行後に `store.savePet(pet)` で永続化する。

---

## PetStats

ペットのステータス値を管理する不変構造体。

### 定数

| 名前 | 型 | 値 | 説明 |
|---|---|---|---|
| `maxHearts` | `Int` | 4 | おなか/ごきげんの最大値 |
| `minWeight` | `Int` | 5 | たいじゅうの最小値 |
| `initial` | `PetStats` | `hunger: 4, happiness: 4, weight: 5` | 初期状態 |

### プロパティ

| 名前 | 型 | 説明 |
|---|---|---|
| `hunger` | `Int` | おなか (0-4) |
| `happiness` | `Int` | ごきげん (0-4) |
| `weight` | `Int` | たいじゅう (グラム) |
| `isHungerFull` | `Bool` | `hunger >= maxHearts` |
| `isHappinessFull` | `Bool` | `happiness >= maxHearts` |
| `isHungry` | `Bool` | `hunger <= 0` |
| `isUnhappy` | `Bool` | `happiness <= 0` |

### メソッド

#### `fed() -> PetStats`

ごはんを食べた結果を返す。`hunger + 1` (上限4), `weight + 1`。

#### `snacked() -> PetStats`

おやつを食べた結果を返す。`happiness + 1` (上限4), `weight + 2`。

#### `playedAndWon() -> PetStats`

ミニゲームに勝った結果を返す。`happiness + 1` (上限4), `weight - 1` (下限5)。

#### `hungerDecayed() -> PetStats`

おなかが1減った結果を返す。`hunger - 1` (下限0)。

#### `happinessDecayed() -> PetStats`

ごきげんが1減った結果を返す。`happiness - 1` (下限0)。

---

## TimeManager

リアルタイム時刻管理。ケースレス `enum` で全メソッドが `static`。

#### `shouldBeSleeping(stage:at:) -> Bool`

```swift
static func shouldBeSleeping(stage: LifeStage, at date: Date) -> Bool
```

指定時刻にペットが寝ているべきかを判定。`stage` が `.egg` または `.dead` の場合は常に `false`。就寝時刻と起床時刻は `LifeStage` の `bedtimeHour` と `wakeUpHour` から取得。日付をまたぐケース(例: 22時-8時)にも対応。

#### `nextWakeUpTime(stage:after:) -> Date`

```swift
static func nextWakeUpTime(stage: LifeStage, after date: Date) -> Date
```

次の起床時刻を算出。指定日の起床時刻が `date` より未来ならそれを返し、過去なら翌日の起床時刻を返す。

#### `nextBedtime(stage:after:) -> Date`

```swift
static func nextBedtime(stage: LifeStage, after date: Date) -> Date
```

次の就寝時刻を算出。ロジックは `nextWakeUpTime` と同様。

#### `petAge(birthDate:at:) -> Int`

```swift
static func petAge(birthDate: Date, at date: Date) -> Int
```

現在のペット年齢を計算。1ペット年 = 実時間24時間(`GameConfig.secondsPerPetYear`)。

---

## PetStore

UserDefaultsベースのペットデータ永続化。`final class`、`@unchecked Sendable`。

### イニシャライザ

```swift
init(defaults: UserDefaults = .standard)
```

テスト時にカスタム `UserDefaults` を注入可能。

### メソッド

#### `loadPet() -> Pet?`

現在のペットをUserDefaultsから読み込む。キー: `"ekocci_current_pet"`。存在しない場合は `nil`。

#### `savePet(_ pet: Pet)`

現在のペットをUserDefaultsに保存する。JSONエンコード。

#### `deletePet()`

現在のペットデータを削除する。

#### `loadHistory() -> [PetRecord]`

歴代ペットの履歴を読み込む。キー: `"ekocci_pet_history"`。存在しない場合は空配列。

#### `addToHistory(_ pet: Pet)`

死亡したペットを履歴に追加する。`PetRecord` に変換して保存。

#### `loadAndCatchUp(at:) -> Pet`

```swift
func loadAndCatchUp(at date: Date = .now) -> Pet
```

起動時にペットを読み込み、`GameEngine.advance` で経過時間分をキャッチアップ。ペットが存在しない場合は `Pet.newEgg()` で新規作成。

---

## 列挙型

### LifeStage

ペットのライフステージ。`String` rawValue、`Codable`, `CaseIterable`, `Sendable`。

| ケース | rawValue | 次のステージ | 持続時間 | 就寝 | 起床 | うんち間隔 | ゲーム可否 |
|---|---|---|---|---|---|---|---|
| `egg` | `"egg"` | `baby` | 5分 | - | - | なし | 不可 |
| `baby` | `"baby"` | `child` | 1時間 | 20時 | 9時 | 20分 | 不可 |
| `child` | `"child"` | `young` | 24時間 | 20時 | 9時 | 1時間 | 可 |
| `young` | `"young"` | `adult` | 3日 | 21時 | 9時 | 1.5時間 | 可 |
| `adult` | `"adult"` | `senior` | 寿命まで | 22時 | 8時 | 3時間 | 可 |
| `senior` | `"senior"` | `dead` | 寿命まで | 21時 | 8時 | 2時間 | 可 |
| `dead` | `"dead"` | nil | - | - | - | なし | 不可 |

#### プロパティ

- `durationSeconds: TimeInterval?` - 次のステージへの所要時間(秒)。`nil` は寿命 or 死亡で終了
- `next: LifeStage?` - 次のステージ(通常進化パス)
- `canPlayGames: Bool` - ミニゲームが可能か (`egg`, `baby`, `dead` は不可)
- `bedtimeHour: Int` - 就寝時刻(時)
- `wakeUpHour: Int` - 起床時刻(時)
- `poopIntervalSeconds: TimeInterval` - うんちの発生間隔(秒)

### CareAction

プレイヤーが実行できるお世話アクション。`String` rawValue、`Codable`, `CaseIterable`, `Sendable`。

| ケース | rawValue | 表示名 | アイコン (SF Symbols) |
|---|---|---|---|
| `feedMeal` | `"feedMeal"` | ごはん | `fork.knife` |
| `feedSnack` | `"feedSnack"` | おやつ | `birthday.cake` |
| `play` | `"play"` | あそぶ | `gamecontroller` |
| `clean` | `"clean"` | そうじ | `sparkles` |
| `medicine` | `"medicine"` | くすり | `cross.case` |
| `discipline` | `"discipline"` | しつけ | `hand.raised` |
| `lightOff` | `"lightOff"` | でんき けす | `lightbulb.slash` |
| `lightOn` | `"lightOn"` | でんき つける | `lightbulb` |

### HapticType

Hapticフィードバックの種類。`Sendable`。

| ケース | watchOS Haptic | 用途 |
|---|---|---|
| `fed` | `.click` | ごはんを食べた |
| `gameWon` | `.success` | ミニゲーム勝利 |
| `gameLost` | `.failure` | ミニゲーム敗北 |
| `disciplined` | `.directionUp` | しつけ成功 |
| `evolved` | `.notification` | 進化 |
| `died` | `.stop` | 死亡 |
| `notification` | `.notification` | 通知 |
| `cleaned` | `.click` | そうじ |
| `healed` | `.success` | 治療 |

### GameConfig

ゲームバランス定数(ケースレスenum、インスタンス化不可)。

| 定数名 | 型 | 値 | 説明 |
|---|---|---|---|
| `hungerDecayInterval` | `TimeInterval` | 4,200秒 (70分) | おなかが1減るまでの時間 |
| `happinessDecayInterval` | `TimeInterval` | 3,000秒 (50分) | ごきげんが1減るまでの時間 |
| `sleepDecayMultiplier` | `Double` | 0.5 | 睡眠中の減衰倍率 |
| `careMissGracePeriod` | `TimeInterval` | 900秒 (15分) | お世話ミスの猶予時間 |
| `poopSicknessThreshold` | `TimeInterval` | 720秒 (12分) | うんち放置で病気になるまでの時間 |
| `sicknessDeathThreshold` | `TimeInterval` | 64,800秒 (18時間) | 病気で死亡するまでの時間 |
| `medicineDosesRequired` | `Int` | 2 | 治療に必要な投薬回数 |
| `starvationDeathThreshold` | `TimeInterval` | 43,200秒 (12時間) | おなか0で死亡するまでの時間 |
| `disciplineIncrement` | `Int` | 25 | 1回のしつけで増加する量 |
| `disciplineMax` | `Int` | 100 | しつけの最大値 |
| `maxPauseMinutesPerDay` | `Int` | 600 (10時間) | 1日の最大一時停止時間(分) |
| `maxPoopCount` | `Int` | 4 | 画面上の最大うんち数 |
| `miniGameWinPoints` | `Int` | 50 | ミニゲーム勝利時のエコポイント |
| `miniGameLosePoints` | `Int` | 10 | ミニゲーム敗北時のエコポイント |
| `maxNotificationsPerDay` | `Int` | 3 | 1日の最大通知数 |
| `secondsPerPetYear` | `TimeInterval` | 86,400秒 (24時間) | 1ペット年の実時間 |
| `maxCatchUpDuration` | `TimeInterval` | 172,800秒 (48時間) | オフラインキャッチアップの最大時間 |

---

## Pet

ペットの全状態を保持する構造体。`Codable`, `Equatable`, `Identifiable`, `Sendable`。

### プロパティ

| 名前 | 型 | 説明 |
|---|---|---|
| `id` | `UUID` | 一意識別子 (let) |
| `stage` | `LifeStage` | 現在のライフステージ |
| `characterId` | `String` | キャラクター外見ID (例: `"adult_tier1"`) |
| `stats` | `PetStats` | おなか/ごきげん/たいじゅう |
| `discipline` | `Int` | しつけ度 (0, 25, 50, 75, 100) |
| `age` | `Int` | ペット年齢 (1 = 実時間24時間) |
| `generation` | `Int` | 世代番号 |
| `birthDate` | `Date` | 誕生日 |
| `stageStartDate` | `Date` | 現ステージ開始時刻 |
| `careMisses` | `Int` | 累計お世話ミス数 |
| `careMissesInStage` | `Int` | 現ステージ内のお世話ミス |
| `isSleeping` | `Bool` | 睡眠中か |
| `isLightOff` | `Bool` | 消灯しているか |
| `isSick` | `Bool` | 病気か |
| `medicineDosesNeeded` | `Int` | 治療に必要な残り投薬回数 |
| `poopCount` | `Int` | うんちの数 (0-4) |
| `lastPoopTime` | `Date?` | 最後のうんち発生時刻 |
| `isPaused` | `Bool` | 一時停止中か |
| `pauseMinutesUsedToday` | `Int` | 本日使用済みの一時停止時間(分) |
| `pauseStartDate` | `Date?` | 一時停止開始時刻 |
| `ecoPoints` | `Int` | エコポイント |
| `lastUpdateTime` | `Date` | 最後の状態更新時刻 |
| `hungerEmptySince` | `Date?` | おなか0になった時刻 |
| `happinessEmptySince` | `Date?` | ごきげん0になった時刻 |
| `sleepWithoutLightSince` | `Date?` | 消灯せずに寝始めた時刻 |

### 算出プロパティ

#### `maxLifespanSeconds: TimeInterval`

最大寿命(秒)。基本25日から `careMisses * 1日` を減算。最低7日。

#### `aliveSeconds(at:) -> TimeInterval`

指定時刻での生存時間(秒)。

#### `hasReachedLifespan(at:) -> Bool`

寿命に達したか。`stage` が `.adult` または `.senior` の場合のみ判定。

### ファクトリメソッド

#### `Pet.newEgg(generation:at:) -> Pet`

```swift
static func newEgg(generation: Int = 1, at date: Date = .now) -> Pet
```

新しいたまごを生成。全フィールドを初期値で設定。`ecoPoints` は `max(0, (generation - 1) * 100)` で前世代からの引き継ぎ。

---

## PetRecord

歴代ペットの記録。`Codable`, `Identifiable`, `Sendable`。

| プロパティ | 型 | 説明 |
|---|---|---|
| `id` | `UUID` | 一意識別子 |
| `characterId` | `String` | キャラクターID |
| `generation` | `Int` | 世代番号 |
| `age` | `Int` | 死亡時の年齢 |
| `birthDate` | `Date` | 誕生日 |
| `deathDate` | `Date` | 死亡日 |
