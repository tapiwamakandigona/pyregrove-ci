# External research — 2026-09-01

Owner directive (2026-09-01, via Viktor session): keep the game smooth on
low-end devices, keep animations/visuals/controls high quality, and keep an
eye on current Android + indie-dev practice. This file records what was
checked, what already holds, and the actionable backlog. Sources are public
web material found 2026-09-01; treat dates as provenance, re-verify before
release decisions.

## Android / Play compliance (verified against our artifacts)

- **16 KB page sizes**: required for new apps/updates targeting Android 15+
  since 2025-11-01 (developer.android.com/guide/practices/page-sizes).
  VERIFIED: `zipalign -c -P 16` passes on the shipped alpha.20 APK; NDK is
  pinned r27 (16 KB-ready). No action needed.
- **Target API 36 by 2026-08-31** (Play target-API policy): VERIFIED — the
  alpha.20 APK reports `targetSdkVersion 36`, `compileSdk 36` (Flutter
  3.44.9 defaults). No action needed.
- Play quality (Feb-2027 charter) work landed earlier (89af754).

## Game feel vs. current state (audit 2026-09-01)

Recommended ranges from current platformer-feel writeups (coyote 90–140 ms,
jump buffer 100–150 ms, land squash ~15%, takeoff stretch ~10%, landing
shake scaled to fall height, particles on land/pickup, pitch-varied sfx):

- Coyote time 0.10 s, jump buffer 0.12 s, attack buffer 0.15 s — already in
  `tuning.dart`, inside recommended ranges. Do not churn without playtest
  evidence.
- Landing squash 15% / 80 ms (AKP-3a) — shipped earlier.
- **Takeoff stretch 10% / 100 ms — ADDED this pass** (paired with squash;
  jumped + airJumped events).
- Hit-stop (kHitPause 0.040), hurt-only screen shake (AKP-3e), landing puff,
  floating damage numbers (AKP-3c), medal chime — all present.

## Perf on low-end devices (practices we already follow / to keep)

- No per-frame allocations in render paths (scratch Vector2 statics in
  components; sign-bubble TextPainter cached per text). Keep auditing new
  components for this.
- Fixed-res 352×198 camera keeps raster cost flat regardless of device
  resolution — the single biggest low-end lever we have.
- flame frame-stats harness exists (frame_stats_test.dart).
- Real-device profiling (P-M7) still BLOCKED on a physical phone: web/CI
  numbers do not stand in for Mali/Adreno raster behaviour.
- Worth trying when device access exists: Impeller vs Skia comparison on a
  2 GB device (Impeller is default on current Flutter; verify no regressions
  with our canvas-heavy draw code).

## Backlog status (updated 2026-09-01, second pass)

- Pitch-varied sfx — DONE (a10231f5, AudioService.sfxRateFor).
- Landing shake scaled to fall height — DONE (landedHard event, camBump 2.0).
- Walk-cycle dust puffs — DONE (run dust synced to footstep clock).
- Parallax gameplay backdrops — ALREADY SHIPPING (correction: this line was
  stale; lib/game/components/parallax_bg.dart draws 4 wrapped layers,
  forest + cave families, in camera.backdrop for every level). What remains
  blocked on hardware is only on-device perf validation (P-M7).
- Enemy hit recoil — DONE (5efc3d06): render-layer jolt away from the
  player, easing with the hurt flash; bosses/totem excluded (mass read).
- Sub-stepped frame pacing — DONE (7f6b4d20): sub-30fps devices no longer
  play in slow motion; <=1/60 sub-steps, 4/60s cap.
- "Borrowing code": only license-compatible sources (MIT/CC0/Apache-2 with
  attribution in CREDITS.md + PROVENANCE.md). No GPL into this codebase.
