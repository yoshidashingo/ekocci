---
layout: default
title: "遊び方ガイド"
description: "エコちっちの遊び方。お世話の仕方、ミニゲーム、ステータスの見方を解説。"
lang: ja
---

<h1>📖 遊び方ガイド</h1>

<div class="pixel-divider"></div>

<div class="section" markdown="1">

## メイン画面

アプリを起動すると、ペットが表示されます。画面上部にはステータスバー、画面下部にうんちアイコン（ある場合）が表示されます。

<div class="screenshot-container">
  <img src="{{ '/assets/images/screenshots/main-pet.svg' | relative_url }}" alt="メイン画面">
  <p class="caption">メイン画面</p>
</div>

タップするとメニューが開き、お世話アクションを選べます。

</div>

<div class="section" markdown="1">

## お世話

### 🍙 ごはん

2種類の食事でペットのおなかを満たします。

| 種類 | 効果 | 副作用 |
|------|------|--------|
| ごはん (Meal) | おなか +1 | たいじゅう +1g |
| おやつ (Snack) | ごきげん +1 | たいじゅう +2g |

おやつの与えすぎは肥満の原因に。進化にも悪影響です。

### 💩 トイレそうじ

ペットは定期的にうんちをします。画面上にアイコンが出現したら、そうじアクションで除去しましょう。放置すると病気のリスクが上がります。

### 💊 くすり

ペットが病気になるとドクロアイコンが表示されます。くすりアクションで1〜3回投与して治療。放置すると数時間で死亡します。

### 📏 しつけ

ゲームの核心メカニクスです。

**しつけるべきタイミング:**
- ペットが呼んでいるが、おなか・ごきげん共に空ではない（わがまま）
- ごはんを拒否する（いたずら）

**しつけてはいけないタイミング:**
- 本当におなかが空のとき
- 病気のとき
- 寝ているとき

正しいしつけ1回で **しつけメーター +25%**。100%で最良の進化先に！

### 💡 でんき

ペットが寝ると ZZZ が表示されます。15分以内に消灯しないとお世話ミスにカウントされます。

</div>

<div class="section" markdown="1">

## ミニゲーム

こども以上の段階で遊べる3種類のミニゲーム。ごきげん回復 & たいじゅう減少に。

<div class="screenshot-row">
  <div class="screenshot-container">
    <img src="{{ '/assets/images/screenshots/game-left-right.svg' | relative_url }}" alt="どっち？">
    <p class="caption">どっち？</p>
  </div>
  <div class="screenshot-container">
    <img src="{{ '/assets/images/screenshots/game-high-low.svg' | relative_url }}" alt="おおきい？ちいさい？">
    <p class="caption">おおきい？ちいさい？</p>
  </div>
  <div class="screenshot-container">
    <img src="{{ '/assets/images/screenshots/game-jump.svg' | relative_url }}" alt="ジャンプ！">
    <p class="caption">ジャンプ！</p>
  </div>
</div>

### どっち？ (Left or Right)
ペットがどちらを向くか当てるゲーム。5回中3回正解で勝ち。

### おおきい？ちいさい？ (High or Low)
次の数字が大きいか小さいか当てるゲーム。5回中3回正解で勝ち。

### ジャンプ！ (Jump)
障害物をタイミングよくタップで避けるゲーム。エコポイントも獲得できます。

</div>

<div class="section" markdown="1">

## ステータス

<div class="screenshot-container">
  <img src="{{ '/assets/images/screenshots/stats.svg' | relative_url }}" alt="ステータス画面">
  <p class="caption">ステータス画面</p>
</div>

| パラメータ | 表示 | 説明 |
|-----------|------|------|
| おなか | ♥♥♥♥ | 時間で減少。ごはんで回復 |
| ごきげん | ♥♥♥♥ | 時間で減少。遊びやおやつで回復 |
| たいじゅう | グラム | ごはん・おやつで増加。ミニゲームで減少 |
| しつけ | 0〜100% | 正しくしつけると+25% |

</div>

<div class="section" markdown="1">

## 睡眠スケジュール

成長段階によって就寝・起床時間が異なります。

| 段階 | 就寝 | 起床 | 睡眠時間 |
|------|------|------|---------|
| あかちゃん | 20:00 | 09:00 | 約13時間 |
| こども | 20:00〜21:00 | 09:00〜10:00 | 約12時間 |
| ヤング | 21:00〜22:00 | 09:00〜10:00 | 約11時間 |
| おとな | 22:00〜23:00 | 08:00〜09:00 | 約10時間 |

睡眠中はうんちが出ず、ステータス減少速度が約50%に低下します。

</div>

<div class="section" markdown="1">

## 呼び出しと猶予時間

ペットがお世話を求めると通知が届きます。呼び出しから **約15分以内** に対応しないとお世話ミスがカウントされます。

| トリガー | 対応 |
|---------|------|
| おなかが空 | ごはんを与える |
| ごきげんが空 | 遊ぶ or おやつ |
| 病気 | くすりを与える |
| うんち | トイレそうじ |
| 就寝 | でんきを消す |
| わがまま | しつけ |

</div>

<div class="section" markdown="1">

## おやすみモード

お世話できない時間帯にペットを「おあずけ」できます。

- おあずけ中はすべてのパラメータ減少が停止
- 1日最大10時間まで
- バッテリー切れ中もパラメータは凍結（バッテリー切れ = 死亡にはなりません）

</div>
