# (b) How comparable premium mobile platformers structure their first 10 minutes and their difficulty curve

Directive 2026-09-02b item 3(b). Pyregrove-scoped. Written 2026-09-02. Five
comparables, each observation tagged with **where it comes from** (reviewer,
developer interview, or database entry — read 2026-09-02) and the date of that
source. Where the source is a reviewer's experience, it is one player's report,
not a measurement; it says so. Pyregrove's side is read from the build
(`[BUILD]`, `assets/levels/*.txt`, `lib/game/difficulty.dart`) on `main`
@ alpha.22. Nothing here is from memory of having played these games.

## 1. The comparables

| Game | Why it is comparable | Platform read |
|---|---|---|
| **Apple Knight** (Limitless Games) | Direct genre twin: pixel-art action-platformer, worlds × levels, per-level difficulty pick. Pyregrove's design reference since 2026-07 (docs/ak-parity-plan.md) | Android/iOS, free w/ IAP — the exception on price |
| **Grimvalor** (Direlight) | Premium mobile-first action-platformer with a combat tutorial and an early boss | iOS/Android premium unlock |
| **Huntdown** (Easy Trigger / Coffee Stain) | Premium port; linear stage → boss structure; unlockable difficulty | iOS/Android premium |
| **Dead Cells** (Motion Twin / Playdigious) | Premium port; the "doesn't hold your hand" end of the curve | iOS/Android premium |
| **Celeste** (Maddy Makes Games) | Not mobile, included only for its **documented** teaching method (GDC 2017 talk by the designer) — the one primary developer source on platformer onboarding available | PC/console |

Leap Day (Nitrome) is cited once for its developer-stated retention design; it
is free-with-ads and not a structural comparable.

## 2. First 10 minutes — what each game does, and who says so

| Game | Observation | Source |
|---|---|---|
| Apple Knight | "a tutorial at the beginning of the game introduces you to the mechanics … After completing the small tutorial section, you get thrown into a new level immediately." Then: world select → level select → **difficulty picked per level** from Story / Casual / Hard / Ultra Hard. "Once you successfully complete the tutorial, the game modes will appear" (Story vs Endless). | gamerforfun.com review 2023-05-31 (reviewer); ldplayer.net beginner guide 2022-11-29 (guide) |
| Grimvalor | "When you start the game, you don't have to think too much about things. Hold the attack button or tap it to keep on swinging, and maybe dash if you see an attack coming." A first boss arrives early and **is optional**: "You don't have to take down that boss … The story will proceed either way. But you can actually win if you get used to dodging and attacking quickly enough." Separate reviewer (Switch build): "You learn mechanics as you need them, but you don't necessarily get punished for not being able to do them … culminates as you meet the boss because you get to practice all that you've learned." | toucharcade.com 2018-10-11 (reviewer, mobile); sequentialplanet.com 2020-04-10 (reviewer, Switch) |
| Huntdown | Linear: "Progression is linear, with new stages unlocked after each boss is defeated … Levels are designed to be short but intense … The central challenge of each mission is a boss encounter at the end of the stage." Hunter chosen at start ("players can select from three"). Mobile-specific friction is the auto-cover: "sometimes the game will just decide when to take cover for you". | mobygames.com entry (database, 2020-05-12); 148apps.com review 2021-06-16 (reviewer) |
| Dead Cells | Touch layout is **customizable** ("You can adjust button size and placement"), and the reviewer's verdict on the opening is "It doesn't hold your hand … Beginners might struggle with the touch controls initially / Steep learning curve." | mobilegaminginsider.com 2025-01-18 (reviewer) |
| Celeste | Designer, GDC 2017: levels are kept very short ("many fit on one screen") to avoid repetition; teaching is by placement, not text — the only text is the basic controls at the start; when a mechanic wasn't landing, the fix was adding **a two-level side section** whose only purpose was to teach it before the level that demanded it. Student case study of the first twenty minutes: "a short hop onto a ledge before the first pit, giving the player a place to safely learn the jump physics before any danger." | GDC 2017 "Level Design Workshop: Designing 'Celeste'", Matt Thorson — gdcvault.com/play/1024307 (session record); gamedeveloper.com 2017-02-24 workshop preview, speaker's own abstract: "teaching players implicitly with level design" (quote); talk detail via youtube.com/watch?v=4RlpMhBKNr0, Korean caption track read — the side-section and one-screen points are **paraphrase, not quote**; caseyjarmes.wordpress.com 2020-09-15 (student analysis) |

**Pattern across the five `[INFERENCE]`:** (1) a mechanic is shown in a safe
place before it is demanded; (2) the first real test is a **boss within the
first world**, and the softest games make failing it non-blocking (Grimvalor)
or shrink boss HP by difficulty (Apple Knight Story −50 %); (3) difficulty is
the player's choice, either per level (Apple Knight) or unlocked after a
clear (Huntdown: "additional difficulty options upon a first clear"); (4) the
premium ports say nothing about their model in-game — the "no ads" sentence
lives on the listing.

## 3. Difficulty curve — how they shape it

| Game | Curve mechanism | Source |
|---|---|---|
| Apple Knight | Four tiers, defined by checkpoints/lives/boss HP: Story = 2 checkpoints, unlimited lives, bosses −50 % HP; Casual = 2 checkpoints, 3 lives, bosses −20 %; Hard = no checkpoints, 1 life; Ultra Hard = Hard with one heart. "The level structure is pretty simple at the beginning … levels get more complex over time." 4 worlds × 10 levels at review time. | gamerforfun.com 2023-05-31 |
| Grimvalor | Curve is combat-pattern learning: "Combat largely comes down to learning enemy patterns, noting openings … Defense is also important, because if the bigger enemies connect with you, things will go south quickly." | toucharcade.com 2018-10-11 |
| Huntdown | Flat-then-optional: difficulty options unlock after first clear; score (time, kills, loot) is the replay curve. | 148apps.com 2021-06-16; mobygames.com |
| Dead Cells | Roguelite: the curve is run-to-run knowledge, not level order; reviewer: "Steep learning curve for some." | mobilegaminginsider.com 2025-01-18 |
| Leap Day | Retention, not difficulty: "How do I increase retention? … get people to come back every day" → one generated level per day from 700–800 hand-built chunks. | pocketgamer.biz interview with MD Matthew Annal, 2016-05-27 (developer) |

## 4. Pyregrove, measured from the build `[BUILD]`

**First 10 minutes.** Title → PLAY → level-select → Forest Edge: two taps, no
account. Tutorial is in-level signs (`s` glyphs), not a separate tutorial
stage. Difficulty is picked on the level-select screen (Easy / Medium / Hard),
Apple-Knight-style, and changes enemy speed ×0.85/1.0/1.2, telegraph
×1.35/1.0/0.7, aggro ×0.8/1.0/1.25, Easy +1 heart. Every stage has 2–3
campfire checkpoints (`K`); lives = 3 (`kStartingLives`). First enemy is a
Thornling within the first screen-widths (harness: ~6 s). Par times sum to
**790 s for world 1** including its boss — the first world *is* the first
~13 minutes at par, so "the first 10 minutes" ≈ Forest Edge → Charcoal Camp.

**Curve, world 1 → world 2** (widths in tiles, glyph counts):

| Level | par s | width | checkpoints | enemies (kinds) | hazards | hearts | coins |
|---|---|---|---|---|---|---|---|
| Forest Edge | 120 | 100 | 2 | 2 (T) | 6 | 0 | 17 |
| Old Orchard | 130 | 112 | 2 | 4 (T V) | 9 | 0 | 16 |
| Bramble Hollow | 140 | 118 | 2 | 7 (T V O N) | 13 | 0 | 11 |
| Charcoal Camp | 140 | 118 | 2 | 5 (T V R) | 9 | 1 | 10 |
| Rootway Ruins | 160 | 128 | 2 | 6 (T V O R) | 8 | 2 | 12 |
| Grove Golem | 150 | 52 | 1 | boss | 0 | 0 | 0 |
| Ashen Gate | 110 | 110 | 3 | 3 (S) | 5 | 0 | 19 |
| Ember Vault | 120 | 120 | 3 | 6 (S D H) | 3 | 0 | 15 |
| Soot Falls | 130 | 121 | 3 | 5 (S D H V) | 5 | 0 | 23 |
| Magma Gallery | 140 | 131 | 3 | 6 (S O D W) | 7 | 4 | 14 |
| Kiln Works | 150 | 134 | 3 | 8 (S D H O R W) | 3 | 0 | 16 |
| Kiln Golem | 150 | 56 | 1 | boss | 6 | 0 | 0 |

Read against the comparables:

- **Safe-space-then-test (Celeste):** present. One new enemy kind per level
  in world 1 (T → +V → +O,N → +R); world 2 resets to one kind (S) then adds
  one per level. Hazards peak at Bramble Hollow (13) then relax — matches
  the wipe-probe fix history (`5de8436`, `be55733`).
- **Early boss within the first world:** present (level 6), and the boss is
  **dormant until approached** (alpha.21), giving the Celeste-style safe
  moment. Unlike Grimvalor, failing it blocks progression; unlike Apple
  Knight, boss HP does **not** scale with difficulty — only speed/telegraph/
  wake range do (docs/release-justification-alpha21.md). Story-mode-style
  boss HP relief does not exist.
- **Difficulty as player choice per level:** present, three tiers. Apple
  Knight's tiers change *structure* (checkpoints, lives); Pyregrove's change
  *enemy tempo* (boss `maxHp` is a constant 150 on both golems, no
  difficulty term). Whether tempo-only tiers read as "easier" to a new player
  is unmeasured — the wipe probe uses bots, not people.
- **World-2 reset:** Ashen Gate is shorter at par (110 s) with fewer
  enemies than Rootway Ruins — a deliberate breather after the first boss,
  same shape Huntdown's "short but intense" stages describe.
- **What the comparables have that Pyregrove lacks:** Huntdown's
  post-clear difficulty unlock (a reason to replay); Dead Cells' adjustable
  touch layout (Pyregrove's HUD buttons are placed from screen insets in
  `ember_game.dart`; settings hold volume/mute/haptics/screen-shake only —
  no size or placement option); Apple Knight's tutorial *stage* (Pyregrove teaches
  in-level via signs — closer to Celeste's method, and untested with real
  first-time players).

## 5. What this does and does not say

It says Pyregrove's opening **shape** matches the genre's documented
practice: short first level, one new thing per level, an early dormant boss,
a breather after it. It does not say the opening *works* — every comparable
observation above is one reviewer's experience, and Pyregrove's side is level
geometry, not player behaviour. The unmeasured items are exactly the ones
only playtesting answers: whether tempo-only difficulty reads as easier, and
whether sign-based teaching lands without a tutorial stage. No feature
follows from this note under the standing order; the two candidate changes it
surfaces (boss HP by difficulty; post-clear difficulty unlock) are recorded
for the owner, not started.
