# External research — 2026-09-01

Owner directive (2026-09-01): keep the game smooth on
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

## Platform watch — 2026-09-01 pass (notes only; NO upgrades under freeze)

Sources read 2026-09-01: docs.flutter.dev release notes; flutter.dev 3.47
blog; github flutter/flutter #187009, #180958, PR #161740;
support.google.com target-API policy; developer.android.com page-sizes.

1. **Flutter stable is now 3.47.0** (2026-08-11); we ship on 3.44.9.
   3.47 relevant bits: Impeller becomes default on *desktop*; changelog
   includes flutter/187237 fix (Impeller/Vulkan crash on shutdown/rotation
   on some Android devices); new Android dependency matrix (AGP 9.1 era).
   ~~No urgency: 3.44.x is one minor behind and still in hotfix range.~~
   **Corrected 2026-09-02** (source: `storage.googleapis.com/flutter_infra_release/releases/releases_linux.json`,
   read 2026-09-02): 3.44.9 (2026-08-06) is the **last** 3.44.x — no hotfix
   line exists behind it. Stable moved 3.47.0 (08-12) → 3.47.1 (08-19) →
   **3.47.2 (08-27, current; Dart 3.13.2)**. We are pinned to an unpatched
   minor, by choice. Hold stands (no Android change is pending), but any
   forced bump goes straight to 3.47.x; before adopting, re-verify the
   `EnableImpeller=false` manifest opt-out still exists at that tag and
   re-run the 2 GB device probe. No code change; owner-visible note only.

2. **Impeller stance re-validated — keep `EnableImpeller=false`.**
   #187009 (Adreno 506 regression) is still OPEN (last update 2026-06-02):
   on 3.44.0 Impeller = ~28–32 fps with 100% jank vs Skia ~54 fps on the
   exact device class our pillar targets; the runtime GPU blocklist from
   #160041 does NOT cover it, and the manifest opt-out remains necessary.
   New data point: #180958 shows severe degradation on *Adreno 840*
   (2026 flagship) too — the problem is no longer only old GPUs.
   ⚠ RISK REGISTER: the manifest opt-out is being *deprecated* upstream.
   Any future Flutter upgrade must first verify (a) opt-out still honored,
   or (b) #187009-class issues fixed, or (c) blocklist covers Adreno
   5xx/6xx. This is the gating criterion for upgrades — not features.

3. **targetSdk deadline (2026-08-31) — already compliant.** New apps and
   updates must target API 36 from 2026-08-31 (extension to 2026-11-01
   available). Shipped alpha.21 targets **36** (androguard-verified at
   release). No action now or at any future upload. [play policy, 2026-09-01]

4. **16 KB page sizes — VERIFIED COMPLIANT on the shipped artifact.**
   Play requirement: apps targeting API 35+ must support 16 KB pages on
   64-bit; updates that don't are blocked from **2027-02-01**. Checked
   alpha.21 APK locally (2026-09-01): all arm64 libs have ELF LOAD
   alignment ≥ 0x4000 (libapp.so 0x10000, libflutter.so 0x10000,
   libdatastore_shared_counter.so 0x4000) and `zipalign -c -P 16 -v 4`
   → "Verification successful". Nothing to do; re-run this check on any
   future Flutter/AGP upgrade.

Net: zero platform debt today. The only standing platform risk is the
Impeller opt-out deprecation (item 2), now a named upgrade gate.
