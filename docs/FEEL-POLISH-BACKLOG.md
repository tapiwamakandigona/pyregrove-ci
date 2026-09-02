# Feel & animation polish backlog — researched critique of the current stack

Written 2026-09-01 under the post-alpha.21 freeze. **Nothing here is
implemented**; this is the ready-made polish list for the day the freeze
lifts, per the standing "research animations / how games can be improved"
directive. Sources read 2026-09-01: Vlambeer "Art of Screenshake" 31-trick
list (designoriented.net writeup); GMTK Celeste feel analysis; Dead Cells
weight-ratio analysis (suitablyflip.com); 2D attack anatomy (charios.com);
pixel-anim frame-count norms (sprite-ai.art); Jonasson/Purho "Juice it or
lose it". Code facts below verified by reading the repo at 86b5c17a.

## A. What we already have (VERIFIED in code — don't re-add)

| Technique | Where | Notes |
|---|---|---|
| Coyote time 0.10s, jump buffer 0.12s, attack buffer 0.15s | tuning.dart | matches genre norms |
| Variable jump (cut 0.45) + apex hang (0.55 grav, hang 40) | tuning.dart | the Celeste "beat of hang" |
| Camera lerp + look-ahead + peek-down | ember_game.dart:778–808 | Vlambeer #13/#14; exp smoothing |
| Hit pause on melee connect | kHitPause 0.040s, session.dart:533 | Vlambeer #17 "sleep" |
| Enemy hurt flash + render-only recoil ≤3px | 5efc3d06 | Vlambeer #10/#11 |
| Screen shake **with accessibility toggle** | f8b4c44 | Nuclear Throne lesson pre-applied |
| Takeoff stretch, landing thud, run dust | caa7fb12/216ca640/3f568099 | squash/stretch + Celeste dust |
| Pitch-wobbled SFX (rate 0.94–1.06, overlap per id) | audio_service.dart | no two hits identical |
| Swing-arc combo overlay, per-weapon tint/range, alternating sweep | player_component.dart:238+ | reads as a 3-beat phrase |
| Haptics on impacts | shipped | Celeste rumble equivalent |
| Parallax backdrop (4 layers) | parallax_bg.dart | depth |

Honest assessment: the foundation layer (control feel + basic juice) is
genuinely complete. What's missing is the **differentiation layer** — making
different actions feel *different in weight*, not just present.

## B. Backlog — prioritized, each item small and testable

### B1. Tiered hitstop (highest feel-per-line-of-code)
Today every melee connect freezes a flat 40 ms. Research consensus: hitstop
should scale with impact meaning. Proposal (all in tuning.dart):
- normal connect 0.035s · **kill blow 0.070s** · boss phase-change 0.100s.
- Keep a hard cap; hitstop above ~120 ms reads as lag, not weight.
Test: extend swing/kill scenario in an existing headless test; assert pause
values by event kind. Cost: ~10 lines + test. CPU-free (it's a timer).

### B2. Per-weapon swing weight (Dead Cells ratio)
VERIFIED gap: all six weapons share one swing timing; wind_gods_hammer
(9 dmg) swings exactly like squire_blade (3 dmg). Dead Cells sells mass by
the **anticipation:strike:recovery ratio** (dagger ≈ 2:2:4 frames,
broadsword ≈ 12:3:5 — most of a heavy swing is wind-up, the strike itself
stays fast). Proposal: add `swingProfile` (windupMul, recoverMul) to the
weapon catalog; light 0.8/0.9, medium 1.0/1.0, hammer 1.5/1.2 with
slightly longer arc + wider stroke. Damage already differs; timing should
agree with it. Test: boss_intent/TTK combos must stay green (retune par_s
if hammer DPS shifts).

### B3. Smear frames on the swing arc (render-only)
VERIFIED gap: no smears anywhere. At 352×198 a 1–2-frame smear (stretched
white-tinted crescent, thicker stroke, 60% opacity) on the fastest part of
the swing is the standard pixel-art trick for selling speed without more
sprite frames. We already draw the arc procedurally — a smear is one extra
arc draw at `progress-0.08` with decayed alpha. Cost: ~15 lines, zero
assets, zero memory.

### B4. Kill permanence (Vlambeer #12 — CHECK first)
CHECK when freeze lifts: do defeated enemies leave anything behind, or
vanish with the FX pop? If they vanish, add a cheap static corpse/ash decal
(one sprite, despawn after 8–10 s or cap N=8 per level, oldest-first) so a
cleared room *looks* cleared. Guard: must stay within the 2 GB-device
budget — static sprites only, no per-corpse animation.

### B5. Escalating pickup pitch (coin chains)
We wobble coin pitch randomly; the researched trick is a **rising** pitch
chain (each coin within ~1.5 s of the last plays a semitone-ish higher,
resets after a gap) — turns a coin run into a little arpeggio. Cost: ~12
lines in AudioService (chain counter + decay timer feeding sfxRateFor's
unit). Distinct from, and composable with, the existing wobble.

### B6. Attack anticipation trails physics, never leads it
Rule to *preserve* (currently true — input fires the hitbox on press, the
arc's wind-up is cosmetic): anticipation frames must never delay the
mechanical attack. When B2 adds longer heavy wind-ups, the hitbox timing
may lag the press for heavies — that's a deliberate weight tradeoff, but
light weapons must keep press==hit. Write this into the B2 test.

### B7. Landing recovery frames — DONE 2026-09-01 (jump slice of directive 2026-09-01d; deep 25%/160ms cosmetic crouch on landedHard, no input lock)
Genre norm: 4–8 frames of visible recovery on hard landings; too long
feels unresponsive. We have kHardLandTiles=4 + thud; CHECK whether a
2-frame crouch sprite on hard landing (cosmetic only, no input lock —
Celeste rule) reads better than the current dust-only landing.

## C. Explicitly rejected (with reasons)

- **More/stronger screen shake** — current level + toggle is right; nausea
  reports are the documented failure mode.
- **Input-locking anticipation** (charios-style 3–8 frame pre-attack
  delay on light weapons) — kills the responsiveness we tuned; weight
  belongs on heavies only (B2).
- **Motion-blur shaders** — Impeller is off and pillar 3 says 2 GB
  devices; procedural smears (B3) give the read at zero GPU cost.
- **Vlambeer tricks that don't map**: muzzle flash / bullet spread /
  bigger bullets — gun-game idioms; apples already have arc+impact FX.

Order of attack when freeze lifts: B1 → B3 → B5 (pure feel, near-zero
risk) then B2 (+B6 rule) → B4 → B7 (need balance/QA passes).
