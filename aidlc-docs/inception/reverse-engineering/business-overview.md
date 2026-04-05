# ビジネスオーバービュー - ekocci (エコちっち)

## 1. ビジネスコンテキスト

### アプリ概要

ekocci (エコちっち) は、Apple Watch をメインプラットフォームとするバーチャルペット育成ゲームである。「たまごっち」の核となるゲームメカニクスをベースに、Apple Watch のハードウェア特性 (Digital Crown, Taptic Engine, コンプリケーション, 常時表示ディスプレイ) を活かしたネイティブ体験を提供する。

### コンセプト

1回のインタラクションは5〜15秒。手首をチラッと見て、サッとお世話して、すぐ日常に戻れる。

### ターゲットユーザー

- Apple Watch ユーザー (Series 7+, watchOS 26+)
- バーチャルペット育成に興味があるユーザー
- 短時間インタラクション型ゲームを好むユーザー

### プラットフォーム

| プラットフォーム | 役割 |
|----------------|------|
| watchOS (メイン) | ペット育成の全機能を提供 |
| iOS (コンパニオン) | 現状はプレースホルダー。将来的にステータス確認・家系図・図鑑等を提供予定 |

---

## 2. ビジネストランザクション (ユーザーアクション)

### 2.1 ごはん (Feed Meal)

- **トリガー**: ユーザーがメニューから「ごはん」を選択
- **前提条件**: ペットがたまご・死亡状態でない、寝ていない
- **効果**: おなか +1, たいじゅう +1g
- **Haptic**: `.click`

### 2.2 おやつ (Feed Snack)

- **トリガー**: ユーザーがメニューから「おやつ」を選択
- **前提条件**: ペットがたまご・死亡状態でない、寝ていない
- **効果**: ごきげん +1, たいじゅう +2g
- **Haptic**: `.click`

### 2.3 あそぶ (Play) - ミニゲーム

ミニゲーム選択画面から2種のゲームをプレイ可能。

#### 2.3.1 どっち? (Left or Right)

- **ルール**: ペットが左右どちらを向くかを当てる。5ラウンド中3勝で勝利
- **判定**: `Bool.random()` による完全ランダム
- **勝利時**: ごきげん +1, たいじゅう -1g, エコポイント +50
- **敗北時**: エコポイント +10

#### 2.3.2 おおきい? ちいさい? (High or Low)

- **ルール**: 次の数字 (1〜9) が現在より大きいか小さいかを当てる。5ラウンド中3勝で勝利
- **制約**: 同じ数字は連続しない
- **勝利時**: ごきげん +1, たいじゅう -1g, エコポイント +50
- **敗北時**: エコポイント +10

### 2.4 トイレそうじ (Clean)

- **トリガー**: うんちが1個以上ある場合にメニューに表示
- **効果**: うんちカウント = 0 (全除去)
- **Haptic**: `.click`

### 2.5 くすり (Medicine)

- **トリガー**: ペットが病気の場合にメニューに表示
- **効果**: 残り投薬回数 -1。0になると病気が完治
- **Haptic**: `.success`

### 2.6 しつけ (Discipline)

- **トリガー**: ユーザーがメニューから「しつけ」を選択
- **前提条件**: ペットがたまご・死亡状態でない、寝ていない
- **効果**: しつけメーター +25% (上限100%)
- **Haptic**: `.directionUp`

### 2.7 でんき操作 (Light Toggle)

- **トリガー**: ペットが寝ている場合にメニューに表示
- **効果**: 消灯/点灯の切り替え。消灯すると `sleepWithoutLightSince` がリセットされ、お世話ミスを防止

### 2.8 おあずけ (Pause / Unpause)

- **効果 (開始)**: 全パラメータ減少を停止
- **効果 (解除)**: 一時停止時間を記録し再開
- **制約**: 1日最大600分 (10時間)

### 2.9 つぎのたまご (Start Next Generation)

- **トリガー**: 死亡画面で「つぎのたまご」ボタンを押す
- **効果**: 現在のペットを履歴に記録し、世代 +1 の新しいたまごを生成
- **世代ボーナス**: 初期エコポイント = (世代 - 1) x 100

### 2.10 ステータス確認

- **トリガー**: メニューから「ステータス」を選択
- **表示内容**: ステージ名、年齢、世代、体重、おなか、ごきげん、しつけ、エコポイント、病気/おあずけ状態

---

## 3. ドメイン辞書

### ペット関連

| 用語 | 英語名 | 型/値 | 説明 |
|------|--------|------|------|
| ペット | Pet | `struct Pet` | ゲームの中心エンティティ。全状態を保持する |
| ライフステージ | LifeStage | `enum` | ペットの成長段階 (egg, baby, child, young, adult, senior, dead) |
| キャラクターID | characterId | `String` | ステージとティアから決定されるキャラクター識別子 (例: `child_tier1`) |
| 世代 | generation | `Int` | 何代目のペットか。死亡後に次世代が +1 で開始 |
| 年齢 | age | `Int` | ペット年齢。実時間24時間 = 1歳 |
| 誕生日 | birthDate | `Date` | ペットが生成された時刻 |

### ステータスパラメータ

| 用語 | 英語名 | 型/値 | 説明 |
|------|--------|------|------|
| おなか | hunger | `Int (0〜4)` | 空腹度。時間経過で減少。ごはんで回復 |
| ごきげん | happiness | `Int (0〜4)` | 機嫌。時間経過で減少。おやつ・あそぶで回復 |
| たいじゅう | weight | `Int (最低5)` | 体重 (グラム)。ごはん +1g, おやつ +2g, ミニゲーム勝利 -1g |
| しつけ | discipline | `Int (0/25/50/75/100)` | しつけ度。25%刻みで増加。進化先に影響 |
| エコポイント | ecoPoints | `Int` | ゲーム内通貨。ミニゲームで獲得 |

### 状態フラグ

| 用語 | 英語名 | 型 | 説明 |
|------|--------|---|------|
| 睡眠中 | isSleeping | `Bool` | 就寝時刻に基づき自動で設定 |
| 消灯 | isLightOff | `Bool` | 睡眠中にユーザーが消灯したか |
| 病気 | isSick | `Bool` | うんち放置等で発症 |
| 一時停止 | isPaused | `Bool` | おあずけモード |
| うんちカウント | poopCount | `Int (0〜4)` | 画面上のうんち数 |
| 投薬残回数 | medicineDosesNeeded | `Int` | 病気完治に必要な残り投薬回数 |

### お世話関連

| 用語 | 英語名 | 説明 |
|------|--------|------|
| お世話アクション | CareAction | ユーザーが実行可能な8種のアクション |
| お世話ミス | careMisses | 猶予時間内にお世話しなかった累計回数 |
| ステージ内ミス | careMissesInStage | 現ステージ内のお世話ミス数。進化先決定に使用 |
| 猶予時間 | careMissGracePeriod | お世話ミス判定までの猶予 (15分) |

### 時間関連

| 用語 | 英語名 | 説明 |
|------|--------|------|
| 就寝時刻 | bedtimeHour | ステージごとに異なる就寝時間 (20〜22時) |
| 起床時刻 | wakeUpHour | ステージごとに異なる起床時間 (8〜9時) |
| 1ペット年 | secondsPerPetYear | 実時間86,400秒 (24時間) |
| 最大キャッチアップ | maxCatchUpDuration | オフライン復帰時の最大巻き戻し (48時間) |

### 進化関連

| 用語 | 英語名 | 説明 |
|------|--------|------|
| ティア | tier | お世話品質に基づくキャラクターランク (1〜4) |
| 寿命 | maxLifespanSeconds | 基本25日 - (お世話ミス x 1日)。最低7日 |

### Haptic

| 用語 | 英語名 | 説明 |
|------|--------|------|
| Hapticタイプ | HapticType | 9種のフィードバック (fed, gameWon, gameLost, disciplined, evolved, died, notification, cleaned, healed) |

### 永続化

| 用語 | 英語名 | 説明 |
|------|--------|------|
| ペットストア | PetStore | UserDefaults ベースの永続化レイヤー |
| ペット記録 | PetRecord | 死亡したペットの履歴レコード (ID, キャラクターID, 世代, 年齢, 誕生日, 死亡日) |

---

## 4. ビジネスルール

### 4.1 ライフサイクルルール

| ID | ルール | ソースコード根拠 |
|----|--------|-----------------|
| LC-01 | たまごは5分後に自動的に孵化し、あかちゃんになる | `LifeStage.egg.durationSeconds = 5 * 60` |
| LC-02 | あかちゃんは1時間後にこどもに成長する | `LifeStage.baby.durationSeconds = 60 * 60` |
| LC-03 | こどもは24時間後にヤングに成長する | `LifeStage.child.durationSeconds = 24 * 60 * 60` |
| LC-04 | ヤングは3日後におとなに成長する | `LifeStage.young.durationSeconds = 3 * 24 * 60 * 60` |
| LC-05 | おとな・シニアは期間指定なし (寿命で管理) | `durationSeconds = nil` |
| LC-06 | 成長段階は egg -> baby -> child -> young -> adult -> senior -> dead の一方向 | `LifeStage.next` |

### 4.2 ステータス減衰ルール

| ID | ルール | ソースコード根拠 |
|----|--------|-----------------|
| SD-01 | おなかは70分ごとに1減少する | `GameConfig.hungerDecayInterval = 70 * 60` |
| SD-02 | ごきげんは50分ごとに1減少する | `GameConfig.happinessDecayInterval = 50 * 60` |
| SD-03 | 睡眠中の減衰速度は通常の50% (間隔が2倍) | `GameConfig.sleepDecayMultiplier = 0.5` |
| SD-04 | おなかの最大値は4、最小値は0 | `PetStats.maxHearts = 4` |
| SD-05 | ごきげんの最大値は4、最小値は0 | `PetStats.maxHearts = 4` |
| SD-06 | たいじゅうの最小値は5g | `PetStats.minWeight = 5` |

### 4.3 お世話ルール

| ID | ルール | ソースコード根拠 |
|----|--------|-----------------|
| CA-01 | ごはん: おなか +1, たいじゅう +1g | `PetStats.fed()` |
| CA-02 | おやつ: ごきげん +1, たいじゅう +2g | `PetStats.snacked()` |
| CA-03 | ミニゲーム勝利: ごきげん +1, たいじゅう -1g | `PetStats.playedAndWon()` |
| CA-04 | しつけは1回25%ずつ増加、上限100% | `GameConfig.disciplineIncrement = 25, disciplineMax = 100` |
| CA-05 | 寝ているペットにはごはん・おやつ・しつけ不可 | `GameEngine.feed/snack/discipline` の `!pet.isSleeping` ガード |
| CA-06 | たまご・死亡状態ではお世話不可 | 各アクションの `pet.stage != .egg, .dead` ガード |
| CA-07 | ミニゲームはこども以降のみプレイ可能 | `LifeStage.canPlayGames` (egg, baby, dead は false) |
| CA-08 | そうじは全うんちを一度に除去する | `GameEngine.clean` で `poopCount = 0` |
| CA-09 | 治療には2回の投薬が必要 | `GameConfig.medicineDosesRequired = 2` |
| CA-10 | 消灯は寝ている時のみ可能 | `GameEngine.turnLightOff` の `pet.isSleeping` ガード |

### 4.4 うんちルール

| ID | ルール | ソースコード根拠 |
|----|--------|-----------------|
| PO-01 | うんちの発生間隔はステージにより異なる (baby: 20分, child: 1時間, young: 1.5時間, adult: 3時間, senior: 2時間) | `LifeStage.poopIntervalSeconds` |
| PO-02 | 画面上の最大うんち数は4個 | `GameConfig.maxPoopCount = 4` |
| PO-03 | 睡眠中はうんちが発生しない | `GameEngine.generatePoop` の `!pet.isSleeping` ガード |
| PO-04 | うんち3個以上で12分経過すると病気になる | `GameEngine.checkSickness`: `poopCount >= 3` かつ `poopSicknessThreshold = 12 * 60` |

### 4.5 お世話ミスルール

| ID | ルール | ソースコード根拠 |
|----|--------|-----------------|
| CM-01 | おなか0の状態が15分継続するとお世話ミス +1 | `GameEngine.checkCareMisses` + `careMissGracePeriod = 15 * 60` |
| CM-02 | ごきげん0の状態が15分継続するとお世話ミス +1 | 同上 |
| CM-03 | 就寝後15分以内に消灯しないとお世話ミス +1 | `sleepWithoutLightSince` チェック |
| CM-04 | お世話ミスは猶予切れ後、次の猶予期間が即座に開始される (繰り返しカウント) | `hungerEmptySince = date` で再設定 |

### 4.6 死亡ルール

| ID | ルール | ソースコード根拠 |
|----|--------|-----------------|
| DT-01 | おなか0が12時間継続すると餓死 | `GameConfig.starvationDeathThreshold = 12 * 60 * 60` |
| DT-02 | 病気が18時間継続すると病死 | `GameConfig.sicknessDeathThreshold = 18 * 60 * 60` |
| DT-03 | 生存時間が寿命に達すると老衰 (おとな・シニアのみ) | `Pet.hasReachedLifespan` |
| DT-04 | 寿命 = 25日 - (お世話ミス数 x 1日)、最低7日 | `Pet.maxLifespanSeconds` |
| DT-05 | 死亡するとステージが `.dead` になり、全操作不可 | `GameEngine.advance` の冒頭ガード |

### 4.7 進化ルール

| ID | ルール | ソースコード根拠 |
|----|--------|-----------------|
| EV-01 | ステージ移行時にキャラクターIDがティアに基づき決定される | `GameEngine.resolveCharacterId` |
| EV-02 | Tier 1: ステージ内ミス 0〜1 かつ しつけ 75%以上 | `case 0...1 where discipline >= 75` |
| EV-03 | Tier 2: ステージ内ミス 0〜2 | `case 0...2` |
| EV-04 | Tier 3: ステージ内ミス 3〜5 | `case 3...5` |
| EV-05 | Tier 4: ステージ内ミス 6以上 | `default` |
| EV-06 | ステージ移行後、ステージ内ミスカウントはリセットされる | `result.careMissesInStage = 0` |

### 4.8 睡眠ルール

| ID | ルール | ソースコード根拠 |
|----|--------|-----------------|
| SL-01 | あかちゃん・こども: 20時就寝, 9時起床 | `LifeStage.bedtimeHour / wakeUpHour` |
| SL-02 | ヤング・シニア: 21時就寝, 9時/8時起床 | 同上 |
| SL-03 | おとな: 22時就寝, 8時起床 | 同上 |
| SL-04 | たまご・死亡状態では睡眠しない | `TimeManager.shouldBeSleeping` のガード |
| SL-05 | 起床時に消灯状態が自動リセットされる | `updateSleepState` で `isLightOff = false` |

### 4.9 一時停止ルール

| ID | ルール | ソースコード根拠 |
|----|--------|-----------------|
| PA-01 | 一時停止中は全パラメータの減少が停止する | `GameEngine.advance` の `!pet.isPaused` ガード |
| PA-02 | 1日最大600分 (10時間) まで | `GameConfig.maxPauseMinutesPerDay = 600` |
| PA-03 | 上限に達すると一時停止の開始不可 | `GameEngine.pause` のガード |

### 4.10 世代ルール

| ID | ルール | ソースコード根拠 |
|----|--------|-----------------|
| GN-01 | 次世代は前世代 +1 | `GameEngine.newGeneration`: `pet.generation + 1` |
| GN-02 | 初期エコポイント = (世代 - 1) x 100 | `Pet.newEgg`: `max(0, (generation - 1) * 100)` |
| GN-03 | 死亡したペットは PetRecord として履歴に保存される | `PetStore.addToHistory` |

### 4.11 ミニゲームルール

| ID | ルール | ソースコード根拠 |
|----|--------|-----------------|
| MG-01 | 全ミニゲームは5ラウンド制、3勝で勝利 | `totalRounds = 5, winsNeeded = 3` |
| MG-02 | 勝利時エコポイント +50 | `GameConfig.miniGameWinPoints = 50` |
| MG-03 | 敗北時エコポイント +10 | `GameConfig.miniGameLosePoints = 10` |

### 4.12 時間管理ルール

| ID | ルール | ソースコード根拠 |
|----|--------|-----------------|
| TM-01 | オフライン復帰時の最大キャッチアップは48時間 | `GameConfig.maxCatchUpDuration = 48 * 60 * 60` |
| TM-02 | ゲームエンジンは30秒ごとにtickする | `GameManager.startTimer` の `withTimeInterval: 30` |
| TM-03 | アプリ起動時に `loadAndCatchUp` で経過時間分を一括シミュレーション | `PetStore.loadAndCatchUp` |
