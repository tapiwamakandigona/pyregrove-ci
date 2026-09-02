# On-device test protocol — groundwork for launch flip-condition #3 (P-M7)

Written 2026-09-01. Research artifact: nothing here is actionable until a
physical Android device exists. Purpose: when hardware appears, P-M7 becomes
a **~90-minute checklist run**, not a research project. Every command below
was verified against current Android docs [developer.android.com tools
overview; perfetto.dev memory case study; Android Developers Blog memory
thresholds post; vitals docs — all read 2026-09-01].

## 0. Ground rules

- Test the **exact shipped artifact**, never a fresh debug build:
  `pyregrove-v1.0.0-alpha.21.apk`, sha256
  `b94c8da33540e91ea4f5c4e25701e027768a937b3f05a4690d6bd6c496b6caf2`
  (or its successor; re-pin first). Verify before installing:
  `sha256sum` the APK, then confirm signer
  `286c4760f1801269550fe40658e6255c96107713690d0e4353cbe76bccee8ffd`.
- Device classes (pillar 3 targets):
  - **Class A (the bar): 2 GB RAM**, Android 8–12 era (e.g. Galaxy A10s,
    Redmi 9A, any Android Go unit). PASS here is the pillar.
  - Class B (nice-to-have): 3–4 GB mid-ranger for a second data point.
- Headless SwiftShader numbers (docs/perf.md) do **not** transfer; this
  protocol supersedes them the moment it runs once.
- Record everything in the results table (§6) with device model, Android
  version, and RAM; commit the filled table to this file.

## 1. Install + startup (10 min)

```
adb install -r pyregrove-v<ver>.apk
adb shell am start -W com.tsorostudios.pyregrove/.MainActivity   # note TotalTime
```
- Cold start (`TotalTime`) target: **≤ 2500 ms** on Class A (ASSUMED bar —
  no Play-published number; revise after first run).
- Repeat warm start ×3; note variance.
- Check install size on device: Settings → Apps → Pyregrove.
  Pillar bar: **< 30 MB** per-device (split APKs are 18.6–21.6 MB, so this
  should pass trivially — verify anyway; universal APK will NOT pass this
  and that is expected).

## 2. Frame performance (30 min)

Primary metric = the game's own FrameStats (fps / frameAvgMs / frameWorstMs,
already shipped): run with the perf overlay build flag when a follow-up
build is ever authorised, or read values via the debug telemetry if
exposed. Until then, use OS-side measurement, with one **known caveat**:
Flutter renders into a SurfaceView, so `dumpsys gfxinfo` percentiles can
under-report game jank [stackoverflow 65536889]. Use both:

```
adb shell dumpsys gfxinfo com.tsorostudios.pyregrove reset
# ... play scenario ...
adb shell dumpsys gfxinfo com.tsorostudios.pyregrove          # aggregate: Janky %, 90/95/99th pct
adb shell dumpsys SurfaceFlinger --latency SurfaceView        # per-frame timestamps, SurfaceView-accurate
```

Scenarios (deterministic, ~4 min each, reset counters between):
1. **w1_l2 traversal** — full run, normal play.
2. **w1_boss full fight** — worst-case entity count + slam waves + FX.
3. **w2_l3 Magma Gallery** — heaviest w2 level (fire tiles + parallax).
4. **Menu → level → pause → resume → map** — transition jank.

Pass bars on Class A (from pillar 3 "60 fps on 2 GB Android"):
- Janky frames **< 10%** per scenario; 95th percentile frame time
  **≤ 22 ms**; no sustained (>2 s) stretch below ~50 fps by eye.
- Any FAIL: re-run once, then record as FAIL with the scenario — do not
  average away a bad scenario.

## 3. Memory (20 min)

Play's incoming thresholds track **dynamic memory = anonymous RSS + swap**
across app states [Android Developers Blog, read 2026-09-01]; exact numeric
limits are still unpublished (PLAY-QUALITY-2027 line stays EXPLICITLY
UNKNOWN), so this protocol *records* evidence rather than inventing a bar.

```
adb shell dumpsys meminfo com.tsorostudios.pyregrove -a
```
Record from **App Summary**: TOTAL PSS, TOTAL RSS, TOTAL SWAP PSS, plus the
Graphics row (bitmap pressure proxy). Take snapshots at:
1. Title screen (fresh launch)
2. Mid-fight in w1_boss (peak)
3. Backgrounded 5 min (home button — dynamic memory should *drop*)
4. Backgrounded 30 min (should drop further or process be cached-killed
   gracefully; relaunch must restore cleanly from save)

Sanity bars (ASSUMED, honest labels): peak TOTAL PSS **≤ 350 MB** on
Class A; background snapshot visibly below foreground. Watch logcat during
the whole session for `lowmemorykiller`, `SIGABRT`, `OutOfMemory`.

## 4. Stability + system behaviours (20 min)

- **Lifecycle:** home/relaunch ×5, screen-off/on during boss fight,
  incoming-call sim (`adb shell am start -a android.intent.action.CALL`
  where possible), rotation locked (game is landscape). Audio must pause
  and resume correctly (518c4dc2 regression check).
- **Back gesture:** Android 13+ device if available — pause menu, not exit
  (c66e02da regression check).
- **Wake locks:** Pyregrove ships WAKE_LOCK (audio/keep-screen-on).
  Excessive partial wake locks get **store visibility penalties from
  2026-03-01** (bad-behavior bar: 5% of sessions) [vitals docs]. Check no
  lock is held after backgrounding:
  `adb shell dumpsys power | grep -i wake` with the app backgrounded.
- **Save integrity:** force-stop mid-level → relaunch → save intact
  (SaveStore atomicity check on real flash storage). Uninstall/reinstall →
  fresh start without crash.
- **Cutouts:** on a notched device, HUD respects safe-area insets.

## 5. Vitals context (for whenever a store listing exists)

Play's core-vitals bad-behavior thresholds (visibility-affecting): crash
rate 1.09% overall / 8% per-device; ANR 0.47% / 8%; wake locks 5%
[developer.android.com/topic/performance/vitals, read 2026-09-01]. Pre-launch
nothing feeds these dashboards — which is exactly why this manual protocol
is the only evidence source until then.

## 6. Results template

| Date | Device (model/Android/RAM) | Build | §1 cold ms | §1 size MB | §2 worst scenario (janky% / p95 ms) | §3 peak PSS MB | §3 bg drop? | §4 all pass? | Verdict |
|------|---------------------------|-------|-----------|-----------|--------------------------------------|----------------|-------------|--------------|---------|
| —    | —                         | —     | —         | —         | —                                    | —              | —           | —            | —       |

One filled row on a Class A device flips LAUNCH-WORTHINESS condition #3
from blocked to evidenced (pass or fail — either is evidence).

## 7. Developer-verification note (checklist line only — DO NOT ACTION)

Per DEMAND.md: Android developer-verification registration
(2026 requirement waves) stays a written checklist item for the owner's
pre-launch list; no registration is to be initiated from this repo.
