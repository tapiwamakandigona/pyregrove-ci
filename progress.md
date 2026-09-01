# progress.md — append-only log (one dated block per completed task, decision, or gate)

> **Compacted 2026-07-25 (owner-directed cleanup).** The old 559-line log spent
> most of its length on the archived dice-builder era and on already-fixed bugs.
> Full detail is preserved in this file's git history
> (`git log --follow -p -- progress.md`), in `checkpoints/`, and on
> `legacy/dice-builder`. Keep NEW entries short: what shipped, evidence, open items.

## Era 1 — dice-builder roguelite (2026-07-23 → 2026-07-24, ARCHIVED)

Emberdelve v1 was a turn-based dice-builder (Defold/Lua → pivoted to
Flutter/Dart with proven sim parity). Shipped through v0.3.9+12 to Google Play
closed testing. Archived intact: branch `legacy/dice-builder`, tag
`v0.3.10-legacy`, release "Emberdelve Classic". Dice-era docs: `docs/legacy/`;
dice-era checkpoints: `docs/legacy/checkpoints/`. **Do not build against it.**

Durable facts that still matter:
- **Play closed testing is LIVE** on release 12 (v0.3.9+12), 177 countries,
  package `com.tsorostudios.emberdelve`. Production gate: 12+ opted-in testers
  for 14 continuous days (met 2026-07-24 → earliest apply ~2026-08-07; a dip
  below 12 resets the clock). App updates and listing edits do NOT reset it.
  Testers get no update notification; Play auto-updates (~24h).
- **PUBLIC PROMISE to testers: an in-game tutorial ships "in the next
  update"** — release blocker for the first pivot release to Play.
- Upload keystore + cert are permanent; CI verifies
  `EXPECTED_CERT_SHA256 = 031acb42…7a0d`. Never regenerate; never change.
- Fine-grained-PAT pushes DO trigger CI (an early claim to the contrary was
  corrected). GitHub Pages serves `main:/docs` — everything under `docs/` is a
  public web page; the hosted privacy policy URL lives in `docs/store/` and
  must not move.
- Tester group: emberdelve@googlegroups.com; store/testing links in
  `docs/store/play-listing.md`.

## Era 2 — action platformer pivot (2026-07-24 → , CURRENT)

2026-07-24 **PIVOT (owner-directed):** Apple-Knight-style 2D action
platformer, Flutter + Flame. Spec `docs/spec.md`, architecture
`docs/architecture.md`. Kept: CI+signing, package id, audio service, seeded
RNG, atomic saves. Standing rule: **push at every milestone** (a prior agent's
unpushed pivot attempt was lost).

2026-07-24/25 **M1–M5 built** (headless-first): tuning in
`lib/game/tuning.dart`; LevelSession headless runtime; physics with
coyote/buffer/variable jump/double jump; 3-hit combo; enemies (Thornling,
Ashbat, Hopper, Ember Totem, Rotshield) + Grove Golem boss (3 telegraphed
phases); ASCII levels `assets/levels/` (legend frozen in
`lib/game/level/level_data.dart` — only ADD); shop/skins/abilities meta;
World 1 "Emberwood" 5 levels + boss with runner-bot completability tests.

2026-07-25 **v1.0.0-alpha.1 → alpha.3 released** (GitHub prereleases, signed
APK+AAB, CI green each time). alpha.1/alpha.2 shipped with touch controls
dead on devices; two root causes found and fixed in alpha.3 (99d0131):
(1) Flame gesture dispatchers must be registered at EmberGame construction —
component-mount registration never attaches in release builds; (2) never hide
a tappable component with `scale=0` — it swallows every tap; gate
`containsLocalPoint` on visibility. Regression: `test/hud_routing_test.dart`.
Verified via the **web test harness** (`lib/main_webtest.dart` +
`docs/web_testing.md` — build web with `-t lib/main_webtest.dart`, telemetry
on `window.__emberdelve`). Harness exists because sandboxes have no KVM for
Android emulation.

2026-07-25 **M8 shipped:** perfect-clear bonus (+25 coins for 3-medal runs)
and Daily Delve (pure date→seed remix of w1_l2..l5, no streaks/FOMO per spec
§7 Ethics). **M9 shipped:** World 2 "Cinder Depths" (5 levels + Kiln Golem,
Soot Creeper + Cinder Diver, cave tileset, two-world level select). Also on
main since alpha.3: roll verb (DOWN+JUMP commit-dodge with i-frames),
footsteps, turnaround assist + ceiling corner-correction, zero-alloc render
layer, sim benchmark, frame-time overlay, W1 decor + juice + layout pass.
**None of this is in any published release yet.**

2026-07-25 **M7 gate (perf) honest status:** headless side done (zero
per-frame allocations in sim+render, benchmark green at `docs/perf.md`);
**measured 60fps + cold start on a 2GB device STILL OPEN — needs a physical
phone.** Release notes must carry this caveat until closed.

2026-07-25 **Owner playtest review of alpha.3** (browser harness, evidence in
`docs/playtest-2026-07-25-alpha3.md`): controls — multi-touch lift desync +
~150ms touch-vs-keyboard latency gap (VERIFIED); level design — w1_l1 spike
pit kills a walk-right player in <3s, hazard pits are inescapable death traps
(32px pit vs 34px jump + knockback juggle), every W1 level has lethal
pressure at spawn (VERIFIED); perf — locked 60fps on web/desktop, device
numbers still open. Recommended: cut alpha.4 from main, W1 safety pass,
multi-finger regression test, on-device overlay numbers.

2026-07-25 **Repo cleanup (owner-directed, this commit):** progress.md
compacted (full text in git history); dice-era checkpoints moved to
`docs/legacy/checkpoints/`; 32 fully-merged/superseded remote branches
deleted (all were ancestors of `main`, `legacy/dice-builder`, or open-PR
branch `feat/content-depth`); kept: `main`, `legacy/dice-builder`, open-PR
heads (`feat/content-depth` #54, `feat/telemetry-v2` #47, `telemetry-phase1`
#27), and unique unmerged work (`plan/legacy-feel`, `feat/combat-weapons-juice`,
`flutter`).

## 2026-07-25 — Original-asset pass 1: zero required attributions (feat/original-assets)
- Owner ask: can we make our own audio/music/graphics that closely replicate the
  originals without violating copyright, so no credits are ever *required* — research
  it, then do it. Research doc: docs/original-assets.md (mechanics/style free;
  assets/characters/melodies protected; CC-BY attribution non-waivable -> replace;
  no-AI-asset rule kept because purely AI-generated work isn't copyrightable, USCO 2023/2025).
- Replaced ALL CC-BY assets with original in-repo-generated work (P-A1, passes=true):
  4 music loops + defeat theme/sting (original compositions, numpy synthesis,
  tool/build_original_music.py), fire ambience loop (procedural crackle), chest
  sprite (original 3-frame design, tool/build_original_art.py), app icon + mipmaps
  (original "ember in the delve" mark; old icon was CC-BY glyph + stale dice branding).
- CREDITS.md rewritten (courtesy-only credits, history section), PROVENANCE.md
  appended with the replacement table + mastering evidence.
- CHECK CHANGE (called out per protocol): test/meta_screens_test.dart credits test
  asserted the dustdfg CC-BY line; that line is intentionally gone, so the test now
  asserts the no-required-attribution statement + courtesy CC0 credits reachable.
- Verified: flutter analyze clean, flutter test 233/233, decoded audio peaks <= -1.3 dBFS.
- NOTE for owner: app icon changed = visible Play-listing branding change; revert
  trivially by dropping the icon commit hunks if unwanted. Music is synthesized
  chiptune-orchestral — replace with commissioned tracks later if wanted; swapping
  files keeps the same paths/loop contract.

---
## 2026-07-25 — AK-parity phase 1 (pre-gate slice of PR #48 plan)
- Branch feat/ak-parity-phase1 off c1957c1. Scope: AKP-1, AKP-2a/2c, AKP-5,
  AKP-6 from docs/ak-parity-plan.md. Deliberately NOT done: AKP-2b air-dash
  (open owner question), AKP-3/4 (M-sized, post-gate), 352×198 zoom variant.
- AKP-1 (2250da3): viewport 480×270 → 384×216 (char ≈11% of screen, AK-range),
  look-ahead 24→32. hud_routing_test now derives button coords dynamically.
- AKP-2a (0e3e12a): roll/dash is a first-class verb — InputIntent.rollPressed
  edge, shared _tryRoll() (chord + button + keyboard Shift/L), ground-only.
- AKP-5 + 2c (03bdafe): AK-style 4-button diamond (jump 56 biggest, sword 52,
  dash 44, apple 44 auto-hide), down-chevron button (peek/drop-through),
  pause 20→44px, idle 0.55/pressed 1.0 opacity, spawn fade. New assets
  hud/btn_down + hud/icon_dash (CC0, tool/build_hud_extras.py, PROVENANCE.md).
  6-test hud_layout_test: ≥44px targets, no overlaps, routing, fade.
- AKP-6 (706af68): w1_l1 teach-before-test rework (first pit 12 tiles out,
  3-wide, step lip blocks non-jumpers; sign teaches DASH) + hazardEject
  damage path (kHazardEjectSpeedY/X) so pits eject instead of cheap-kill.
  onboarding_test: naive hold-right bot survives ≥30s; design guard: no
  hazard pit >5 wide in ANY shipped level.
- VERIFIED: flutter analyze clean; 250/250 tests green (233 baseline + 17
  new); web-harness screenshots confirm zoom + new HUD live in release build.
- features.json untouched — AKP items are plan-tracked (PR #48), not
  feature-gate items. Device metrics (P-M7) still the open gate item.

---
## 2026-07-25 — owner-directed PR #51 update (zoom, alignment, air dash, spell shop)
- Owner answered all three open questions (DM 09:30): zoom = AK-exact, air
  dash = YES, spell slot = in this PR. Plus new report: button/icon
  misalignment and untested behaviour across screen sizes / nav modes.
- ddae760 AKP-1 rev: 384×216 → 352×198 (24px player = 12.1% of screen height,
  AK ≈12.5%). kCameraLookAhead 32→40 keeps ~1.8s forward sight at kRunSpeed.
- 8d28dfb alignment pass: icon_dash.png glyph was VERIFIED 6px left of centre
  (generator bug, fixed + regenerated); dash/apple now centred on their
  sword/jump columns; HUD geometry moved to _layoutHud() and made safe-area
  aware — GameScreen pushes MediaQuery.viewPadding, converted to viewport
  units with letterbox-band absorption (notches, punch-holes, gesture and
  3-button nav all clear every control). +4 tests incl. an icon
  optical-centering drift guard (decodes the PNGs).
- c790cb3 AKP-2b air dash: dash button fires mid-air — kRollSpeed burst,
  gravity suspended + vy zeroed for the window, roll i-frames, ONE per
  airborne period (landing re-arms). kAirDashEnabled flag for on-device A/B.
  New PlayerEvent.airDashed. +5 tests.
- 6d40dc8 AKP-4d spell shop: SPELLS tab (Ember Burst 700c AoE+ignite —
  pierces Rotshield block; Stone Veil 1100c 3s immunity; Hearth Light 10f
  +2 hearts). One equipped, ONE cast per run, premium-only (pinned by test).
  Save fields ownedSpells/equippedSpell (json round-trip tested), session
  castSpell() headless, auto-hiding HUD button (dash column cap), Q/M keys,
  original CC0 icons via tool/build_spell_icons.py (PROVENANCE updated).
- VERIFIED: analyze clean; 267/267 tests green (250 baseline + 17 new);
  web-harness release build screenshots: akp_352_hud_aligned.png (new zoom,
  centred dash icon, symmetric diamond, spell button correctly absent with
  no spell equipped), akp_airdash_midair.png.
- Next (owner, same DM): more characters + enemies, map/pacing pass,
  per-level lore blurbs, Easy/Med/Hard + smarter AI → follow-up PR.

---
## 2026-07-25 — Stage 2: content depth (owner "go", branch feat/content-depth)
- cf1eb7b two new characters: Grove Sentinel (1600c) + Ash Wraith (25f),
  full 9-sheet sets via build_skins.py recolor pipeline (CC0).
- b596887 difficulty + AI + enemies + lore:
  - Easy/Med/Hard (settings picker, save.difficulty): scales enemy speed /
    telegraph windows / detection + 1 heart on Easy. NEVER hp/damage —
    pinned by test ("no cheap stat walls").
  - Smarter AI: thornling hunt-burst, hopper leads moving targets,
    rotshield guard-turn vs backstab campers, totem/diver ranges scaled.
  - New enemies: Pyre Wisp (chasing spirit, hp3) + Slag Hound (telegraph →
    charge, ledge-safe). 'W'/'H' legend chars, placed in 6 levels by
    swapping existing enemies (density preserved, all bots still pass).
  - Lore: meta: lore= in all 12 levels (≤58 chars, tested); HUD intro
    shows name + blurb for the first 4.5s (evidence:
    docs/ak-parity/evidence/stage2_lore_intro.png).
- VERIFIED: analyze clean, 279/279 tests (267 + 12 stage2_test.dart);
  web-harness release screenshot confirms lore intro live.
- Map/pacing: no geometry changes needed — gap-budget + completability
  guards all green with the new enemy mix; new enemies add threat variety
  without new leap-of-faith or chokepoint risks.

---
## 2026-07-25 — Stage 3: consolidation + owner-reported bug/feel fixes (feat/content-depth)
- Consolidation (owner DM 10:58): #50 (original assets) + #53 (music engine
  v2) merged into this branch; plan/ak-parity (#48) merged so the plan doc +
  reference pack land on main; PR #54 retargeted to main; #48/#50/#51/#53
  closed as superseded.
- 5fac665 enemies rendered in reverse: enemy art faces LEFT, player art faces
  RIGHT; EnemyComponent used the player flip rule. Mirror now on facing > 0;
  rotshield plate drawn facing-explicit outside the mirror; golem same rule.
- c0d6b8d movement stutter root cause 1: playSfx re-prepared the audio source
  on every one-shot (footsteps every 0.26s while running = rhythmic jank).
  Per-id prepared lowLatency (SoundPool) voices, stop+resume per shot. Bonus
  fix: danger loop now pauses/resumes with app lifecycle.
- eb6235d movement stutter root cause 2: fractional camera coords under
  nearest-neighbor ~5-6x upscale = full-screen shimmer while panning +
  frame-rate-dependent linear smoothing. Exponential smoothing on unrounded
  accumulators, viewfinder quantized to whole world pixels, scratch Vector2.
- Level layout pass (owner: "level designs don't make sense"): every
  campaign level rebuilt around its name/lore with real macro structure —
  Old Orchard canopy route, Bramble Hollow spike bowl, Charcoal Camp mounds
  + stone kiln, Rootway Ruins colonnade/sunken court/buried shrine, Ashen
  Gate descending terraces + sealed gate, Ember Vault one grand breakable
  treasury with diver guards, Soot Falls hanging falls (one hides a room
  behind a breakable curtain), Magma Gallery stacked galleries over magma
  channels, Kiln Works work floors ramping to the boss door. Coins now trace
  jump arcs; secrets vary (buried cellars / walled shrines / behind-the-fall
  alcove); enemy rosters + introduction order preserved; w1_l1 (tuned
  onboarding) and both boss arenas untouched.
- VERIFIED: analyze clean (1 pre-existing info), full suite 279/279 green —
  incl. per-level completability bots, gap budget, hazard-run <= 5, quotas,
  secret-behind-cracked-wall, lore, onboarding invariants.

---
## 2026-07-25 — owner-directed alpha pass: bugs, audio, level depth (fix/alpha-polish)
Owner (DM): "quite some bugs… find better audio and sound effects… level design
is not as deep as Apple Knight… play apple knight for inspiration… open a PR and
produce an APK." Everything below is labelled VERIFIED (measured here) or
ASSUMED.

### Method
- Toolchain built in-sandbox: Flutter 3.32.7 (CI-pinned), JDK 17, Android SDK 35.
- **Apple Knight played first-hand** in the Poki web build (Unity, desktop
  viewport, keyboard bindings) — new observations beyond the alpha.3 reference
  pack: AK has **campfire checkpoints** ("Light this campfire to activate the
  checkpoint"), a **lives** counter, attackable **levers**, 3-4 stacked terrain
  tiers per screen, coin columns as skill invitations, and damage numbers +
  white swing arcs. Screenshots kept out of the repo (copyright).
- Emberdelve driven headlessly (session bots) and in the browser harness.

### VERIFIED defects found
1. **Every level killed a casual player in 4-16 s.** Sweep over all 12 levels
   with a hold-right/jump-when-stalled/swing bot: 6 levels ended the run in
   4-16 s (first damage 1.0-2.4 s), the other 6 stalled at 10-26 %. Root cause
   was pacing, not physics: the first enemy stood 1-2 s from spawn in nearly
   every level, and a death threw away the whole run.
2. **A tap-jump rose ~7 px** — less than one 16 px tile. On touch, quick taps
   read as dropped inputs (kJumpCutMultiplier applied with no floor).
3. **World 2's boss arena was a byte-identical copy of World 1's**, same Grove
   Golem entity, renamed "Kiln Golem" in meta only.
4. **All twelve levels played the same music track.** `boss_combat.ogg`
   (661 KB) shipped in every APK with no level referencing it.
5. **The SFX/music set was inaudible on a phone.** Band analysis: land.ogg
   100 % of energy < 300 Hz, danger_loop 100 %, enemy_death 99.8 %, player_hit
   99.4 %, jump 96.6 %; music beds 88-91 %. Phone loudspeakers reproduce almost
   nothing below ~500 Hz. Level spread across the set was 37 dB.
6. **w2_l3's strongroom shaft was one tile wide** — narrower than the player
   body, so its secret chest was unreachable and the lip trapped runners.
7. Deaths from enemy contact, boss hazards and ember shots bypassed the new
   checkpoint path (three direct `_fail()` call sites) — found by re-running
   the sweep after the first checkpoint implementation.

### Fixes
- **Campfire checkpoints + lives** (AK's model): new `K` legend char,
  `CheckpointEntity`, `kStartingLives` 3, respawn heals and grants 2 s of
  i-frames, and enemies within 96 px of the respawn are sent home so a
  campfire can never become a meat grinder. HUD shows lives; new campfire art
  from `tool/build_checkpoint_art.py` (original, CC0).
- **Minimum jump hold** (`kMinJumpHold` 0.09 s): the cut cannot land before the
  jump has been rising that long, so a tap clears ~1.5 tiles while a full hold
  still buys the whole 2.3-tile arc (variable height preserved — pinned by
  physics_test).
- **World 1 re-authored from scratch** via the new `tool/level_author.py` DSL:
  three terrain tiers, high/low branching routes, 12-tile safe teaching runway,
  two campfires per level, shallow escapable spike pits on bedrock instead of
  chain-death wells, strongrooms behind cracked walls, canopy sky-vaults.
- **World 2 pacing pass** (`tool/w2_pacing_pass.py`, mechanical, layouts kept):
  16-tile enemy runway, 14-tile hazard runway, no enemy within 3 columns of a
  hazard, max 3 enemies per 20-tile window, early hazard runs capped at 2
  columns, three campfires placed away from patrols and hazards.
- **Kiln Golem arena rebuilt**: fire channels split the floor into three
  islands with plinths and an upper platform run. (ASSUMED-follow-up: the boss
  *behaviour* is still GroveGolemCore — a distinct moveset is the next step.)
- **Audio v3**: whole SFX set rebuilt from recorded CC0 sources and mastered
  through a phone-speaker model (`tool/build_audio_v3.py`); music re-mastered
  and World 2 given its own bed, boss arenas wired to `boss_combat`
  (`tool/build_music_v3.py`). Measurements ship in `tool/audio_mix.json`.
- **Web harness fixed**: it crashed with a null-check error on death or level
  complete (no `overlayBuilderMap`), which blocked automated full-clear
  verification; telemetry widened to run state, chests, kills, damage.

### VERIFIED results
- `flutter analyze`: clean. `flutter test`: **325/325 green** (279 baseline +
  46 new in `fairness_test.dart` and `audio_mix_test.dart`).
- Survivability sweep after the fixes: **no level ends a run in under 21 s**
  (was 4-16 s in six levels); W1 l1-l4 and several W2 levels survive the full
  180 s sample; w2_l3 now clears at 97 %.
- Audio: every foreground one-shot within ~1 dB of one phone-band target
  (-22 dBFS) with >= 35 % of its energy above 500 Hz; music beds at -26 dBFS.
  Audio payload 3.8 MB -> 1.9 MB.

### CHECK CHANGES (called out per protocol)
- `game_screen_smoke_test.dart` pinned the old tutorial (3 signs, 1 enemy). It
  now pins the new contract: 4 signs (the campfire is taught before the first
  hazard), 2 thornlings, 2 checkpoints. Same intent, new content.
- `physics_test` "early release rises less than full hold" still passes
  unchanged — the minimum-hold window was chosen so variable height survives.

## 2026-07-25 — release: v1.0.0-alpha.5 pre-release (owner request)

Owner: "publish the alpha 5 as pre-release on github releases."

- **VERIFIED** `pubspec.yaml` bumped to `1.0.0-alpha.5+17` (commit `696a400`);
  PR CI run 30164664613 on that SHA: success.
- **VERIFIED** PR #58 merged into `main` (merge commit `e35858e`).
- **VERIFIED** main-push CI run 30165034323 on `e35858e`: both jobs success
  ("Analyze + test (headless)", "Build signed Android release (APK + AAB)").
- **VERIFIED** artifacts `emberdelve-release-apk` / `-aab` downloaded from that
  run; `aapt2 dump badging` reports `versionCode='17'
  versionName='1.0.0-alpha.5'`; `apksigner verify --print-certs` reports signer
  SHA-256 `031acb42566a51d5b59ffd5deb173f1b0e817a9edff1bb6979f68564d44b7a0d`
  == the expected upload key, so it installs over alpha.1–alpha.4.
- **VERIFIED** release published: tag `v1.0.0-alpha.5` -> `e35858e`,
  `prerelease: true`, `draft: false`, assets
  `emberdelve-v1.0.0-alpha.5.apk` (24,184,091 B) and
  `emberdelve-v1.0.0-alpha.5.aab` (43,200,161 B), both state `uploaded`.
  https://github.com/tapiwamakandigona/emberdelve/releases/tag/v1.0.0-alpha.5
- Note for the record: the APK hand-delivered to the owner earlier in the day
  was built before the version bump and reported `1.0.0-alpha.4+16` despite
  being named alpha.5. The release asset is the correct `1.0.0-alpha.5+17`.
- Open follow-ups unchanged: Kiln Golem moveset (reuses GroveGolemCore),
  World 2 full re-authoring, AK-parity juice (AKP-3), on-device perf (P-M7).

---
## 2026-07-26 — Kiln Golem gets its own fight (fix/kiln-golem-moveset)
Owner (DM): "if there are any issues that need fixing/improvement open a pr
for em." No open tracker issues; the highest-priority VERIFIED open defect on
main was the alpha.5 follow-up: **w2_boss "Kiln Golem" was GroveGolemCore** —
the same World 1 fight renamed and retinted.

### Changes
- `boss_core.dart`: extracted shared abstract `BossCore` (telegraphed
  idle→telegraph→attack→recover machine, self-owned hazards, phase math off
  `maxHpTotal`, hazardHits/hazardSourceX/telegraphPulse). GroveGolemCore
  behaviour is unchanged (same timings/attacks; per-attack code moved under
  the hooks). New `KilnGolemCore`, fire moveset: P1 ember mortar (aimed
  0.58 s-flight lobs that ignite 1.5 s fire patches where they land), P2
  + vent wall (4 flame pillars marching from the golem toward the player,
  staggered warnings, jump the wave), P3 1.5x speed + 3-ember volley and the
  vent wall marches both directions. New hazards: emberBomb / firePatch /
  flamePillar. Hazard iteration is index-based so a landing ember can append
  its patch mid-update without ConcurrentModificationError.
- Session/HUD made boss-kind-agnostic (`whereType<BossCore>`,
  `boss.maxHpTotal` instead of the hardcoded GroveGolemCore.maxHp).
- New legend char `M` = kilnGolem; w2_boss.txt swaps G→M and its sign now
  describes the real fight (layout untouched — arena stays as tuned).
- Renderer: kiln case (terracotta tint, same CC0 thornling base — zero new
  art); ember/patch/pillar drawn procedurally; grove keeps moss tint
  unconditionally (the env-dependent tint hack is gone with its reason).

### VERIFIED
- analyze: 1 pre-existing info (settings activeColor deprecation — left
  alone: replacement API risk on CI's pinned 3.32.7 not worth an info).
- tests: **334/334 green** (325 baseline + 9 in kiln_golem_test.dart:
  spawn/lock, phases+events, telegraph-before-hazard, no-grove-hazards in any
  phase, mortar arcs + ignites + punishes an idle player, vent warnings
  before eruptions + >=4 marching pillars, >=3-ember volley, door unlock,
  victory burst).
- Real-arena sim (temp test, removed): crude jump/attack bot in w2_boss.txt
  — fight functions end to end, boss damaged, emberBomb+firePatch seen;
  same bot vs w1_boss for parity: both fights end a lobotomized bot (bosses
  stay a skill check by design, fairness_test exemption unchanged).

### CHECK CHANGES (called out per protocol)
- `world2_levels_test.dart`: the boss-entity check now pins KilnGolemCore
  and asserts GroveGolemCore is ABSENT from w2_boss (was: expects
  GroveGolemCore). Same intent — "the boss spawns" — plus the regression
  guard against reskinning.
- `fairness_test.dart`: kilnGolem added to the enemy-kind set used by the
  spawn-runway rule (data list, no logic change).

### Open follow-ups (unchanged)
- World 2 full re-authoring, AK-parity juice (AKP-3), on-device perf (P-M7).

---
## 2026-07-26 — AKP-3 animation & game juice (feat/akp3-juice)
Owner (DM): "go ahead" on the follow-up stack. AKP-3 from
docs/ak-parity-plan.md §3 — the "reads like AK" combat pass. AKP-3d
(enemy hit-flash) already shipped earlier; this lands the rest. All render
side: no gameplay value, hitbox or timing changed.

- **AKP-3a landing squash**: PlayerComponent scales 1.15x/0.85y anchored at
  the feet for 80ms on PlayerEvent.landed, easing to 1:1 (render transform
  only). Dust on land/dash already existed.
- **AKP-3b swing arcs**: procedural white crescent (canvas.drawArc) swept
  across the middle 60% of each attack animation, in front of the player,
  flipped with facing, direction alternating per combo step, thicker on the
  finisher, tinted per weapon special (none/wallBreaker/burn/bonusHeart/
  lunge/tripleJump each get a hue). Zero new art assets.
- **AKP-3c damage numbers**: SessionEvent gains `amount` (emitted at all
  four damage sites: melee, apple, spell burst; burn ticks deliberately
  silent). DamageNumberFx: ui.Paragraph laid out once at construction, two
  pre-baked alpha variants instead of a per-frame saveLayer (offscreen
  layer per number would eat the Android frame budget), ease-out rise,
  crits bigger/golden/longer-lived, hard cap of 24 live numbers with
  constructor/onRemove accounting (skips silently at the cap).
- **AKP-3e camera shake**: hurt now bumps the camera (3.0); normal enemy
  hits no longer do — shake only on crits and the combo finisher (the old
  every-hit 1.5 bump was exactly the motion-sickness noise the plan warns
  about). bossPhase/bossDefeated bumps unchanged.

VERIFIED: analyze clean (2 pre-existing activeColor infos), tests
**344/344** (3 new in juice_test.dart: enemyHit carries real damage,
damage-number cap accounting + crit-lives-longer, squash decay). Remaining
AKP-3 DoD item that needs hardware: side-by-side capture vs the AK
reference + perf overlay on the fire-pit scene (folds into P-M7).

## 2026-07-26 — World 2 re-authored + reachability contract (feat/world2-reauthor)
Owner (DM): "go ahead" on the follow-up stack after #61. This is the World 2
full re-authoring, plus a defect it flushed out of BOTH worlds.

### World 2 rebuilt in the design DSL
- w2_l1..w2_l5 moved into `tool/level_author.py` (same DSL, rules and
  teach-then-test pacing as World 1); `tool/build_w2_levels.py` and
  `tool/w2_pacing_pass.py` deleted as superseded. W1 + both boss arenas
  regenerate byte-identical from the tool (idempotence check before touching
  anything).
- Level identities, macro structure first: Ashen Gate = surface shelf, a
  real gate (hollow sealed gatehouse over the road) and terraces stepping
  down into the cave; Ember Vault = one grand sealed treasury (cracked
  doors at body height, gold + diver guards + a reliquary inside); Soot
  Falls = stepped basins with coin-trickle drop lines and the fallers' room
  behind a cracked curtain; Magma Gallery = a pillar colonnade carrying an
  upper gallery over a magma-channel hall; Kiln Works = rising work floors
  around the great kiln (fire in its throat), ramping down to the boss
  door. Rosters and introduction order preserved from alpha.5. Cave read:
  ceiling + stalactite drips kept >= 4 rows out of play space.

### VERIFIED defect (shipped, both worlds): unenterable secret vaults
- `sky_vault` built a 1-tile (16px) interior and 1-tile doors; the player
  body is ~20px. Physically impossible to enter — measured in-session: the
  body cannot pass the door (playerX pinned at the wall), so **every
  sky-vault secret in w1_l1..w1_l5 was uncollectable and the "all chests"
  medal unattainable on those levels.** Interior + doors are now 2 tiles;
  approach platforms re-aligned. Also fixed: w1_l1's upper route needed a
  5-row rise (budget is 4); w1_l3/l4/l5 vault approaches got a mid step;
  w2_l5 had a 4-deep trench (chain-death well) before the kiln — filled.

### New contract: collectible reachability
- `tool/reachability_lint.py` + `test/reachability_test.dart` (same
  algorithm): jump-physics flood fill (double-jump budgets verified
  empirically: a standing double jump lands a 4-row ledge; ~6 columns of
  air reach; body needs head clearance; cracked walls count as breakable).
  Every c/a/f/C/X/K/E in every shipped level must be reachable. The door
  bots prove the exit; this proves the loot. It fails the alpha.5 levels
  as shipped and passes after the fixes.

### VERIFIED results
- analyze clean (2 pre-existing infos: settings activeColor x2, the second
  arrived with #47); tests **353/353 green** (341 post-#61/#47 baseline +
  12 reachability). Runner-bot completability + fairness suites green on
  the new layouts; full-clear seek-bot probe (temp, removed) collected
  every ground-route collectible; w2_l5 runner bot finishes in 21s.

## 2026-07-26 — Land the open follow-up PRs; salvage from stale #62
Owner (DM): "work on alpha version of emberdelve."

- **VERIFIED** integration main + #64 + #65 locally on Flutter 3.32.7:
  analyze clean, 356/356 tests green.
- **VERIFIED** PR #64 squash-merged (208938f): World 2 re-authored in the
  design DSL + collectible-reachability contract; fixes the shipped
  unenterable-sky-vault defect in both worlds.
- **VERIFIED** PR #65 squash-merged (a38751c) after resolving the
  progress.md append conflict against post-#64 main and re-running the
  suite (356/356) + PR CI green on the resolved head (e678b41).
- Salvaged from stale umbrella #62 (superseded by #61+#64+#65):
  `tool/survivability_sweep.dart`, the casual-bot measurement tool behind
  fairness claims. **VERIFIED** it runs on current main
  (SWEEP_SECONDS=30, w1_l1 68% reached/alive, w2_l1 63%/alive).
  Not salvaged: #62's camera_shake.dart module + kHitPauseHeavy (superseded
  by #65's tuned-shake approach), kiln_boss_test.dart (superseded by #61's
  kiln_golem_test.dart, legend M not Q).

## 2026-07-26 — release: v1.0.0-alpha.6+18
- pubspec bumped 1.0.0-alpha.5+17 -> 1.0.0-alpha.6+18; checkpoint
  checkpoints/09-alpha6-w2-reauthor-juice-kiln.md written (tester-facing
  changes: enterable vaults fix, W2 re-author, Kiln Golem fight, AKP-3 juice).
- Release evidence appended after CI + prerelease publish (see below).
- **VERIFIED** release PR #67 squash-merged to main as 1301606a; main-push CI
  run 30197743835 green (Analyze + test (headless) + Build signed Android
  release success).
- **VERIFIED** CI APK badging: com.tsorostudios.emberdelve, versionCode 18,
  versionName 1.0.0-alpha.6; signer cert SHA-256 031acb42...4d44b7a0d matches
  the pinned upload key (also enforced in the CI build job).
- **VERIFIED** GitHub prerelease v1.0.0-alpha.6 published on 1301606a with
  emberdelve-v1.0.0-alpha.6.{apk,aab}; release asset sha256 digests match the
  locally verified CI artifacts (apk 026e51a1..., aab b276a19d...).
- Still open: P-M7 on-device perf (needs hardware), P-M10 beta.1 to Play
  closed testing (owner call), AKP-4 weapon identity.

---
## 2026-07-26 — AKP-4 weapon identity (feat/akp4-weapon-identity)
Owner (DM): "start" — proceeded with the last open workable item: AKP-4
(P-M7 blocked on hardware, P-M10 owner call; AKP-4d already shipped 6d40dc8).

- AKP-4a — render the equipped weapon:
  - tool/build_weapon_sprites.py splits the baked-in ivory blade (#fffff2 —
    VERIFIED that exact color is blade/swing-FX-only in the pixivan pack)
    out of all 9 player sheets into assets/images/player/body/ (bladeless)
    + assets/images/player/weapons/<id>/ (6 per-weapon overlays: hilt→blade
    →tip recolor gradient from the grip, 1px head dilation for axe/hammer).
    The baked swing crescents inherit the weapon tint for free.
  - build_skins.py now recolors the bladeless body sheets (all skins
    regenerated); PlayerComponent drives a weapon-overlay ticker in lockstep
    with the body ticker (same transform: flip/squash/blink); shop
    SkinPreview composites the equipped weapon; missing sheets degrade to
    bare hands, never a crash. PROVENANCE.md updated (all CC0-derived).
- AKP-4b — per-special identity:
  - Skypiercer lunge IMPLEMENTED (was stats-only despite the specialText
    promise): kLungeSpeed 150 px/s burst at swing start; ground friction
    bleeds it in ~0.09s ≈ 7px step; wall-clipped by the normal integrator;
    horizontal-only so jump height and reachability contracts are untouched.
    + dash-streak PuffFx on swing.
  - Ember Fang hits shed ember SparkleFx; Woodsman's Axe one-chop wallBreak
    puffs bigger rubble (radius 7→10).
- AKP-4c — apple lob: launch flattened 40°→22.5° (feel-notes rec; speed 220
  kept — flight is flatter/faster, flat-ground range ~unchanged ≈56px, no
  test pinned the old angle). Held throw button (touch or K/C) shows a faint
  arc-preview dot trail computed from the projectile's own launch params +
  gravity (Session.appleArcPreview, preallocated buffers, zero per-frame
  allocations); throw itself stays on the press edge.
- Webtest harness: ?weapon=<id> and ?apples=N params (harness-only).

### VERIFIED
- flutter analyze: No issues found. Tests 363/363 green (356 baseline + 7
  new in test/weapon_identity_test.dart: overlay sheet completeness /
  dimensions / per-weapon pixel-difference, lunge steps forward ~7px while
  control weapon stays put, lunge never clips a wall, 22.5° launch vector,
  arc preview matches a 120Hz-stepped projectile to <0.01px on every dot).
- In-game evidence (web harness, release build): per-weapon idle + mid-swing
  screenshots + apple arc preview in docs/ak-parity/evidence/akp4/.

## 2026-07-26 — AKP-4 merged to main
- PR #69 squash-merged as 1cb919b (branch feat/akp4-weapon-identity deleted).
- VERIFIED: PR CI "Analyze + test (headless)" pass (1m14s,
  run 30198891118); mergeStateStatus CLEAN before merge.
- No release cut this run (feature-only; next release alpha.7 on owner call).
- Still open: P-M7 (on-device perf, needs hardware), P-M10 (Play beta.1,
  owner call).

## 2026-07-26 — release v1.0.0-alpha.7+19 (chore/release-alpha7)
Owner (DM): "cut me a pre release I can test". Cut from main at ef73fa8
(AKP-4 weapon identity, merged as 1cb919b, was unreleased).

- pubspec 1.0.0-alpha.6+18 → 1.0.0-alpha.7+19 (versionCode 19).
- checkpoints/10-alpha7-weapon-identity.md: tester-facing notes.
- No code changes in this release PR.

### VERIFIED — v1.0.0-alpha.7 shipped
- PR #73 squash-merged to main as 38137e2 (branch deleted); PR CI
  "Analyze + test (headless)" green, mergeStateStatus CLEAN before merge.
- Main CI run 30201005775 on 38137e2: both jobs success — "Analyze + test
  (headless)" and "Build signed Android release (APK + AAB)"; CI's own
  signer check against EXPECTED_CERT_SHA256 passed (untouched).
- Artifacts downloaded from that run and re-verified locally:
  pyaxmlparser badging → package com.tsorostudios.emberdelve,
  versionCode 19, versionName 1.0.0-alpha.7. Signer cert SHA-256 recomputed
  from META-INF/CERT.RSA = 031acb42566a51d5b59ffd5deb173f1b0e817a9edff1bb69
  79f68564d44b7a0d — exact match to the pinned upload key, so it installs
  over alpha.1–alpha.6.
- GitHub prerelease v1.0.0-alpha.7 published on 38137e2 with both CI assets
  (state: uploaded):
  emberdelve-v1.0.0-alpha.7.apk  25,545,105 B
    sha256 d3c3cff1558bbbf439c293c35807c2496071d63b7583c3ad23d7184cbda6bbe0
  emberdelve-v1.0.0-alpha.7.aab  45,347,574 B
    sha256 de4ff93945ed7c97450439d8557f6882c52267333d978481b7c3b4d1cce1698d
  https://github.com/tapiwamakandigona/emberdelve/releases/tag/v1.0.0-alpha.7
- No local build shipped (CI artifacts only); no Play upload (P-M10 stays an
  owner call).
- Still open: P-M7 (on-device perf, needs hardware), P-M10 (Play beta.1).

## 2026-08-31 — session start: Emberwood gauntlet resumes (owner: "work on emberdelve alpha version that isn't the dice game")
- Track: `main` (Emberwood platformer, com.tsorostudios.emberwood), worktree
  /work/repos/emberwood off the dice checkout. DEMAND.md written for this
  branch (platformer standards; root DEMAND.md on legacy branch is
  dice-scoped). Owner will drive the loop with "continue" pings, dice-style
  cadence: one improvement per release.
- BLOCKER (carried until fixed): GitHub PAT is dead — 401 on api.github.com
  with the documented token [github, 2026-08-31]. Same failure the dice
  branch has logged since 2026-08-25 ("push pending GitHub auth"): remote
  legacy/dice-builder sits at v0.60.0 while local is v0.148.0 (92 unpushed
  commits). NO pushes, tags, CI dispatches, or GitHub releases possible from
  the sandbox until the owner re-provisions a PAT. Working in
  gates-green-commit-locally mode meanwhile. Escalated to owner this session.
- Baseline VERIFIED at 1326a80: flutter analyze 2 infos (deprecated
  activeColor), suite 363/363 green (Flutter 3.44.9 from /work/temp/flutter;
  pinned 3.32.7 unavailable — no regressions observed, watch goldens).

## v1.0.0-alpha.8+20 — The Readable Wood (2026-08-31)
- One improvement: in-world HUD text legibility. Look pass (web harness,
  915x412 phone + 1280x800 desktop, spawn+mid shots, all 8 sampled levels
  across both worlds) found counters/timer/lives/lore-intro ivory text with
  NO outline — unreadable over World 1's pale sunburst sky in every W1 shot
  (self-found, 3-second-stranger fail). Fix: HudReadout.hudTextStyle gains
  four 1px cardinal ink shadows (0xFF201826, blur 0) — pixel-outline look,
  bakes into cached TextPainters, zero steady-state cost.
- Also: settings_screen.dart activeColor→activeThumbColor (2 deprecations);
  analyze now clean.
- VERIFIED: suite 364/364 (+1 hud outline pin test; fails on old code via
  stash run — compile-level bind on hudTextStyle + shadow asserts). After
  shots confirm crisp readouts on w1_l1/w1_l3 (sunniest levels).
- OBSERVED (open, minor): all coins share one global spin phase — every coin
  on screen hits the edge-on frame simultaneously; caught in the after shots
  looking candle-like for a frame. Candidate future improvement: per-coin
  phase offset from spawn position.
- Release mechanics: version 1.0.0-alpha.8+20, checkpoint
  checkpoints/11-alpha8-hud-legibility.md. Tag/CI/GitHub prerelease PENDING
  GitHub auth (see blocker above); commit is release-shaped so the publish
  is a tag+dispatch away once auth returns.

## v1.0.0-alpha.9+21 — Twinkling Hoard (2026-08-31)
- One improvement: per-coin spin phase (the open minor logged in alpha.8).
  CoinEntity.spinPhase from spawn position; ItemsComponent draws per-coin
  frames from a precomputed sprite list (pure coinFrame(), no per-frame
  allocations, shared ticker removed). Suite 366/366 (+2). Visual VERIFIED:
  w1_l1 cluster shows mixed frames in one still; candle-wall gone.
- Publish still PENDING GitHub auth (PAT dead — see 2026-08-31 blocker).

## v1.0.0-alpha.10+22 — Unstuck Steps (2026-08-31)
- Publish unblocked: user re-provisioned the PAT. alpha.8 + alpha.9 pushed,
  tagged, CI-built (Flutter pin -> 3.44.9 after activeThumbColor broke the
  3.32.7 analyze) and released as GitHub prereleases with signed APK/AAB.
- One improvement: w1_l4 chute-trap fix. Playthrough probe (hold-jump casual
  bot, 4 seeds, all 12 levels, stall telemetry) found the Cinder Steps
  1-wide inter-tower slots trapped the bot for 290+ s every run; col-59 slot
  needed rise 6 (> double-jump budget 4). Filled both slots into staircase
  steps; permanent chute-trap lint gate added (fails on old geometry,
  VERIFIED). Suite 378/378. Probe: w1_l4 now CLEAR in 21 s all seeds.
- Checkpoint: checkpoints/13-alpha10-cinder-steps-trap.md.

## v1.0.0-alpha.11+23 — Mended Hearts (2026-08-31)
- One improvement: heart pickups (first heal item in the game). Wipe probe
  with hit attribution showed w2_l4 wiping at 73% (all seeds) and w1_l5 at
  30-41% — long checkpoint gaps stacked with hazards and zero mid-run
  healing. Added SpawnKind.heart ('h'): +1 heal, stays put at full health;
  procedural 8x8 HUD-matching sprite with bob+shadow; heal sfx + red
  sparkle. Placed 2 in w1_l5, 2 in w2_l4. Probe: w2_l4 flips to COMPLETED
  (~28 s, all seeds). w1_l5 still wipes — root cause is the thornling@36 +
  totem@44 colonnade geometry, next release's target. Suite 385/385 (+7,
  incl. design pin that both levels keep >= 1 heart). Look pass VERIFIED
  phone+desktop at all 4 heart sites.
- Checkpoint: checkpoints/14-alpha11-heart-pickups.md.

## v1.0.0-alpha.12+24 — Totem Squeeze Purge (2026-08-31)
- One improvement: purged the "totem squeeze" pocket (stationary totem 1
  free tile from a >=2-tall wall = unavoidable contact-damage trap) from all
  three levels that had it. w1_l5: pillar x38-40 collapsed to a 1-tall step
  + totem moved to the row-12 platform (45,11) — probe flips 10 hits/2
  deaths/38 s to 3 hits/0 deaths/22 s COMPLETED all seeds. w2_l4: totem
  perched on the 58-60 wall (59,13) — pocket gone, completion unchanged
  (73% wipe; creeper attrition is next). w2_l5: totem to (95,9), 2-tile
  landing restored — COMPLETED all seeds. Permanent gate
  test/totem_squeeze_test.dart (red on old geometry, VERIFIED) + the wipe
  probe committed as a skipped test (test/wipe_probe_test.dart). Suite
  397+1 skipped. Look pass phone+desktop at all three sites.
- Checkpoint: checkpoints/15-alpha12-totem-squeeze-purge.md.

## v1.0.0-alpha.13+25 — Fire Toll Relief (2026-08-31)
- One improvement: w2_l4 flips from 73% WIPE to COMPLETED on all 4 probe
  seeds. Root cause decoded from the probe trace: every life reached a fire
  pit at 1 heart and paid the 1-damage pit "toll" (hazard eject) — 3 pits =
  3 deaths = wipe at pct 79, deterministic. Fix (level-data only): high-road
  platform row 12 cols 85-94 completing the sign fiction ("miners took the
  high road" — every other pit already had its tier); totem (96,12) ->
  (98,12) so the tower landing tile is no longer camped point-blank; hearts
  at (41,15) and (101,15) breaking the toll chain before pits 1 and 3
  (AKP-7a precedent). Probe: 28 s, 1 death, all seeds. Suite 397+1 skipped,
  analyze clean. Look pass phone+desktop at both changed sites (4/4).
- Checkpoint: checkpoints/16-alpha13-fire-toll-relief.md.

## v1.0.0-alpha.14+26 — Vault Break-Out (2026-08-31)
- One improvement: w2_l3 flips from TIMEOUT on all 4 probe seeds (bot pinned
  177 s at col 91) to COMPLETED 26 s all seeds. The loot vault at 86-92
  broke the established `B.X.B` grammar (cracked walls BOTH sides) and
  shipped `B.cXc.#` — breakable entry, solid exit, solid roof: break in,
  loot, trapped. Fix: right wall (92,14)+(92,15) '#' -> 'B'. New permanent
  gate test/secret_vault_test.dart (12 tests): every secret chest's first
  2-tall lateral barrier within 8 tiles must be breakable, both sides —
  VERIFIED red on old geometry (flags exactly w2_l3 X@(89,15)), green on
  new. Suite 409+1 skipped, analyze clean. Look pass phone+desktop at the
  vault site.
- Checkpoint: checkpoints/17-alpha14-vault-break-out.md.

## v1.0.0-alpha.15+27 — Crown Strike (2026-08-31)
- One improvement: the boss design-intent review the alpha.14 sweep called
  for. Verdict: masher wipes on both bosses are BY DESIGN (fairness_test
  already pins "bosses are a skill check") — a coached-strategy bot beats
  Grove Golem 22 s/1 death and Kiln Golem 13 s/0 deaths on all 4 seeds. But
  the review caught a real defect: Kiln Golem is caged in its pen and ground
  melee CANNOT reach it (0/60 dmg measured from every ground bot — the perch
  route over the pillar crowns is mandatory), yet its sign coached ground
  play ("Keep moving!"). Fix: w2_boss sign rewritten to coach the crown
  strike ("no blade reaches it from the floor. Climb the vent pillars and
  strike its crown"). New permanent gate test/boss_intent_test.dart (2
  tests, 4 seeds each): each boss's coached strategy must complete the level
  with a life to spare — goes red if a level edit ever breaks the w1
  hit-and-run windows or the w2 moat-jump/perch reach. Suite 411+1 skipped,
  analyze clean. Look pass phone+desktop at the sign site.
- Checkpoint: checkpoints/18-alpha15-crown-strike.md.

## v1.0.0-alpha.16+28 — Small-Phone Sweep (2026-08-31)
- One improvement: the DEMAND gate "Overflow sweep for Flutter UI screens at
  small phone + 1.3× text" had no automation and no recent manual run. New
  permanent gate test/overflow_sweep_test.dart pumps title / level select /
  shop / settings / credits at 320×568 AND 568×320 logical px with
  TextScaler 1.3 (loaded save: 999999 coins + all 36 medals so the widest
  content lays out; lazy lists flung to the bottom). VERIFIED red on old
  code — 4 real overflows: title menu Row +201 px right (320 portrait),
  title Column +103 px bottom (568×320 landscape), level-select AppBar
  actions +14 px (WalletChip at 1.3x), shop card rows +17 px (price+BUY
  cluster) and +38 px (_WeaponStats fixed-width bars).
- Fixes: title menu wrapped in Center>FittedBox(scaleDown) (whole menu
  shrinks uniformly instead of clipping); WalletChip and the shop card's
  trailing purchase cluster keep base text scale via
  MediaQuery.withClampedTextScaling(1.0) (compact iconographic chrome —
  the description column keeps full 1.3x and wraps); _WeaponStats bars in
  FittedBox(scaleDown, centerLeft). Sweep 10/10 green after.
- Harness: lib/main_webtest.dart gains ?screen=title|select|shop|settings|
  credits (+ ?coins=N, ?allclear=1) so release look-passes can screenshot
  the real meta screens in a browser (harness-only entrypoint, not in the
  Android app).
- Gates: analyze clean, suite 421 passed + 1 skipped. Look pass phone
  915×412 + desktop 1280×800 on title/select/shop: unchanged at normal
  sizes, no regressions.
- Carry-forward (pre-existing, untouched): disabled BUY button on
  feather-priced shop items (e.g. Skypiercer 12 feathers, wallet 0) is
  near-invisible — white12 fill on dark panel reads as an empty gap next to
  the price. Worth a contrast pass.
- Checkpoint: checkpoints/19-alpha16-small-phone-sweep.md.

## 2026-08-31 — v1.0.0-alpha.17+29 "The Rekindling" (repo move + total rename)
Owner directive (app chat 18:01): move the platformer out of the emberdelve
repo, rename it entirely, commit the store keys in the repo so any AI can
build signed. Name: **Pyregrove** (web-checked, no game collision; alternates
Cinderbough/Kilnfall also clear). New PRIVATE repo tapiwamakandigona/pyregrove.
Renamed: pubspec name (pyregrove, 191 imports), package id
com.tsorostudios.pyregrove (namespace/applicationId/MainActivity dir),
app label, title 'PYREGROVE', subtitle 'Delve the burning grove', world-1
header 'THE PYREGROVE', save/settings filenames, web manifest,
window.__emberdelve → window.__pyregrove (harness scripts updated too).
Signing: FRESH PKCS12 upload keystore generated in-sandbox (no JDK —
python cryptography), alias 'upload', committed at android/signing/ with
key.properties (owner directive; repo is private). New pin
286c4760f1801269550fe40658e6255c96107713690d0e4353cbe76bccee8ffd. Old alphas
(.8–.16, com.tsorostudios.emberwood, pin 031acb42…) coexist, never upgrade
in place. CI: signing from repo files, no secrets; artifacts pyregrove-*.
Firebase: google-services.json client block duplicated for new package
(HACK — analytics attribute to old app id; owner follow-up: register the new
package in Firebase console). Gates: analyze clean, 421 passed + 1 skipped,
look-pass PASS phone+desktop (title/select/shop).

**alpha.17 shipped (18:35):** GitHub Actions billing-blocked on private repos
(owner must fix account billing) → built+signed LOCALLY (portable JDK17 +
Android SDK in /work/temp, scripts /work/temp/rel/local_*.sh). androguard
VERIFIED: 1.0.0-alpha.17 / 29 / com.tsorostudios.pyregrove / pin 286c4760…
MATCH. Prerelease id 379966012 live with pyregrove-v1.0.0-alpha.17.apk+.aab.

## 2026-08-31 — v1.0.0-alpha.18+30 "Bright Ledger" SHIPPED (first mirror-CI release)
- Shop readability fix (4a3c2a9): disabled BUY now visible (white α0.06 bg, white54 label, white24 outline); unaffordable price tinted #D57C6A; contrast guard test in shop_flow_test.dart.
- DEMAND.md signer-pin reference corrected to Pyregrove key (e76f38f).
- Gates VERIFIED: analyze clean; 421 passed + 1 skipped (opt-in wipe probe); shop look-pass phone 915×412 + desktop 1280×800 at coins 0/300/999999 (/work/temp/emberwood_shots/a18/) — disabled state readable, affordable green, gem item correctly gated.
- Release flow: private main+tag pushed → scripts/sync_public_ci.sh v1.0.0-alpha.18 (mirror commit 580c8c6, source e76f38f) → pyregrove-ci run 33426661619 GREEN (analyze+test, signed build) → artifacts downloaded → androguard VERIFIED 1.0.0-alpha.18 / 30 / com.tsorostudios.pyregrove / pin 286c4760…cee8ffd MATCH → prerelease id 379980173 on PRIVATE repo, APK (53244323 B) + AAB (53281551 B) uploaded, sha256s in notes.
- Mirror validation run (pre-tag, source e969a057) 33425717460 also green — billing bypass confirmed end-to-end.
- Open: GitHub billing fix (owner) would re-enable private CI unchanged; Firebase re-registration in progress by another AI (owner update pending).

## 2026-08-31 — v1.0.0-alpha.19+31 "True Name" SHIPPED (identity/store truth pass)
- CREDITS.md rebranded Emberdelve→Pyregrove, duplicate audio section merged, lineage note added (published during dev as Emberdelve v2 / Emberwood, renamed 2026-08-31); test-asserted strings preserved.
- Dice-game inheritance deleted: docs/HOW-TO-PLAY.md, dice store screenshots + feature graphic + howto plates, obsidian-die app-icon-512, annotate_howto_screenshots.py — repo-wide grep confirms no dangling refs.
- New docs/store/app-icon-512.png from real launcher icon (NEAREST from app_icon_master_1024.png). play-listing.md rewritten as honest Pyregrove platformer draft (screenshots/feature graphic TODO; Play submission stays owner-gated P-M10).
- Privacy policy md+html rebranded (covers earlier Emberwood/Emberdelve-v2 alphas explicitly); live Pages copy on old repo main updated (doc-only 9abefd4, freeze banner stands) — live URL VERIFIED shows "Pyregrove — Privacy Policy". consent_dialog URL deliberately unchanged (baked into shipped builds; private repo has no Pages) with rationale comment.
- First release with correct Firebase attribution: com.tsorostudios.pyregrove registered with own app id (cd525ae, by owner's other AI; project gen-lang-client-0980262477).
- Gates VERIFIED: analyze clean; 421 passed + 1 skipped; credits look-pass phone+desktop PASS. Content commit 6c2ba5f, release commit/tag on 6c2ba5f.
- Release flow: tag v1.0.0-alpha.19 → sync_public_ci.sh (mirror ef50ba6) → pyregrove-ci run 33428839791 GREEN → androguard VERIFIED 1.0.0-alpha.19 / 31 / com.tsorostudios.pyregrove / pin 286c4760…cee8ffd MATCH → prerelease id 379993214 on PRIVATE repo, APK 53244355 B + AAB 53281518 B uploaded, sha256s in notes.
- Mirror safety audit: public tree contains no keystore/key.properties (only legacy prose doc with old public cert fingerprint — harmless).

## 2026-09-01 19:00 — Local signed-build verification of accumulated freeze work (no code change)
- Ran the full local release build (scripts in /tmp tooling; `flutter build apk --release`, JDK17, build-tools 36) against main @ 28cf7a37 — first Android build exercised since 89af754; 56 accumulated commits compile clean. Gradle assembleRelease 433s, APK 53.3MB.
- androguard verification on the fresh universal APK: package com.tsorostudios.pyregrove, versionCode 33 / versionName 1.0.0-alpha.21, signer sha256 286c4760f1801269550fe40658e6255c96107713690d0e4353cbe76bccee8ffd — matches the pinned upload signer. NOT published (freeze); artifact stays local as build-health proof for the owner's consolidated release.
- Owner-push check: `git fetch` clean, no commits on origin/main beyond local, DEMAND.md md5 unchanged (3d19777bc846962150a030ecaf1043d5).

## 2026-09-01 18:05 — Live loop validation; background-audio regression fixed (518c4dc2)
- Sub-stepped loop validated END-TO-END in a real browser: scripted w1_l1 full completion (21s, 4 hits, 53fps) and the face-hug masher replay on w1_boss still WIPES (t=22s, boss 138/150, fail overlay) - loop change altered nothing at 60fps, as designed.
- REGRESSION FOUND: v0.3.1 F3's lifecycle audio wiring (WidgetsBindingObserver) died with the dice UI in the platformer pivot; AudioService.pauseAll/resumeAll existed but were called by NOTHING - Android kept music playing after Home/lock. Fixed: root AppLifecycleListener in main.dart (audio) + EmberGame.lifecycleStateChange override (backgrounding mid-run opens the pause menu; Flame's default would silently auto-resume gameplay on return).
- test/lifecycle_pause_test.dart (2 tests; overlay builders must be stubbed via overlays.addEntry in headless boots). Suite 456 green +1 skipped, analyze clean. Dart-only, no mirror sync owed. Freeze respected.
- Probe scripts kept: /work/temp/live_smoke.py (live completion driver: swing constantly, jump only when stuck - blind periodic jumping dies), /work/temp/recoil_cap.py. Gotcha: ?spawn next to a patrolling enemy = beaten to death during the 5.6s banner wait (hearts 0 before input starts); spawn on a ledge above instead.

## 2026-09-01 17:20 — Enemy hit recoil; research backlog closed out (5efc3d06)
- Feel gap: hits had flash/damage numbers/hit-stop but no directional response. EnemyComponent now translates the sprite <=3px away from the player, easing out with the 0.15s hurt flash. Render-layer ONLY (canvas translate) - the physics body never moves, so probes/balance/headless tests untouched. Bosses + Ember Totem deliberately excluded (mass/rootedness is a read); mimic bush + rotshield plate recoil with the body.
- test/enemy_recoil_test.dart: direction both sides, ease-out with flash decay, zero body displacement. Suite 454 green +1 skipped, analyze clean.
- docs/research-2026-09.md backlog refreshed: pitch sfx / scaled landing shake / run dust / recoil / sub-stepping all DONE; corrected a stale line - in-level parallax ALREADY SHIPS (parallax_bg.dart, 4 layers, forest+cave); only on-device perf validation remains hardware-blocked.
- Dart-only, no mirror sync owed. Freeze respected: no tag, no release.

## 2026-09-01 16:45 — Low-end pacing: sub-stepped frames (slow-motion bug fixed), throttled perf probe (7f6b4d20)
- Standing directive "smooth on all devices even low end": profiled the web harness headless (SwiftShader, no GPU) with CDP CPU throttling across 5 busy scenes (w1_l2/w2_l1/w2_l3 walks, both boss fights). Baseline ~50fps avg; x6 throttle ~8-10fps UNIFORMLY - no scene outlier, boss fights cheapest. Renderer already alloc-clean (batched tiles, cached text layouts); cost is pipeline-flat, so no content hotspot to fix.
- Real bug found instead: update() clamped dt at 1/30 in a single step, so any sub-30fps device played the whole game in SLOW MOTION (20fps = 0.66x speed). Now simulates real elapsed time in <=1/60 sub-steps, catch-up capped at 4/60s (full speed down to ~15fps, graceful slow-mo below rather than a death spiral). Input edges delivered on first sub-step only (no re-armed jump buffers on slow frames).
- Telemetry bridge now publishes fps/frameAvgMs/frameWorstMs (always-on FrameStats on EmberGame; a few float ops per frame).
- VERIFIED live in throttled browser: 29.5fps timescale 1.00; 22fps timescale 0.98 (old code: 0.73). Probe scripts /work/temp/perf_throttle.py, /work/temp/timescale_check.py.
- test/substep_test.dart: 4 regressions. Suite 452 green +1 skipped, analyze clean. Dart-only - no mirror sync owed. Freeze respected: no tag, no release.

## 2026-09-01 15:55 — Full-game curve probe re-run (supersedes the 97f47a4 table)
Casual bot (wipe_probe_test), 4 seeds each, avg values; format completions/4, time, deaths, hits:

| level | easy | medium | hard |
|---|---|---|---|
| w1_l1 | 4/4 14s d0 h2 | 4/4 14s d0 h2 | 4/4 14s d0 h2 |
| w1_l2 | 4/4 29s d2 h7 | 4/4 18s d0 h2 | 4/4 29s d2 h7 |
| w1_l3 | 4/4 18s d0 h2 | 4/4 18s d0 h2 | 4/4 18s d0 h2 |
| w1_l4 | 4/4 19s d0 h3 | 4/4 18s d0 h2 | 4/4 22s d1 h3 |
| w1_l5 | 4/4 22s d0 h3 | 4/4 22s d0 h3 | 4/4 22s d0 h4 |
| w1_boss | 0/4 56s d3 h12 | 0/4 28s d3 h9 | 0/4 23s d3 h9 |
| w2_l1 | 4/4 23s d1 h4.8 | 4/4 22s d1 h4 | 4/4 28s d1.8 h6.2 |
| w2_l2 | 4/4 24s d0 h3 | 4/4 26s d1 h5 | 4/4 28s d1 h5 |
| w2_l3 | 4/4 19s d0 h3 | 4/4 26s d1 h3 | 4/4 25s d1 h3 |
| w2_l4 | 4/4 23s d0 h4 | 4/4 28s d1 h7 | 4/4 22s d0 h4 |
| w2_l5 | 4/4 23s d0 h3 | 4/4 27s d1 h5 | 4/4 28s d1 h3 |
| w2_boss | 0/4 20s d3 h11 | 0/4 14s d3 h8 | 0/4 14s d3 h8 |

Reading: every regular level clears 4/4 on every difficulty; both bosses wipe the casual bot on every difficulty (skill check by measurement, not by claim). Medium hits rise w1 (2-3) -> w2 (3-7): between-world ramp intact. Boss rows now differentiate by difficulty (w1_boss easy survives 56 s vs hard 23 s). Easy-column hit counts remain a bot artifact (slow enemies hover and re-contact; see wipe_probe_test header) - compare medium/hard. w1_l2 easy/hard d2 is the known pit-hopper bot artifact from the 97f47a4 table, unchanged. w2_boss pct 40-48: the bot dies in the approach works before the pen - boss cadence unmeasured by design for casual play.

## 2026-09-01 15:40 — Bosses now honor difficulty; w1 arena head-bonk trap fixed; curve re-probed
- Difficulty curve re-probe after the 150 hp retune found bosses IGNORED difficulty entirely (medium and hard probes byte-identical): BossCore never read `mods` while every regular enemy scales. Wired mods into the shared state machine - mods.speed on walk + slam shockwaves, mods.telegraph on wind-ups/idle/recover + root-spike warnings + vent-wall march delays, mods.aggro on wake range. Aimed lobs (rocks, ember mortars) keep their launch math (vx solves an aim equation; the arc is the warning). New regression group in boss_core_test: time-to-first-attack easy>medium>hard, wake range scales, slam wave speed scales.
- Coached-gate hardening exposed a REAL LEVEL FLAW: w1_boss apple ledges (rows 12-13, cols 18-22/30-34) were solid - the walking boss corners you under them and jump (the core dodge verb) silently head-bonks 12 px up into the wave. Frame dump proof: vy -273 -> 0 in 3 frames at ledge underside. Converted to one-way platforms (matches the arena's existing row-9 platform); row 13 emptied. Pixel-scan verified the thin platform band renders.
- boss_intent_test now takes --dart-define=DIFF (default medium for CI); coached bot rewritten from hit-log evidence: holds the strike band instead of blanket retreat (retreat = get walked into the wall), hops shockwaves on time-to-impact (<0.32 s) not proximity (44 px triggered too early on hard, too late logic on easy), drifts against a hopped wave so it passes under, boss spacing OUTRANKS wave drift (drifting into the hull was every medium death), flees root-spike brackets, double-jump escape from contact chains. Hit log now prints dist/air/hazards.
- VERIFIED: all 24 combos green (2 bosses x 3 difficulties x 4 seeds): w1 medium 55 s/1 death, hard 44-47 s/1 death, easy 81-88 s/2 deaths; w2 22-28 s. Casual wipe probe post-wiring: wipes on every boss at every difficulty, easy measurably gentler (w1 survival 56 s easy vs 23 s hard; hits 12 vs 9). Skill-check curve shape restored.
- Suite 448 green (+3 new), analyze clean. Dart/level/test-only - no mirror sync owed. Freeze respected: nothing published.

## 2026-09-01 12:10 — Grove Golem playthrough: TTK was broken; bosses retuned (unpublished, freeze)
- Fresh live playthrough (w1_boss seed 7, 844x390, full feel stack): presentation good (dormant grey -> wake lerp, phase notches, rage flash, victory shower) but the FIGHT collapsed - a face-hug hop-masher killed the 60 hp golem in ~9 s (par 150 s) taking 2 hits. Phases 2/3 lived ~3 s each.
- Verified headlessly on seeds 7/13/42/99 (temp masher probe, deleted): kill in ~10 s, 5 hits, never lost a life. Even the COACHED gate route won in 17 s. The boss_intent_test charter's claim "masher wiping on bosses is BY DESIGN" was stale.
- Root causes: (1) slam shockwaves spawned at centerX +/- 26 - OUTSIDE a hugging player - and raced away, so point-blank was a safe spot; (2) 60 hp ends the fight inside two attack cycles at starter DPS.
- Fix: slam waves now spawn at the fists (+/- 6, boss_core.dart executeAttack) and both bosses are 150 hp (GroveGolemCore/KilnGolemCore maxHp; HUD/phases key off maxHpTotal so no other change). Charter comment rewritten with measured numbers; intent-test log prints hp/maxHpTotal.
- After: masher probe pays 7 hits / ~2 lives for a 20 s kill; live replay of the same script WIPES at t=37 s with boss at 50/150 in phase 3 (fail overlay verified). Coached gate still wins every seed (45 s w1, 23 s w2, within first-life pace on strikes).
- Suite 445 green, analyze clean. Dart-only - no mirror sync owed. Captures /work/temp/rel/desk/boss/.

## 2026-09-01 11:25 — Title screen QA + corner build label (unpublished, freeze)
- Title QA at 844x390, 390x844, 320x568: parallax drift live (4s-apart frames differ), FittedBox handles the 320px case, hierarchy clean, ui_tap + ember ambience wired and assets present. No layout defects.
- Gap vs pillar 4 / alpha-testing practice: no version visible anywhere, so testers can't say which build a bug came from. Added lib/version.dart (kAppVersion) + bottom-right corner label on the title (Positioned outside the FittedBox column, SafeArea, white38 10px). test/version_test.dart fails the suite if kAppVersion drifts from pubspec.yaml; docs/release.md step 2 updated to bump both.
- Screenshot-verified at 844x390 and 320x568 (/work/temp/rel/desk/titlev_*.png): legible, unobtrusive, clear of menu.
- Suite 445 green (+1), analyze clean. Dart-only - no mirror sync owed.

## 2026-09-01 11:00 — Combined feel-stack playthrough critique (record; no defects)
- Real run in w1_l2 seed 7 (enemies live), phone viewport 844x390: run -> jump -> land burst captures (/work/temp/rel/desk/feel_*_c.png).
- Takeoff stretch visible immediately after jump input, normal 100ms later. Landing frame composes squash + landing puff + trailing run dust into one beat - no clutter. Run dust intermittence is correct by construction (life 0.22s < kFootstepInterval 0.26s -> deliberate gaps).
- Hierarchy verified in situ: dust < landing puff < hard-land thud (2.0) < hurt (3.0). No anchoring drift, no sprite sliding.
- Hard-land camera bump not still-capturable (1-2 frames); accepted via unit tests + charter check. Pitch variance needs the on-device listen-through (P-M7).
- Verdict: feel stack ships as a composition. No changes needed.

## 2026-09-01 10:40 — Run dust puffs (research backlog item 3) (unpublished, freeze)
- Footstep tick in ember_game.dart (cadence-gated step sfx site, ~:520) now also spawns a PuffFx at the heel (centerX - facing*4, bottom-1): alpha 0x55, life 0.22s, radius 2.5 - deliberately smaller/dimmer than the landing puff so it reads as trail, not event. Audio-visual sync for free since it rides the existing _stepClock.
- Perf: PuffFx is allocation-free after construction; spawn rate = footstep cadence (kFootstepInterval), max ~4/s, self-removing. Negligible on low-end.
- Browser-verified with feet-band crops on clear ground (/work/temp/rel/desk/dust_crop*.png): puff visible at heel mid-run, faded next frame, invisible when idle.
- Suite 444+1 green, analyze clean, web build ok.

## 2026-09-01 10:15 — Heavy-landing thud (research backlog item 2) (unpublished, freeze)
- New PlayerEvent.landedHard fires alongside landed when the fall spanned >= kHardLandTiles (4) tiles, tracked via _fallTopY (highest airborne point since last grounded; y grows downward so it's a min()).
- Render response: _camBump = max(current, 2.0) + Haptics.light(). Design-checked against the AKP-3e charter first: shake stays reserved for impacts that matter - 4 tiles never triggers in normal hop-play (verified: flat-ground jump lands soft in the unit test), stays below the hurt bump (3.0), and the single _camBump consumer already respects the screen-shake toggle.
- Both directions unit-tested in physics_test: normal jump = landed only; 5-tile teleport-drop = landed + landedHard.
- Suite 444+1 green, analyze clean.

## 2026-09-01 09:55 — Pitch-varied SFX (research backlog item 1) (unpublished, freeze)
- playSfx now wobbles playback rate uniformly in [0.94, 1.06] for the 10 fatigue-prone ids (coin, enemy_hit, player_hit, land, step1/2, swing1/2/3, block); jingles/UI/jump stay pitch-stable on purpose (confirmation sounds read better fixed).
- Pure helper AudioService.sfxRateFor(id, unit) + variedSfx set are public and unit-tested (bounds, stable ids, no-typo check against sfxPaths). setPlaybackRate sits inside playSfx's existing try/catch - platforms that reject rate changes (some low-latency Android paths) degrade to normal pitch silently.
- audioplayers note: SoundPool (Android lowLatency) supports rate 0.5-2.0; web supports playbackRate; worst case is a no-op. On-device listen-through still owed when P-M7 unblocks.
- Suite 443+1 green, analyze clean.

## 2026-09-01 09:30 — Research pass + takeoff stretch (AKP-3a pairing) (unpublished, freeze)
- Owner directive (09-01): keep it smooth on low-end, keep animations/visuals/controls high quality, research current Android + indie practice regularly. Findings + audit in docs/research-2026-09.md.
- Compliance VERIFIED against artifacts (not just docs): alpha.20 APK passes `zipalign -c -P 16` (16KB page mandate, Nov-2025) and targets API 36 (Aug-2026 mandate). NDK r27 pinned. No Android config change needed - no mirror sync.
- Feel audit vs current practice: coyote 0.10s / jump buffer 0.12s / attack buffer 0.15s / land squash 15% / hit-stop / hurt-shake all already in spec ranges. Gap: no takeoff stretch.
- ADDED: takeoff stretch - 10% narrower/taller for 100ms on jumped + airJumped, feet-anchored, render-only, squash outranks stretch on conflict (else-if). Test added (juice_test). Verified in browser: takeoff frame visibly taller/narrower, normal after landing.
- Backlog recorded in research doc: pitch-varied sfx, fall-height-scaled landing shake, walk dust, in-level parallax (all need device perf checks first; P-M7 still blocked).
- Evidence /work/temp/rel/desk/stretch_*.png. Suite 442+1 green.

## 2026-09-01 08:55 — Real-navigation smoke: title -> select -> game -> pause -> leave -> re-enter (verification only, no code change)
- All prior overlay QA used the harness's no-op callbacks; this pass drove the REAL widget stack by pixel coords in the browser: PLAY (422,209) -> Forest Edge row (422,128) -> gameplay + lore -> pause button (711,57) -> PAUSED overlay -> Leave level (422,241) -> level select (state intact, wallet/records preserved) -> re-enter -> fresh run (timer reset).
- Zero defects: no stuck overlays, no black screens, no double-mounted game. Real GameScreen callbacks (resume verified earlier; leave verified here) both good.
- Evidence /work/temp/rel/desk/nav_1..5*.png.

## 2026-09-01 08:35 — Sign-clip ROOT CAUSE fixed: bubbles now wrap to the view (unpublished, freeze)
- The 'positional' clip was misdiagnosed: the bubble TextPainter laid out on ONE unbounded line, so any text wider than the 352px view clipped no matter what - the edge clamp can only rescue bubbles narrower than the view. Position only decided which clips got rescued.
- Fix: layout(maxWidth: kBubbleMaxWidth) where kBubbleMaxWidth = viewWidth - 10 (2px margin + 3px padding per side), new public const on ItemsComponent.
- Proof: temporary 171-char sign1 in w2_l5 wraps to two full lines entirely in view (would previously have run off-screen); probe reverted, short signs verified pixel-identical after.
- Retires the standing 'positional clip, root cause unresolved' item; the screenshot-verify-every-new-sign rule stays (cheap, catches other classes).
- Evidence /work/temp/rel/desk/wrap_probe.png, wrap_after_short.png.

## 2026-09-01 08:10 — Daily Delve deep QA + ?dailybest harness param (unpublished, freeze)
- New harness param ?dailybest=MS fakes a daily best recorded today (sets save.dailyBestDate=dailyKey(now) + dailyBestTimeMs), so the title's 'best M:SS' subtitle state is screenshot-able.
- Title verified both states on phone: fresh = 'DAILY DELVE / Charcoal Camp' (today's dailyLevelId), best = 'Charcoal Camp · best 1:07' (67000ms, math correct). Layout clean, no wrap.
- Full flow verified: clicking DAILY DELVE (canvas app - click by pixel coords 422,258, no DOM locators) opens exactly the promised level with lore banner ('They burned the wood to keep the wood away.'), normal HUD. Determinism subtitle-to-run confirmed visually; payout/record semantics already unit-tested in daily_test.dart.
- Playwright note: flutter web = canvas, text locators NEVER match - always click by coordinates.
- Evidence /work/temp/rel/desk/title_fresh.png, title_best.png, daily_run*.png.

## 2026-09-01 07:45 — Level-content invariants promoted to tests (unpublished, freeze)
- test/level_data_test.dart 'shipped levels' group grew two tests: (1) sign grid/meta parity - every grid `s` needs a numbered `meta: signN=` with non-empty text and vice versa (the exact bug class shipped in w2_l5 until today; session.dart silently renders '' for missing metas and never renders orphans); (2) economy invariant - all 10 combat levels carry exactly 2 chests + 2 secret chests.
- Mutation-verified: removing w2_l5's sign2 meta fails the parity test; file restored. Suite 441+1 green.
- Authoring note for future me: writing Dart `$`-interpolation through python heredocs is escape-hell - write test bodies with plain $ (quoted heredoc passes them through) instead of escaping.

## 2026-09-01 07:20 — World 2 in-place visual sweep; w2_l5 orphaned sign placed; opening coin motifs differentiated (unpublished, freeze)
- Full w2 sweep, 17 in-place phone captures (3 per level + boss): burnt-forest palette, skull-brick platforms, fire/vent hazards all render clean. Grids verified genuinely distinct (5-9/20 shared rows in cols 0-44, mostly empty rows).
- Found + fixed: w2_l5 had `meta: sign2=` ("Work floors ramp to the kiln...") but only ONE `s` in the grid - authored text that never rendered. Placed at row 13 col 41 (start of the work-floor ramps, solid below). Scan order made it sign1, so meta texts swapped; both signs screenshot-verified in place (peace=1, H patroller nearby).
- Sign audit script extended mentally: grid `s` count vs `meta: signN=` count must match - w2_l5 was the only mismatch repo-wide.
- Found + fixed: w2_l2/l4/l5 opened with the IDENTICAL 7-coin diamond over the same P/sign/rock runway - first impressions of three levels were interchangeable. l4 now opens with rising staircase pairs (hints its col-22 high ledge), l5 with a low running line; l2 keeps the diamond. Coin totals per level unchanged. Both reshaped openings screenshot-verified.
- Capture-artifact note (not bugs): spawning ?spawn onto fire tiles (w2_l4 65,15 / w2_boss 20,12) costs a life before the shot - pick spawn tiles off hazards.
- Evidence /work/temp/rel/desk/w2_*.png.

## 2026-09-01 06:40 — Level select + settings deep QA; harness gets a real AudioService (unpublished, freeze)
- Level select: fresh-save and allclear states verified on phone (fresh: only Forest Edge open, locks + "Finish all five levels to face the Golem" hint; allclear: numbered green badges, boss flame badge, 3 gold medal icons per row). Zero defects. "DELVE" appbar title checked for rename residue - it predates Pyregrove but reads as the campaign verb (title tagline "Delve the burning grove", Daily Delve) - kept.
- Settings: found the harness hid Music/SFX sliders AND the haptics/screen-shake toggles behind the 'Audio unavailable' fallback (they're gated on AudioService.instance, which shipping main.dart always sets but the harness left null - so those controls were never QA-able). Harness now installs a real AudioService with in-memory AudioSettings (playSfx is internally try/catch'd; headless-safe). Full screen verified: sliders at 70%/90%, both toggles ON default, analytics OFF default, confirm-guarded reset dialog ("cannot be undone", red RESET).
- Note: the 'Audio unavailable' ListTile in settings_screen.dart is dead code in the shipping app (instance set before runApp); left in place as a harmless failsafe.
- Evidence /work/temp/rel/desk/select_*.png, settings_*.png.

## 2026-09-01 06:05 — Shop deep visual QA: all 4 tabs + scrolled bottoms, zero defects (unpublished, freeze)
- First full-depth pass over the shop (?screen=shop&coins=500, phone viewport): WEAPONS / SKINS / SPELLS / ABILITIES tabs plus scrolled list bottoms all render clean - no clipping, stat bars scale correctly, EQUIPPED vs BUY states right.
- Affordability edge verified: Apple Pouch at exactly 500/500 coins shows an enabled green BUY (>= not >); gem-priced items correctly greyed at 0 gems and use the distinct gem glyph.
- Only defect found: a stale header comment calling it "the 3-tab meta shop" (predates SPELLS) - fixed. Evidence /work/temp/rel/desk/shop_*.png.
- Harness know-how: tabs are clickable at y=78, x=844*(i+0.5)/4 on the 844x390 viewport; mouse wheel scrolls the lists.

## 2026-09-01 05:35 — Pause overlay: last banner stub replaced with the real widget (unpublished, freeze)
- PauseOverlay made public and mounted in the harness with the real g.resumeGame callback (leave is a no-op); the unused _HarnessBanner stand-in is deleted - every in-game overlay the player can see is now the shipping widget.
- Verified 844x390 + 1600x900: panel clean, Resume actually resumes (telemetry time ticks after click). Evidence /work/temp/rel/desk/pause_*.png.

## 2026-09-01 05:00 — End-of-level screens: real overlays in the harness, both verified (unpublished, freeze)
- The web harness stubbed results/fail overlays with banner placeholders, so the actual player-facing end screens had never been screenshot-verified. Made ResultsOverlay/FailOverlay public in lib/ui/game_screen.dart and mounted the real widgets in main_webtest.dart with no-op navigation (pause keeps its stand-in).
- Verified: LEVEL CLEAR panel (time vs par, coins, chests, 3 medal states) clean on 844x390 and 1600x900; FALLEN screen clean on phone. Evidence: /work/temp/rel/desk/results_*.png.
- Capture know-how: spike pits can't reliably kill for a game-over capture — hazardEject (AKP-6b) throws the player out of the pit. Park the player on a thornling home tile instead (?spawn=52,15 on w1_l2): contact loop kills through all lives in ~40s.

## 2026-09-01 04:10 — Desktop visual pass + credits screen readability fix (unpublished, freeze)
- First full desktop-viewport (1600x900) pass: title, select, shop, settings, credits, w1_l1/w2_l2 gameplay, w1 boss intro. All meta screens and the fixed-res game camera scale cleanly. Touch controls visible on desktop are harness-only (Android is the shipping target). Evidence: /work/temp/rel/desk/.
- Real defect found: credits screen rendered one Text per source line, so the hard-wrapped CREDITS.md showed ragged mid-sentence breaks and broken bullet indents; backticks leaked through literally. Rewrote lib/ui/credits_screen.dart around a testable parseCreditsBlocks() that coalesces wrapped lines into paragraph/bullet blocks and strips ** and ` — Flutter now does the wrapping. 4 new tests (test/credits_blocks_test.dart). Verified on both viewports.

## 2026-09-01 03:20 — Sign audit COMPLETE: all 18 long signs verified full-render (unpublished, freeze)
- Finished the sign audit with screenshot evidence: every sign over 55 chars (18 across 13 levels) captured in place on the phone viewport and confirmed rendering fully — w2_boss (fixed last iteration) was the only clipper. Shorter signs are well under any observed clip threshold. Evidence: /work/temp/rel/audit_*.png.
- Three captures kept failing because hoppers/ashbats knocked the player off the sign during the 5.6s lore wait. Added harness param `?peace=1` (main_webtest.dart, test entrypoint only): clears session.enemies once up. Quirk: sprites linger as inert ghosts — the renderer holds its own enemy list — but contact/damage is gone (enemiesAlive=0, hitsTaken=0). Documented in docs/web_testing.md.
- Capture-QA rule: spawning ON a sign next to a patroller needs &peace=1; a "no bubble + hitsTaken>0" screenshot means the capture is invalid, not that the sign is broken.

## 2026-09-01 02:50 — Sign audit: w2_boss brief was clipped mid-sentence (unpublished, freeze)
- Audited all 28 signs across 13 levels with a scan-order length report + screenshot spot-checks (new ?spawn param makes each check ~30s). Result: 74-77 char signs render fine (w1_l1, w2_l4 verified full), but w2_boss sign1 was 178 chars — hard-clipped at the screen edge, cutting off the boss's core mechanic ("climb the vents, strike its crown") and the lingering-fire warning. Players only got "...walled into its own kiln - no blade reaches it from the floor. Climb the vent pillars and st|".
- Fix: split into two signs along the approach floor: sign1 @c7 "Its kiln walls it in. No blade lands from the floor." (52) + NEW sign2 @c16 "Climb the vents - strike the crown. Embers burn where they fall!" (64). Both screenshot-verified full on phone viewport; sign2 sits 192px from the dormant boss (wake radius 120px) so it reads safely pre-fight.
- Earlier "keep ≤~50 chars" note refined: length alone isn't the trigger (74+ renders fine elsewhere); the clip is positional. The hard rule stands: screenshot-verify every new/edited sign in place.

## 2026-09-01 02:25 — Mimic fair-warning sign + sign-bubble viewport clamp (unpublished, freeze)
- w1_l3 gets a 4th sign on the high-road approach shelf (r13 c69, beside the decoy bush): "Some bushes bite. Prod before you pass." — the mimic now has an AK-style fair introduction (honest-presentation pillar). Sign metas renumbered: parser assigns sign1..N in row-major grid-scan order, so the new r13 sign becomes sign1 and the old three shift to sign2-4. RULE: adding a sign anywhere renumbers every sign after it in scan order — always re-map the meta lines.
- Sign bubble (items_component.dart) now clamps horizontally/vertically to the camera view instead of naive world-space centering (defensive; analyze+suite green).
- LEARNING: long sign texts (>~55 chars) can still clip on web — my 63-char draft cut off mid-word in captures on BOTH phone and exact-16:9 desktop viewports while the 65-char sign2 rendered fine elsewhere; suspected TextPainter/font measurement quirk in the cached painter. Keep sign texts ≤ ~50 chars; verify new signs with a capture (spawn param makes it 30s).
- Verified in-game (phone viewport): full bubble text, sign placed in the bush/coin scene as intended. Probe medium at exact baseline after sign placement; suite 435+1 green.

## 2026-09-01 02:00 — Harness ?spawn=col,row + mimic scenes verified at final spots
- Added `?spawn=col,row` to lib/main_webtest.dart (harness-only, one-shot teleport that also moves the respawn point) — look-passes can now screenshot ANY scene without a scripted bot surviving the walk there. Documented in docs/web_testing.md. Dart-only, nothing in the Android app reads it.
- Visual QA at final mimic placements (phone viewport 844x390, w1_l3 seed 7):
  - Chest platform (r11 c72/74/76): hidden mimic renders pixel-identical to the real decoy bush — bush/chest/bush reads exactly as intended ambiguity. Reveal + hit verified (leaf-green tint, knockback).
  - Late spot (N r15 c104→105 area): reveal + pursuit verified; test spawns inside trigger radius prove the ambush fires. Note the tail layout is B@97 X@99 B@101 N@105 C@107 (earlier session notes said c104/c106 — off by one, corrected here).
- Suite 435+1 green, analyze clean.

## 2026-09-01 01:40 — Mimic camouflage fix: decoy bushes (unpublished, freeze)
- Decor audit found w1_l3 had ONE real bush but TWO bush-mimics — camouflage by rarity fails: when bushes are rare, every bush is suspicious and the mimic reads as "the obvious trap prop", not an ambush.
- Planted 4 decoy bushes on natural ground (start ground c23, mid ledge r13 c65, chest platform r11 c72 right next to the mimic, endgame ground c95). Bush population now 5 real + 2 mimics; the chest-platform decoy pairs a true bush beside the mimic so even players who KNOW the tell must look twice.
- Decor is renderer-only (zero collision) — level linter + full suite green (435+1), probe medium AND hard at exact baseline (0 deaths / 2 hits, all seeds).
- Design rule for future mimic placements: never place a mimic in a level (or world) whose bush count is 0-1; decoys are part of the enemy.

## 2026-09-01 01:15 — Curve-at-freeze record (medium, casual probe bot, seeds 7/42 agree)
| level | result | t | deaths | hits |   | level | result | t | deaths | hits |
|-------|--------|---|--------|------|---|-------|--------|---|--------|------|
| w1_l1 | DONE | 14s | 0 | 2 |   | w2_l1 | DONE | 23s | 1 | 4 |
| w1_l2 | DONE | 18s | 0 | 2 |   | w2_l2 | DONE | 26s | 1 | 5 |
| w1_l3 | DONE | 18s | 0 | 2 |   | w2_l3 | DONE | 26s | 1 | 3 |
| w1_l4 | DONE | 18s | 0 | 2 |   | w2_l4 | DONE | 28s | 1 | 7 |
| w1_l5 | DONE | 22s | 0 | 3 |   | w2_l5 | DONE | 27s | 1 | 5 |
| w1_boss | WIPE (by design) | – | 3 | 9 |   | w2_boss | WIPE (by design) | – | 3 | 8 |
- Monotonic: every w1 level ≤ every w2 level; no level out-classes its world. Bosses wipe the CASUAL bot by design (the suite's own boss-bot tests prove completability with real fighting). Mimics in w1_l3 cost the through-path nothing. w2_l4 (7 hits) is the in-world peak — end-of-world position, acceptable.
- This is the baseline to diff after any future level/enemy change: full log /work/temp/rel/probe_table.log, command in test/wipe_probe_test.dart header.

## 2026-09-01 00:55 — NEW ENEMY: Bramble Mimic (unpublished, freeze)
- Owner wishlist "more enemies". BrambleMimicCore (enemy_core.dart) extends ThornlingCore via new `.asKind` ctor: sits disguised as the ordinary bush prop, reveals when the player comes within 56px*aggro (or pokes it — damage() override), shivers harmless for 0.7s*telegraph (`harmless` getter, new session contact gate `!e.harmless`), then fights with the thornling patrol/hunt brain at hp 8. Legend char 'N'. SessionEventKind.mimicRevealed -> leaf PuffFx + 'block' sfx + light haptic. Render: props/bush.png bottom-anchored (trembles during telegraph), revealed = thornling strip tinted leaf-bright 0xFFB8D97A so veterans can tell mimic from thornling. All existing art (honest-presentation pillar).
- Design rules learned via probe iterations: (1) mimics guard OPTIONAL treasure, never the mandatory walk line — walk-line placements wiped the hard bot at the game's third level (respawn camping); (2) respawn-clear now calls rehide() so a revealed mimic goes back into its bush (fresh telegraphed ambush instead of a hunter camping the checkpoint); (3) hidden mimics settle under gravity — screenshot pass caught a floating bush over the spike pit that dropped into hazards on reveal.
- Placement (w1_l3 "Bramble Hollow" — the lore line already foreshadows them): one guarding the high-road chest (r11 c75), one before the late chest (r15 c104). Probe: medium AND hard identical to pre-mimic baseline (0 deaths / 2 hits all seeds) — mimics only cost players who detour for loot.
- Tests: test/bramble_mimic_test.dart, 6 tests (hidden+harmless+motionless; proximity reveal event once + harmless shiver + hunts after; contact gate across all three states; poke reveal; difficulty scales shiver; respawn rehide). Suite 435 passed + 1 skipped, analyze clean.
- No tag, no release per freeze.

## 2026-09-01 00:25 — Session audit: freeze compliance + enemy roster (no code change)
- Freeze audit: tags stop at v1.0.0-alpha.20 locally AND on origin; no releases cut; android/ untouched since the mirror snapshot of 89af754 (every commit since is Dart/level/test/docs only, so pyregrove-ci mirror sync is NOT required). 13 commits accumulated on main for the owner's consolidated cut.
- Enemy-usage audit across all 12 levels: all 11 enemy kinds are placed, distribution escalates properly (w1: thornling-heavy intro; w2: sootCreeper base + rare pyreWisp late). No dead content — "more enemies" wishlist item is genuinely served; next content work should be new-enemy design, not placement.
- Session totals (2026-08-31): boss presentation trilogy (dormant intro b0e5b54, wake b135aa9, death 158372f, phase 46d34ca), balance (w1_l4 5de8436, w1_l2 be55733 + hard/medium probe sweeps), kiln QA + ?bosshp harness (e4c8ddf), screen-shake toggle + phone wrap fix (f8b4c44). Suite 429 passed + 1 skipped, analyze clean throughout.

## 2026-09-01 00:05 — Screen-shake toggle + phone settings wrap fix (unpublished, freeze)
- Accessibility: today's juice added several _camBump producers; players prone to motion sickness need an off switch. AudioSettings gains `screenShake` (default true, json roundtrip + legacy-file test — settings written before the field must not turn it off). Single guard at the bump APPLICATION site in ember_game (covers all producers, present and future). Settings UI: "Screen shake — camera kick on hits and boss beats" switch under Haptics.
- Note: harness `?screen=settings` shows "Audio unavailable" (no AudioService in web harness), so the switch is verified by test, not screenshot; it renders on device beside Haptics.
- Bonus fix found in the phone screenshot pass: the difficulty SegmentedButton wrapped "Medium" onto two lines at 390px width. showSelectedIcon:false + tighter padding + 13px text; verified at 390x844.
- Gates: analyze clean, 429 passed + 1 skipped (new settings test). No tag, no release per freeze.

## 2026-08-31 23:40 — Kiln Golem presentation QA + ?bosshp harness param (unpublished, freeze)
- All boss presentation beats (wake/phase/death) were only visually verified on the Grove Golem; the Kiln Golem shares the code but a different palette (kiln-terracotta). QA'd all beats on w2_boss.
- The w2 arena is too roamy for the scripted hammer duel (bot died for 200s; the golem climbs the pillars). Added harness-only `?bosshp=N` to main_webtest.dart: clamps boss hp once spawned, NO fake events — the capture bot then lands one real hit (apple lob from the one-way platform perch, KeyC) to cross each threshold with full presentation. Capture: /work/temp/emberwood_shots/a28/bot4.py (bosshp=41 -> phase2, 21 -> phase3, 1 -> kill).
- VERIFIED on kiln palette: dormant grey statue + hidden bar; wake beat; threshold shard bursts + gold surge; steady P3 warm tint clearly distinct from phase-1 teal AND from the red telegraph; kill freeze + 2x flash + rubble + coin/feather shower.
- Perch numbers for future w2_boss capture: double jump at x≈285, land one-way platform, stop x≈372-392 (y≈198); boss wakes from there; apples hit at that range.
- Gates: analyze clean, 428 passed + 1 skipped. No tag, no release per freeze.

## 2026-08-31 23:10 — Hard-mode probe pass + w1_l2 stacked-pair fix (unpublished, freeze)
- Probe gained --dart-define=DIFF=easy|medium|hard (test/wipe_probe_test.dart). Hard sweep across all 10 non-boss levels: everything COMPLETED on all seeds; only outlier w1_l2 (2 deaths/8 hits — worse than any w2 level on hard, at the game's second level).
- Cause: ashbat V stacked directly over the thornling T (row13 col50 over row15 col52) — hard's 1.25x aggro triggers both at once.
- Tried three placements, probed each on multiple difficulties: col44 ground-level fixed hard (0/2) but broke medium (0/2 -> 2/5, bat ambushes open ground); raised row11 col50 keeps medium at 0/2 and improves hard 8->7 hits; col46 raised identical to col50 raised. Settled on raised row11 col50 (minimal diff; dive from above telegraphs itself).
- IMPORTANT probe learning (documented in the test header): easy-mode hit counts are a BOT ARTIFACT — slower enemies hover beside the dumb bot and re-contact after iframes (easy reads 2/7 on every layout tried, incl. original). Humans get more reaction time on easy. Compare medium/hard only. Also: git stash during A/B baselines reverts the probe's own edits — one baseline run silently measured medium 3x before I caught the missing difficulty tag in the output.
- Residual hard 2/7 at w1_l2 is thornling roam pressure (fair, single, telegraphed) — accepted; hard should bite and the bot is a casual proxy (bosses wipe on it by design).
- Gates: analyze clean, 428 passed + 1 skipped. No tag, no release per freeze.

## 2026-08-31 22:45 — Difficulty-curve audit: w1_l4 spike fixed (unpublished, freeze)
- Ran the wipe probe (casual bot, seeds 7/13/42/99, Difficulty.medium) across all 12 levels: every non-boss level COMPLETED with 0-1 deaths EXCEPT w1_l4 — WIPED at 48% on all seeds (3 deaths, 8 hits, 7 of them from the Rotshield at row13/col27). Curve inversion mid-world-1: w1_l4 played harder than all of world 2. Bosses WIPE by design (skill check; the casual bot can't fight).
- Cause: that Rotshield patrolled the mandatory 2-tile-high mound top — the player has to jump onto it straight into the guard. The sign's lesson ("bait the guard-turn") is unplayable on a 7-tile perch.
- Fix (level data only): Rotshield moved to open ground at row15/col36 (before the apple/sign, room to bait or jump over — mirrors this level's own fair col104 encounter); heart pickup `h` on the mound top at col27 (w1_l4 was the only hit-heavy w1 level with zero hearts; w1_l5 has 2).
- Re-probe: COMPLETED t=18s, 0 deaths, 2 hits on all seeds — now sits between w1_l3 (2 hits) and w1_l5 (3 hits). Bot still meets the Rotshield once, so the teaching beat survives.
- Full-run probe log: /work/temp/rel/probe_all.log. Gates: analyze clean, 428 passed + 1 skipped. Visual: heart on mound + clear jump verified (a26/).
- No tag, no release: accumulating on main per the freeze.

## 2026-08-31 22:20 — Boss phase-up presentation + enrage tell (unpublished, freeze)
- Middle beat of the fight: bossPhase had sfx+camBump but zero visual on the boss, and P3's 1.6x speed was invisible.
- Now: shard burst at the boss on each threshold (ember_game bossPhase handler, RubbleFx count 18 / power 1.2, position via session.boss — the event only carries the phase); white-GOLD surge + tremble on the boss for kBossPhaseFxTime 0.5s (render-layer detection in EnemyComponent: _phaseSeen/_phaseFlashT, headless core untouched); constant kiln-gold enrage tint (0xFFFFC275 modulate) while phase==3.
- Color audit: first cut used red — collided with the telegraph tint 0xFFE86A4A ("attack incoming" must never look like "enraged"). Re-hued to gold; comment in code pins this.
- Harness: window.__pyregrove gained bossHp/bossPhase for deterministic phase captures (tool: /work/temp/emberwood_shots/a25/shoot_phase2.py).
- Gates: analyze clean, 428 passed + 1 skipped. Visual: threshold burst, gold surge, and steady P3 warm tint all verified (a25/q*.png); paint priority hurt > dormant > wake > phaseFlash > telegraph > enrage.
- No tag, no release: accumulating on main per the freeze.

## 2026-08-31 22:05 — Boss death presentation: the kill lands hard (unpublished, freeze)
- Bookend to the wake intro. Before: a 72×56 golem died with the same 40×41 poof as a thornling, straight into the coin shower.
- Now: `kBossKillPause` 0.22s frame-freeze on the killing blow (set in `_onEnemyDeath` for BossCore — covers sword/apple/burn paths), then a 2× death flash (`DeathFx` grew an optional `size`) + heavy rubble burst (`RubbleFx` grew `power` scaling speed/shard size; count 26, power 1.5) over the existing coin/feather shower.
- Tests: +1 in boss_core_test.dart (killing blow sets hitPause > kHitPause, via burn-tick kill). Gates: analyze clean, 428 passed + 1 skipped.
- Visual: scripted hammer-bot kill in the web harness (shots/bot /work/temp/emberwood_shots/a24/) — frozen kill frame → big flash + shards → coin fountain + feathers → door open.
- No tag, no release, no version bump: accumulating on main per the freeze.

## 2026-08-31 21:35 — Wake presentation pass: the stone shell cracks off (unpublished, freeze)
- Follow-up to the dormant-intro fix: the wake was mechanically right but visually just an instant tint flip. Now (all render-side, no gameplay/hitbox/timing change):
  - `RubbleFx` (fx.dart): one-shot seeded burst of 14 stone shards + moss flecks with gravity, spawned at the boss on `bossAwakened`; allocation-free render, fades over 0.7s.
  - Tint crossfade: statue grey → flesh lerped over `kBossWakeFxTime` 0.6s (reused `_wakePaint`, filter re-lerped per frame) instead of the instant flip.
  - Tremble: ±1.6px sin shake on the sprite draw position during the crossfade, damping to 0.
  - Driven by new `BossCore.sinceWake` clock (0 while dormant, counts up after wake, capped at 60s).
- Tests: +1 in boss_wake_test.dart (sinceWake zero while dormant, counts after wake). Gates: analyze clean, 427 passed + 1 skipped.
- Visual: 8-frame burst capture around the wake (shots /work/temp/emberwood_shots/a23/) — statue → bar slam + shard burst → mid-crossfade tremble → normal tint.
- No tag, no release, no version bump: accumulating on main per the freeze.

## 2026-08-31 21:05 — Boss intro readability: bosses now spawn DORMANT (unpublished, freeze)
- Problem (logged at alpha.20): Grove Golem started its attack cycle at spawn, 368px from the player with a 176px camera half-view — the first shockwave arrived from off-camera, unseen. First contact with the boss was an invisible hit.
- Fix: new `BossState.dormant` initial state for both bosses (BossCore). A dormant boss is a statue — no walking, no attacks, no hazards, rendered with a desaturated mossy-grey tint, boss HP bar hidden (the bar+name appearing IS the intro beat). Wakes on player proximity (`kBossWakeDistance` 120px — statue is clearly on screen for ~0.7s of approach before it stirs; visually tuned down from 208→192→160, which all woke it the frame its edge entered the screen) or on a landed hit (ranged apple opener wakes it, dormant ≠ invulnerable). Wake emits `bossAwakened` (thud sfx + haptic + camera bump), then `kBossWakeGrace` 1.5s before the first telegraph. Exit door stays locked while dormant.
- Tests: new test/boss_wake_test.dart (5 tests: dormant beyond range w/ no hazards+locked door, proximity wake fires event exactly once at ≤ wake distance, grace holds before first telegraph then attacks follow, landed hit wakes, kiln golem dormant too). Attack-cycle suites (boss_core, kiln_golem) wake the boss in their session helper — they test the cycle, not the intro. Gates: analyze clean, 426 passed + 1 skipped.
- Visual: verified in web harness — statue beat reads, wake slams the bar in, first telegraph/slam fully witnessed (shots in /work/temp/emberwood_shots/a22/).
- No tag, no release, no version bump: accumulating on main per the freeze.

## 2026-08-31 19:55 — RELEASE FREEZE acknowledged; alpha.21 tag retracted
- Owner directive 3a67796 (19:52Z) landed while the alpha.21 "Migration Ready" tag push was mid-flight; the tag reached both repos before the directive was read. **No GitHub release was created and no assets were published.** Remediation: v1.0.0-alpha.21 tag deleted from pyregrove AND pyregrove-ci; releases stop at alpha.20 (published ~19:30Z, before the directive).
- The alpha.21 *work* stays merged on main per "freeze is on publishing, not on work": explicit R8 config + trimmed keep rules, backup/device-transfer rules (saves included — Pyregrove has no paid entitlements), version 1.0.0-alpha.21+33, correction appended to docs/PLAY-QUALITY-2027.md (Flutter already minifies by default; alpha.21 classes.dex byte-identical to alpha.20).
- From here: no tags, no releases, no store-listing edits. Work continues on the owner's ranked focus list (download size first).

## 2026-08-31 20:05 — Freeze focus item 1 (download size): Pyregrove MEASURED, already compliant
- Split-per-ABI release APKs (local build @ alpha.21+33 config): armeabi-v7a **18.6 MB**, arm64-v8a **20.2 MB**, x86_64 **21.6 MB** — all under the 30 MB bar; universal 50.8 MB (this repo's pillar 3 says ≤ 60 MB). The 33–37 MB split APKs cited in the directive were measured on the other repo (Emberdelve), not here.
- arm64 composition (compressed): libflutter.so 11.05 MB + libapp.so 4.75 MB = 15.8 MB native (engine floor), assets 2.94 MB (audio 2.1 MB, fonts 0.98 MB), classes.dex 0.86 MB. No credible trim target without cutting content; icon-font already tree-shaken 99.8%.
- Conclusion: no size work needed for Pyregrove. Focus item 2 (R8 explicit + backup/device-transfer rules) already merged on main; mirror pyregrove-ci main @ 89af754 snapshot carries the same Android config (mirroring rule satisfied), no tags/releases anywhere past alpha.20.

## 2026-08-31 — v1.0.0-alpha.20+32 "Storefront" SHIPPED (store asset pass)
- 6 landscape 1920×1080 store screenshots in docs/store/screenshots/ (Old Orchard run, Ember Vault, Grove Golem duel, level select, Ember Shop, title) — all captured from the real game via the web harness; boss duel framed with a pixel-scoring burst picker (golem+player both visible, full hearts). Capture/compose scripts committed in tool/store_shots/.
- Feature graphic 1024×500 (real title backdrop + in-app Cinzel wordmark, honest tagline). play-listing.md: screenshots + feature graphic checked off; remaining Play items owner-gated (P-M10).
- Coordination note: another AI pushed docs to main mid-release (5c094c1 Play-quality-2027 brief) → rebase + re-tag before mirror sync; tag = c7a5eab.
- Gates VERIFIED: analyze clean; 421 passed + 1 skipped. Release flow: mirror sync (source c7a5eab) → pyregrove-ci run 33431286945 GREEN → androguard VERIFIED 1.0.0-alpha.20 / 32 / com.tsorostudios.pyregrove / pin 286c4760…cee8ffd MATCH → prerelease id 380007609, APK 53244355 B + AAB 53281512 B uploaded, sha256s in notes.
- Boss-fight observation for a future polish pass: Grove Golem spends most of the opener off-camera (arena x≈424, player spawn x≈56) — first contact is an unseen shockwave. Consider a camera intro pan or spawning the golem closer (design call, not a bug).
2026-09-01 THE STEADY RENDERER (mirrored from emberdelve per DEMAND config-mirror rule): AndroidManifest opts out of Impeller (io.flutter.embedding.android.EnableImpeller=false), keeping Skia. Rationale: Adreno <=650 is Vulkan-denylisted -> Impeller GLES measures ~28fps vs Skia ~54 on Adreno 506 (flutter/flutter#187009); Android-10 Mali ImageDecoder SIGABRT under Impeller (#190640); pure-2D CustomPaint game. Flag verified in emberdelve's merged manifest via aapt2 [2026-09-01]. Re-evaluate on every Flutter upgrade. Manifest-only; synced to pyregrove-ci mirror.
