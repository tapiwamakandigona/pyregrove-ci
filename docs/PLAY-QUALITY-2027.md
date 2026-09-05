# Play quality requirements (enforced Feb 2027) — evidence-graded checklist

Rewritten 2026-09-01 per the owner directive in DEMAND.md (fb5f70bc): every line
carries a verdict — **VERIFIED-MET**, **VERIFIED-UNMET**, or **EXPLICITLY
UNKNOWN** — with the evidence next to it. Nothing below is from memory; every
verdict names its source. Original narrative (fix history, Emberdelve
monetization question) is retained in the appendix.

## What Google announced

Primary sources, all read 2026-09-01: owner's Play email of 2026-08-26
(verbatim in `docs/research/owner-inbox-evidence.md` — read that first, per
DEMAND 2026-09-01c); Android Developers Blog "Elevating app quality: Reducing
memory usage and improving device migration" (android-developers.googleblog.com
/2026/08/app-quality-memory-optimization-secure-onboarding.html); Android
vitals bitmap-memory-usage page; press coverage 9to5google.com 2026-08-26,
pocketgamer.biz 2026-08-27, techrepublic.com 2026-08-31.

1. **Performance thresholds** on three metrics — **enforcement starts
   February 2027**; apps over the "bad behavior thresholds" "will see reduced
   app visibility and publishing capabilities":
   - dynamic memory usage (anonymous RSS + swap, excludes files/code/assets,
     assessed per app state and device performance category),
   - bitmap memory usage (foreground use expected; holding bitmaps in
     background/cached states is the violation),
   - DEX code optimization ("a minimum of 25% coverage across optimization,
     shrinking, and obfuscation using a tool such as R8").
   **Numeric memory thresholds are UNPUBLISHED** as of 2026-09-01 — per-RAM-
   bucket, with **games getting distinct (higher) criteria than apps**
   [techrepublic 2026-08-31]. Do not write numbers here until Google does.
   Context: Android 17 adds per-app OS memory limits ("Android Memory
   Limiter", Pixel first) — over-limit apps "will be slowed down and may be
   terminated" [9to5google 2026-08-26].
   New Play Console tools (rolling out now): OOM-termination filter in
   Crashes/ANRs, dynamic-memory + bitmap metrics in Android vitals with
   percentile/RAM-bucket drilldown, proactive bad-behavior alerts.
2. **Zero-Tap Sign-In / device migration**: apps with any sign-in must
   auto-restore sign-in state across devices via the Android Restore
   Credentials API — Play-required from **April 2027**. **"Games are
   currently exempt"** (blog, verbatim); dedicated games guidance promised
   in 2027.

## The checklist — Pyregrove (build audited: released v1.0.0-alpha.21+33 APK; alpha.22+34 re-read 2026-09-02 — targetSdk 36, 16 KB zipalign pass, same signer, no Android/gradle change since 89af754, so rows 1–2, 5, 7 carry over unchanged; see docs/research/a-play-2027-bar-first-listing.md)

All "shipped APK" evidence below was read with androguard from the actual
release asset `pyregrove-v1.0.0-alpha.21.apk` (sha256 `b94c8da3…b6caf2`,
prerelease 380442904), not from source — the artifact players get is the
artifact audited.

| # | Requirement line | Verdict | Evidence |
|---|---|---|---|
| 1 | DEX optimization ≥25% coverage (R8 optimize/shrink/obfuscate) | **VERIFIED-MET** | Shipped APK `classes.dex`: 1,985 classes, **1,861 (93.8%) carry R8-obfuscated short names** (final segment ≤2 chars) — measured 2026-09-01 with androguard. Config explicit since `89af754`: `isMinifyEnabled`/`isShrinkResources` + `proguard-rules.pro` (`android/app/build.gradle` :69–73). |
| 2 | Resource shrinking | **VERIFIED-MET** | `isShrinkResources = true` explicit (same commit); universal APK 53.3 MB, per-ABI splits 18.6–21.6 MB (size audit `6d6c913`) — within our own ≤60 MB / <30 MB pillars. |
| 3 | Memory usage threshold (anonymous RSS + swap) | **EXPLICITLY UNKNOWN** | Google has published no numeric threshold; the metric is computed from Play vitals field data. Pyregrove is not on Play → zero vitals exist and none can exist pre-launch. Even Emberdelve (on Play) shows "-" / "Limited data" for this metric (Play Console, 2026-08-31). Closest available proxy: none measured — on-device `adb shell dumpsys meminfo` audit is blocked on having a physical device (P-M7). Content-side static bound (measured from repo assets, 2026-09-02): decoded RGBA of **all 179 bundled PNGs resident simultaneously = 6.34 MiB**; decoded SFX pool (SoundPool, all 28 one-shots at 44.1 kHz 16-bit) ≈ 3.6 MiB; music is mono via MediaPlayer one track at a time, worst track ≈ 4.2 MiB decoded; fonts 0.96 MiB on disk; level text 30 KiB. Worst-case game-content memory ≈ **15 MiB** — so if the app ever trips a memory threshold, the cause will be engine/framework overhead (Flutter engine, Dart heap, Skia surfaces, platform buffers), which only a device profile or vitals can measure. Bound ≠ RSS; verdict stays UNKNOWN. **Emulator partial data point (2026-09-01):** shipped alpha.21 APK (sha256-verified) on a 2 GB-RAM AVD (AOSP android-34 default x86_64, swiftshader, TCG software emulation, no KVM): `dumpsys meminfo` TOTAL PSS **83.4 MB at title screen**, **89.6 MB at menus/level-select** (Native heap ~31–33 MB, Dalvik ~1.7–2.7 MB, TOTAL RSS 211–222 MB, swap 0). In-GAMEPLAY memory could NOT be measured: that system image cannot decode any PNG larger than 8×8 through the Android engine's image path (see `docs/EMULATOR-LIMITS.md`), so no level ever rendered. Numbers are emulator-measured (x86_64 ABI, software GL) — indicative only, not device truth; gameplay PSS remains unmeasured. |
| 4 | Bitmap memory usage threshold | **EXPLICITLY UNKNOWN** | No numeric threshold published; no vitals, no device. Metric semantics now sourced (Android vitals bitmap page, 2026-09-01): 28-day aggregate per process state; the violation is holding bitmaps in background/cached states; leak heuristic = foreground P99/P50 ratio >3.5x. Content-side static bound (measured 2026-09-02): all 179 bundled PNGs decode to **6.34 MiB RGBA total**; the largest single bundled texture is a 400x368 tileset (0.56 MiB decoded) — the 1024px icon master lives in `assets/icon/` which is NOT in the pubspec asset bundle (a previous line here claimed launcher assets were the largest bundled images; corrected). 16 px-tile pixel art, tile layer batched via `SpriteBatch`, no full-screen decoded photos. Flutter caveat: bitmap accounting of the Flutter engine's image cache on Android is undocumented — recorded unknown, not assumed fine. |
| 5 | Backup config declared (not inherited) | **VERIFIED-MET** | Shipped APK manifest: `android:allowBackup="true"`, `android:dataExtractionRules` and `android:fullBackupContent` both set (resource refs resolve to the XMLs landed in `89af754`; cache excluded, saves/settings included). Read from the release APK with androguard 2026-09-01. |
| 6 | Data carry-over on device upgrade works for the user | **VERIFIED-MET (by design), UNVERIFIED (end-to-end)** | Saves (`pyregrove_save.json`, `pyregrove_settings.json`) live in app documents dir, inside both `<cloud-backup>` and `<device-transfer>` sets; no login, no server, nothing else to migrate. A real phone-to-phone transfer test needs two physical devices — not possible in this sandbox; mark end-to-end as untested. |
| 7 | Zero-Tap Sign-In (device-migration onboarding standard) | **EXEMPT (currently) — sourced** | The standard is now published: Restore Credentials API required from April 2027 for "any app supporting user sign-in, optional or mandatory" — and **"games are currently exempt"** (Android Developers Blog, read 2026-09-01). Pyregrove is a game AND has no sign-in of any kind (no accounts, no login; `firebase_analytics_collection_enabled=false`, `AD_ID` force-removed — confirmed in shipped APK), so it is outside the requirement twice over. Re-check when the promised 2027 games guidance lands; if Pyregrove never gains sign-in, the requirement cannot bind regardless. |
| 8 | Play vitals warnings clean | **EXPLICITLY UNKNOWN (no console entry)** | Pyregrove has no Play Console app entry (Play distribution frozen, owner call). Nothing to read. Emberdelve's policy center was clean 2026-08-31. |

### What could still be done pre-launch (no action now — research phase)

- #3/#4 content-side exposure is now bounded (~15 MiB worst case, see rows) —
  the remaining unknown is engine/framework overhead, which is only measurable two ways: (a) Play vitals after launch with enough
  installs, or (b) locally with `dumpsys meminfo` / Android Studio profiler on
  a physical device. (b) is the only pre-launch option and is device-blocked.
- #6 end-to-end: needs two devices, or one device + cloud backup/restore cycle.
- Re-check this file when Google publishes the numeric thresholds and the
  onboarding standard text — items 3, 4, 7 should then flip to VERIFIED-*.

## Appendix — original notes (2026-08-31, corrected)

### Emberdelve (dice game, on Play) status table as read 2026-08-31

| Item | Emberdelve | Pyregrove (now) |
|---|---|---|
| `isMinifyEnabled` (R8) | true (since `8f756dd8`, PR #94/#96) — **DEX VERIFIED-MET 2026-09-01**: shipped v0.178.0 arm64 APK, 3,537 classes, 2,640 (74.6%) R8-obfuscated short names (androguard; evidence: emberdelve `docs/research/memory-budget.md`) | true, explicit (`89af754`) |
| `isShrinkResources` | true | true, explicit |
| `allowBackup` / `dataExtractionRules` / `fullBackupContent` | not declared | all declared |

Play Console → Vitals for Emberdelve: "-" for both memory metrics, "Limited
data" (install base too small). Policy center clean.

### Correction (kept for the record)

An earlier revision claimed Pyregrove's R8 "defaults false" — wrong for
Flutter: the Flutter Gradle plugin enables R8 + resource shrinking by default
for release builds. Evidence: making the flags explicit in alpha.21 produced a
`classes.dex` **byte-identical** to alpha.20's (sha256 prefix
`b5244d9c363bec91`). Pyregrove met the DEX requirement all along; `89af754`
made it explicit and auditable.

### Emberdelve open decision (owner call, unchanged)

Emberdelve's paid Ember Forge entitlement (`forgeUnlocked` +
unlock-code nonces in `emberdelve_meta.json`) currently rides along with both
cloud backup and device transfer. Keep-portable vs exclude is a monetization
product call — do not change silently; ask the owner. (Does not apply to
Pyregrove: no paid entitlements.)

### Backup config reference (as shipped)

`android/app/src/main/res/xml/data_extraction_rules.xml` (Android 12+) and
`backup_rules.xml` (≤11): cache excluded from `<cloud-backup>` and
`<device-transfer>`, everything else (saves, settings) included. Manifest
attributes on `<application>` as in checklist item 5.
