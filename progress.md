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

## 2026-09-02 13:19Z — alpha.23 #43: clear card shows Hits, so a missed low-damage medal explains itself
- Mirror CI recorded: 33633743185 (3d83097 = a951dcd, #41) **green**; 33634223310 (baf39dc = 447023f, #42) **green**.
- Clear-card audit against the rules (first ten minutes): "Coins +N" is the run's coins and the PERFECT line carries the +25 separately (correct, verified against `totalCoins`); "Chests 1/4" explains a missed All-chests medal; "Low damage" missed had no number next to it — the player could not tell whether they took 2 hits or 6, and the rule (≤ 1 hit) was only ever stated on one sign in w1_l4. Added `hitsTaken` to `LevelResults` (default 0, set in `_complete`) and "Hits N" to the stat line: `Coins +9   Chests 1/4   Hits 0`. Same idiom as Chests, no new row, card height unchanged.
- Proof: test/results_next_test.dart 'shows the hit count beside the medals' (Chests 1/3 and Hits 2 both on the card with Low damage unearned); test/session_test.dart medal test now also pins `results.hitsTaken` to the run's count. Web harness phone 915×412 + desktop 1280×720 clear card: stat line fits on one row at both sizes, no wrap. Shots outside the repo.
- Gates: `flutter analyze` clean; `flutter test` 587 passed + 1 skipped. Release notes item 37.

## 2026-09-02 13:10Z — alpha.23 #42: sign audit closed — every sign claim checked against code; two more corrected
- Finished reading all 30 signs against the enemy/session code. Verified true as written (no change): Hopper "leap at you… time your swing for the landing" (hops toward the player within range); Bramble Mimic "some bushes bite, prod before you pass" (poke reveals, telegraphed); Totem "spit fire on sight, break the line" (line-of-sight gate); Rotshield "block from the front… bait the guard-turn" (front shield, guardTurnDelay); Creeper "do not stop for lava" (creeper hazards); Cinder Diver "watch for the shudder" (telegraph state before dive); Slag Hound "when one crouches, be somewhere else" (crouch telegraph then charge); Kiln Golem "no blade lands from the floor… climb the vents, strike the crown"; Grove Golem "watch its wind-up"; both bonus-level signs describe layout only.
- Two more were false and are fixed:
  - w1_l4 sign3 promised the third medal for "don't get hit"; the rule is `hitsTaken <= 1` (session.dart, results). Stricter than the game — a player who took one hit gave up on a medal they still had. Now "take one hit at most". Pinned: test/session_test.dart runs the door with hitsTaken 0/1/2 → lowDamage true/true/false and asserts the sign text contains "one hit at most", so rule and sign move together.
  - w2_l4 sign1 "Totems spit farther in the dark" — nothing scales totem range by world or lighting (EmberTotemCore.range = 8 tiles × difficulty aggro only). Now "Totems spit on sight from eight tiles out. Break the line, or keep moving." Pinned: test/totem_rotshield_test.dart asserts range == 8 × kTileSize and the sign says "eight tiles".
- Sign audit is closed: 30/30 signs now describe mechanics that exist, behaviours the code has, and controls the HUD shows. Five sign texts changed in total across #40–#42 (w2_l1, w1_l2, w2_l3, w1_l4, w2_l4). Not shipped: keyboard-specific sign variants for desktop — Android is the target and the touch HUD is drawn on every platform, so the button vocabulary is what the player sees.
- Gates: `flutter analyze` clean; `flutter test` 586 passed + 1 skipped. Release notes item 36.

## 2026-09-02 13:05Z — alpha.23 #41: Ashbat signs told the truth-free version; bubble was drawable-under (first ten minutes)
- Continued the sign read-through against the code. w1_l2 sign3 "Ashbats dive from the canopy. Duck under, then punish." and w2_l3 sign2 "Ashbats nest above the spray. Duck the dive, then punish." were wrong twice: AshbatCore is a kinematic sine flyer around its anchor (±36 px sway, ±24 px bob, never targets the player — it does not dive), and the player has no duck (verbs: run, jump, double-jump, swing, roll/dash, drop-through, throw). A new player was being taught a counter that does not exist for an attack that does not happen. Anchors sit 2–5 tiles above ground (w1_l2 cols 50/84, w1_l5 col 52, w2_l3 col 46), so the honest counter is "swing on the low pass, or jump to meet it". New texts: w1_l2 "Ashbats weave in place and never chase. Swing on the low pass - or jump to meet them."; w2_l3 "Ashbats nest above the spray, weaving on a fixed loop. Jump and swing on the low pass."
- Guard extended (test/level_data_test.dart sign-vocabulary test): a sign may not open a sentence by ordering Duck/Crouch/Parry/Block/Slide/Glide/Swim/Fly. Proven to fail on the old w1_l2 text before the fix ("orders a verb the player lacks").
- Real render defect found by the screenshot of the new sign: the Ashbat covered the last word of the bubble. Cause: ItemsComponent (priority 1) drew the active sign bubble; enemies are priority 2, player 3, fx 4/5 — anything moving over a sign hid the text. Fix: lib/game/components/sign_bubble.dart, `SignBubbleComponent` at priority 6 (above damage numbers, below coin flights 9 / HUD 10) — same layout cache, same view clamp, exposes `lastRect`; ItemsComponent lost the bubble code and its text imports. Registered in EmberGame.onLoad under the first-frame hold like every other world layer.
- Proof: test/sign_bubble_test.dart (3 tests) — bubble priority > every EnemyComponent, the PlayerComponent and ItemsComponent on w1_l2; at the Ashbat sign (teleport col 75,15 like the harness) the bubble draws with its rect inside the camera view and ≤ kBubbleMaxWidth; away from signs nothing draws. Web harness reshoot (phone + desktop, w1_l2 spawn 75,15; w2_l3 63,15): the bat now passes under the bubble, all words readable on both viewports. Shots outside the repo.
- Gates: `flutter analyze` clean; `flutter test` 584 passed + 1 skipped. Release notes items 34 (signs) and 35 (bubble layer).

## 2026-09-02 12:48Z — alpha.23 #40: sign vocabulary — one name for the roll everywhere (first ten minutes)
- Read every sign in the game as a new player would (w1_l1 → w2_l3, 30 signs). The tutorial (w1_l1 sign4) teaches "Tap DASH to roll through danger"; the first World 2 sign then said "Roll (DOWN+JUMP) through danger!" — a chord no on-screen control is labelled with. Both inputs work (PlayerCore keeps the DOWN+JUMP chord as the keyboard alternative), but the sign is the only tutorial there is, and it must name what the HUD shows. w2_l1 sign1 is now "Soot Creepers never stop at ledges. Tap DASH to roll straight through them." (roll grants kRollIFrames, so the promise is true).
- Guard: test/level_data_test.dart 'sign text uses the on-screen control vocabulary only' — every sign meta in assets/levels is free of DOWN+JUMP / Shift / Space / WASD / ctrl / "arrow key" (30 signs checked, count asserted >20 so an empty match set cannot pass silently).
- Visual check (web harness rebuilt at this commit, phone 915×412 + desktop 1280×720, w2_l1 spawn 8,15 peace): the new bubble lays out on one line inside kBubbleMaxWidth, no clipping, readable over the ash background. Shots outside the repo.
- Gates: `flutter analyze` clean; `flutter test` 581 passed + 1 skipped. Release notes item 33.

## 2026-09-02 12:40Z — alpha.23 #39: economy pacing measured from the level files; pacing guard test
- Mirror CI recorded: pyregrove-ci 33628837602 (cb6db6b, all code through #37) **green**; 33629880116 (5e2baf8 = 2a83e92 docs-only) **green**. The 12:00Z–12:30Z start delay was GitHub-side queueing, nothing in the workflow.
- Extra visual bar shots this stretch (phone + desktop, web harness at cb6db6b): pause overlay mid-level (w1_l2) and the state right after a respawn (w1_l1, one heart, walked into the first hazard). Pause card centred, Resume primary, Restart/Leave secondary, touch controls dimmed under the scrim; respawn lands at the campfire sign with full hearts and the sign bubble is readable over the coins on both viewports. Defects: 0.
- First ten minutes, economy: nobody had ever added up what the levels pay versus what the shop asks. Measured from `assets/levels/*.txt` spawns + tuning (kCoinValue 1, chests 12–30 → avg 21, boss burst 45–60 coins + 3 feathers; enemies drop nothing):

  | level | coins min/avg/max | feathers |
  |---|---|---|
  | w1_l1 / l2 / l3 / l4 / l5 | 65/101/137 · 64/100/136 · 59/95/131 · 58/94/130 · 60/96/132 | 1 each |
  | w1_boss | 45/52/60 | 3 |
  | w2_l1 / l2 / l3 / l4 / l5 | 67/103/139 · 64/100/136 · 71/107/143 · 62/98/134 · 64/100/136 | 1 each |
  | w2_boss | 45/52/60 | 3 |
  | w1_bonus / w2_bonus | 78/123/168 · 71/107/143 | 2 each |

  Totals (avg, everything collected, no perfect bonus): World 1 538, World 2 560, bonus 230 → **1 328 coins and 20 feathers per full playthrough**. Pre-boss World 1 = 486.
- Reading: the first coin purchase (Woodsman's Axe 450 / Apple Pouch 500) arrives after a full-chest clear of w1_l1–l5, or around the W1 boss for a player who skips secrets (~59/level → ~300 over W1 + 52 boss + replays). Cheapest feather item (Chest Radar 8) is affordable after W1 boss + Ember Hollow (10 feathers). Most expensive items (Grove Sentinel 1600 coins, Ash Wraith 25 feathers) need a second lap or Daily Delve runs — deliberate for the rare tier, and everything on sale is reachable: no item priced beyond two playthroughs (2 656 coins / 40 feathers). Every combat level pays within 94–123 avg, none reads as a dud. **Verdict: pacing is sound; no price or level change.** Whether 450 should be the first-purchase price is the owner's call and stays on his list — this entry gives him the numbers.
- Guard: test/economy_pacing_test.dart (4 tests) — prints the table; W1 pre-boss avg income ≥ cheapest coin item; every catalog item (weapons, skins, abilities, spells, both currencies) affordable within two full playthroughs; World 1 + Ember Hollow feathers ≥ cheapest feather item; every combat level's avg income within 60–140 % of the combat mean. A level edit that strips coins or a price bump past the income fails the suite.
- Gates: `flutter analyze` clean; `flutter test` 580 passed + 1 skipped. No user-visible change (verification row only, no release-notes item).

## 2026-09-02 12:25Z — alpha.23 #38: screenshot critique pass at cb6db6b + release-notes numbering fixed
- Visual bar for the release (phone 915×412 + desktop 1280×720, web harness built from cb6db6b): title, level select (all-clear), settings, shop, w1_l1 spawn, w2_l1 spawn, w1_boss arena. Checked: HUD hearts (rasterised in #37) read identically to the old rect hearts at both scales; no missing sprites on the first frame (#34); controls do not cover the player at spawn on either world; boss bar + name centred under the timer; no text clipping on shop/settings rows. Defects found: 0. Shots kept out of the repo (owner asset rule; nothing generated ships).
- Release-notes draft: items were numbered 1–27 then 32 then 28–31 (the "32" was the progress-item number for Control height leaking into the player-facing list). Renumbered sequentially 1–32 (Control height = 28, first frame 29, sprite warm-up 30, SFX warm-up 31, hearts 32); cross-reference in the SFX item updated; the four "Release notes item N" lines in the entries below now point at the new numbers. No code change; gates unchanged from #37.
- Mirror CI for cb6db6b (pyregrove-ci run 33628837602): queued 12:14Z, still running at 12:25Z — result to be recorded when it lands.

## 2026-09-02 12:13Z — alpha.23 #37: render ops per frame measured; hearts rasterised once (pillar 3, low-end)
- New measurement (docs/perf.md §1d): a counting Canvas (`implements ui.Canvas`, `noSuchMethod` tally) fed to `EmberGame.render` after a real boot, at spawn and after 300 frames running right. First numbers ever for the render side: draw ops/frame w1_l1 244, w1_l5 409, w2_l5 253, w1_boss 202, w2_bonus 351 — and 160–323 of each were `drawRect`.
- Cause: HudReadout drew every heart from the 8×8 bitmask pixel by pixel, 40 `drawRect` per heart × (maxHearts + lives heart) = 160 per frame on medium; ItemsComponent drew each heart pickup the same way at 1.5× with shadow + shine = 81 per pickup (w1_l5 has two → 323). Static shapes, re-recorded every frame.
- Fix: lib/game/pixel_heart.dart — `kHeartRows`, `heartPixelCount()` (40), `paintHeartPixels()` (the original routine, now used only to record), `rasterHeart(fill, shadow?, shine?, scale)` → `Picture.toImageSync`, one `drawImage` per heart. HUD caches full/empty images, items caches the pickup image; both disposed in `onRemove`.
- Proof: test/pixel_heart_test.dart — the HUD image and the pickup image are byte-identical (`toByteData`) to the per-pixel drawing at 1:1. test/render_ops_test.dart — after: w1_l1 88, w1_l5 93, w2_l5 97, w1_boss 46, w2_bonus 115 draw ops/frame; drawRect 0–3. Bounds with headroom guard it. Web harness phone shot (915×412) heart crop before/after: the hairline seams between the 40 separate rects at the non-integer scale are gone, hearts read solid (/work/temp/emberwood_shots/a23set/hearts/crop_before.png, crop_after.png) — a visual improvement, not just parity.
- Noted, not acted: items/enemies are drawn without camera culling (`drawImageRect` 35–98 per frame); Skia quick-rejects off-screen quads, so only recording cost remains — small at these counts; would matter only if a level grew to hundreds of items.
- Gates: `flutter analyze` clean; `flutter test` 576 passed + 1 skipped. Release notes item 32 + verification row.

## 2026-09-02 12:04Z — alpha.23 #36: title-screen SFX voice warm-up (02d step 1, first ten minutes)
- Defect (from the code's own history, lib/audio/audio_service.dart playSfx doc): voices are created lazily per sfx id — `AudioPlayer()` + `setPlayerMode(lowLatency)` + `setSource` (Android SoundPool sample load) happen INSIDE the first shot of each id. So the first jump, step, swing, coin, enemy hit, player hit of a session are each late by one native player creation + sample load, and that allocation lands mid-gameplay on the platform thread — the same class of hitch the 2026-07-25 SoundPool rework removed for the second shot onwards.
- Change: `_ensureVoice(vid, path)` extracted from playSfx (unchanged shot path); `warmSfx({ids})` creates both voices for every concrete variant of `kSfxWarmIds` (lib/audio/round_robin.dart: step1/2, jump, double_jump, land, swing1–3, coin, enemy_hit, enemy_death, player_hit, block, whoosh, chest_open, feather, heal, secret — 18 ids → 22 files via `sfxWarmVariantIds`; loops and UI sounds excluded, they have their own players / tolerate a menu-time load). main.dart runs it after the sprite warm-up (#35), sequentially, after the first frame — cold-start path unchanged. Hardening: a voice joins the slot list only after full setup and is disposed on failure, so a failed setup never poisons a slot (before, a dead player could sit in `_sfx[vid]`).
- Measured here: platform-less test binding — warmSfx returns 0, no throw, 0 occupied slots; 22/22 variant ids resolve to bundled paths (audio_assets_test covers file existence). What a 2 GB phone gains in first-shot latency is `unknown` until hardware exists (docs/DEVICE-TEST-PROTOCOL.md — add "first jump sound on time" to the checklist when it runs).
- Test: test/sfx_warmup_test.dart (3 tests). Gates: `flutter analyze` clean; `flutter test` 568 passed + 1 skipped. Release notes item 31 + verification row.

## 2026-09-02 11:59Z — alpha.23 #35: title-screen sprite warm-up (02d step 1, first ten minutes) + directive 2026-09-02M/N executed
- Directive M (4f6ee57 → now 98281d3): read 11:45Z, pushed the one unpushed commit at once (the 02L ACK), then no commits; WIP kept as a patch + stash. Directive N (dce9f4c) read 11:55Z: `git fetch origin --prune --tags --force`, `git reset --hard origin/main` (no pull/merge/rebase anywhere), WIP re-applied from the stash. Rewritten tree verified identical to the pre-rewrite tree at the ACK (`git diff <old> <new> --stat` empty), so the green gates below stand.
- Proof for N: `git log --format='%an <%ae>' | sort | uniq -c` on `main` → `414 Tapiwa Makandigona <tapiwamakandigoner@gmail.com>` and `4 tapiwamakandigona <tapiwamakandigoner@gmail.com>` (both the owner; the lower-case name is the GitHub web-UI form, owner's own commits). `git status` clean after this commit. The `pyregrove-ci` mirror is re-synced from this commit (its snapshots are authored as the owner too since the 02L change to `scripts/sync_public_ci.sh`).
- Why: with #34 holding the loading state until every sprite is decoded, the first PLAY of a session pays the cold decode as a black gap. Probe (desktop VM, `Flame.images` cold): w1_l1 onLoad 143–153 ms and 51 images decoded; every later level 6–18 ms. Warm the cache on the title screen instead.
- Change: lib/game/asset_warmup.dart — `kWarmupSharedImages` (both worlds' backdrops, tilesets, props, items, HUD, fx, all nine enemy strips), `warmupImagesFor(skinId, weaponId)` adds the player body + equipped skin (if not 'red') + equipped weapon overlay, `warmUpLevelSprites(save)` filters the list against the asset manifest (an unbundled skin/weapon dir is skipped — Flame's cache would otherwise raise the miss as an unhandled async error) and decodes fail-open. main.dart kicks it off after the first frame is scheduled (`unawaited`, same pattern as the deferred Firebase init), so the cold-start path is unchanged. Decoded size of the starter set: 64 files, 3.35 MiB RGBA (PNG headers), versus 6.34 MiB for all 179 bundled PNGs; Flame never evicts, and a W1 level would pin most of this anyway.
- Measured after: with the cache warmed, booting w1_l1, w1_l2, w1_boss, w2_l1, w2_l5, w2_boss decodes 0 sprites the warm-up did not cover; w1_l1 onLoad 45 ms warm (was 143–153 cold). What the title screen pays for it on a phone is `unknown` until hardware exists (docs/DEVICE-TEST-PROTOCOL.md).
- Not warmed on purpose: shop icons, non-equipped skins/weapons, the legacy bladed base sheets (fallback only), `bg/sunny_back.png`, `items/cherry.png`, `props/block.png` (no code under lib/ references them — only tool/build_assets.py copies them in; candidates for a later asset prune, logged not acted).
- Test: test/asset_warmup_test.dart (4 tests). Gates: `flutter analyze` clean; `flutter test` 565 passed + 1 skipped. Release notes item 30 + verification row.

## 2026-09-02 11:44Z — alpha.23 #34: a level's first frame is complete (02d step 1, first ten minutes)
- Directive 02L proof, after the ACK commit (46fdef9 in the rewritten history): `git log -1 --format='%an <%ae> | %cn <%ce>'` → `Tapiwa Makandigona <tapiwamakandigoner@gmail.com> | Tapiwa Makandigona <tapiwamakandigoner@gmail.com>`; name-grep count → 4 total, all four inside the directive text in DEMAND.md, 0 elsewhere.
- Defect (measured, not guessed): `EmberGame.onLoad` returned as soon as the session existed; the parallax, decor, tile layer, items, player, enemies and the ten HUD elements each decode their sprites in their own `onLoad`, which GameWidget does not wait for. Probe (desktop VM, cold `Flame.images` cache, w1_l1, game sized 800×450): at onLoad return **4/7 world children, 10/10 viewport children and 1/1 backdrop children were still unloaded** (DecorLayer, TileLayer, Items, Player, all Hud*, ParallaxBackground); w2_l5 with a warm cache 12/14 world + 10/10 + 1/1 (cache hits still resolve a tick later). So the first frames of a level rendered partial content, longest on the first level of a session and on slow decoders — exactly the 2 GB-phone case of pillar 3.
- Fix (lib/game/ember_game.dart): collect the futures `add()` returns for every level component (only when the game has a layout; headless probes get null) plus `_buildHud()` (now returns the viewport `addAll` future) and `await Future.wait(...)` before onLoad resolves. Fail-open: per-future `catchError` and a `kFirstFrameHoldMax = 6 s` timeout, so a failed or stalled decode degrades to a missing sprite (the previous behaviour) instead of a level stuck on the loading state.
- After: 0 unloaded components on w1_l1 (cold), w2_l5, w1_boss. onLoad wall time w1_l1 cold 111 → 153 ms on the desktop VM — that ~40 ms is the decode that used to happen after loading ended; on a phone it is proportionally longer, which is the point.
- Web harness check: fresh `flutter build web -t lib/main_webtest.dart --release`, first capture at the `loaded` marker + 100 ms shows the complete scene (tiles, player, sign, coins, HUD, parallax) for w1_l1 and w2_l5; 5 s captures normal. /work/temp/emberwood_shots/a23set/{w1_l1,w2_l5}_ff{0,1,2}.png.
- Test: test/first_frame_complete_test.dart (3 levels + headless-boot guard, 4 tests). Gates: `flutter analyze` clean; `flutter test` 561 passed + 1 skipped.
- Docs: release-notes item 29 + verification row; the pre-#33 "w2_l4 0/4 WIPED" verification row is now marked superseded (it sat below the full-matrix row and read as current).

## 2026-09-02 11:42Z — ACK owner directive 2026-09-02L (3fe1c53): author identity — everything in my name
- Read at 11:39Z (fetch before the next commit, as the rule says). Actioned in this commit:
  1. Local git identity in every clone I use for this repo set to `Tapiwa Makandigona <tapiwamakandigoner@gmail.com>` (author and committer). No `GIT_AUTHOR_*` / `GIT_COMMITTER_*` env overrides exist in the sandbox shell (checked with `env`). The sandbox-wide global gitconfig still carries the old identity because other repositories share it; the per-repo config overrides it for pyregrove, and the `git log -1` proof below is what counts. The old per-clone email override is gone.
  2. Name grep (the command in the directive) scrubbed: PROJECT.md (removed the "built and orchestrated by" sentence), PROVENANCE.md ×4 (backdrop rows now credit "Tsoro Studios (deterministic procedural script, non-AI-image-gen)"), docs/EMULATOR-LIMITS.md (scratch probe app id), docs/legacy/FIX_PLAN_v0.3.1.md (first person), docs/research-2026-09.md (directive line), progress.md line 1540 (commit reference). Remaining matches: only the directive text in DEMAND.md.
  3. `scripts/sync_public_ci.sh` mirror snapshot commits were authored as `pyregrove-sync <sync@pyregrove.invalid>`; they now carry my identity too, so the public `pyregrove-ci` history is in my name from the next sync.
  4. Release notes / tags / release bodies: none carry agent attribution today (grep of "assistant|generated by|agent" finds only script provenance lines). Rule noted for alpha.23.
  5. No history rewrite, no force-push to pyregrove (the mirror stays snapshot-only as designed).
- Proof (`git log -1 --format='%an <%ae> | %cn <%ce>'` and the name-grep count) is recorded in the next entry, after this commit exists.
- 2026-09-02M (4f6ee57, read 11:45Z before pushing) says: push unpushed commits now, then no commits/pushes/tags until "history rewrite COMPLETE". This commit is that push. It was replayed onto 4f6ee57 (owner's DEMAND-only commit, no file overlap) because a plain push cannot land behind it otherwise — no merge commit, nothing rewritten, nothing forced. Uncommitted work (alpha.23 #34, first-frame hold; tested green) is held as a local patch until the rewrite is declared complete.

## 2026-09-02 11:22Z — alpha.23 #33: creeper retune — W2 ramp regression found by the full probe matrix (02d step 2, curve)
- Trigger: first full casual-bot matrix (14 levels × easy/medium/hard × seeds 7/13/42/99, 168 runs, /work/temp/wipe_matrix.sh). Completions were all fine (12/12 regular 4/4, bosses 0/4 by design) — but cell-by-cell against the 09-01 15:55 table, W2 medium had collapsed from d1 h4/5/3/7/5 to d0 h2/2/2/3/2: World 2 equalled World 1. The 05:54Z #3 curve check had called that ramp "intact"; #27 later removed it and the completion-only probe after #27 could not see it.
- Bisect (worktree): w2_l3 medium d1 h3 through 12820bd → d0 h2 at adbe451 (#27). File-swap isolation inside adbe451: hazardsKill block alone — no change; spawn-facing block alone — no change; `kCreeperWakeDistance` 192 → 720 restores d1. w2_l3 has a SootCreeper at x=488 (my earlier grep missed it — count glyphs with the parser, never grep).
- Sweeps (W2 six levels, hits per w2_l1/l2/l3/l4/l5/bonus, deterministic across seeds):
  - face-on wake 12/16/18: medium 2/2/2/3/2/2 (flat). face-on wake 20: 2/4/2/4/**8 WIPED**/2. face-on wake 24: 2/4/2/4/**8 WIPED**/2, hard w2_l1 **WIPED**. face-on wake 45: 4/4/5/4/**8 W**/**9 W**.
  - face-off wake 12: 2/2/2/3/2/2. face-off wake 45: 3/5/3/**10 WIPED**/4/2. **face-off wake 24: medium 2/5/2/3/4/2 (d 0/1/0/0/1/0), hard 2/5/6/4/4/2, easy 2/2/2/3/2/2 — all 4/4.**
  - hazardsKill on/off: zero effect on bot numbers at every wake value.
- Decision: `kCreeperWakeDistance` = 24 tiles (384 px; still wakes before fully on screen, half-view 176) and drop the spawn-facing override (default patrol facing +1). Only measured combination that restores W2 > W1 with no wipes on any difficulty. Facing-toward-player + wide wake was the wipe driver (w2_l5 8 hits/3 deaths); 12-tile wake was the flatten driver.
- Tests: creeper_hazard_test — 'spawn facing the player' → 'keep the default patrol facing at spawn' (with the numbers), wake test camera 20 → 30 tiles; Ashen Gate 'first creeper is a fight, last one burns' unchanged and passing. Gates: analyze clean, 557 passed + 1 skipped.
- Full matrix after (first seed; all four seeds identical):

| level | easy | medium | hard |
|---|---|---|---|
| w1_l1 | 4/4 d0 h2 t14s | 4/4 d0 h2 t14s | 4/4 d0 h2 t14s |
| w1_l2 | 4/4 d2 h7 t30s | 4/4 d0 h2 t18s | 4/4 d1 h5 t22s |
| w1_l3 | 4/4 d0 h2 t18s | 4/4 d0 h2 t18s | 4/4 d0 h2 t18s |
| w1_l4 | 4/4 d0 h3 t19s | 4/4 d0 h2 t18s | 4/4 d1 h3 t22s |
| w1_l5 | 4/4 d0 h3 t22s | 4/4 d0 h3 t22s | 4/4 d0 h4 t22s |
| w1_boss | 0/4 d3 h12 t54s | 0/4 d3 h9 t50s | 0/4 d3 h9 t29s |
| w1_bonus | 4/4 d0 h3 t19s | 4/4 d2 h6 t31s | 4/4 d2 h8 t27s |
| w2_l1 | 4/4 d0 h2 t16s | 4/4 d0 h2 t16s | 4/4 d0 h2 t16s |
| w2_l2 | 4/4 d0 h2 t23s | 4/4 d1 h5 t27s | 4/4 d1 h5 t28s |
| w2_l3 | 4/4 d0 h2 t18s | 4/4 d0 h2 t18s | 4/4 d2 h6 t30s |
| w2_l4 | 4/4 d0 h3 t21s | 4/4 d0 h3 t21s | 4/4 d0 h4 t22s |
| w2_l5 | 4/4 d0 h2 t21s | 4/4 d1 h4 t25s | 4/4 d1 h4 t28s |
| w2_boss | 0/4 d3 h11 t22s | 0/4 d3 h8 t16s | 0/4 d3 h9 t17s |
| w2_bonus | 4/4 d0 h2 t19s | 4/4 d0 h2 t19s | 4/4 d0 h2 t19s |

  W2 medium mean hits 3.2 vs W1 2.2; hard 4.2 vs 3.2; easy flat (2.2 vs 2.4 — easy is meant to be gentle). This table supersedes the 09-01 15:55 one. Bosses 0/4 is the casual bot's limit, not a level fault (coached route: boss_intent_test). Oddities noted, not acted: w1_l2 easy (d2 h7) is harder for the bot than medium (d0 h2) — easy's slower enemies desync the bot's fixed 0.5 s attack cadence; a human reads telegraphs, the bot does not. w1_bonus medium/hard d2 is the bonus level's intended bite (par 170, gated behind the boss).
- Lesson (recorded in the harness skill): completion counts hide difficulty drift. After any enemy/AI/tuning change, run the full matrix and diff hits/deaths cell-by-cell against the last table — not just COMPLETED counts.
- Still not done: on-device feel of a creeper walking into view already moving (needs hardware); human par calibration. No tag, no publish.

## 2026-09-02 10:41Z — render/update allocation re-audit (closed, no code change)

- Pillar 3 pass over lib/game/components/* + ember_game/session update
  bodies on alpha.23 code: no per-frame text layout (timer rebuilds once
  a second), no Paint/Path construction in render, event lists `const []`
  when quiet, footstep puff Vector2 is per-step not per-frame.
- Tried view-culling decor/walls/fire draws; recounted properly: ≤22
  individual world draws per level (my first grep over-counted 3×), so
  culling saves ≤18 Skia ops/frame — unmeasurable here, reverted rather
  than shipped on faith. Numbers recorded in docs/perf.md §1b.

## 2026-09-02 10:34Z — alpha.23 #32: Control height (the last (b) gap that is code)

- Re-read docs/research/b §4 against what shipped: size (#2) and swap
  sides (#9) covered Dead Cells' "size and placement" except vertical
  reach. Added `controlLift` 0/14/28 px (Settings > Control height:
  Flush/Raised/High), applied to both clusters in `_layoutHud`, clamped
  by `clampedControlLift()` so the spell button stays inside the top pad.
  Honest limit: at Large size the headroom is ~2 px, so High ≈ Flush —
  asserted in test, stated in release notes.
- Tests: haptics_test (roundtrip/clamp/snap + pure clamp), hud_layout_test
  (exact lift per button, pause fixed, no overlap; Large clamp). Harness
  `?lift=`. Screenshots a23set/lift*.png reviewed: correct on phone,
  mirrored desktop, Large.
- Gates: analyze clean, 557 passed + 1 skipped.

## 2026-09-02 10:11Z — alpha.23 #31: code-health sweep of the alpha.23 surface

- Scanned every top-level symbol in lib/ for zero in-lib references, and
  the alpha.22→HEAD diff for TODO/FIXME and duplicated tuning constants.
  Constants: every k* introduced this cycle is declared exactly once.
  TODO/FIXME: none. Harness-only paths (`?slowmo=` etc.) live in
  main_webtest.dart and reach the game only through documented setters.
- Dead code found and removed: `totalMedals()` (progress_state.dart,
  unreferenced since the M1 scaffold) and `mimicName()` (mimic_disguise.dart,
  added in #23 with a doc comment claiming it fed unlock notices/credits —
  it fed nothing; the game never prints enemy names). Its two test lines
  went with it.
- Kept on purpose: `abilityById` (one of the symmetric *ById catalog
  family) and `difficultyId` (inverse of the save parser, round-trip
  tested). `LevelRecord.medals` looked orphaned but has a save_test
  contract — restored after the suite caught it. Lesson logged: reference
  searches must not be truncated with `head`.
- Gates: analyze clean, 553 passed + 1 skipped.

## 2026-09-02 09:58Z — alpha.23 #30: sim hot-path re-bench incl. World 2

- Wanted a 2 GB-emulator PSS/frame number with the new audio players; the
  `lowmem` AVD cannot enter gameplay (PNG-decode wall, docs/EMULATOR-LIMITS.md
  — environment, not re-diagnosed). Took the number that IS measurable
  here instead: extended test/session_bench_test.dart from 3 to 6 levels
  (+ w2_l5 densest W2, w2_boss, w2_bonus) and re-ran three times.
- Numbers in docs/perf.md §1c (avg 5–27 µs; p99 ≤132 µs; w2_l5 max 5–8 ms
  recurring but frame-random → GC class, logged as such, not chased).
  Regression bounds unchanged and green on all six.
- Gates: analyze clean, 553 passed + 1 skipped.

## 2026-09-02 09:51Z — alpha.23 visual critique pass + credits line (#29)

- Screenshot critique, phone 915×412 + desktop 1280×720, 16 frames
  (a23crit/): title (both daily variants), select, shop, settings,
  credits, w1_l1, both bonus levels, Ember Vault, both boss arenas
  asleep, low-HP HUD, mirrored+large controls. No visual defects found:
  HUD ghosting works under the roll button, mirrored layout is clean,
  bonus levels read as their world's palette, control size scales.
  Noted, not acted on (owner-gated): Settings still shows the "Gameplay
  analytics" toggle (Firebase keep/remove); Credits lists CC0 third-party
  art (pre-existing, pillar 5 scope is the owner's call).
- Found one gap: CREDITS.md (rendered in-app) did not name the new
  original track "Wrath Rising". Added one sentence to the original-music
  bullet. Gates: analyze clean, 553 passed + 1 skipped.

## 2026-09-02 09:46Z — alpha.23 #28: w2_l4 into kDailyPoolWorld2 (L6 follow-up)

- Listing rule was "probe 4/4 on medium"; #27 left w2_l4 at 12/12 across
  easy/medium/hard (logged above), so `kDailyPoolWorld2 = [w2_l2, w2_l3,
  w2_l4, w2_l5]`. daily_test flipped from "w2_l4 absent" to "all four
  present". Gates: analyze clean, 553 passed + 1 skipped.

## 2026-09-02 09:43Z — alpha.23 #27: L5 twist audit → Ashen Gate creepers (LEVEL-CRAFT L5)

- Audit method: enemy count per level third for all ten levels + a
  headless 30 s drift probe (every walker awake; where does it end?).
  Finding: only w2_l1 fails the "does it twist" question, and it fails
  hard — its three Soot Creepers (the level's concept) ended at
  (49,18)/(48,18) inside the spike trench and (89,18) inside the lava
  within 5–10 s of waking, and they woke 45 tiles out. Other W2 levels'
  creepers all patrol sanely (probe numbers in the test log).
- Code: `EnemyCore.wakeDistance` (default `kEnemySleepDistance` 720,
  replacing the inline 1.5×480) and `hazardsKill` (default false);
  SootCreeper: wake 12 tiles × aggro, hazardsKill true; spawns facing the
  player. Session: hazard contact on an opted-in walker → alive=false →
  `_onEnemyDeath` (ash puff, kills++).
- Level: w2_l1 lip '#' at (42,13) (creeper #1 patrols cols 27–41 — the
  fight), sign 's' at (78,15) + sign3. reachability_lint OK.
- Tests: test/creeper_hazard_test.dart (5): lava death + kill count,
  facing, other walkers unaffected, wake distance bounds, Ashen Gate
  contract (#1 stays on its floor 30 s; #2, #3 burn; 3 signs).
- Gates: analyze clean, **553 passed + 1 skipped**. Probes medium
  w2_l1 16s / w2_l2 23s / w2_l3 18s / w2_l4 21s / w2_l5 22s / w2_bonus
  19s, all 4/4 COMPLETED 0 deaths; **w2_l4 also 4/4 easy and 4/4 hard**
  (the 2026-09-02 medium wipe is gone — the creeper timeline shifted the
  bot's arrival at the col-94 pillar; listing rule for the daily pool is
  now met → next commit).
- Screenshots: a23set/cr_*.png — sign3 renders, creeper #3 approaches the idle harness player at t+0.8 s and is gone by t+6.5 s; the burn itself happens at col 89, one tile past the 915×412 view from the sign, so the visual proof of the death is the headless test, not a frame.

## 2026-09-02 09:26Z — alpha.23 #26: cave_combat re-level (AUDIO-POLISH C2)

- Measured first: combat −21.8 LUFS, cave_combat −23.3, boss_combat
  −21.3 (ffmpeg ebur128). Re-exported cave_combat with volume=1.5dB at
  q5 → −21.8 LUFS, phoneRms −24.4 dB (was −26.0; the mix test's bed
  ceiling is −24.0, so this is the last dB available), peak −5.8 dBFS,
  duration 49.5625 s unchanged. Mix report updated by hand (music entry).
  Source mp3 not in repo → one extra lossy generation; noted in backlog.
- AUDIO-POLISH-BACKLOG C1–C7 all closed.
- Gates: analyze clean, 548 passed + 1 skipped.

## 2026-09-02 09:18Z — alpha.23 #25: boss intensity layer (AUDIO-POLISH C5)

- tool/build_boss_layer.py → assets/audio/sfx/boss_layer.ogg ('Wrath
  Rising', 5.8 s seamless loop, 56,853 B). Imports the score's synthesis
  kit (build_original_music.py) so it is original like the music. Design
  choice: tempo- and chord-agnostic (ember-wind tremolo at the score's
  9.5 Hz, two free taiko rolls, faint D3 rumble) because audioplayers
  cannot beat-align a second player — a gridded percussion loop would
  flam against the track's drums. First render measured above500 0.017
  (rumble/taiko dominated) and clipped; rebalanced to wind 0.16 / taiko
  0.10 / rumble 0.006 → above500 0.59, peak −12.8 dBFS, phoneRms −31.0 dB
  (danger_loop is −32.1; beds are −26). Mix report entry written by the
  script.
- AudioService.setBossLayer(on): own looping player at 0.6× music,
  failed-start frees the slot, pause/resume/applySettings handled.
  music_mix.dart `bossLayerWanted(bossPhase, bossDead, over)`; ember_game
  update() drives it each frame next to setDanger; onRemove turns it off.
- Tests (+1). Gates: analyze clean, **548 passed + 1 skipped**.
- NOT verified: audible balance against boss_combat on a device (meters
  only); whether 0.6× reads as escalation or clutter — owner's ears.

## 2026-09-02 09:09Z — alpha.23 #24: SFX round-robins (AUDIO-POLISH C4)

- tool/build_sfx_variants.py: coin_b (rate ×1.045, HP 900, treble +3),
  coin_c (×0.965, LP 6k, shorter tail), enemy_hit_b (×0.93, bass +4, LP
  5k), enemy_hit_c (×1.07, HP 350, treble +2, shorter tail). Each variant
  is gain-matched to the source's phone-band RMS (the mix report's
  meter), peak capped at −1 dBFS. Measured: coin/coin_b/coin_c phoneRms
  −21.8/−21.9/−21.9 dB; enemy_hit/_b/_c −23.8/−24.9/−24.0 dB; spectral
  centroids differ (coin 4.7k / 5.0k / 2.3k Hz; hit 5.8k / 4.0k / 6.5k Hz)
  so the variation is timbral, not only pitch. tool/audio_mix.json
  updated by the script (audio_mix_test caught the missing entries first).
- lib/audio/round_robin.dart: kSfxVariants, pickVariantIndex (never the
  previous index), variantId. AudioService.playSfx resolves the variant
  before voice lookup; the logical id still drives wobble + coin chain.
- +4 assets, 23,167 bytes total. Same CC0 sources → CREDITS unchanged.
- Tests (+4): round_robin_test (no repeat over 500 draws, all reachable,
  no-variant ids, every variant path exists). Gates: analyze clean,
  **547 passed + 1 skipped**. On-device listen NOT done.

## 2026-09-02 09:01Z — alpha.23 #23: Spore Mimic (LEVEL-CRAFT L1)

- lib/game/mimic_disguise.dart: `mimicDisguiseAsset(env)` (cave →
  props/shrooms.png, else props/bush.png), `mimicRevealTint(env)`
  (spore-violet 0xFFC9A6E6 vs leaf-green), `mimicName(env)`.
  enemy_component reads `game.session.level.environment` at load. No new
  asset (pillar 5): the cave's own shroom prop is the disguise.
- Levels: w2_l3 N at (22,10), two tiles right of the real shrooms at
  (20,10), just past checkpoint K(17) — teaching beat. w2_l5 N at (48,11)
  on the chest platform (cols 44–48), chest at (46,11), new 'm' decor at
  (44,11). Lint OK both.
- Tests (+2): cave mimics need shrooms within 4 cols/1 row; W2 ≥ 2
  mimics; disguise mapping. Gates: analyze clean, **543 passed + 1 skipped**.
- Probe medium: w2_l3 4/4 COMPLETED (t=26 s, 1 death, 3 hits), w2_l5 4/4
  COMPLETED (t=25 s, 1 death, 4 hits). Daily pool unaffected.
- Visual (phone 915×412, a23set/m_*.png, not committed): at rest the two
  clusters in w2_l3 are indistinguishable; revealed form reads violet,
  clearly not a thornling; w2_l5 chest platform shows cluster + chest +
  cluster. Not checked: real-device frame cost (one extra 16×15 prop draw,
  negligible by construction).

## 2026-09-02 08:50Z — LEVEL-CRAFT L2 audit closed (no change)

- Secret idioms measured across w1_l1..w2_l5 (20 X): 20/20 cracked-wall;
  6 also high/off-camera (rows 4–8). Diversifying collides with
  secret_vault_test's "X within 5 cols/3 rows of a B" fairness contract —
  loosening that is a design call, so it is logged for the owner in
  LEVEL-CRAFT-BACKLOG L2 rather than done. Retention-spine Phase A (daily
  modifiers) likewise left for the owner: agent-proposed, never directed.

## 2026-09-02 08:45Z — alpha.23 #22: LEVEL-CRAFT L4 denial & reward (w2_l2)

- assets/levels/w2_l2.txt: pillar chest (77,12) → coin; chest now at
  (91,9) on a 2-wide ledge (row 10, cols 90–91) against the vault's right
  wall — six rows above the floor, visible, beyond the 4.6-tile double
  jump. Roof hole cols 90–91 row 5; roof extended cols 93–95; bridge
  platform '=' cols 97–101 row 8 (gap 102–104 to the feather platform);
  stalactite at col 96 shortened to rows 1–2 (its row-3 tip blocked the
  head on the roof hop — the lint caught it); right diver 87→84 so it
  doesn't camp the landing.
- Proof: tool/reachability_lint.py OK on the shipped grid, FAIL
  `C@(91,9)` with the hole sealed. Pinned in world2_levels_test (imports
  reachability_test's fill). Chest economy 2+2 intact (level_data_test
  caught the first draft at 3 plain chests → moved instead of added).
- Wipe probe w2_l2: medium 4/4 COMPLETED (t=27 s, 1 death, 5 hits, same
  as before the edit), easy 4/4 (0 deaths, 3 hits), hard 4/4 (1 death,
  5 hits). Daily-pool level stays 4/4.
- Visual: phone 915×412 from the vault floor (col 84) shows the chest
  top-right, clearly unreachable; roof and bridge shots read fine
  (a23set/l4_*.png, not committed).
- Gates: analyze clean; **541 passed + 1 skipped**.

## 2026-09-02 08:23Z — alpha.23 #21: audio backlog C1/C3/C6 (+C7 check)

- lib/audio/music_mix.dart: pure `musicGain({sinceStart, duck})` (fade-in
  0.4 s mirrors the existing 0.4 s fade-out; duck floor 0.5, d² ease-out
  over 0.35 s) and `dangerLevel(hearts)` (0.5 at one heart = the previous
  constant, → 0.8 toward zero). AudioService: one 50 ms gain timer that
  runs only while gain moves; `duckMusic()`; `setDanger(on, level:)`
  pushes level changes live; applySettings respects gain + danger level.
  Stings (`loop:false`) skip the fade — victory/defeat should hit.
- Wired: PlayerEvent.hurt, bossPhase, bossDefeated → duckMusic. Not coins
  or swings (backlog rule: constant pumping).
- C7 checked: only `playMusic('victory'/'defeat')` fires; the sfx copies
  are unreferenced. No double trigger.
- Not measurable here: how the duck reads on a phone speaker. Values are
  the backlog's suggested ones; a listen on device is the open check.
- Tests: test/music_mix_test.dart (6). Gates: analyze clean; **540 passed
  + 1 skipped**.

## 2026-09-02 08:16Z — alpha.23 #20: Daily Delve World 2 rotation (LEVEL-CRAFT-BACKLOG L6) + w2 probe finding

- Probed w2_l2/l3/l4/l5 on medium (seeds 7/13/42/99) as L6 requires
  ("probe-verified 4/4 first"): w2_l2 4/4 (1 death/5 hits), w2_l3 4/4
  (1/3), w2_l5 4/4 (1/4), **w2_l4 0/4 WIPED** (t=34 s, pct 74, 3 deaths,
  10 hits, 3 s stall at col 93). Then w2_l4 easy 4/4 (0 deaths/4 hits) and
  hard 4/4 (0/4, on 2 hearts). Hit log on medium: double soot-creeper hits
  at col 31 (t=3.7/4.7 — the bot stands still through its i-frames), then
  the totem at col 98 hits it point-blank at cols 95/97 while it stalls on
  the 3-high pillar (cols 94–98). Medium slower and deadlier than hard on
  identical geometry = casual-bot route desync by the probe's own reading
  rules (wipe_probe_test.dart header; same spot flagged in the jump-retune
  log). Runner bot in world2_levels_test still clears w2_l4. No geometry
  change — the owner's bar is "a test shows a level became unclearable".
  Earlier today (#3, 05:54Z) w2_l4 medium was COMPLETED 7 hits; the death
  hold (#11/#19) shifts respawn phase, which is the likely flip cause.
  Human read of the spot: hearts at cols 90 and 101 bracket the totem
  climb, so the pressure is anticipated by the design.
- L6 shipped: `kDailyPoolWorld2 = [w2_l2, w2_l3, w2_l5]`;
  `dailyLevelId(d, {world2Unlocked})` — the W1 pick is computed exactly as
  before and returned when W2 is locked (nobody's daily changed); with W2
  open a second date-only draw makes ~half the days a W2 day. Title screen
  passes `isWorld2Unlocked(save)` and looks the name up in kAllLevels.
- L3 checked (parsed w1_l1: two six-coin arcs, walking line, double-jump
  platform coins) → closed as verified, no change. Backlog section D
  reconciled with 02d ("then content"): bonus levels are side content.
- Tests: daily_test +1 (120-day sweep). Gates: analyze clean; **534 passed
  + 1 skipped**.

## 2026-09-02 08:08Z — Visual check of #17 (UNLOCKED rows) on phone + desktop

- Harness `?unlocks=w1_boss` added (main_webtest only) so the results
  overlay can be captured with the rows; walked into the w1_l1 door from
  spawn=93,15. Both 915×412 and 1280×720: two green rows sit between the
  medals and the buttons, nothing clipped, panel still centred
  (a23set/results_unlock_*.png). No code change to the game.

## 2026-09-02 08:04Z — alpha.23 #19: death beat on the last life too

- #11 held only when lives remained; the last death popped FALLEN in the
  same frame. Now `_onDeath` (lives ≤ 1) emits `playerDied`, holds
  `kDeathHold`, sets `_failPending`; `update()` runs `_fail()` on the first
  live frame after. Consistent beat on every death.
- Tests: fairness_test +1 (failed=false during the hold, playerDied
  emitted, failed within 3 frames of kDeathHold). Gates: analyze clean;
  **533 passed + 1 skipped**.

## 2026-09-02 08:01Z — alpha.23 #18: Firebase init off the cold-start path (02d step 3, Play "slow cold start")

- Read main(): `await initTelemetry()` (→ `Firebase.initializeApp()`) sat
  before `runApp`. Now: `await TelemetryService.instance.load()` stays
  before the first frame (TelemetryConsentGate reads `needsConsentDialog`
  on its first post-frame callback — deferring it would re-ask every
  launch), then `unawaited(_startTelemetryAfterFirstFrame())` → yields one
  microtask, `initTelemetry(loadPrefs: false)`, `app_open`.
- Not measured: no device here; Firebase init cost on a low-end phone is
  ASSUMED non-trivial, not known. The claim is only "one SDK init fewer
  before the first frame".
- Tests: telemetry_test +1 (deferred path fails closed without Firebase,
  prefs untouched). Gates: analyze clean; **532 passed + 1 skipped**.
- Mirror CI: #16 447a021 run 33605855610 and #17 84c2f34 run 33606192912
  were in progress at 07:58Z.

## 2026-09-02 07:57Z — alpha.23 #17: clear screen names what a first boss kill unlocked

- With two gated bonus levels, a boss kill silently opened content in a
  list the player might not scroll. `unlocksOnFirstClear(levelId)` (pure,
  progress_state) → EmberGame reads `rec.finished` BEFORE `mergeLevelResult`
  and sets `unlockNotice`; ResultsOverlay shows green "UNLOCKED  <label>"
  rows after the medal reveal. Replays: nothing.
- Tests: results_next_test +2 (widget shows both W1-boss lines; only the
  two gates return anything). Gates: analyze clean; **531 passed + 1
  skipped**. Release-notes draft: item 17 + "Not done" now lists par
  calibration and the firebase decision.

## 2026-09-02 07:53Z — alpha.23 #16: Slag Cellar — World 2 bonus level (02d step 4, content)

- Second bonus, own gate: `kBonusGates = ['w1_boss','w2_boss']`,
  `isBonusGateMet(save, i)`; `isLevelUnlocked` for the bonus list consults
  the gate, not a chain. Level select lock copy per level. 130×20 cave
  layout from `tool/levels/gen_w2_bonus.py`; roster W×3 S×4 D×3 H×2 O R.
- Held to every World 2 rule + reachability + `onboarding_test` hazard-pit
  ≤ 5 rule (caught the 6-wide fire trench; narrowed). Runner bot clears the
  3-high wall (double jump) — kept as the level's one mandatory skill test.
- Probe (casual bot, 3 seeds × 3 difficulties): COMPLETED 18–19 s, 0
  deaths, 2 hits (fire + the spike bridge, misattributed to the nearest
  enemy). Kiln Works baseline today: 1 death / 4 hits medium. Honest read:
  the straight-line bot never stalls long enough for hounds/creepers to
  engage; adding a creeper, moving the hound to the vault landing, a diver
  over the spike bridge and a wisp over the gauntlet changed nothing for
  the bot. Enemy census verified alive=14 at spawn. A human clear is the
  real measurement — open item.
- Gates: analyze clean; **529 passed + 1 skipped**. Visual: 7 harness spots
  (a23set/c_*.png) — trench/bridges, shelves+divers, vault+wall, spike
  bridge with sign, gauntlet under the floating vault, finish.
- Process: `dart format lib test tool` rewrote 85 files (tall style) —
  reverted all but the touched files; rule added to the harness skill.

## 2026-09-02 07:40Z — alpha.23 #15: coins fly to the counter (02d step 4, feel)

- lib/game/components/coin_fly.dart: `coinFlyPoint` (pure, quadratic ease-in
  + sin arc) and `CoinFlyFx` (viewport component, priority 9, one sprite
  draw, static `inFlight` cap 12 via `tryAdd`). HudReadout exposes
  `coinIconCenter()` / `coinSprite` / `bumpCoin()`; the coin icon renders
  with a 0.16 s sin pulse on arrival. `EmberGame.worldToScreen`. Session
  gets a `debugEmitCoin` test hook (events only, wallet untouched).
- Bench: w1_bonus added to session_bench_test — avg 9.4 µs, p99 49 µs
  (w1_l5 27 µs / 174 µs; w1_boss 6.7 µs / 47 µs).
- Tests: test/coin_fly_test.dart (2). Gates: analyze clean; **515 passed +
  1 skipped**. Visual: w1_l1 coin arc at `?slowmo=0.35`, 10-frame burst —
  coin visibly arcs to the wallet, icon pulses (a23set/coin_sheet.png).
- Learned: components added to `camera.viewport` mount on the NEXT update;
  tests need two ticks before asserting on `children`.

## 2026-09-02 07:33Z — alpha.23 #14: Ember Hollow — World 1 bonus level (02d step 4, content)

- First content item after steps 1–3. Side level, not a campaign insert:
  `kBonusLevels` (LevelEntry.isBonus), gate `isBonusUnlocked` = Grove Golem
  finished, `kCampaignOrder` unchanged (Next level never routes into it),
  `kAllLevels` for content tests. Level select: third section "BONUS — THE
  GROVE'S PURSE" with star badge and its own lock copy.
- Layout: 124×20, `tool/levels/gen_w1_bonus.py` → assets/levels/w1_bonus.txt.
  Roster T V O(×2) R(×2) N(×2); hazards: 4-tile spike bed, 3-tile fire pit;
  3 campfires (first BEFORE the totem — the first draft had it after and
  the casual bot died twice before reaching it), 5 chests (2 secret behind
  B walls), 2 feathers, 1 heart, 3 signs, par 170.
- Gates: all World 1 content rules now run over the bonus (lints, gap ≤ 6,
  quotas, secret placement, par, runner bot, reachability) — green;
  analyze clean; **513 passed + 1 skipped**.
- Probe (casual bot, seeds 7/13/42/99): easy COMPLETED 19 s, 0 deaths, 3
  hits; medium COMPLETED 25–31 s, 2 deaths, 6 hits; hard COMPLETED 27 s,
  2 deaths, 8 hits. Baselines today: w1_l3 medium 0/2, w1_l5 medium 0/3.
  Read: harder than the campaign finale, never a wipe; the bot's deaths are
  spikes/fire it walks into (no bridge-taking) plus totem shots.
- Visual: 9 harness spots + tall level-select in locked/unlocked states
  (a23set/b_*.png). Vaults, bridges, pillars and the roof coins read.
- Open: a human clear time to calibrate par 170 (bot ignores coins).

## 2026-09-02 07:20Z — Correction: entry clocks for today's alpha.23 items

- The `HH:MMZ` labels on entries #1–#13 below were written from a drifting
  estimate, not a clock, and ran up to 5 h 38 min ahead of reality. They
  now carry each item's commit time (`git log --date=iso`, UTC), which is
  the ground truth. Nothing else in those entries changed.

## 2026-09-02 07:17Z — alpha.23 #13: first-run PLAY opens Forest Edge directly (02d step 1)

- (b) §2 Apple Knight: tutorial stage first, menus after. Pyregrove's PLAY
  always went to level select — a screen a brand-new player has no use for
  (one card unlocked). Pure `firstRunLevelId(save)` in progress_state.dart:
  `w1_l1` while no record is finished, else null → level select. Title PLAY
  branches on it.
- Tests: test/first_run_test.dart (3: fresh, abandoned-unfinished + legacy
  tutorialSeen, any finished incl. odd w2 record); ui_smoke_test split into
  fresh → GameScreen(w1_l1) and veteran → level select.
- Gates: analyze clean; **504 passed + 1 skipped**.

## 2026-09-02 07:12Z — alpha.23 #12: Restart level in the pause menu (02d step 1)

- Pause menu was Resume / Leave level only; restarting a run took three
  steps through level select. Added `onRestart` (optional) to PauseOverlay,
  wired to the existing `_replay` (same seed + daily flag as Replay on the
  clear screen). Harness pause mount passes a no-op.
- Tests: new test/pause_overlay_test.dart (2): presence + top-to-bottom
  order Resume → Restart → Leave, each button fires only its own callback;
  omitted `onRestart` hides the button.
- Gates: analyze clean (after fixing one lint the gate caught —
  prefer_function_declarations_over_variables in the new test); **500
  passed + 1 skipped**.
- Mirror CI: #10 cc57c82 → e29a18a run 33601373836 GREEN; #11 8de1cda →
  ef5071b run 33602152625 in progress at 07:09Z.

## 2026-09-02 07:08Z — alpha.23 #11: death beat — hold at the death spot, then respawn (02d step 1)

- Found while reading the death path for the screenshot pass: `_onDeath`
  revived the player in the same frame it died. The player's 6-frame death
  animation had never been visible, and the cause of death left the screen
  before it could be read (camera snapped to the campfire instantly).
- Fix in the sim: `kDeathHold = 0.55` — `_onDeath` (lives left) emits
  `SessionEventKind.playerDied(x,y)`, sets `hitPause = kDeathHold` and flags
  `_respawnPending`; `update()` runs `_respawn()` (the old revive + landing-
  zone clear + `respawned` event) on the first live frame after the hold.
  Level clock frozen during the hold. Last-life death (`_fail`) unchanged.
  Game layer: red PuffFx + 10-shard RubbleFx + heavy haptic + camera bump at
  the death spot.
- Tests: fairness_test death case now asserts the hold (player still dead
  and unmoved after the first frame, playerDied at the death x, respawn
  lands within 3 frames of kDeathHold, clock frozen); lives-exhaustion and
  bramble_mimic respawn-clear tests ride out the hold. Gates: analyze clean;
  **498 passed + 1 skipped**.
- Visual: harness `?hearts=1&spawn=33,15` walk into the w1_l1 spike pit —
  burst + body in the pit for 3 captures (~0.18 s apart), then the campfire
  puff (a23set/death_00..03.png).

## 2026-09-02 06:59Z — alpha.23 #10: HUD buttons ghost while the player is behind them (screenshot-pass find)

- Phone (915×412) + desktop (1280×720) screenshot critique of the alpha.23
  set (title, select, settings, shop, w1_l1, w2_l1, w1_boss; shots in
  /work/temp/emberwood_shots/a23set/). Meta screens: no regressions; the two
  new Settings rows read well on both sizes. Gameplay find: in the Grove
  Golem arena the boss camera (#6) keeps the player 48 px from the frame
  edge — at ground level that is under the dash/apple/jump column, and the
  player sprite was fully behind a button in the desktop shot. Same class
  of problem as the swapped layout's diamond sitting on the spawn.
- Fix (render-only): `HudHoldButton.update` ghosts to 0x40 alpha the frame
  `coversRect(button, game.playerScreenRect(), pad: 6)` is true, eases back
  to 0x8C idle at rate 12/s, never while pressed. Spawn fade kept as a
  special case of the same rule. `EmberGame.playerScreenRect()` = body
  translated by the centre-anchored camera.
- Tests: +2 (hud_layout: same-frame ghost / eased recovery / pressed solid /
  re-ghost on release; pure coversRect). Old spawn-fade test widened to 90
  frames because the recovery is now eased.
- Gates: analyze clean; **498 passed + 1 skipped**. Visual: 8-frame burst
  in the boss arena — dash then apple button visibly ghost as the player
  passes under them, recover after (a23set/ghost_*.png).
- Not changed: boss camera margin (48 px keeps the "both in frame" promise
  from #6; a bigger margin would give the framing back).
- Mirror CI for #9 (66e4163 → pyregrove-ci af0ac39): see next entry.

## 2026-09-02 06:48Z — alpha.23 #9: Swap control sides (02d step 1, last (b) gap that is code)

- (b) §2 Dead Cells: "adjust button size and placement". #2 did size; this
  does placement the cheap, testable way — one switch mirrors the layout
  (move-pad right, diamond left) instead of free-drag. `hudMirrored` read
  once per level like `hudScale`; `_layoutHud` lays the clusters out in the
  swapped-inset frame, reflects them across the view axis, then swaps the
  two arrows back so LEFT stays left of RIGHT. Pause/readout fixed. The
  spawn fade now follows the cluster on the left edge (mirrored: the
  diamond fades, arrows don't) — caught in the harness screenshot, the
  diamond sat on the spawned player.
- Tests: +3 (hud_layout: exact reflection / order / no overlap / pause
  fixed; asymmetric safe area; spawn-fade side) and +1 settings roundtrip
  (haptics_test). Tolerances 1e-3 because Vector2 stores float32.
- Gates: analyze clean; **496 passed + 1 skipped**. Visual: harness
  `?mirror=1` and `?mirror=1&controls=1.2` at 915×412 — layout reads
  correctly, nothing clipped.
- Mirror CI for #8 (0134569 → pyregrove-ci 972800e): run 33599004907 GREEN.
  For #7 (e19b999): run 33598779999 GREEN.

## 2026-09-02 06:28Z — alpha.23 #8: B2 swing weight, feel-only (02d step 4)

- Chose the variant that cannot move balance: no anticipation/recovery
  timing change (B6 rule "press == hit" kept for every weapon, tested).
  `swingWeightFor(weapon)` derives light/medium/heavy from damage (starter
  light, Wind God's Hammer the only heavy). Heavy: hitstop ×1.35 (kill blow
  94 ms, still < 120 ms lag threshold), arc stroke +1 px, camera thud 1.6 on
  a plain connect. Light/medium multipliers are exactly 1.0 so the starter
  blade feels identical to alpha.22.
- Tests: swing_weight_test (mapping, 1.0 invariants, heavy bounds);
  combat_test B1 case updated for the hammer multiplier.
- Gates: analyze clean; **492 passed + 1 skipped**. FEEL-POLISH backlog now
  cleared on main; the timing-ratio B2 stays an owner balance call.

## 2026-09-02 06:25Z — alpha.23 #7: B4 kill permanence (ash decal) (02d step 4)

- CHECK first (per backlog): defeated enemies vanished with the 6-frame
  DeathFx pop — nothing stayed on the floor. Fix: `ashLeft` session event
  (foot point + body width) on grounded non-boss kills → `AshDecalFx`, three
  flat ellipses, no asset, no animation; 10 s life, alpha decays only in the
  last 2 s; `AshDecals` registry caps 8 per level, oldest evicted. Bosses
  keep the victory burst (no decal). Tuning in tuning.dart (kAshDecal*).
- Tests: test/ash_decal_test.dart — bot kills a thornling on flat ground →
  enemyDeath then ashLeft with y at the floor tile boundary (±0.6) and w>0;
  registry cap+eviction; self-removal at kAshDecalLife.
- Visual: harness w1_l1 seed 7 spawn 43,14, kill the first thornling —
  dark smudge sits on the grass line beside the player; reads as "something
  died here", not as an item. Analyze caught `width` shadowing
  PositionComponent.width → renamed `footprint` before commit.
- Gates: analyze clean; **489 passed + 1 skipped**.

## 2026-09-02 06:15Z — alpha.23 #6: boss-arena camera framing (02d step 1/4, readability)

- Closes the alpha.20 observation ("Grove Golem spends most of the opener
  off-camera; first contact is an unseen shockwave"): once a boss is awake,
  `_followCamera` targets the player↔boss midpoint via pure
  `bossCameraTargetX()` (lib/game/camera_frame.dart), clamped so the player
  is never nearer than 48 px to a frame edge. Look-ahead camera resumes when
  the boss dies. Dormant statue phase unchanged. Level clamp still applies.
- Test: test/camera_frame_test.dart (midpoint, both-in-frame bound, wide
  separation clamps to margin both sides, degenerate view).
- Visual (harness w1_boss seed 3, spawn 17,15, wake then retreat left to
  x≈216): player at left third, golem in frame at right — under the old
  look-ahead camera the frame would have been 0..352 with the golem at/over
  the right edge. Gates: analyze clean; **486 passed + 1 skipped**.

## 2026-09-02 06:09Z — alpha.23 #5: feel slice ported to main (02d step 4, second item)

- Cherry-pick of d159c1e from `update/delvers` (code applied clean; only the
  harness file and progress.md needed hand-merge): B1 tiered hitstop
  (kHitPause 0.035 / kKillPause 0.070 / kBossPhasePause 0.100 / kBossKillPause
  0.22 — session picks by outcome), B3 swing smear echo (render-only, one
  extra drawArc), B5 rising coin-pickup pitch (1.5 s window, +1 semitone per
  coin, cap 8). Harness gains `?slowmo=` (`EmberGame.timeScale`, never written
  by the app). No economy/roster change came with it — delvers stay parked.
- FEEL-POLISH-BACKLOG status line corrected: B1/B3/B5/B7 shipped on main;
  B2(+B6), B4 open.
- Gates: analyze clean; full suite **482 passed + 1 skipped**.
- Visual: harness w1_l1 `?peace=1&slowmo=0.12`, 20 captures ≈0.25 s real
  apart after KeyX — sword pose animates frames 0–5, arc+smear crescent lands
  in capture 4 (bright, thick, reads as speed). Capture cadence is coarser
  than the 0.6×220 ms arc window, so the crescent showing in one capture is
  expected, not a bug.

## 2026-09-02 05:57Z — alpha.23 #4: Hard clear mark (02d step 4, replay reason from (b))

- Huntdown-style post-clear challenge without gating: LevelRecord.hardCleared
  (json key `hardCleared`, legacy → false) set when a level is finished on
  Hard; level card subtitle appends "· Hard clear". Record merge pulled out of
  EmberGame._persistResults into pure `mergeLevelResult()` (progress_state)
  and unit-tested. Behaviour of coins/feathers/kills persistence unchanged.
- Gates: analyze clean; full suite **480 passed + 1 skipped**.
- Mirror: snapshot of 6d0d7cb synced to pyregrove-ci (28ad5a2), CI run
  33596609468 started 05:54Z — **GREEN** (release APK+AAB built, 06:00Z).
  Release-build check of alpha.23 through 6d0d7cb passes. No tag.

## 2026-09-02 05:54Z — alpha.23 #3: curve measured (no change) + crash guard ported (02d steps 2–3)

- Step 2, curve: re-ran the boss probes (w1_boss medium 4/4 WIPED 28 s pct 85
  d3 h9; w2_boss 4/4 WIPED 14 s pct 40 d3 h8) and re-read the 85c7595f regular-
  level table (all 4/4 COMPLETED, medium hits w1 2/2/2/2/3, w2 4/5/3/7/5).
  No within-world ordering fault; the only break is regular→boss, whose
  comparable remedies are owner-gated (HP rule / optional boss). No level
  file changed — a geometry edit without a measurement would be a guess.
  Fixed (b): Kiln Golem K=1 not 0 (recounted all 12 files; rest matched).
- Step 3, code item from (a) row 6: lib/core/crash_guard.dart +
  test/crash_guard_test.dart ported from update/delvers f99d871, wired in
  main(). No IO, nothing leaves the device. firebase_analytics keep/remove
  remains the owner's call (not touched).
- Gates: analyze clean; full suite **479 passed + 1 skipped**.

## 2026-09-02 05:49Z — alpha.23 #2: Control size setting (02d step 1)

- Gap from (b) §2 (Dead Cells mobile: adjustable button size). New Settings
  row Control size: Small 0.85× / Normal / Large 1.2×; every touch button
  scales, pause + readout fixed; applies at next level start. Persisted as
  `controlScale` (clamped 0.85–1.2 on load; missing key → 1.0).
- Measured: at 1.2× on the 800×450 canvas jump = 67.2 px, arrows 62.4 px,
  small 52.8 px; layout test asserts no overlap and all inside the view at
  both extremes. Screenshots 915×412 Large/Small + Settings: clean.
- Harness: `?controls=0.85|1.0|1.2` for look-passes.
- Gates: analyze clean; full suite **478 passed + 1 skipped** (+2 tests).

## 2026-09-02 05:41Z — alpha.23 #1: Next level from the clear screen (02d step 1)

- Gap from (b) §2 (Apple Knight: "thrown into a new level immediately"):
  Pyregrove's LEVEL CLEAR only offered Continue → level select. Now offers
  Replay · Levels · **Next level**; falls back to Continue when no successor
  (final boss, daily, or successor boss still locked). Rule is pure
  (`nextLevelId`, lib/meta/progress_state.dart) and tested for chain, world
  boundary, lock, end, daily. Measured: menu round-trip per clear 2 taps → 0.
- Version bumped to 1.0.0-alpha.23+35 (first user-visible change). NOT tagged.
- Gates: analyze clean; full suite **476 passed + 1 skipped** (+3 tests).
- Skipped on purpose: boss HP by difficulty — contradicts the owner's
  2026-07-25 difficulty rule in lib/game/difficulty.dart ("never cheap stat
  walls"). Flagged in docs/release-notes-draft-alpha23.md for the owner.

## 2026-09-02 05:36Z — ACK directive 2026-09-02d (c525018) — research over, build alpha.23

Read in full. Understood: (a)(b)(c) closed, no new research files. Build order:
(1) first-ten-minutes gaps from (b), cheapest first, one commit each with a test
or a measured number here; (2) curve findings applied to existing levels, jump
retune untouched unless a test shows a level unclearable; (3) code-side Play 2027
items from (a) — paperwork (Firebase entry, Play registration) stays with the
owner; (4) content. Bump to 1.0.0-alpha.23+35 on the first user-visible change;
keep release-notes draft current. **No tag, no publish until the owner says so.**
FLIP repos: not touched. Working on `main`; `update/delvers` stays parked.

## 2026-09-02 05:05Z — Research (a)(b)(c) per 2026-09-02b item 3 — on main, Pyregrove-scoped

- docs/research/a-play-2027-bar-first-listing.md — 10 threshold rows + listing
  paperwork, read against the shipped alpha.22 APK (androguard/zipalign) and
  Play help pages fetched today (answers 11926878, 9844486, 14151465, 10787469,
  9859655; page-sizes guide). Met: API 36, 16 KB, R8, backup declared. Unknown:
  all field metrics. Pending owner decision: firebase_analytics keep/remove
  (Data-safety consequence).
- docs/research/b-comparables-first-10-minutes.md — Apple Knight, Grimvalor,
  Huntdown, Dead Cells (+ Celeste GDC talk for method, Leap Day interview for
  retention); each observation names reviewer/interview/database + date. Pyregrove
  curve measured from assets/levels (par, width, checkpoints, enemy kinds, hazards).
  Two candidate changes recorded, not started: boss HP by difficulty, post-clear
  difficulty unlock.
- docs/research/c-play-or-itch.md — one page, both sides, settling facts table,
  sequencing option. No verdict; owner decides.
- docs/research/README.md index. No features, no listing edits, no Emberdelve data.

## 2026-09-02 04:49Z — v1.0.0-alpha.22 "The Forgiving Jump" RELEASED (the one prerelease per 2026-09-02b)

- Release commit c725e41 (pubspec 1.0.0-alpha.22+34, kAppVersion same,
  docs/release-justification-alpha22.md). Tag v1.0.0-alpha.22 → c725e41 (annotated
  4b933ecc). Gates on that tree VERIFIED: analyze clean, 473 passed + 1 skipped.
- Mirror: sync_public_ci.sh → pyregrove-ci main ced99e5 (source c725e41), tag pushed.
  CI run 33591597500 GREEN (created 04:38:47Z). No Android/gradle change since
  89af754 (alpha.21) — signing path unchanged.
- androguard VERIFIED: APK com.tsorostudios.pyregrove / 1.0.0-alpha.22 / 34 /
  signer 286c4760f1801269550fe40658e6255c96107713690d0e4353cbe76bccee8ffd MATCH.
  AAB META-INF/UPLOAD.RSA signer MATCH; base/manifest carries versionName
  1.0.0-alpha.22 + package.
- GitHub prerelease id 380982465 on the PRIVATE repo, tag v1.0.0-alpha.22:
  pyregrove-v1.0.0-alpha.22.apk 53,278,203 B
    sha256 38cbe6d66672ac77ff3e5cbea5a6f21b95d3ed04e20c8397038dcaa9e1ed8fc3
  pyregrove-v1.0.0-alpha.22.aab 53,353,589 B
    sha256 0739a50fd3e9dd06d01a8eefd6c0d336457a382c74269d57b573e8df1e2d3715
  Both sha256s are in the release body.
- Re-download check: APK re-downloaded via the release asset URL, sha256 MATCH
  (38cbe6d6…8fc3, 53,278,203 B). **Deviation, stated plainly:** the directive asks
  for an *unauthenticated* re-download; that returns HTTP 404 because this repo is
  private (keystore committed → must stay private per docs/release.md). The
  re-download was therefore authenticated with the same PAT. If the owner wants a
  truly public asset check, it needs a public release surface (e.g. mirror the two
  files to a pyregrove-ci release) — not done, not in the directive; owner call.
- Not on any Play track; no listing edits. Branch update/delvers not included.
- Next: research (a)(b)(c), Pyregrove-scoped, in docs/research/.

## 2026-09-02 04:40Z — ACK directive 2026-09-02b (Pyregrove scoping) — read at 04:36Z, before any other action

Understood and applied:
- 2026-09-02a and 2026-09-01g were Emberdelve-scoped; nothing from them (v0.179.0,
  Ember Forge, 38 installs, USD 4.25) is acted on here. No Emberdelve research
  will be written into this repo.
- The one major update = what is on `main` since alpha.20 (jump retune ec994eb +
  gap-budget daf8276, dormant boss intro, R8/backup rules, Skia manifest
  opt-out). No new features start.
- Next: cut ONE prerelease v1.0.0-alpha.22 from `main` — GitHub only, APK + AAB,
  sha256s in the body, androguard against pin 286c4760…cee8ffd, unauthenticated
  re-download + hash check. Tag + downloadable asset = release; "built via CI"
  is not. If not finished in one sitting, that sentence goes here.
- Then research (a)(b)(c), Pyregrove-scoped, primary-source cited, in docs/research/.
- Unchanged: no ads/analytics/telemetry/phone-home/dark patterns; no store-listing
  edits; mirror-to-pyregrove-ci rule.

Disclosure so the owner can decide: branch `update/delvers` (@d33e923, pushed,
UNMERGED) holds a Delvers roster + Seven Hearths + feel slice built 2026-09-01/02
under my reading of 2026-09-01f as applying to Pyregrove. It is NOT part of
alpha.22 and stays unmerged unless the owner says otherwise. Its docs/research/
notes cite Emberdelve numbers and will not be merged; (a)(b)(c) start fresh on main.

## 2026-09-02 09:10 — Emulator session: memory partials, PNG-decode wall (env bug), 2 real app finds; directive 2026-09-01f absorbed

- Ran shipped alpha.21 APK (sha256-matched) on sandbox AVD: AOSP android-34 default x86_64, 2 GB RAM, swiftshader, TCG (no KVM). Boot 6.5 min. dumpsys needs `-t 120`.
- MEMORY (emulator-measured, memory-only valid under TCG; fps invalid): TOTAL PSS 83.4 MB title, 89.6 MB menus (Native 31-33 MB, Dalvik 1.7-2.7 MB, RSS 211-222 MB). PLAY-QUALITY-2027 rows 3/4 updated with partial datapoint; gameplay PSS UNMEASURED (see next).
- PNG-DECODE WALL: level entry = grey screen (release ErrorWidget). Root-caused via scratch probe app + VM-service Flutter.Error events (renderedErrorText names assets when logcat is silent): this system image fails EVERY PNG > 8x8 through the engine codec AND AssetImage — including fresh PIL solids and ffmpeg/PIL re-encodes. Assets exonerated: all 179 bundled PNGs byte-identical repo↔APK (sha256) and decode clean on desktop engine. Environment bug (flutter#42065 class), NOT a game bug. Full recipe + evidence: docs/EMULATOR-LIMITS.md.
- NEW GATE: test/asset_decode_test.dart — all 179 bundled PNGs through ui.instantiateImageCodec + count pin. Suite 473 green + 1 skipped, analyze clean.
- REAL app finds (queued for the authorized game-code window): (1) no FlutterError.onError/runZonedGuarded/ErrorWidget.builder — any release unhandled error = silent grey screen; (2) RenderFlex overflow 692px right at 800x480/240dpi, uncovered by overflow_sweep_test.
- Owner directive 2026-09-01f absorbed (519707f): player evidence says CONTENT — more delvers + 7-day hearth retention hook; one major update authorized ON A BRANCH, complete content only, no tag/release/Play, no tracking; 5-star review email is real but NOT on the public listing (never call it a public review).

## 2026-09-02 08:10 — Suite audit #5 (final pass): UI smokes + util tests — series CLOSED
- Spot-audited the remaining low-claim-density files: hud_layout, hud_routing, shop_flow, onboarding, lifecycle_pause, session_bench, telemetry, version, haptics, rng, level_data.
- ONE stale claim, fixed (comment-only): hud_layout_test header still cited the pre-2026-07-25 384x216 view for its touch-target math. Body was always correct (uses EmberGame.viewWidth/Height = 352x198); at the CURRENT view 44 view-px ≈ 51dp on a 411dp phone, so the shipped guarantee is STRONGER than the 48dp guideline, not weaker. Header now says so.
- Verified honest, no action: telemetry_test is load-bearing for the owner's no-tracking stance — asserts default-off on fresh install, no emission without BOTH explicit opt-in AND Firebase config, revocation from Settings, choice persistence, and backend errors never propagating; hud_layout measures the REAL mounted HUD incl. letterbox/safe-inset cases at two canvas sizes; version_test pins kAppVersion == pubspec version; rng/level_data/haptics assert what they claim.
- Gate: analyze clean, 472 green + 1 skipped.
- AUDIT SERIES CLOSED after 5 passes: 4 real finds (fairness runway enumeration polarity, through-B reachability + untested save fallback, boss phase-threshold drift, gap budget above measured double-jump range) + ~10 stale/false prose-and-header claims fixed across 3 claims-audit passes. Everything left in the freeze-lift queue is game code (frozen). Next continues: freeze-period research per standing directive, or owner directives from fetch.

## 2026-09-02 07:40 — Suite audit #4: gap budget exceeded measured double-jump range (real find #4)
- REAL FIND, fixed: world1/world2_levels_test capped required level gaps at maxGapTiles = 7, with headers calling it "the double-jump budget from the physics tuning" — but NOTHING in the suite measured double-jump horizontal range. Measured in-engine via the jump_arc harness (measure(air:true, run:true)): double jump at full run = 6.33 tiles. The 7-tile budget EXCEEDED real reach — a future level with a 7-tile bottomless gap would pass the gate while being uncrossable by double jump (air dash could still save it, but that is not what the gate claims). Same drift class as the boss-phase find: a constant claiming provenance from tuning with no tether to it.
- Vacuous-today check (both parsers agree, python + the game's own LevelData.parse): every shipped level measures widestGap = 0 — all columns have a floor somewhere; pits are spiked floors, not voids. So the gate has never bitten; it exists purely for future bottomless-gap content, which is exactly why its budget being wrong would have gone unnoticed until it certified a broken level.
- Fixes: maxGapTiles 7 -> 6 in both world tests (with the audit note); NEW jump_arc test "double jump at run speed: ~6.33 tiles of horizontal range" pins the measured value AND asserts range > 6.0 explicitly tied to the gap budget — a movement nerf below the budget now fails loud; tool/reachability_lint.py comment synced (was also claiming "maxGapTiles is 7").
- Also verified this pass, honest/no action: physics_test coyote/buffer probes bracket thresholds from both sides (0.08 in / 0.2 out — still valid at the retuned 0.12/0.16, correct polarity); juice/combat timing literals bracket tuning constants (fail loud on retune); mechanical sweep across ALL test files for set-but-never-asserted flags and expect-free test bodies: zero hits; air dash confirmed a base verb (kAirDashEnabled, one per airborne period) so full-kit reach comfortably exceeds 6 tiles; parSeconds IS consumed (results screen, game_screen.dart:330) so the par-fairness test guards live data.
- Freeze compliance: test + tool comment only. Gate: analyze clean, 472 green + 1 skipped.
- Suite audit series now 4 passes, 4 real finds (runway polarity, through-B reachability + save gap, boss phase drift, gap budget vs measured range). Remaining unaudited: the widget/UI smokes (hud_*, ui_smoke, shop_flow, game_screen_smoke, onboarding, back_gesture, lifecycle_pause) and small util tests (rng, haptics, version, level_data, telemetry, session_bench windowing) — lower claim-density, spot-check next if freeze holds.

## 2026-09-02 07:10 — Suite audit #3: boss-test phase drift after the 150-hp retune (real find); economy/daily/boss_intent verified honest
- REAL FIND, fixed: the 2026-09-01 TTK retune (60 -> 150 hp, both bosses) silently invalidated every hard-coded hp in the boss behaviour tests. At 150 max hp, phase 2 = 51-100: boss_core_test's "phase 2 root spikes" set hp=30 and kiln_golem_test's "phase 2 vent wall" set hp=30 — BOTH actually ran in phase 3 and only passed because phase 3's attack cycle happens to include the same attack. Kiln's "never borrows grove hazards in any phase" sweep used [maxHp, 30, 10] — 30 and 10 are both phase 3, so phase 2 was never covered by that sweep at all. Phase-2 attack SELECTION was untested for both bosses since the retune.
- Fix pattern (stale-proof): every phase-targeting hp is now DERIVED from the threshold ((maxHp*2/3).floor() / (maxHp/3).floor()) and each test ASSERTS boss.phase before proceeding — a future hp retune flips these tests red instead of silently moving them to the wrong phase. Stale 60-hp-era comments ("40 -> phase 2", "20 -> phase 3") corrected to 100/50. Suite green: the phase-2 attacks genuinely fire in phase 2 (chooseAttack cycle.isEven paths confirmed exercised).
- Verified honest, no action: economy_test asserts real Wallet/buy/effectivePrice behaviour AND the shop UI routes through those exact functions (shop_screen.dart _priceFor/_buy -> economy.dart, checked call sites — the tested boundary is the used boundary); daily_test's determinism/pool/round-trip claims all carry matching asserts; boss_intent_test's header matches its assertions (completed==true + deaths<=2 per boss per seed, 8 runs); all 6 BossAttack values are reachable in the two chooseAttack switches (no dead attacks shipping).
- Freeze compliance: test-only. Gate: analyze clean, 471 green + 1 skipped.
- Suite audit state: 3 passes done (fairness/runway polarity; reachability through-B model + save corruption; boss phase drift). The suite's claim-surface is now audited end to end for the headline files; remaining unread tests are small mechanism tests (roll, air_dash, chute_trap, heart_pickup, hold_button, decor, environment, hud_*, rng, substep, secret_vault, credits_blocks, economy covered, telemetry, session, world1_levels, physics, juice, enemy_*, audio_mix, back_gesture, boss_wake, game_screen_smoke, lifecycle_pause, onboarding) — spot-audit opportunistically if freeze holds.

## 2026-09-02 06:40 — Suite audit #2: reachability model bug (through-B rise), save corruption gap, stale meta_screens header
- REAL FIND, fixed in test + mirror lint: the reachability model (test/reachability_test.dart + tool/reachability_lint.py) treated cracked walls 'B' as fully passable — including rising straight UP through one. The swing hitbox is horizontal-only (player_core.dart attackHitbox: extends from body.right/left, no upward swing), so a block directly overhead can never be broken: a secret vault sealed only by an overhead B would have been CERTIFIED reachable while being physically unenterable — exactly the alpha.5 sky-vault failure class this test exists to prevent. Probes run before fixing: (1) strict variant (B fully solid) fails 10/12 levels — in w2_l2 even the EXIT sits behind side-breakable walls, so B-as-breakable is load-bearing and a fully-solid model would be over-strict; (2) corrected middle model (B passable for horizontal entry + standable-on, but NOT risable-through) passes all 12 shipped levels. So: latent model overclaim, no live bug — same polarity as the brambleMimic find. Both files now use pass_v/passV for the two vertical rise segments; headers document the side-break-only rule.
- Coverage gap closed in test/save_test.dart: save.dart promises "corrupt live -> backup; corrupt backup -> fresh save" but only the first half was tested. Added the both-files-corrupt case (must boot with a fresh save, not crash). Passes against current code — regression guard, suite is now 471.
- Stale header fixed: test/meta_screens_test.dart still said credits render "the required CC-BY chest attribution" — the dustdfg chest was replaced in the 2026-07-25 original-asset pass and the test BODY already asserts the opposite (no CC-BY left). Header now matches the body.
- Verified honest along the way: save_test round-trip/migration/progression assertions all check real fields; reachability's "over-approximation is impossible" claim is TRUE for geometry (every move collision-checked) and now true for break mechanics too.
- Freeze compliance: test + tool + comment changes only; gate analyze clean, 471 green + 1 skipped.
- Suite audit remaining candidates (pass #3, if freeze holds): economy_test price/refund claims vs catalog, daily_test seed-rotation claims, boss_intent_test phase coverage vs boss_core phases.

## 2026-09-02 06:10 — Suite audit #1: does any test claim what its assertions don't check?
- Same audit discipline as the prose passes, pointed at test/. Mechanical sweep first: only 3 test bodies contain zero expect() calls, all legitimate by design (overflow_sweep fails via FlutterError during layout — documented in its header; wipe_probe is the @Skip'd bot harness).
- REAL FIND, fixed: test/fairness_test.dart's "spawn runway is safe" rule used a HAND-ENUMERATED enemy set — SpawnKind.brambleMimic was missing, so a mimic ambush placed inside a spawn runway would have PASSED the safety gate. Scanned all 12 shipped levels: no 'N' within 14 tiles of any spawn, so this was a latent hole, not a live bug. Fix: enemy set is now derived by exclusion (SpawnKind.values minus an explicit non-enemy list), so any FUTURE enemy kind is treated as dangerous by default instead of silently exempted. This is the right polarity for a safety gate: forgetting to classify a new kind now fails toward safety.
- Header overclaim fixed: fairness_test's pin #4 said the casual bot "survives the opening minute of every level"; the actual assertion is conditional (IF the run dies out, it must last >=12 s and reach >=30%; bosses exempt). Header now states exactly that. Verified campfire "reachable" claim is genuinely covered — by reachability_test, not fairness_test.
- Honest headers confirmed elsewhere: session_bench explicitly disclaims device raster cost (regression guard, not a 60fps proof); frame_stats tests the windowing math only; audio_assets does check both directions (ids->files and no orphan .ogg).
- Freeze compliance: test-only + comment changes strengthen the gate; no game code, no release. Gate: analyze clean, 470 green + 1 skipped.
- Audit coverage so far: zero-expect sweep (whole suite) + deep read of fairness/frame_stats/session_bench/audio_assets headers-vs-asserts. Remaining candidates for a second pass: reachability_test's actual reachability model, save_test's corruption cases, meta_screens claims.

## 2026-09-02 05:45 — Claims audit #3 (final prose surfaces): spec.md, features.json, one more PROJECT.md falsehood
- docs/spec.md corrected against code (every number re-verified in tuning.dart before editing):
  * SS3 feel spec still said coyote 0.10 / buffer 0.12 — stale since the owner-directed 2026-09-01d retune (now 0.12/0.16). Updated with pointer to JUMP-PHYSICS.md and note that tuning.dart is canonical. Attack buffer 0.15s and hit-pause 40ms verified still true (kAttackBufferTime/kHitPause).
  * SS5 "par times for medals" — medals are finish/all-chests/low-damage; no par times exist (P-M8 evidence already admitted the wording predates the shipped design). Corrected.
  * SS5 "Worlds 2-3 (Cinder Caves, The Delve) later" — World 2 shipped as "Cinder Depths". Corrected.
  * SS8 release targets were dice-era misleading ("Play closed-track update", production "~2026-08-07"): left the original plan intact as history, added a dated status note (alpha.1-.21 = GitHub prereleases only; Play = NEW listing, owner call, freeze in effect; quests not shipped).
- PROJECT.md #10 said World 2 "shipped as 'Kiln Hollows'" — FALSE: shipped UI string is 'WORLD 2 — CINDER DEPTHS' (level_select_screen.dart:74); Kiln Golem is the boss, Kiln Hollows appears nowhere in lib/. Fixed.
- features.json: P-M7 note refreshed (universal APK 50.8MB snapshot -> alpha.21 shipped 53.3MB, both provenance-marked; pointer to DEVICE-TEST-PROTOCOL.md). Evidence fields of PASSED features left untouched — they are flip-time proof snapshots (P-M4's dustdfg CC-BY mention is historical truth; P-A1 documents the replacement). Protocol respected: no id/title/acceptance edits. JSON re-validated; no test/ or tool/ consumer of features.json or spec.md (grepped).
- With this, every prose claim surface in the repo has had one full audit pass: CREDITS/PROVENANCE (04:50), README/PROJECT/play-listing (05:20), spec/features (this entry). Claim-audit vein is mined out until code changes resume; remaining unverifiable claims are the device-blocked ones (P-M7, on-device feel).

## 2026-09-02 05:20 — Published-claims audit #2: README/PROJECT/listing vs reality; co-agent commit absorbed
- Absorbed commit 48169fb: Emberdelve appendix row in PLAY-QUALITY-2027.md now carries a measured DEX verdict for the DICE game (v0.178.0, 74.6% R8 coverage, evidence in the emberdelve repo). Properly scoped + sourced; accepted as-is. Note: dice game is at v0.178.0 now — anything in this repo citing its version is historical.
- Ran the full gate BEFORE further doc edits because yesterday's CREDITS.md fix ships in-app (CREDITS.md is a pubspec asset rendered by credits_screen.dart, and meta_screens_test renders the real file): analyze clean, 470 tests green. The false font-license claim WAS user-visible in alpha.21's credits screen; fixed text ships with the next build.
- Stale/false claims found and fixed (all verified against code/toolchain/tags before editing):
  * PROJECT.md said engine = "Flutter (stable 3.32.x)" — toolchain is 3.44.9. Fixed with as-of date.
  * PROJECT.md said last published tag = alpha.20, twice — alpha.21 is the owner-authorized cut of 2026-09-01. Fixed both spots. This mattered: the repo's resume-from-files-alone contract would have misled the next AI about what shipped.
  * PROJECT.md M6 release link was relative (../../releases/tag/v1.0.0-alpha.1) — the tag exists here but the RELEASE object lives on the old emberdelve repo (verified via API). Linked absolutely to the old repo.
  * README said "CI builds signed APK/AAB on main" — Actions are billing-blocked on this private repo; CI runs on the public mirror, signed builds are local. Rewritten to reality.
  * README said "Art/audio: CC0/CC-BY only ... attribution shipped in-app" — nothing shipped requires attribution since the 2026-07-25 original-asset pass; reworded (policy vs current state) and noted CREDITS.md is a bundled asset.
  * play-listing.md draft claimed "chargeable apple throws" — no charge mechanic exists anywhere in lib/ (throw is a held/press trigger; the only charge code is enemy AI). Fixed to "arcing apple throws".
- FLAGGED, not resolved (owner call): listing draft's analytics bullet truthfully describes shipped code (consent-gated telemetry, Firebase collection off by default) but sits in tension with DEMAND 2026-09-01b "no in-app tracking ever". If the telemetry module is removed when the freeze lifts, the bullet must become "No analytics. No tracking." Inline REVIEW note added to the draft; not shipping-blocking since the listing itself is frozen. Removing lib/telemetry/ is game code = frozen; queued for freeze-lift.
- Store-listing freeze check: the freeze bans edits to the LIVE Play listing (dice game); this file is an in-repo draft for a future owner review — editing it is doc work.

## 2026-09-02 04:50 — Font licensing audit: shipped APK compliant, repo claim was false, fixed
- Audited OFL compliance for the two shipped fonts (Cinzel-Variable, Inter-Regular). Finding: CREDITS.md claimed the OFL license text was "retained with the font files in the repository" — FALSE, no OFL text existed anywhere in the repo (only the root proprietary LICENSE). Honest-presentation pillar: a public courtesy doc contained an untrue statement.
- However the SHIPPED artifact was never in violation: extracted both .ttf files from the released alpha.21 APK and read their name tables with fontTools — copyright (name0) + OFL declaration (name13) + license URL (name14) present in both. OFL 1.1 explicitly allows the notice+license "in the appropriate machine-readable metadata fields", so embedded metadata satisfies it. VERIFIED, not assumed.
- Fix (freeze-compliant, repo text only — assets/fonts/ is not in the pubspec asset bundle, only the two .ttf paths are, so nothing ships differently): landed upstream license texts as assets/fonts/OFL-Cinzel.txt (NDISCOVER/Cinzel OFL.txt) + assets/fonts/OFL-Inter.txt (rsms/inter LICENSE.txt), corrected the CREDITS.md fonts paragraph to state exactly what is true, and added the missing per-file font entries to PROVENANCE.md (its pivot note said "font entries remain shipped" but the audit-trail tables had none — fonts landed at 54f2e85, 2026-07-23).
- No game code touched. Freeze intact.

## 2026-09-02 04:20 — Memory rows bounded content-side; FALLEN-card nit stays frozen
- PLAY-QUALITY-2027.md rows 3/4 amended with a measured static bound (no device needed, no tracking): all 179 bundled PNGs decode to 6.34 MiB RGBA total (largest single texture = 400x368 tileset, 0.56 MiB); SFX SoundPool pool ~3.6 MiB decoded (28 one-shots, 21.5s total); music mono via MediaPlayer one track at a time, worst 4.2 MiB; fonts 0.96 MiB; levels 30 KiB. Worst-case game-content memory ~15 MiB. Verdicts stay EXPLICITLY UNKNOWN — bound != RSS; if a threshold ever trips, the cause is engine/framework overhead (Flutter engine, Dart heap, Skia, platform buffers), measurable only by device profile or vitals. This is the artifact version of "our content cannot be the problem": it narrows what a future device profile needs to look at.
- CORRECTION found while measuring: row 4 previously said "largest bundled images are store/launcher assets" — false. assets/icon/ is not in the pubspec asset bundle; the 1024px icon master (4 MiB decoded) never ships as a runtime asset. Fixed in the doc with the correction noted inline.
- FALLEN-card/title-banner overlap nit: located in lib/ui/game_screen.dart — game code OUTSIDE the jump slice, so it stays frozen under directive 2026-09-01b/d (narrow lift covers jump tuning only). Not fixed, deliberately; noted here so it isn't forgotten when the freeze lifts.

## 2026-09-02 03:50 — Difficulty probe re-run vs retuned arc: curve PRESERVED (120/120 completions)
- Re-ran the committed wipe probe (10 regular levels x easy/medium/hard x 4 seeds) against the 2026-09-01d jump retune. Every run COMPLETED. Cell-by-cell vs the 85c7595f baseline table: 29/30 cells identical in time/deaths/hits (w1 rows byte-identical; w2 rows within 1s/0.2h).
- One delta: w2_l4 MEDIUM 28s d1 h7 -> 38s d2 h9 (new 3s stall col93). Easy AND hard on the same level are unchanged (23s d0 h4 / 22s d0 h4), so this is a casual-bot route desync — the bot's fixed 0.3s held jumps land differently under the wider apex hang and sync badly with one medium-speed enemy — not a difficulty regression. A slower time on medium than hard is bot-artifact territory by the probe's own reading rules (see wipe_probe_test.dart header). Completability unaffected; no action.
- Between-world ramp intact (medium hits w1 2-3 -> w2 3-9). Bosses not re-run (baseline = wipes casual bot by design; coached-bot verification already done in the 02:20 entry: deaths unchanged, hits improved).
- Verdict: the retune made jumping more forgiving without moving the difficulty curve the levels were balanced against. Probe log discarded after comparison; regen command unchanged in progress.md canon.

## 2026-09-02 03:20 — B7 hard-landing recovery crouch shipped (jump slice, directive 2026-09-01d)
- Implemented the last jump-slice backlog item: falls >= kHardLandTiles now get a visible recovery crouch — 25% squash easing out over 160ms (vs the normal landing's 15%/80ms), render-only, NO input lock (Celeste rule), replaces the normal squash outright (no stacking). player_component.dart triggerHardSquash + render branch (deep crouch outranks squash outranks stretch); wired at PlayerEvent.landedHard in ember_game.dart next to the existing thud+haptic.
- Test: juice_test.dart "B7 hard-landing crouch" (replaces normal squash, live at 0.10s, gone by 0.17s). Gates: analyze clean, 470 tests + 1 skipped green.
- Visual QA: web harness, w1_l5 tower drop (spawn 64,6), 14 frames at 70ms sampling — crouch clearly visible at touchdown (wider flattened silhouette, feet anchored, dust synced), clean recovery, no artifacts.
- Jump slice of FEEL-POLISH-BACKLOG now fully closed (marked in doc). Rest of backlog remains frozen. No release, no tag.

## 2026-09-02 02:55 — Visual QA of the retuned jump: PASS (9 captures, phone + desktop)
- Web harness rebuilt on ec994eb7; scripted arc captures at the two owner-flagged sensitive spots: w1_l3 (full jump rise/apex/fall + tap-jump apex/land, phone 844x390) and w2_l4 one-way climb (single->double->settle, phone) + desktop 1440x810 wide apex.
- Verdict: no visual defects. Arc phases read distinctly (takeoff stretch, apex silhouette, landing dust); the lifted tap jump (1.6 tiles) reads as a deliberate jump, not a stumble; w2 palette climb clean, no tile clipping; HUD/sign bubbles/touch controls intact. Phone telemetry 60fps steady; desktop capture 38fps is the SwiftShader headless artifact (documented in docs/perf.md), not a device claim.
- No code changed. On-device feel still owner-verifiable only (see 02:20 entry).

## 2026-09-02 02:35 — Directive 2026-09-01e acknowledged: privacy policy page is published surface
- My 2026-08-31 commit 9abefd4 scoped the GitHub-Pages privacy policy to Pyregrove while that exact URL is the Privacy Policy field on the LIVE Play listing of com.tsorostudios.emberdelve — a compliance exposure on the one earning app for ~a day. Owner fixed it (page now "Tsoro Studios Games", covers all three packages) and set rules: never scope that page to one game, never move/rename it, per-app sections if practices diverge, and treat docs/ in the public repo as published surface — grep for dependents before any rebrand. Rules recorded in my memory files; mistake owned.

## 2026-09-02 02:20 — Directive 2026-09-01d: jump feel retuned (narrow freeze lift), suite 469 green
- Owner directive 66513ba8 landed mid-session: "make the jumping a little easier and balanced… research first" — jump tuning authorised onto main, nothing else. Executed end-to-end this iteration.
- Verified the DEMAND arc table in-engine (all deltas <=3%, no engine/maths divergence; range 3.69 was standing-start, running-start measures 3.81 tiles). References researched with citations (Celeste 83ms coyote/0.15s buffer ON PC; touch adds ~50-100ms → mobile guidance 0.20-0.25s; AK frame-measured 0.72s airtime + ~0.2s apex hang, already in feel-notes.md; Pittman GDC jump maths; SMB 2-3.5x fall gravity).
- Changed (tuning.dart): kCoyoteTime 0.10→0.12, kJumpBufferTime 0.12→0.16, kApexHangSpeed 40→64, kJumpCutMultiplier 0.45→0.55. NEW kLedgeLandNudge 4px (physics.dart): falling mirror of the ceiling nudge — committed falls (vy>=120) missing a SOLID ledge by <=3px slide on. kJumpSpeed/kGravity untouched. Full docs/JUMP-PHYSICS.md with before/after tables.
- Balance gate: gap audit of all 12 levels — widest required gap 4 tiles DESCENDING; no flat/ascending gap >=4 anywhere, so +0.31 tiles of range unlocks nothing; vertical gating intact (2.33<3, 4.20<5). Enforced as invariants in new test/jump_arc_test.dart (7 tests: arc characterisation in tiles/ms — update deliberately with any retune — plus ledge-nudge lands-2px/misses-8px pair, plus margin invariants).
- Two hard-won exclusions: (1) ledge nudge must NOT apply to one-way platform lips (drop-down routes; with them included the w1_l3 bot got trapped bouncing on the lip above the exit — vy guard also added after walk-offs went sticky, 8 tests failed then fixed); (2) w2_boss coached bot re-coached to the floatier arc (air-brake 14px early, hold release over the pillar, perch anchor 424→418, bomb-dodge window 0.35s/30px→0.5s/38px) — baseline check confirms deaths-per-run unchanged (1) and hits-to-win improved (5→4), so bot routing, not level regression.
- Gates: analyze clean, 469 tests + 1 skipped all green (was 462; +7 arc tests). Freeze otherwise intact: no release, no tag, no Play.
- HONEST LIMIT (per directive deliverable 4): on-device feel is unverifiable here — whether the wider windows read as "easier" under real touch latency needs the owner's thumbs on a phone; w1_l3 spike hops and w2_l4 one-way climbs are the spots to try first.

## 2026-09-02 01:35 — Directive 2026-09-01c actioned + closed-track gate verified
- Mid-iteration fetch caught owner commits f56416f1/8d3c0d93 (directive 2026-09-01c): primary-source drop of Google's 2026-08-26 email — two new Play quality requirements. Read docs/research/owner-inbox-evidence.md before touching PLAY-QUALITY-2027.md, as instructed.
- Hunted the primary sources the email references and found them: Android Developers Blog 2026-08 announcement + Android vitals bitmap page + press (9to5google/pocketgamer/techrepublic). Now SOURCED: memory enforcement Feb 2027 ("reduced visibility and publishing capabilities"); games get distinct HIGHER memory criteria than apps; numeric thresholds still UNPUBLISHED (left unknown per directive — no invented numbers); Zero-Tap Sign-In required April 2027 but "games are currently exempt" (verbatim); new Play Console tools (OOM filter, dynamic-memory+bitmap vitals, alerts); Android 17 per-app Memory Limiter context.
- docs/PLAY-QUALITY-2027.md updated: "What Google announced" rewritten with provenance; row 4 gains sourced metric semantics (28-day aggregate, background/cached-state holding = the violation, P99/P50>3.5x leak heuristic, Flutter image-cache accounting recorded unknown); row 7 upgraded EXPLICITLY UNKNOWN -> EXEMPT (currently): Pyregrove is a game AND has no sign-in — outside the requirement twice over. Rows 3/4 memory verdicts stay EXPLICITLY UNKNOWN (no thresholds published, no device, no vitals).
- NEW docs/CLOSED-TRACK-GATE.md (verdict-first): Google's 12-tester/14-day closed-test gate for personal accounts created after 2023-11-13 VERIFIED against Google's help center (was 20, reduced 2024-12-11); Production AND Pre-registration disabled until met. Whether it binds = unknown (account creation date not knowable from repo) but BOTH branches collapse to the same sequence — flip condition #3 already specifies the same 12/14 closed track, and pre-registration (our one Play-native receipt tactic) sits behind the gate anyway. No owner question needed now; "confirm account creation date" queued as first flip-time checklist item.
- Session checks: DEMAND md5 74c4084e after pull (2026-09-01c in force); docs only; freeze intact; no code, no tags, no releases.

## 2026-09-02 01:05 — Channel-receipt hunt (flip condition #1) -> docs/CHANNEL-RECEIPTS.md: NOT MET, evidence strengthens the freeze
- Hunted documented launch postmortems with numbers (10 receipts tabled, 2015-2026). Findings: (1) Play cold-launch failure is the BASE RATE — three independent 2022-2025 receipts (11 installs / 32 sales / 16 sales) reproduce Emberdelve's 38; (2) no modern Play-native receipt clears 1,000 first-month installs — best on record is Mission Jet Shield 2026: ~900 installs from 1,500 pre-registrations, zero spend; (3) every modern no-budget success (Ortica 4K, Moonbrella ~10K, onlypancak3s 28K) is short-form video -> STEAM wishlists, none route to Play; (4) short-form is a lottery with a grind floor (same authors' misses: 200-1,000 views).
- Consequences written verdict-first: flip condition #1 NOT MET and likely not meetable for Play -> the freeze is now evidence-backed, not only directive-backed. If Pyregrove ever launches with a distribution story, receipts point devlog->Steam, Play as trailing port; Steam-build investigation = feature work, frozen, noted only. Pre-registration = the one Play-native tactic with a receipt, compatible with the closed-track path. Conversion of short-form views to Play installs recorded UNANSWERABLE-until-attempted (owner-effort, no tracking).
- Session checks: git fetch clean (no new owner commits), DEMAND.md md5 de90fade unchanged. Docs only; no code, no tags, no releases.

## 2026-09-02 00:40 — Owner directive 2026-09-01b (4677607a) executed: LAUNCH-WORTHINESS.md rewritten verdict-first; freeze-lift plan CANCELLED
- New owner commit landed (DEMAND.md md5 now de90fadec1b48f009dd61c3ac27314a4). Read in full. Compliance on alpha.21 acknowledged; freeze UNCHANGED (no releases, no Play, Firebase settled).
- WARNING TAKEN: backlogs written during a freeze are work orders, not research — the drift that produced 177 releases. The queued "consolidated freeze-lift execution plan" was exactly that pattern and is CANCELLED, not deferred. B/C/L backlog docs stay as written (owner read them; deleting rewrites history) but gain no successors; future artifacts must be able to talk us OUT of something.
- LAUNCH-WORTHINESS.md rewritten per the three asks: (1) verdict in line one — do NOT launch; (2) case AGAINST launching is the load-bearing half, anchored on the differ test: any launch plan must name the distribution input that differs from Emberdelve 2026 ("the game is better" fails — quality was above the bar last time and moved nothing); (3) flip conditions now concretely checkable: #1 channel receipt (comparable no-budget platformer with documented >=1,000 first-month installs via an ownable channel), #2 audience numbers (>=3 posts >=1,000 organic views + >=200 in owned space, 60 days pre-decision), #3 retention proxy WITHOUT in-app tracking (closed track >=12 testers/14 days clean, or 5/10 hand-run testers returning unprompted <72h; public D30 recorded as UNANSWERABLE per no-tracking rule), #4 one filled Class A device row, #5 owner-written one-sentence goal with a number. "Polish"/"more content"/"World 3" explicitly rejected as flip conditions. Honest exit (portfolio piece, installs irrelevant) kept.
- Session checks: pulled ff-only to 4677607a before working. No code, no tags, no releases.

## 2026-09-02 00:10 — Level/content craft research -> docs/LEVEL-CRAFT-BACKLOG.md (docs only) + parsed-level audit
- Researched teach-test-twist/kishotenketsu (Hayashida, GMTK), platformer flow guides, level-design theory glossary (breadcrumbing, denial & reward, foreshadowing), Rayman Legends secrets design, Apple Knight reception; graded all 12 level files (parsed assets/levels/*.txt) + 144-run probe evidence.
- VERIFIED strengths: textbook one-new-enemy-per-level cadence across both worlds; signs fade 4->3->2 (geometry takes over); verticality finales (one-ways spike to 78/87 at w1_l5/w2_l4); hearts cluster exactly where the probe shows pressure; clean boss arenas; campfire chunking; par_s+medals everywhere.
- MAIN FINDING: rigid per-level template — EVERY regular level has exactly 2 chests/2 secret X/1 feather/~8 cracked blocks. Read as count-promise strength (Apple Knight praise = "secret-heavy, consistent") + concealment-idiom risk. Verdict: keep 2C/2X/1f contract, diversify hiding idioms.
- Backlog: L1 w2 mimic gap now DATA-CONFIRMED (N only in w1_l3, zero in w2 — the known-deferred item's spec home); L2 secret-idiom audit (>=3 idioms/world, capture-review with existing harness); L3 w1_l1 coin-arc breadcrumbing pass (CHECK flat rows vs arcs); L4 denial&reward moment (candidate w2_l2, lowest hazard count); L5 per-level "where does it twist?" capture audit; L6 widen kDailyPool to w2 after L1/L5 (probe 4/4 first). Rejected: World 3 before retention+audience, breaking the count contract, tutorial popups, procedural campaign levels. Order: L3->L1->L2->L5->re-authors->L6.
- Session checks: git fetch clean, DEMAND.md md5 unchanged. No code, no tags, no releases; parsing reads only.

## 2026-09-01 23:45 — Audio craft research -> docs/AUDIO-POLISH-BACKLOG.md (docs only) + measured mix audit
- Researched vertical layering / horizontal resequencing (Phillips GDC 2021), indie SFX workflow norms (Krotos, SonusGearFlow transient/body/detail/tail), Celeste (Raine) + Hollow Knight (Larkin) audio interviews; graded lib/audio/audio_service.dart against them. Engine plumbing solid: per-family beds + dedupe, orphan-safe fade-out, ambience bed, danger heartbeat bed (= vertical layering already proven), SoundPool low-latency voices (stutter fix, load-bearing), pitch wobble, step/swing round-robins, mixWithOthers, lifecycle pause/resume.
- MEASURED shipped assets (ffmpeg ebur128/astats, commands in doc SD): music spread 2.6 LU, cave_combat -23.3 LUFS is ~1.5 LU quieter than combat -21.8 -> W2 reads flatter for a MIXING reason; no clipping anywhere; SFX hierarchy broadly right; sub-400ms files gate to -70 LUFS under ebur128 (use astats for one-shots).
- Backlog (nothing implemented): C1 symmetric crossfade (VERIFIED gap: new track starts at full volume, only old fades); C2 re-level cave_combat +1.5 LU (asset-only, cheapest real win); C3 music ducking on player_hit/boss_death/phase-change (never on coins/swings); C4 sample round-robins for coin+enemy_hit (single sample each, most-fired ids); C5 boss phase-2/3 intensity layer via the setDanger pattern; C6 danger bed scales with peril; C7 CHECK victory/defeat double-trigger (both music sting and sfx exist). Rejected: middleware migration, horizontal resequencing, positional SFX, 48kHz re-export churn, >4 simultaneous loops (2GB RAM floor). Order: C2->C1->C3->C6->C4->C5.
- Session checks: git fetch clean, DEMAND.md md5 unchanged. No code, no tags, no releases; ffmpeg reads only.

## 2026-09-01 23:20 — Feel/animation craft research -> docs/FEEL-POLISH-BACKLOG.md (docs only)
- Researched Vlambeer 31-trick list, GMTK Celeste analysis, Dead Cells weight ratios, 2D attack anatomy, pixel-anim frame norms; then read the repo to grade honestly. Verdict: foundation layer (coyote/buffers/jump-cut/apex hang, camera lerp+lookahead+peek, hitpause, hurtFlash+recoil, shake+toggle, takeoff stretch/thud/dust, pitch-wobble SFX, swing-arc combo, haptics, parallax) is COMPLETE — gap is the differentiation layer (actions don't differ in weight).
- Backlog written, prioritized + costed, nothing implemented: B1 tiered hitstop (flat 0.040 -> 0.035/0.070 kill/0.100 boss-phase, cap ~120ms); B2 per-weapon swing weight (VERIFIED gap: hammer 9dmg swings identical to squire 3dmg; Dead Cells anticipation:strike:recovery ratios via catalog swingProfile); B3 smear frames (VERIFIED absent; one extra decayed-alpha arc draw, zero assets); B4 kill permanence (CHECK-first corpse decals, N-capped for 2GB budget); B5 escalating coin-pitch chains (composable with existing wobble); B6 rule: anticipation trails physics, light weapons keep press==hit; B7 hard-landing recovery frames (conditional on B2). Rejected with reasons: stronger shake, input-locking anticipation on lights, motion-blur shaders, gun-idiom Vlambeer tricks. Order: B1->B3->B5 then B2/B6->B4->B7.
- Session checks: git fetch clean, DEMAND.md md5 unchanged. No code, no tags, no releases.

## 2026-09-01 22:55 — Platform watch pass (notes only) + 16KB compliance VERIFIED
- docs/research-2026-09.md gained "Platform watch 2026-09-01": Flutter stable now 3.47.0 vs our 3.44.9 (no urgency; 3.47 makes Impeller default on desktop, ships 187237 Vulkan crash fix). Impeller stance RE-VALIDATED: #187009 still open (Adreno 506: Impeller 28-32fps/100% jank vs Skia 54fps on 3.44.0, blocklist doesn't cover it) + NEW #180958 Adreno 840 (2026 flagship) also degraded — EnableImpeller=false stays; named upgrade gate: manifest opt-out is being deprecated upstream, so any Flutter upgrade must first prove opt-out honored / issue fixed / blocklist coverage. targetSdk: API-36 requirement lands 2026-08-31 — alpha.21 already targets 36, compliant. 16KB pages (updates blocked from 2027-02-01): VERIFIED on shipped alpha.21 APK — arm64 ELF LOAD aligns 0x10000/0x10000/0x4000 + zipalign -c -P 16 "Verification successful". Zero platform debt; evidence commands recorded for re-run on future upgrades.
- Session checks: git fetch clean, DEMAND.md md5 unchanged. No code, no tags, no releases; local checks read-only against the shipped artifact.

## 2026-09-01 22:30 — On-device test protocol (flip-condition #3 groundwork; docs only)
- docs/DEVICE-TEST-PROTOCOL.md written: P-M7 becomes a ~90-min checklist run when hardware exists. Sections: artifact pinning (test the shipped signed APK, sha256+signer verify first); Class A bar = 2GB device; startup via `am start -W`; frame perf via gfxinfo reset->aggregate + SurfaceFlinger --latency (KEY CAVEAT researched: Flutter renders into a SurfaceView so gfxinfo percentiles under-report game jank — stackoverflow 65536889); memory via `dumpsys meminfo -a` App Summary (TOTAL PSS/RSS/SWAP PSS + Graphics row) at 4 app states, matching Play's incoming anon-RSS+swap dynamic-memory metric; stability battery incl. wake-lock check (visibility penalties from 2026-03-01, 5% bad-behavior bar — Pyregrove ships WAKE_LOCK so backgrounded lock check is mandatory); vitals thresholds recorded (crash 1.09%/8%, ANR 0.47%/8%); results table template — one filled Class A row flips condition #3 to evidenced either way. ASSUMED bars labelled as such (cold start ≤2500ms, peak PSS ≤350MB); Play memory limits still unpublished so PLAY-QUALITY line stays EXPLICITLY UNKNOWN. Dev-verification kept as DO-NOT-ACTION note per DEMAND.md.
- Session checks: git fetch clean, DEMAND.md md5 unchanged. No code, no tags, no releases.

## 2026-09-01 22:05 — Audience playbook (flip-condition #2 groundwork; docs only)
- docs/AUDIENCE-PLAYBOOK.md written: consensus model from four 2026 launch-strategy sources (6-18mo devlog runway or compressed milestone posts; 1 short-form clip/wk + 1 long-form/mo cadence; before/after + problem->solution content performs; short-form=discovery, long-form=trust, Discord=ownership). Pyregrove-specific: 4 honest angles (original assets, no ads/trackers, low-end-first engineering, the AI-assisted build process itself) + a 12-clip bank mapped to EXISTING capture tooling (boss flow, wipe-probe montage, before/afters from fixed bugs, feel-stack slow-mo) + 5 long-form arcs already in repo history. Division of labour split: accounts/voice/identity = owner-only; recording/editing/copy/calendar = repo side when asked. Sequencing: if owner time (~2-4h/wk) doesn't exist, the honest close is declaring Pyregrove a portfolio piece (settles flip-condition #4).
- Session checks: git fetch clean (no owner commits), DEMAND.md md5 unchanged. No code, no tags, no releases.

## 2026-09-01 21:40 — Visual-QA backlog cleared + retention-spine design research (freeze respected)
- view_image infra recovered; all 19 queued captures eyeballed (boss sequence spawn->wake->p2->p3->end, arena one-ways, recoil frames, sign-wrap pre-caps). VERDICT: no defects. Sign-wrap fix 3daccc70 confirmed visually (bubble wraps in-view). One cosmetic nit recorded, not actioned: FALLEN card overlaps the still-fading level-title banner on instant-death runs — only reachable via harness ?spawn-next-to-patroller, legible, harmless.
- docs/RETENTION-SPINE.md written (research artifact, explicitly not-for-implementation while frozen): groundwork for LAUNCH-WORTHINESS flip-condition #1. Researched (sources inline): daily-run canon = shared 24h seed + dials (Spelunky one-shot vs Dead Cells best-of; Caveblazers modifier sets; neutralise non-skill randomness); Apple Knight's loop = campaign-to-learn + endless-to-compete; median mobile D30 ~0.7% so single-player D30 targets must stay honest. Design: Phase A = deepen existing Daily Delve (date-seeded modifiers from DifficultyMods + streak, offline, days of work); Phase B = Endless Grove via hand-authored chunk library + edge-stitching (Dead Cells template approach), feasibility-validated by the EXISTING wipe-probe bot (we already own the hard part per Cloudberry Kingdom postmortem). Out of scope on principle: notifications/FOMO/login rewards (pillar 4). Sequencing note: Phase B before an audience exists = polishing a game no one awaits.
- No code, no tags, no releases. Play frozen.

## 2026-09-01 21:10 — Research phase deliverables (owner directive fb5f70bc; no code, no releases)
- docs/PLAY-QUALITY-2027.md rewritten as an evidence-graded checklist: 8 lines, each VERIFIED-MET / VERIFIED-UNMET / EXPLICITLY UNKNOWN with named evidence. New hard evidence read from the SHIPPED alpha.21 APK with androguard (not from source): manifest carries allowBackup/dataExtractionRules/fullBackupContent; classes.dex 1,985 classes with 1,861 (93.8%) R8-obfuscated short names (>25% DEX bar); analytics collection off, AD_ID absent. Items 3/4/7 (memory, bitmap, onboarding standard) are EXPLICITLY UNKNOWN — no published thresholds, no Play vitals possible pre-launch, on-device measurement blocked on hardware (P-M7).
- docs/LAUNCH-WORTHINESS.md written: the launch case incl. the case against. Verdict NOT YET, with 5 checkable flip conditions (retention spine, pre-existing audience, real-device evidence, written launch goal, checklist). Key researched facts (2026-09-01, sources inline): median Play app ~305 lifetime downloads, cold organic launch = 30–150 installs in month 1 (Emberdelve's 38 was the median outcome, not bad luck); ranking is driven by D1/D7/D30 retention + ratings with 7-day uninstall rate the heaviest negative — a weak launch actively buries the listing; Apple Knight (direct comp, 5M+ installs, 4.7★, #1 for "platformer") is estimated under $10K/mo, 72% ads → revenue is not a reason to launch in this category.
- Developer-verification registration recorded as a checklist line only (owner directive: not urgent, only if/when distributed) — NOT actioned.
- Play remains frozen; no tags, no releases, no new features. Open: re-check quality items when Google publishes numeric thresholds; conditions 1–4 are owner/product calls.

## 2026-09-01 20:15 — v1.0.0-alpha.21+33 "Real Fights, Real Phones" SHIPPED (the one owner-authorised release)
- Owner directive fb5f70bc executed exactly: ONE prerelease after one cohesive major update, justified in writing BEFORE the tag (docs/release-justification-alpha21.md, commit 157b9cff). 57 commits since alpha.20 consolidated; two themes (bosses become real fights; correct on real phones) + content/feel batch.
- Release flow: tag v1.0.0-alpha.21 @ 157b9cff → sync_public_ci.sh (mirror a23eb19) → pyregrove-ci run 33494632440 GREEN → androguard VERIFIED com.tsorostudios.pyregrove / versionCode 33 / 1.0.0-alpha.21 / signer pin 286c4760…8ffd MATCH → prerelease id 380442904 on PRIVATE repo, pyregrove-v1.0.0-alpha.21.apk (53,278,055 B) + .aab (53,346,551 B) uploaded, sha256s in release notes.
- SHA-256: APK b94c8da33540e91ea4f5c4e25701e027768a937b3f05a4690d6bd6c496b6caf2; AAB 9bf7555c0ea4aaaea596c112072384bc3da2b589f736e6f47da73eb9f0b1a4c8.
- Suite at tag: 462 passed + 1 skipped, analyze clean. Google Play: STILL FROZEN (owner call; not submitted, listing untouched).
- RELEASING NOW STOPS per the directive. Next work = research phase only: evidence-graded docs/PLAY-QUALITY-2027.md checklist (every line verified-met / verified-unmet / explicitly unknown) + launch-worthiness case doc (incl. the case against; emberdelve cautionary tale). Developer-verification registration noted in the launch checklist only, not actioned.

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

## 2026-09-05 07:45Z — v1.0.0-alpha.23 "Straight On" RELEASED (owner: "yes cut releases" + "also add pyregrove" [to Play], 2026-09-05)

- Tag `v1.0.0-alpha.23` at 11ea8a5 (main HEAD; pubspec 1.0.0-alpha.23+35,
  kAppVersion same). Mirror synced (pyregrove-ci main 9213776, tag pushed) →
  pyregrove-ci run 33951603864 GREEN: analyze clean, **587 tests passed**,
  signed APK+AAB job green.
- androguard on the downloaded artifacts: com.tsorostudios.pyregrove /
  versionName 1.0.0-alpha.23 / versionCode 35 / signer pin 286c4760…8ffd MATCH
  on both APK and AAB.
- Prerelease id 383170278 on the PRIVATE repo, body = draft notes (changes
  sections) + Verification + bytes/sha256 table. Assets
  pyregrove-v1.0.0-alpha.23.apk (53673664 B), .aab (53603099 B); API
  re-download of both hash-matched (repo is private, so no anonymous path).
- Play (owner call granted): app "Pyregrove: Pixel Platformer" created in
  the console (id 4975338342572773386, package com.tsorostudios.pyregrove,
  Game/Free, automatic protection OFF because sideload APKs continue).
  Main store listing saved from docs/store/ (title, short 75/80, full
  1515/4000, icon, feature graphic, 6 screenshots in phone/7"/10" slots).
  Next: store settings, app content declarations, internal-testing upload
  of this AAB, send for review. No production rollout without the owner.

## 2026-09-05 08:40Z — Pyregrove on Google Play: internal testing LIVE, listing + declarations sent for review

- Store listing saved (en-GB): title, short/full description from docs/store/play-listing.md, icon, feature graphic, 6 screenshots in phone + 7" + 10" slots.
- Store settings: Game > Action; contact tapiwamakandigoner@gmail.com; website https://tapiwa.me.
- App content declarations, all "Change saved": privacy policy URL (emberdelve Pages page, covers Pyregrove); Ads = No; Sign-in details = no restrictions; Target audience 13-15/16-17/18+ (same as the other apps; ASSUMED owner preference, avoids Families policy); Advertising ID = No (AD_ID stripped in manifest); Government = No; Financial = none; Health = none; Data safety imported from CSV = App interactions + Device/other IDs, both Optional, collected only, purpose Analytics, encrypted in transit, no account, no deletion path — mirrors Emberdelve's live declaration exactly.
- IARC questionnaire submitted → ESRB Everyone 10+ (Fantasy violence), PEGI 7, ClassInd/GRAC all ages, Taiwan PG12, Saudi 12. Answers: violence vs non-humans only, fantastical, pixelated, unrealistic reactions, distant perspective, blood None (the death "burst" is an abstract puff + rubble shards, no blood asset), "fierce sounds / sinister characters / dark overtones" = Yes (bosses, boss intensity music) — this one added the Fear/Horror descriptors; owner may resubmit with No if he disagrees.
- Internal testing track 4701745001089119884: release 35 (1.0.0-alpha.23) uploaded from the verified CI AAB (sha256 695f1787…ff9a04), 11.6 MB download, API 24+, target 36. "Save and publish" → Active, Available to internal testers (temporary app name until review). Testers list "Emberdelve Testers" (2) attached. Play App Signing accepted the upload; no key regenerated.
- Publishing overview: "Submit 9 changes for review" → **Changes in review** (~7 days). Production untouched.
- Upload note: the remote browser rejects set_input_files > 50 MB; the AAB (53.6 MB) was pushed in 6 MB base64 chunks into the page and set on the hidden file input via DataTransfer (change event) — worked first try.

## 2026-09-05 10:33Z — Directive 05b ACK + DONE: "More from Tsoro Studios" at the bottom of Settings (alpha.24+36, not cut)
- `lib/ui/more_games.dart` + two ListTiles under Reset save: Emberdelve (Play, market:// with utm_source=pyregrove → https)
  and Fliptide (itch page until `kFliptideOnPlay`). No badge, modal, telemetry or new permission.
- `url_launcher ^6.3.1`; manifest `<queries>` for VIEW market:// + https://. Version 1.0.0-alpha.24+36 (pubspec + lib/version.dart).
  Tests 591 pass (4 new), analyze clean. Ships with the next normal cut — no Play touch.
## 2026-09-05 — coin-flight lifecycle fixed and web harness checked
- VERIFIED: current main 0a5a6eb target files matched the 330e2d0 review base.
  Installed Flame 1.35.1 removal code explains why onRemove alone is not enough
  for queued effects or root GameWidget removal.
- Three additive regressions failed on baseline: `Expected: <0>` /
  `Actual: <12>` on mounted cancellation; `Expected: <1>` / `Actual: <2>`
  on root removal and duplicate arrival. Same test bytes now pass.
- Production change: owner-scoped flight registry, release-once cancellation,
  no stale completion pulse, root viewport cleanup. Cap 12 / life 0.42s,
  wallet crediting/path unchanged.
- VERIFIED: analyzer clean; focused 3/3; full suite 590 passed / 1 existing
  manual difficulty-probe skip; release main_webtest build passes. Existing
  CupertinoIcons expected-font warning retained, not suppressed.
- Browser harness: boot, keyboard movement and pause at 1280x720 and 915x412,
  zero page exceptions. Default executable was absent; one corrected launch
  used the installed matching Chromium binary. No check changed.
- Details: checkpoints/2026-09-05-coin-flight-lifecycle.md. No Android package,
  phone timing, full playthrough or holistic visual-review claim. Original
  tests/features, levels/tuning/economy, dependencies/signing/store untouched.

## 2026-09-05 11:15Z — alpha.24 cut: AGP 8.7.3 → 8.9.2 (url_launcher transitive deps)
- Mirror CI run 33962376877 failed at `assembleRelease` with, verbatim: `Dependency 'androidx.browser:browser:1.9.0'
  requires Android Gradle plugin 8.9.1 or higher. This build currently uses Android Gradle plugin 8.7.3.` (also
  androidx.core:core(-ktx):1.17.0). Pulled in by url_launcher_android (05b row). Fix: AGP 8.9.2 in
  android/settings.gradle.kts — the same AGP/Gradle 8.12 pair Emberdelve already builds with. No test/check edited.
- Tag v1.0.0-alpha.24 moved from f7775d7 to this commit before any release was published (nothing downloaded it).

## 2026-09-05 11:35Z — v1.0.0-alpha.24 RELEASED (GitHub pre-release)
- Tag `v1.0.0-alpha.24` @ 224578f. Mirror CI run 33962677869 green (analyze + 594 tests, 1 skip) after the AGP fix.
- VERIFIED before upload (androguard): pkg com.tsorostudios.pyregrove, versionName 1.0.0-alpha.24, versionCode 36;
  signer 286c4760…8ffd on APK and AAB.
- Release id 383226285, 2 assets; both re-downloaded via API and sha256 matched the body table (PASS x2).
- Play: NOT touched (internal track still on 35). Next Play internal upload = this AAB once owner-side review of the
  9 pending changes clears.
