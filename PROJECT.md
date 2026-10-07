# PROJECT.md — Pyregrove (formerly Emberwood / Emberdelve v2: action platformer)

## October 2026 quality pass — 2026-10-03

**Goal.** One quality pass under the owner brief of 2026-10-02 (PLAN.md §1):
better feel, animation, character art, effects and UI, using what is good in
open PR #9, ending in a GitHub prerelease cut by the release process in
PLAN.md §5 / `docs/release.md`.

**Standing decisions for this pass.**
- Order: Emberdelve (done, v0.186.0) → **Pyregrove (this pass)** → Fliptide.
- **Play hold:** owner, 2026-10-03 14:33 UTC: "no need for playstore now just
  work on the games". No Play Console/API, store-listing or track action.
- PR #9 `experimental/polish-loop` is never merged; reviewed parts are
  ported by path into an ordinary PR and recorded there.
- One feature per branch/PR; merge gate = local Flutter 3.44.9
  `flutter analyze` clean + full `flutter test` green on the PR head (private
  repo Actions are billing-blocked). No changes under `android/` in this pass
  (they would need the public mirror too). Save format stays backward
  compatible. No new dependencies, no ads/analytics/tracking.
- Version plan: one candidate `1.0.0-alpha.30+42` (code > 41, the
  never-shipped alpha.29 mirror build, and > 40, the highest Play code).
  Tag, signed build and GitHub prerelease happen in the release step, not in
  feature PRs.

**Status (2026-10-03).** Released `1.0.0-alpha.30+42` as private GitHub
prerelease
[v1.0.0-alpha.30](https://github.com/tapiwamakandigona/pyregrove/releases/tag/v1.0.0-alpha.30)
(source `a5032cf`; signed mirror CI run 37133160031 on `5eb16f0`; evidence
in `docs/releases/v1.0.0-alpha.30.md`). Not on Google Play (owner hold).
Next pass starts from backlog row 4. Row 9 (review finding) was fixed first, 2026-10-03 17:10 UTC; not in a build yet.

**Ranked backlog (player-visible value × risk; controls/feel → animation →
character art → effects/UI → bugs).**

| # | Item | Source | Status |
|---|---|---|---|
| 1 | Fill wide phones edge-to-edge + physical-pixel camera snap (removes the 5–6 px scene steps and knight wobble while the camera follows) | PR #9 d741c9e | done, PR #12 |
| 2 | Ambient forest embers and cave dust (depth, life in the backdrop) | PR #9 d741c9e | done, PR #12 |
| 3 | Rootway Ruins (w1_l5) hopper spawns buried in rock | PR #9 75cd5a6 | done, PR #12 |
| 4 | Knight animation pass: run cycle, jump/land squash, attack anticipation frames | owner brief | open |
| 5 | Knight + enemy sprite redraw at higher detail (in-repo original art tool) | owner brief | open |
| 6 | Touch buttons: pressed states and placement review at 1.3× text | owner brief | open |
| 7 | Audio that does not sound synthetic (owner, 2026-09-10) — needs a human audition | progress archive | open |
| 8 | Device gates P-IDLE-DEVICE-20260910 / P-M7 perf — need a physical phone | features.json | blocked (no device) |
| 9 | AmbientMotes: cache the per-bucket `Float32List` views so render() allocates nothing per frame (P-OCT-FILL-SCREEN clause; set back to passes=false) | read-only review 2026-10-03 | done, `fix/motes-no-alloc-20261003` (P-OCT-FILL-SCREEN passes again) |
| 10 | `tool/level_author.py` no longer reproduces the shipped w1_l2–w1_boss grids (hand edits predate this pass); reconcile before re-running the tool | read-only review 2026-10-03 | open |

## Current build-parity pass — 2026-09-18

Owner authorized build parity and phone verification. Prepare one signed
candidate `1.0.0-alpha.28+40` containing the already-merged September10 idle
fix; synchronize the source-only public CI mirror through normal branches/PRs.
Do not recreate the bug fix or change tests to pass. Original feature objects,
full progress history, Android configuration, signer, assets and save schema
remain unchanged. Use managed Git/authorship; historical force-push/identity
instructions are not active.

Baseline VERIFIED on exact CI-pinned Flutter3.44.9: analyzer clean,
655 passed / 2 pre-existing skips; all tracked source unchanged after checks.
Local `flutter devices --machine` lists Linux only; no owner Android phone,
USB passthrough or Android SDK is available. Phone acceptance stays false.
Build through the unchanged public CI; no tag, GitHub release or Play upload.
Actual download/package/version/signer verification is required after CI.

## Idle ground-contact correction — 2026-09-10 evening

Owner reports fast crouch-like animation while stationary and rejects the
current game audio quality. Read [the reproduced idle fault and checked
source fix](docs/idle-ground-contact-sep10.md) first. A sub-millisecond
trailing physics step lost floor contact and emitted a new landing every
frame. One collision-boundary expression corrected; 10 additive regressions
pass unchanged after expected-red, full suite 655 passed / 2 old skips,
analyzer clean. Existing tests, sounds, sprites and Android config unchanged.

**Source correction only — not shipped to Play.** No new tags/releases or
promotions in this pass. Actual phone confirmation and real audio audition
remain open; tests and waveform metrics are not quality approval. The
historical release-status sections below retain their original dates.

## Checked save-backup recovery fix — 2026-09-09

Read [backup recovery](docs/save-backup-recovery-sep09.md). An unreadable live
save no longer replaces the last readable backup after recovery. Seven
immutable red/green regressions verify normal rotation, legacy migration and
full progression recovery; **644 passed / two existing skips**, analyzer clean.
Existing tests/schema/Android/signing unchanged. Source fix only, not yet
included in the alpha.26 Play binary. Device/production gates remain open.
[primary CI34323313039/34323537255 and source, 2026-09-09]

## Active quality pass — 2026-09-08

Owner-requested movement, visuals, low-end performance and Play updates.
Read `docs/quality-sep08.md` before the historical review below. The owner has
authorized release work for this pass; immutable signing and real release
verification are not waived. Classic physics remains available alongside a
new forgiving touch profile. No physical-device result is assumed.

VERIFIED iteration 8: offline French/Spanish/pt-BR first-session menus,
comfort controls and four Forest Edge signs; saved manual/device language,
English fallback. Render-only translation; gameplay codes/IDs unchanged.
Analyzer clean; 637 passed / 2 original skips. See `docs/quality-sep08.md`.

Iteration 11 candidate `1.0.0-alpha.26+38`, not a promoted beta. VERIFIED:
authorized PAT dispatched existing public CI34247076464 on `f9c7aa2`
(private source `4ade200`); signing/package/version/hash checks pass.
Play internal38 and closed-Alpha38 are now both available to testers
(review cleared; final release-overview readback verified). Both previews showed zero
newly unsupported devices. Production access denied; private CI unchanged.
See `docs/releases/verification-1.0.0-alpha.26.md`. The earlier GitHub App
403 was not a test of the separately supplied PAT.

## Current review — 2026-09-05

Title readability proposal: `docs/visual-polish-20260905.md`.
Public mirror run 33950210756 is green (593 passed / 1 skipped); genuine
before/after plates under `docs/visual/2026-09-05/`. No release or deployment.
Private CI is disabled by authorized API change to keep work on free public
PR runners. Physical-device and owner-release gates below remain open.

**Goal:** A 2D **pixel action-platformer** for Android (Google Play), built with Flutter + Flame. Inspired by *Apple Knight*'s loop — run/jump/double-jump, melee combat, coins, treasure chests, secret rooms, level-based worlds, and a meta shop (weapons · skins · abilities) — but tighter, fairer, and better optimised. Landscape, touch-first, 2–5 minute levels. Free download, no forced ads.

**Owner:** memorymadie (Tsoro Studios, GitHub `tapiwamakandigona`). This repo is designed so **any AI agent can resume the project from these files alone** — read this file, `features.json`, the tail of `progress.md`, then run `init.sh`.

> **Pivot note (2026-07-24, owner-directed):** The original turn-based dice-builder
> is archived intact on branch `legacy/dice-builder`, tag `v0.3.10-legacy`, and the
> GitHub release "Emberdelve Classic". Everything below describes the new game.
> The legacy spec lives at `docs/legacy/`; do not build against it.

## Canonical artifacts
| What | Where |
|---|---|
| Product spec v2 (platformer) | `docs/spec.md` |
| Architecture v2 | `docs/architecture.md` |
| Definition of done | `features.json` (machine-readable; workers only flip `passes` + `evidence`) |
| History / decisions | `progress.md` (append-only), `checkpoints/` |
| Dev environment | `init.sh` |
| Asset licensing | `PROVENANCE.md`, `CREDITS.md` (shipped in-app) |

## Standing decisions (do not relitigate without owner)
1. **Engine:** Flutter stable (3.44.9 as of 2026-09-02; pubspec floor Dart ^3.8.1) + **Flame** (pinned in pubspec). Owner mandate: Flutter for consistency with their other apps.
2. **Repo:** PRIVATE (`tapiwamakandigona/pyregrove`) — signing keys are committed here; **never make it public**. A public mirror `tapiwamakandigona/pyregrove-ci` exists only to run GitHub Actions (private-repo Actions are billing-blocked); sync via `scripts/sync_public_ci.sh` (strips signing). **Any change under `android/` must land in BOTH repos** (Dart/level/test/docs changes are exempt). Never regenerate `android/app/google-services.json`. Assets: only CC0 / CC-BY with attribution shipped in-app (`PROVENANCE.md`).
3. **Package id / signing:** `com.tsorostudios.pyregrove` (renamed from `com.tsorostudios.emberwood` on 2026-08-31, owner-directed, together with the move to the private `tapiwamakandigona/pyregrove` repo). This app is NOT yet on any Play track; when it ships it goes up as a NEW Play listing. Signing: fresh permanent Pyregrove upload keystore, **committed in this private repo** (`android/signing/upload.keystore` + `android/key.properties`, owner directive so any AI/collaborator can build signed). From here it is **immutable** — never regenerate keys; never change `EXPECTED_CERT_SHA256` in CI (`286c4760…cee8ffd`).
4. **Architecture seam:** game logic (`lib/game/`) is engine-code but *headless-testable*: level parsing, physics resolution, economy, and save data have zero rendering dependencies and are covered by `flutter test`. Determinism where it matters (drops, daily seeds) via seeded RNG (`lib/core/rng.dart`).
5. **Gameplay loop:** level-based worlds → collect coins/apples/chests/secrets → spend in shop (weapons with stats+specials, skins with levels, abilities) → replay for 3-medal completion. Fair-addictive: mastery and collection, never dark patterns.
6. **Monetization:** free; optional one-time supporter IAP later. **Banned:** energy timers, decaying streaks, FOMO-expiring content, loss-framed notifications, pay-to-win.
7. **Performance targets:** 60 fps on 2GB-RAM Android (see spec §Performance): sprite batching / atlases, object pooling for projectiles+particles, no per-frame allocations in hot paths, `--release` profiling before each release.
8. **Tutorial:** the first level teaches movement/jump/attack/throw via signs & guided layout (shipped; keep it true for w1_l1). The original "tutorial promise" was made to old-package Play testers in the dice era.
9. **Milestones (v2):** M1 scaffold (boots, CI green) → M2 engine core (player+physics+camera+touch) → M3 combat & pickups → M4 meta (shop/save/level-select) → M5 content (World 1 “Emberwood”: 5 levels + boss) → M6 release `v1.0.0-alpha.1` — **all shipped 2026-07-25** ([release, on the old repo](https://github.com/tapiwamakandigona/emberdelve/releases/tag/v1.0.0-alpha.1)). **Push to GitHub at every milestone — never hold work locally.**
10. **Milestones (v2.1):** M8 game-feel and M9 World 2 (shipped as "Cinder Depths", boss: Kiln Golem) are done; P-M7 on-device perf needs a physical phone (open); P-M10 Play release is an **owner call — never submit to Play unasked**. Acceptance criteria live in `features.json`.
11. **⛔ RELEASE FREEZE (owner directive 2026-08-31, see DEMAND.md):** keep building and merging to `main`, keep the suite green — but **no new git tags, no GitHub releases, no Play submissions, no store-listing edits**. The next release is one consolidated cut by the owner + his ops agent (draft notes ready in `docs/release-notes-draft-next.md`; last published tag `v1.0.0-alpha.21` — the one owner-authorized cut of 2026-09-01, see DEMAND.md; freeze re-affirmed after it). Emergencies (crash/data loss/security): write severity+evidence at the top of `progress.md` and STOP — do not cut a release yourself.
12. **Owner directives arrive via `DEMAND.md`** — re-read it (and `git log main..origin/main`) at every session start; another agent may have pushed.

## Play publishing status (updated 2026-09-01)
- **Pyregrove is not on Play yet** — it ships as a NEW listing (new package + signer) when the owner says so. The old Play closed-testing track belongs to the dice-era package `com.tsorostudios.emberdelve` and is not ours to touch.
- GitHub prereleases (private repo) stop at `v1.0.0-alpha.21` (owner-authorized cut, 2026-09-01) per the freeze.

## Dev quickstart (headless sandbox)
- Gates: `flutter analyze && flutter test` (must be clean/green before every commit).
- Difficulty probe (casual-bot balance check): `flutter test --run-skipped --dart-define=LVL=<level_id> --dart-define=DIFF=<easy|medium|hard> test/wipe_probe_test.dart` — see the file header; curve baseline in `progress.md` ("Curve-at-freeze").
- Visual QA web harness: `flutter build web --release -t lib/main_webtest.dart`, serve `build/web`, drive with Playwright. Params: `?level=&seed=&weapon=&apples=&bosshp=&coins=&allclear=1&screen=title|select|shop|settings|credits`; wait for `window.__pyregrove.loaded`; telemetry object `window.__pyregrove` (x, y, hp, bossHp, bossPhase, completed, hitsTaken, …). Details: `docs/web_testing.md`.
- Release flow (when the owner lifts the freeze): `docs/release.md`.

## Session-start ritual (for any AI/human resuming)
1. Read this file, `features.json`, tail of `progress.md`, latest `checkpoints/*.md`.
2. `git log --oneline -20` for recent history.
3. `./init.sh` to bring the environment up and run the test suite.
4. Work the next unfinished feature; update `features.json` (evidence required) and append to `progress.md`. Commit + push.
