# Release notes draft — next consolidated release (post-alpha.20)

Prepared 2026-09-01 for the owner's consolidated cut (per the freeze directive
in DEMAND.md). Covers everything merged to `main` since `v1.0.0-alpha.20`
(alpha.20 sha `379…` release id 380007609). Update the version/tag lines when
the cut is made; everything below is written to be pasted into the GitHub
release + Play "What's new".

Version at time of drafting: `1.0.0-alpha.21+33` (pubspec unchanged since
89af754 — bump if the owner wants each merged feature batch counted).

---

## Player-facing notes (paste into release / Play "What's new")

**New enemy: the Bramble Mimic.** Some bushes bite. Watch for the shiver —
that's your window. First sighted in Bramble Hollow, guarding treasure.

**Boss fights got a real opening, middle and end.**
- Bosses now start dormant — a mossy statue until you get close (or poke
  them). The wake-up is announced with a roar, rubble and their health bar
  slamming in.
- Crossing a phase threshold now bursts shards off the boss with a golden
  surge; in the final phase the boss stays visibly enraged (it *is* faster —
  now you can see it).
- The killing blow freezes the moment, then the boss breaks apart properly.

**Fairer difficulty curve.** Fixed two spots that were harder than anything
in world 2: the mound ambush in Charcoal Camp (plus a new heart pickup
there) and a stacked ashbat/thornling pair early in world 1 on Hard.

**New option: Screen shake.** Turn off camera kick entirely in Settings if
motion bothers you. Also fixed the difficulty selector wrapping on narrow
phones.

**Under the hood.** Android app-size and quality work for upcoming Play
requirements; save-backup rules so your progress survives phone migration.

---


**Clearer signs.** The Kiln Golem's arena brief was getting cut off at the
screen edge — you never saw the part that tells you how to hurt it. It's now
two short signs on the way in. New warning sign in the Bramble Hollow near
the first mimic: some bushes bite.

**Tidier credits page.** Paragraphs no longer break mid-sentence and stray
formatting marks are gone.
## Technical notes (paste into GitHub release body)

Since `v1.0.0-alpha.20` (`git log v1.0.0-alpha.20..<release-sha>`):

- `89af754` Play Feb-2027 quality pass: explicit `isMinifyEnabled` /
  `isShrinkResources` + trimmed proguard rules (R8 was already on via
  Flutter defaults — see docs/PLAY-QUALITY-2027.md for the correction);
  `allowBackup` + `dataExtractionRules` + `fullBackupContent` (cache
  excluded; saves/settings included — no paid entitlements exist in
  Pyregrove). **Android config: mirrored to pyregrove-ci** (snapshot of this
  commit); all commits after it are Dart/level/test/docs only.
- `6d6c913` Size audit: split APKs 18.6–21.6 MB per ABI (<30 MB pillar),
  universal 50.8 MB (≤60 MB pillar). `flutter build apk --release
  --split-per-abi`. No size work needed.
- `b0e5b54` Boss dormancy: `BossState.dormant`, wake at 120 px or on hit,
  1.5 s wake grace before the first telegraph, exit stays locked, HP bar
  hidden until wake. +tests (attack-cycle helpers must call `.wake()`).
- `b135aa9` Wake presentation: `RubbleFx` (seeded, allocation-free),
  statue-grey→flesh crossfade (0.6 s), damped tremble, `BossCore.sinceWake`
  render clock. +test.
- `158372f` Death presentation: `kBossKillPause` 0.22 s on the killing blow
  (all damage paths), 2× `DeathFx`, `RubbleFx` `power` knob. +test
  (burn-tick kill).
- `46d34ca` Phase presentation: threshold shard bursts, white-gold surge
  (gold on purpose — red-orange belongs to the telegraph), steady P3 enrage
  tint. Harness telemetry: `bossHp` / `bossPhase`.
- `5de8436` Balance: w1_l4 mound Rotshield → open ground + heart on mound.
  12-level wipe-probe: WIPED 48% → baseline. Level data only.
- `be55733` Balance: w1_l2 ashbat raised 2 tiles (stacked pair fired
  together under Hard's 1.25× aggro). Probe gained
  `--dart-define=DIFF=easy|medium|hard`; easy-mode bot hit counts documented
  as artifact.
- `e4c8ddf` Harness `?bosshp=N` (clamp once, no fake events); Kiln Golem
  presentation verified on its palette.
- `f8b4c44` `AudioSettings.screenShake` (default on, legacy-safe) guarded at
  the single `_camBump` application site; fixed difficulty SegmentedButton
  wrap at 390 px. +test.
- `df6f435` **New enemy: Bramble Mimic** (12th kind, legend `N`).
  `EnemyCore.harmless` contact gate; `ThornlingCore.asKind`; reveal
  telegraph 0.7 s × difficulty; respawn-clear re-disguises; hidden mimics
  settle under gravity. Placed in w1_l3 guarding both chests (probe baseline
  unchanged on medium + hard). +6 tests.

Suite at draft time: **435 passed + 1 skipped**, `flutter analyze` clean.

Release checklist reminders (owner standards): tag at release sha; signed
APK + AAB from the CI workflow_dispatch on the mirror; sha256s in the notes;
signer pin `286c4760…8ffd` must match; freeze remains in force until the
owner cuts this release.
- `7c4b97f` w1_l3 decoy bushes: mimics no longer the only bushes in the level.
- `96db8bc` Harness `?spawn=col,row` (test entrypoint only); mimic visual QA.
- `6a889fe` w1_l3 fair-warning sign for the mimic; sign bubble clamps to the
  camera view.
- `bb457e0` w2_boss 178-char brief was clipped in-game — split into two signs
  (verified full render); sign-length audit across all 13 levels.
- Web-harness `?peace=1`: clears logic enemies after load for knockback-free scene/sign captures (test entrypoint only; documented quirk: renderer sprites linger as inert ghosts).
- Credits screen: hard-wrapped CREDITS.md lines now coalesce into paragraphs/bullets before rendering (fixes ragged mid-sentence breaks and literal backticks on the credits page); new parseCreditsBlocks() + 4 tests.
- Web harness now mounts the real end-of-level overlays (ResultsOverlay/FailOverlay made public) instead of placeholder banners, so LEVEL CLEAR and FALLEN screens are screenshot-verifiable; both verified on phone + desktop viewports.
- Pause overlay also mounts the real widget in the harness (banner stubs fully removed); Resume verified functional via telemetry.
- Web harness installs a real AudioService (in-memory settings), unhiding the volume sliders and haptics/screen-shake toggles for visual QA; level-select fresh/allclear states and the full settings screen verified defect-free.
- World 2 visual sweep: Kiln Works' second sign (authored but never placed) now stands at the start of the work floors; w2 level openings each have a distinct coin formation instead of three sharing one diamond.
- Sign bubbles now wrap to the screen instead of clipping when their text is wider than the view (root cause of the old Kiln Golem arena clip).
- Jumps now start with a brief takeoff stretch (pairs with the landing squash) for extra weight and anticipation.
- Frequent sounds (coins, hits, steps, swings) now vary slightly in pitch on each play so they never drone; jingles and UI sounds stay stable.
- Big drops (4+ tiles) now land with a small camera thud and a light haptic tick; normal jumps stay quiet.
- Running now kicks up faint dust at your heels, synced to footsteps.
- The title screen now shows the build version in the corner - handy when reporting bugs.
- Boss fights are real fights now: both golems have more health, and standing inside the Grove Golem's slam no longer dodges it. Watch the wind-up - then strike.
- Difficulty now changes boss fights too: Easy golems wind up slower and wake later, Hard ones are faster and more alert. Fixed a trap in the Grove Golem arena where the side ledges could block your dodge jump - they're jump-through platforms now.
- Fixed: on lower-end phones the game no longer runs in slow motion when the frame rate dips - game speed now stays true down to ~15 fps.
- Combat feels weightier: enemies now visibly flinch away from your hits.
- Fixed: pressing Home or locking your phone now properly silences the game and brings you back to the pause menu - no more music playing in the background and no more surprise unpause mid-fight.
- Fixed: the Android back gesture no longer quits a level instantly - it opens the pause menu (back again while paused resumes; on the results screen it leaves as before).
