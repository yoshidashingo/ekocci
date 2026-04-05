---
layout: default
title: "Game Guide"
description: "How to play ekocci. Learn about care actions, mini games, and status management."
lang: en
---

<h1>📖 Game Guide</h1>

<div class="pixel-divider"></div>

<div class="section">

## Main Screen

When you launch the app, your pet appears on screen. The status bar is at the top, and poop icons (if any) appear at the bottom.

<div class="screenshot-container">
  <img src="{{ '/assets/images/screenshots/main-pet.svg' | relative_url }}" alt="Main Screen">
  <p class="caption">Main Screen</p>
</div>

Tap to open the menu and choose a care action.

</div>

<div class="section">

## Care Actions

### 🍙 Feeding

Two types of food to fill your pet's hunger.

| Type | Effect | Side Effect |
|------|--------|-------------|
| Meal | Hunger +1 | Weight +1g |
| Snack | Happiness +1 | Weight +2g |

Too many snacks cause obesity, which negatively affects evolution.

### 💩 Cleaning

Your pet poops regularly. When the icon appears on screen, use the clean action to remove it. Leaving it too long increases the risk of illness.

### 💊 Medicine

When your pet gets sick, a skull icon appears. Administer medicine 1-3 times to cure it. If left untreated, your pet will die within hours.

### 📏 Discipline

The core mechanic of the game.

**When to discipline:**
- Pet is calling but hunger and happiness are NOT empty (being spoiled)
- Pet refuses food (being naughty)

**When NOT to discipline:**
- When actually hungry
- When sick
- When sleeping

Each correct discipline gives **+25% to the discipline meter**. 100% leads to the best evolution!

### 💡 Lights

When your pet falls asleep, ZZZ appears. You must turn off the lights within 15 minutes or it counts as a care miss.

</div>

<div class="section">

## Mini Games

Available from the Child stage onward. Three games to restore happiness and reduce weight.

<div class="screenshot-row">
  <div class="screenshot-container">
    <img src="{{ '/assets/images/screenshots/game-left-right.svg' | relative_url }}" alt="Left or Right?">
    <p class="caption">Left or Right?</p>
  </div>
  <div class="screenshot-container">
    <img src="{{ '/assets/images/screenshots/game-high-low.svg' | relative_url }}" alt="High or Low?">
    <p class="caption">High or Low?</p>
  </div>
  <div class="screenshot-container">
    <img src="{{ '/assets/images/screenshots/game-jump.svg' | relative_url }}" alt="Jump!">
    <p class="caption">Jump!</p>
  </div>
</div>

### Left or Right?
Guess which way your pet will turn. Win 3 out of 5 rounds.

### High or Low?
Guess if the next number is higher or lower. Win 3 out of 5 rounds.

### Jump!
Tap to jump over obstacles with good timing. Earn Eco Points too!

</div>

<div class="section">

## Status

<div class="screenshot-container">
  <img src="{{ '/assets/images/screenshots/stats.svg' | relative_url }}" alt="Status Screen">
  <p class="caption">Status Screen</p>
</div>

| Parameter | Display | Description |
|-----------|---------|-------------|
| Hunger | ♥♥♥♥ | Decreases over time. Restored by feeding |
| Happiness | ♥♥♥♥ | Decreases over time. Restored by playing or snacks |
| Weight | Grams | Increases with food. Decreases with mini games |
| Discipline | 0-100% | +25% per correct discipline |

</div>

<div class="section">

## Sleep Schedule

Sleep times vary by growth stage.

| Stage | Bedtime | Wake Up | Sleep Duration |
|-------|---------|---------|----------------|
| Baby | 20:00 | 09:00 | ~13 hours |
| Child | 20:00-21:00 | 09:00-10:00 | ~12 hours |
| Teen | 21:00-22:00 | 09:00-10:00 | ~11 hours |
| Adult | 22:00-23:00 | 08:00-09:00 | ~10 hours |

During sleep, no poop is produced and status decay rate drops to ~50%.

</div>

<div class="section">

## Alerts & Grace Period

Your pet will notify you when it needs care. You have **about 15 minutes** to respond before it counts as a care miss.

| Trigger | Response |
|---------|----------|
| Hungry | Feed your pet |
| Unhappy | Play or give snack |
| Sick | Give medicine |
| Poop | Clean up |
| Bedtime | Turn off lights |
| Spoiled | Discipline |

</div>

<div class="section">

## Pause Mode

You can pause your pet when you can't provide care.

- All parameter decay stops while paused
- Maximum 10 hours per day
- Battery death also freezes parameters (battery death ≠ pet death)

</div>
