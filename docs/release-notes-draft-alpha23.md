# v1.0.0-alpha.23 — release notes draft (LIVE — kept current per directive 2026-09-02d)

**Status: NOT TAGGED. Do not tag or publish until the owner says so.**
Version on `main`: `1.0.0-alpha.23+35` (bumped at the first user-visible change).

## Working title: "Straight On"

Turns research notes (a) and (b) into the build, in the directive's order:
first ten minutes → difficulty curve → Play-2027 code items → content.

## Changes since v1.0.0-alpha.22 (c725e41)

### First ten minutes
1. **Next level from the clear screen.** LEVEL CLEAR now offers
   *Replay · Levels · Next level*; "Next level" is the primary button and
   opens the next campaign stage directly (including Grove Golem → Ashen
   Gate). It is not offered after the final boss, in Daily Delve, or when
   the successor is a boss whose prerequisites are unmet (then the old
   *Continue* to level select shows). Gap source: (b) §2 Apple Knight —
   "you get thrown into a new level immediately". Menu round-trips removed
   per clear: 2 taps (Continue → level card). Pure rule `nextLevelId()` in
   `lib/meta/progress_state.dart`; tests `test/save_test.dart`,
   `test/results_next_test.dart`.

2. **Control size (Small / Normal / Large) in Settings.** Scales every
   touch button 0.85× / 1.0× / 1.2× (pause and the readout stay fixed);
   applied at the next level start. Gap source: (b) §2 Dead Cells mobile —
   "You can adjust button size and placement". Layout test proves no
   overlap and every button inside the view at both extremes on the
   800×450 reference canvas; screenshot-checked at 915×412. Setting is
   persisted (`controlScale`, clamped on load; legacy files → Normal).
   Free-drag placement is not in this cut.

9. **Swap control sides (Settings).** One switch mirrors the touch layout:
   move-pad bottom-right, action diamond bottom-left — the left-handed
   layout. LEFT stays left of RIGHT, pause and the readout never move, and
   the one-second spawn fade follows whichever cluster now covers the spawn
   point. Applied at the next level start. Gap source: (b) §2 Dead Cells
   mobile — "adjust button size **and placement**"; this closes the
   placement half. Layout tests prove the mirrored positions are the exact
   reflection of the normal ones, no overlaps, and correct behaviour under
   an asymmetric cutout (59 px left / 24 px right / 34 px bottom).
   Persisted (`mirrorControls`; legacy files → off). Harness `?mirror=1`.

28. **Control height (Flush / Raised / High) in Settings.** Lifts both
   touch clusters 0 / 14 / 28 view px off the bottom edge so the bottom
   row clears the thumb crease on tall phones; pause and the readout stay
   put. Applied at the next level start. Gap source: (b) §2 Dead Cells
   mobile "placement" — with Swap sides this is the two-axis version of
   placement without a drag editor. Clamped so the tallest cluster button
   (spell) never leaves the top pad: at Large size that leaves only ~2 px
   of lift, which the layout test asserts and the settings copy does not
   over-promise. Persisted as `controlLift`, clamped on load; legacy files
   → Flush. Screenshot-checked at 915×412 (Flush/Raised/High, High+Large,
   High+mirrored 1280×720). `?lift=` in the web harness.

10. **Buttons get out of the way.** Any touch button the player's sprite
    passes behind ghosts to 25 % opacity that same frame and eases back over
    ~0.3 s once they're clear; a button you are holding never ghosts. Found
    in the alpha.23 screenshot pass: in the Grove Golem arena the boss camera
    parks you 48 px from the frame edge — exactly under the dash/apple/jump
    column — and with the swapped layout the diamond sits on the spawn point.
    The one-second spawn fade is now a special case of this rule. Tests:
    ghost-the-same-frame, eased recovery, pressed-stays-solid, pure
    `coversRect`. Render-only.

11. **A death is a beat, not a teleport.** Lose your last heart and the sim
    holds for 0.55 s at the spot — the death animation (which never played
    before: the revive was instant) runs, a red burst and shards mark the
    place — then you're back at the campfire. What killed you is on screen
    when it happens. Losing the last life is unchanged (fail screen at
    once). Session-level: `kDeathHold`, new `playerDied` event, respawn
    deferred to the first live frame after the hold; the level clock does not
    run during the hold. Harness `?hearts=N` stages a one-touch death.
    Gap source: (b) §2 Celeste's respawn beat / Apple Knight's death anim.
    *Also on the last life:* the same 0.55 s hold and burst play before the
    FALLEN screen, so the hit that ended the run is seen, not covered.

12. **Restart level from the pause menu.** Pause now reads Resume · Restart
    level · Leave level. Before, restarting a bad run meant Leave → level
    card → tap: three steps for the genre's most common action. Restart keeps
    the run's seed and Daily Delve flag (same code path as Replay on the
    clear screen). Widget test covers presence, order and wiring.

13. **First run: PLAY goes straight into Forest Edge.** On a save with no
    finished level, PLAY opens the first level directly instead of the level
    select — one screen fewer between install and the first jump. From the
    first clear on, PLAY opens the level select as before. Keyed on finished
    records (an abandoned first run still lands in Forest Edge). Gap source:
    (b) §2 Apple Knight — the tutorial stage first, the menu after. Pure
    `firstRunLevelId()`; unit + widget tests.

### Content / replay (02d step 4, first item)
4. **Hard clear mark.** A level finished on Hard shows "· Hard clear" on its
   level-select card, forever. Gap source: (b) §2 Huntdown — "additional
   difficulty options upon a first clear" as a reason to replay; Pyregrove
   keeps difficulty freely selectable (no gating) and adds the mark instead.
   Record merge extracted to pure `mergeLevelResult()` and tested (medals and
   counts only rise, best time only falls, unfinished Hard runs don't count,
   legacy saves → false).
5. **Hits have weight.** Hitstop now scales with what the blow meant: a plain
   connect 35 ms, a killing blow 70 ms, a boss phase change 100 ms, the boss's
   last hit 220 ms (was a flat 40 ms for everything). The sword arc leaves a
   brief smear behind its fastest third. Coins picked up in quick succession
   climb a semitone each (resets after 1.5 s), so a coin run plays as a little
   arpeggio. Render/audio-only, no balance change.
6. **Boss fights stay in frame.** Once a boss wakes, the camera frames you
   and the boss together (you never sit closer than 48 px to the edge), so a
   shockwave or lobbed rock is never thrown from off-screen. Camera-only; no
   change to boss stats or arenas.
7. **Cleared rooms look cleared.** A grounded enemy you defeat leaves a small
   ash smudge where it fell (fades after ten seconds; at most eight per
   level). No new art, no animation — safe on 2 GB phones.
8. **The hammer hits like a hammer.** Wind God's Hammer connects with a
   longer freeze, a thicker arc and a small camera thud. Swing timing, damage
   and reach are unchanged for every weapon — this is feel, not balance.

15. **Coins fly to the counter.** Every coin you grab sends a small coin
    arcing from the pickup into the HUD wallet, which pulses when it lands
    (0.42 s, ease-in with a lift). Pure feedback — the wallet is credited at
    pickup as before. Capped at 12 in flight so a long chain never piles up
    draw work on a low-end phone. Tests: pure path (start/end/arc/ease),
    real event path spawns one flight that lands and pulses, cap holds.
    The bonus level is also in the sim benchmark now (avg 9 µs/update,
    cheaper than Rootway Ruins' 27 µs).

### Content (02d step 4)
14. **New level: Ember Hollow (World 1 bonus).** A coin-rich side level with
    the full World 1 roster — spike bed under a brick bridge, two ember
    totems on pillars, a rising thin-platform stair with an ashbat over it, a
    fire pit, an enemy gauntlet, two hidden vaults (one on the ground, one on
    a floating block reached from an approach platform), five chests, two
    feathers, three campfires, three signs. Opens once the Grove Golem falls
    (same gate as World 2) and appears as its own "Bonus — the Grove's
    Purse" section with a star badge. It is outside the campaign order: Next
    level never routes into it and nothing requires it. Held to every World 1
    content rule (lints, gap budget, quotas, secret placement, par, runner
    bot, collectible reachability). Casual-bot probe, 4 seeds: easy 0 deaths
    / 3 hits, medium 2 deaths / 6 hits, hard 2 deaths / 8 hits, all
    completed — harder than Rootway Ruins (0 deaths / 3 hits medium), never
    a wipe. Layout source: `tool/levels/gen_w1_bonus.py`.

16. **New level: Slag Cellar (World 2 bonus).** Cave-set side level under the
    kiln: a fire trench with two stacked bridges and a wisp over the coins,
    a soot-creeper step into a diver-watched shelf climb, a ground vault with
    a slag hound waiting where the jump lands, a three-tile wall you must
    double-jump with the hound on your heels, a spike bridge under a diver, a
    hound / rotshield / creeper gauntlet under a floating vault, a second
    wall out. 14 enemies, 4 chests (2 secret), 2 feathers, 1 heart, 3
    campfires, 3 signs, par 180. Opens when the Kiln Golem falls — its own
    gate; clearing Ember Hollow does not open it. Held to every World 2
    content rule plus the hazard-pit width rule (which caught a 6-wide
    trench → 5). Casual-bot probe: completes on all three difficulties with
    0 deaths / 2 environmental hits — the bot outruns the roster; the
    engagement is for players who stop for coins and vaults. Layout source:
    `tool/levels/gen_w2_bonus.py`.

17. **The clear screen says what you unlocked.** A first Grove Golem kill
    now shows "UNLOCKED World 2 — Cinder Depths" and "UNLOCKED Bonus — Ember
    Hollow" under the medals; a first Kiln Golem kill shows "UNLOCKED Bonus —
    Slag Cellar". Replays show nothing (the record is read before it is
    merged). Pure `unlocksOnFirstClear()`; widget + unit tests.

### Difficulty curve (02d step 2) — measured, no level changed
- Casual-bot wipe probe (seeds 7/13/42/99, medium): every regular level
  clears 4/4 with 0–1 deaths; hits w1 2/2/2/2/3, w2 4/5/3/7/5 — within-world
  order is monotone enough and w2's spike (Magma Gallery, 7 hits) already
  carries 4 hearts. Both bosses wipe the bot on every seed (Grove Golem 28 s,
  85 %; Kiln Golem 14 s, 40 %) — the known bot ceiling, not a human number.
- The one curve break the comparables address (regular levels → first boss)
  has two documented remedies: boss-HP relief by difficulty (blocked by the
  2026-07-25 difficulty rule) or a non-blocking first boss (structural,
  owner call). No level-geometry change is justified by a measurement, so
  none was made; the jump retune is untouched.
- Correction to (b): Kiln Golem has **1** checkpoint (col 10), not 0.

### Play 2027 bar — code items (02d step 3)
3. **Crash guard on `main`** (ported from `update/delvers`, `f99d871`):
   uncaught async errors are absorbed and remembered in a 20-line in-memory
   ring; release `ErrorWidget` becomes a compact honest notice instead of a
   silent grey rectangle. Stores nothing, sends nothing (no IO in the file).
   Addresses (a) row 6's repo-side gap. Paperwork rows stay with the owner.

18. **Firebase init moved off the cold-start path.** `main()` used to await
    `Firebase.initializeApp()` before `runApp` — the only pre-first-frame
    step gameplay never needed (analytics collection is off by default and
    consent-gated). It now runs after the first frame is scheduled; the
    consent *choice* (local prefs) is still loaded before the first frame so
    the "one ask ever" gate keeps working. Effect on time-to-first-frame is
    **unmeasured** (no device); the change removes one SDK init from the
    path, nothing else. Test: deferred init fails closed when Firebase is
    unconfigured and never re-reads prefs.

19. **Daily Delve reaches into World 2.** Once the Grove Golem is down,
    about half the days remix a Cinder Depths level (Slag Steps, Ash Nursery,
    Cinder Crown). Players still in World 1 keep exactly the pick they had
    before; on a non-World-2 day everyone plays the same World 1 level.
    Magma Gallery stays out of the rotation for now — the listing rule is
    "casual-bot probe 4/4 on medium", and it wiped 4/4 there today (easy and
    hard 0 deaths; logged below as a bot route desync, not a level bug).
    LEVEL-CRAFT-BACKLOG L6. Test: 120-day sweep, locked pick unchanged,
    W2 share within 30–90 days, all three W2 levels appear.

20. **The mix reacts.** Music now fades *in* over 0.4 s on a track switch
    (it already faded out — every change used to front-load a hard edge);
    it dips to half for a beat when you take a hit, when a boss changes
    phase and when a boss falls, easing back over 0.35 s; and the low-health
    heartbeat bed gets louder the closer you are to zero instead of one flat
    level. Victory/defeat stings still land at full volume. Audio backlog
    C1/C3/C6; C7 checked (single sting path). Pure gain math unit-tested
    (test/music_mix_test.dart, 6 tests); on-device listen **not done**.

21. **Ember Vault has a "how do I get up there?" chest.** One of its two
    chests now sits on a ledge high inside the vault, on screen but out of
    jump range. The way up is outside: climb the platforms past the vault,
    cross a new broken bridge, walk back along the vault roof and drop
    through the hole. Same treasure budget as before; a coin marks the
    pillar the chest left. A test proves the chest is reachable only
    through the hole. Casual-bot probe: 12/12 completes on easy/medium/hard.

22. **Spore Mimics.** World 2 now has its own mimic: the shroom cluster
    that bites. Two of them — one just past Ash Gallery's first checkpoint
    where it costs almost nothing to learn, one beside a chest in Cinder
    Reach. Same shiver tell as the bramble mimic; revealed form is
    spore-violet so you can tell it from a plain thornling. Uses the cave's
    existing shroom prop, no new art. Casual-bot probe: both levels 4/4.

23. **Coins and hits stop sounding like one sample.** The two most-played
    sounds now have three takes each, differing in tone (not just pitch),
    and the same take never plays twice in a row. Derived from the same
    CC0 sources; about 23 KB added.

24. **Boss fights get louder as they get worse.** From the boss's second
    phase a second layer — ember wind and taiko rolls — rides over the boss
    music and drops the moment the boss falls. Original, synthesized with
    the same kit as the score. About 56 KB.

25. **World 2 music is no longer quieter than World 1.** The cave bed was
    1.5 LU under the grove bed; now they match.

26. **Soot Creepers finally do what the sign says.** Ashen Gate (2-1)
    teaches that creepers never stop at ledges — but all three used to
    drop into the spike pit or the lava before you got there and sit in
    it. Now creepers wake about a screen out (24 tiles, not 45), keep
    their patrol, and burn if they crawl into a hazard (it counts as a
    kill — luring is a tactic). A one-tile lip keeps the first one on its
    floor so you still get the fight, and a third sign names the lesson.
    (First cut woke them at 12 tiles facing you; the full probe matrix
    showed that flattened World 2 to World 1's hit counts — retuned.)

27. **Magma Gallery joins the Daily Delve rotation** (once the Grove Golem
    is down). It was held back until the casual-bot probe cleared it on
    every difficulty; it does now.
29. **A level's first frame is complete.** Entering a level used to end the
    loading state the moment the simulation was ready, while the tiles,
    player, items, enemies, HUD and backdrop were still decoding their
    sprites — so the first frames could be a bare backdrop with pieces
    popping in, worst on the first level of a session (cold image cache)
    and on slow phones. The game now holds the loading state until every
    level component has finished decoding (capped at 6 s and fail-open, so
    a broken decode degrades to a missing sprite as before instead of a
    level that never starts). Measured before the change: 4 of 7 world
    components, all 10 HUD elements and the parallax were still unloaded
    when loading ended; after: none.
30. **The first PLAY of a session starts faster.** While you are still on
    the title screen the game now decodes every sprite a level can need
    (both worlds' backdrops and tilesets, props, items, HUD, every enemy,
    your body and the equipped skin and weapon — 64 files, 3.35 MiB decoded
    for a fresh save; not the shop icons or the skins/weapons you do not
    wear). Together with item 29 this means the gap between PLAY and the
    first frame no longer contains a cold sprite decode: on the desktop
    test VM a cold Forest Edge load took 143–153 ms, a warm one 45 ms; a
    2 GB phone pays proportionally more, which is the point. Nothing on the
    cold-start path changed — the warm-up starts after the first frame is
    scheduled and quietly skips anything not bundled.
31. **The first sound of every kind is on time.** Each one-shot used to
    create its native player and load its sample the first time it fired —
    so the first jump, first footstep, first swing, first coin and first
    hit of a session each arrived late, with the allocation landing in the
    middle of play. The 18 one-shots a level fires first (22 files with the
    coin and hit round-robins) are now prepared on the title screen after
    the sprites. Loops and menu sounds are unchanged. Also, a voice that
    fails to set up no longer occupies a slot. On-device latency numbers
    remain `unknown` until hardware exists.
32. **Hearts cost one draw call, not forty.** The three hearts and the
    lives heart in the corner were drawn pixel by pixel every frame (40
    little rectangles each), and heart pickups in levels 81 each. They are
    now drawn once into a tiny image and stamped — the same pixels at 1:1,
    and at phone scale the hairline seams between the old rectangles are
    gone, so the hearts read solid. Measured with a counting canvas: Forest
    Edge went from 244 to 88 draw operations per frame, Charcoal Camp from
    409 to 93, Slag Cellar from 351 to 115. The render-ops bench is now a
    test so this cannot creep back.

33. **Signs speak the controls' language.** The World 2 opening sign now
    says "Tap DASH to roll" like the tutorial did, instead of naming a
    button chord that isn't on screen.

34. **Ashbat signs tell the truth.** Two signs said Ashbats dive and told
    you to duck. Ashbats weave in place on a fixed loop, and there is no
    duck. The signs now say what works: swing on the low pass, or jump to
    meet them.

35. **Sign text is never covered.** The tutorial bubble is drawn above
    enemies and the player, so a bat weaving over a sign can no longer hide
    the words explaining it.

36. **Every sign checked against the game.** The medal sign now says the
    truth — the low-damage medal allows one hit, not zero — and the Magma
    Gallery totem sign describes the real range instead of a darkness bonus
    that never existed. All 30 signs now match what the code does.

37. **The clear card counts your hits.** "Hits 0" now sits beside Coins and
    Chests, so when the low-damage medal is missed you can see by how much
    (the medal allows one hit).

### Not done, with reasons (owner may overrule)
- **Secret hiding idioms.** All 20 secret chests use the cracked-wall tell
  (measured). Adding other idioms means changing the fairness contract that
  every secret is signposted by a cracked block — owner call.
- **Daily Delve modifiers (one-heart / no-apples / time-attack).**
  Proposed in RETENTION-SPINE Phase A, never directed. Small, offline, no
  streaks; ready to build on a yes.
- **Boss HP by difficulty** (Apple Knight Story −50 %): conflicts with the
  owner-directed difficulty rule in `lib/game/difficulty.dart` (2026-07-25):
  "enemy HP and contact damage are identical on every difficulty … never
  cheap stat walls". Left as-is; needs an explicit owner change of that rule.
- **Par times for Ember Hollow (170 s) and Slag Cellar (180 s)** are set by
  the same formula as the campaign levels, not by a human clear; the casual
  bot ignores coins so its 19–31 s clears say nothing about par. One human
  run each would calibrate them.
- **`firebase_analytics` keep/remove** — owner decision (Data safety form vs
  "no analytics"); unchanged in this build.

## Verification (fill on each change)
| Change | Gate | Result |
|---|---|---|
| Next level | `flutter analyze` | clean (2026-09-02) |
| Next level | `flutter test` (full) | 476 passed + 1 skipped (2026-09-02) |
| Control size | `flutter analyze` | clean (2026-09-02) |
| Control size | `flutter test` (full) | 478 passed + 1 skipped (2026-09-02) |
| Crash guard | `flutter analyze` + `flutter test` | clean; 479 passed + 1 skipped (2026-09-02) |
| Hard clear | `flutter analyze` + `flutter test` | clean; 480 passed + 1 skipped (2026-09-02) |
| Feel slice (hitstop/smear/coin chain) | `flutter analyze` + `flutter test` | clean; 482 passed + 1 skipped (2026-09-02) |
| Boss camera framing | `flutter analyze` + `flutter test` | clean; 486 passed + 1 skipped (2026-09-02) |
| Ash decal (kill permanence) | `flutter analyze` + `flutter test` | clean; 489 passed + 1 skipped (2026-09-02) |
| Swing weight (feel-only) | `flutter analyze` + `flutter test` | clean; 492 passed + 1 skipped (2026-09-02) |
| Swap control sides | `flutter analyze` + `flutter test` | clean; 496 passed + 1 skipped (2026-09-02) |
| Control height | `flutter analyze` + `flutter test` | clean; 557 passed + 1 skipped; layout tests: lift exact at 14/28, clamped at Large, no overlap (2026-09-02) |
| HUD ghost-when-covering | `flutter analyze` + `flutter test` | clean; 498 passed + 1 skipped (2026-09-02) |
| Death beat (hold + burst) | `flutter analyze` + `flutter test` | clean; 498 passed + 1 skipped (2026-09-02) |
| Pause → Restart level | `flutter analyze` + `flutter test` | clean; 500 passed + 1 skipped (2026-09-02) |
| First-run PLAY routing | `flutter analyze` + `flutter test` | clean; 504 passed + 1 skipped (2026-09-02) |
| Ember Hollow (bonus level) | `flutter analyze` + `flutter test`; wipe probe ×3 difficulties | clean; 513 passed + 1 skipped; all probes COMPLETED (2026-09-02) |
| Coin flight + bench | `flutter analyze` + `flutter test` | clean; 515 passed + 1 skipped (2026-09-02) |
| Slag Cellar (W2 bonus) | `flutter analyze` + `flutter test`; wipe probe ×3 | clean; 529 passed + 1 skipped; probes COMPLETED (2026-09-02) |
| Unlock notice on clear | `flutter analyze` + `flutter test` | clean; 531 passed + 1 skipped (2026-09-02) |
| Firebase init deferred | `flutter analyze` + `flutter test` | clean; 532 passed + 1 skipped (2026-09-02) |
| Death beat on the last life | `flutter analyze` + `flutter test` | clean; 533 passed + 1 skipped (2026-09-02) |
| Daily Delve W2 rotation | `flutter analyze` + `flutter test` | clean; 534 passed + 1 skipped (2026-09-02) |
| Music fade-in / ducking / danger scaling | `flutter analyze` + `flutter test` | clean; 540 passed + 1 skipped (2026-09-02) |
| Ember Vault denial-and-reward chest | `flutter analyze` + `flutter test`; wipe probe w2_l2 ×3 difficulties | clean; 541 passed + 1 skipped; 12/12 COMPLETED (2026-09-02) |
| Spore Mimics (w2_l3, w2_l5) | `flutter analyze` + `flutter test`; wipe probe medium | clean; 543 passed + 1 skipped; 8/8 COMPLETED (2026-09-02) |
| SFX round-robins (coin, enemy_hit) | `flutter analyze` + `flutter test`; mix-report meters | clean; 547 passed + 1 skipped; variants within 1.1 dB phone-band RMS of source (2026-09-02) |
| Boss intensity layer | `flutter analyze` + `flutter test`; mix-report meters | clean; 548 passed + 1 skipped; layer phoneRms −31.0 dB under the −26 beds (2026-09-02) |
| cave_combat re-level | ebur128 + mix-report meters, audio_mix_test | −21.8 LUFS = combat; phoneRms −24.4 dB (2026-09-02) |
| Creeper hazards + Ashen Gate | `flutter analyze` + `flutter test`; wipe probes w2_l1–l5, w2_bonus medium; w2_l4 easy/hard | clean; 553 passed + 1 skipped; 32/32 COMPLETED (2026-09-02) |
| Sim hot-path cost, all six bench levels incl. W2 | `test/session_bench_test.dart` ×3 (VM JIT, sandbox CPU) | avg 5–27 µs/frame, p99 ≤132 µs; w2_l5 max 5–8 ms recurring, frame-random (GC class); bounds green (2026-09-02) |
| Creeper retune (wake 24 tiles, patrol facing) — bisect + 3 sweeps | `wipe_probe_test` W2 ×6 levels × {face on/off} × wake {12,16,18,20,24,45} × easy/medium/hard | wake 12–18: W2 medium hits 2/2/2/3/2 = W1 (flat); face-on ≥20 tiles wipes w2_l5 medium; face-off wake 45 wipes w2_l4; **face-off wake 24: medium 2/5/2/3/4, hard 2/5/6/4/4, easy 2/2/2/3/2, all 4/4** (2026-09-02) |
| Full probe matrix 14 levels × easy/medium/hard × seeds 7/13/42/99 | `wipe_probe_test` (168 runs, deterministic across seeds) | 12/12 regular levels 4/4 on every difficulty; both bosses 0/4 by design (casual bot cannot fight bosses); W2 medium mean hits 3.2 vs W1 2.2, hard 4.2 vs 3.2 (2026-09-02) |
| W2 casual-bot probe, medium, seeds 7/13/42/99 — **superseded** by the full matrix row above after #33 (w2_l4 medium is 4/4 now) | `wipe_probe_test` | historical (2026-09-02 pre-#33): w2_l2 4/4 (1 death/5 hits), w2_l3 4/4 (1/3), w2_l5 4/4 (1/4); w2_l4 0/4 WIPED (3 deaths/10 hits, pct 74); w2_l4 easy 4/4 0/4, hard 4/4 0/4 |
| First frame complete (level component load hold) | `test/first_frame_complete_test.dart` (w1_l1 cold, w2_l5, w1_boss, headless boot) + web harness first-frame shots | unloaded components at onLoad return: before 4/7 world + 10/10 HUD + 1/1 backdrop (w1_l1 cold) → after 0/0/0 on all three levels; onLoad wall time desktop VM cold w1_l1 111 → 153 ms (the decode time that used to leak past the loading state); browser first capture at 0:00 shows tiles, player, HUD, parallax all present for w1_l1 and w2_l5 (2026-09-02) |
| Title-screen sprite warm-up | `test/asset_warmup_test.dart` (bundled-asset check, skin delta, coverage boot of w1_l1/w1_l2/w1_boss/w2_l1/w2_l5/w2_boss, fail-open) | every warm path decodes (64/64 starter set, 3.35 MiB RGBA from PNG headers); after warm-up the six levels decode 0 extra sprites; onLoad w1_l1 143–153 ms cold → 45 ms warm on the desktop VM; unbundled weapon dir skipped without an asset error (2026-09-02) |
| Title-screen SFX voice warm-up | `test/sfx_warmup_test.dart` (ids ⊆ sfxPaths, variant expansion 18 → 22 no duplicates, fail-open without a platform leaves 0 dead voices) + audio suite | 22/22 ids resolve; platform-less warmSfx returns 0 with no throw and no occupied slot; on-device first-shot latency `unknown` (2026-09-02) |
| Hearts rasterised once (render ops) | `test/render_ops_test.dart` (5 levels, spawn + run300, bounds) + `test/pixel_heart_test.dart` (40 lit pixels; HUD and pickup images byte-identical to the per-pixel drawing) + web harness heart crop | draw ops/frame w1_l1 244→88, w1_l5 409→93, w2_l5 253→97, w1_boss 202→46, w2_bonus 351→115; drawRect per frame 160–323 → 0–3; hearts on the phone shot lose the rect seams (2026-09-02) |
| Economy pacing (levels vs shop prices) | `test/economy_pacing_test.dart` (income from level files + tuning; W1 pre-boss ≥ cheapest coin item; every item ≤ two playthroughs; W1 feathers ≥ cheapest feather item; combat levels within 60–140 % of mean) | 1 328 coins + 20 feathers per full playthrough; W1 pre-boss avg 486 ≥ 450; combat levels 94–123 avg; no price/level change (2026-09-02) |
| Sign vocabulary (roll named DASH everywhere) | `test/level_data_test.dart` sign-vocabulary test (30 signs; banned: DOWN+JUMP, Shift, Space, WASD, ctrl, arrow key) + web harness w2_l1 bubble shots | 30/30 clean; bubble single-line, unclipped on phone + desktop (2026-09-02) |
| Ashbat signs vs AshbatCore behaviour; sign bubble layer | sign-vocabulary test (imperative verbs the player lacks; fails on old text) + `test/sign_bubble_test.dart` (priority above enemies/player/items; rect inside view at the w1_l2 sign; nothing drawn away from signs) + web harness reshoot | 30/30 signs clean; bubble priority 6 > 3/2/1; bat passes under the bubble on phone + desktop (2026-09-02) |
| Sign audit closed (medal rule, totem range) | `test/session_test.dart` hitsTaken 0/1/2 → lowDamage + sign text pin; `test/totem_rotshield_test.dart` range == 8 tiles + sign text pin | 30/30 signs match code; lowDamage true/true/false; range 128 px (2026-09-02) |
| Clear card Hits stat | `test/results_next_test.dart` (Hits 2 + Chests 1/3 on card, Low damage unearned) + `test/session_test.dart` hitsTaken pin + web harness clear-card shots | text present; stat line single-row on phone + desktop (2026-09-02) |
