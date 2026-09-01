# PROJECT.md — Pyregrove (formerly Emberwood / Emberdelve v2: action platformer)

**Goal:** A 2D **pixel action-platformer** for Android (Google Play), built with Flutter + Flame. Inspired by *Apple Knight*'s loop — run/jump/double-jump, melee combat, coins, treasure chests, secret rooms, level-based worlds, and a meta shop (weapons · skins · abilities) — but tighter, fairer, and better optimised. Landscape, touch-first, 2–5 minute levels. Free download, no forced ads.

**Owner:** memorymadie (Tsoro Studios, GitHub `tapiwamakandigona`). Built and orchestrated by Viktor (AI). This repo is designed so **any AI agent can resume the project from these files alone** — read this file, `features.json`, the tail of `progress.md`, then run `init.sh`.

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
1. **Engine:** Flutter (stable 3.32.x, Dart ≥3.8.1) + **Flame** (pinned in pubspec). Owner mandate: Flutter for consistency with their other apps.
2. **Repo:** PRIVATE (`tapiwamakandigona/pyregrove`) — signing keys are committed here; **never make it public**. A public mirror `tapiwamakandigona/pyregrove-ci` exists only to run GitHub Actions (private-repo Actions are billing-blocked); sync via `scripts/sync_public_ci.sh` (strips signing). **Any change under `android/` must land in BOTH repos** (Dart/level/test/docs changes are exempt). Never regenerate `android/app/google-services.json`. Assets: only CC0 / CC-BY with attribution shipped in-app (`PROVENANCE.md`).
3. **Package id / signing:** `com.tsorostudios.pyregrove` (renamed from `com.tsorostudios.emberwood` on 2026-08-31, owner-directed, together with the move to the private `tapiwamakandigona/pyregrove` repo). This app is NOT yet on any Play track; when it ships it goes up as a NEW Play listing. Signing: fresh permanent Pyregrove upload keystore, **committed in this private repo** (`android/signing/upload.keystore` + `android/key.properties`, owner directive so any AI/collaborator can build signed). From here it is **immutable** — never regenerate keys; never change `EXPECTED_CERT_SHA256` in CI (`286c4760…cee8ffd`).
4. **Architecture seam:** game logic (`lib/game/`) is engine-code but *headless-testable*: level parsing, physics resolution, economy, and save data have zero rendering dependencies and are covered by `flutter test`. Determinism where it matters (drops, daily seeds) via seeded RNG (`lib/core/rng.dart`).
5. **Gameplay loop:** level-based worlds → collect coins/apples/chests/secrets → spend in shop (weapons with stats+specials, skins with levels, abilities) → replay for 3-medal completion. Fair-addictive: mastery and collection, never dark patterns.
6. **Monetization:** free; optional one-time supporter IAP later. **Banned:** energy timers, decaying streaks, FOMO-expiring content, loss-framed notifications, pay-to-win.
7. **Performance targets:** 60 fps on 2GB-RAM Android (see spec §Performance): sprite batching / atlases, object pooling for projectiles+particles, no per-frame allocations in hot paths, `--release` profiling before each release.
8. **Tutorial:** the first level teaches movement/jump/attack/throw via signs & guided layout (shipped; keep it true for w1_l1). The original "tutorial promise" was made to old-package Play testers in the dice era.
9. **Milestones (v2):** M1 scaffold (boots, CI green) → M2 engine core (player+physics+camera+touch) → M3 combat & pickups → M4 meta (shop/save/level-select) → M5 content (World 1 “Emberwood”: 5 levels + boss) → M6 release `v1.0.0-alpha.1` — **all shipped 2026-07-25** ([release](../../releases/tag/v1.0.0-alpha.1)). **Push to GitHub at every milestone — never hold work locally.**
10. **Milestones (v2.1):** M8 game-feel and M9 World 2 (shipped as "Kiln Hollows") are done; P-M7 on-device perf needs a physical phone (open); P-M10 Play release is an **owner call — never submit to Play unasked**. Acceptance criteria live in `features.json`.
11. **⛔ RELEASE FREEZE (owner directive 2026-08-31, see DEMAND.md):** keep building and merging to `main`, keep the suite green — but **no new git tags, no GitHub releases, no Play submissions, no store-listing edits**. The next release is one consolidated cut by the owner + his ops agent (draft notes ready in `docs/release-notes-draft-next.md`; last published tag `v1.0.0-alpha.20`). Emergencies (crash/data loss/security): write severity+evidence at the top of `progress.md` and STOP — do not cut a release yourself.
12. **Owner directives arrive via `DEMAND.md`** — re-read it (and `git log main..origin/main`) at every session start; another agent may have pushed.

## Play publishing status (updated 2026-09-01)
- **Pyregrove is not on Play yet** — it ships as a NEW listing (new package + signer) when the owner says so. The old Play closed-testing track belongs to the dice-era package `com.tsorostudios.emberdelve` and is not ours to touch.
- GitHub prereleases (private repo) stop at `v1.0.0-alpha.20` per the freeze.

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
