# Coin-flight lifecycle — scoped source and web-harness verification

## Change

Coin-flight effects release their capacity once when they arrive or are
cancelled. Root game removal cancels both mounted and queued flights owned
by that viewport, without resetting another game's count. Cancelled effects
cannot later pulse the HUD from a stale update. The cap, lifespan, coin
crediting and path are unchanged.

## VERIFIED

- Base main `0a5a6ebc10f066833d54f8f1349c53b23e814e34`; target files did not
  change since the initial `330e2d0` review. [managed Git diff, 2026-09-05]
- Installed Flame **1.35.1** source inspected: component `onRemove` follows
  `onMount`; GameWidget's removal finalizes the root separately. A component
  `onRemove` override alone misses pre-mount and root disposal cases.
  [installed package source, 2026-09-05]
- Three additive regressions use existing public methods. All fail against
  baseline production code, then pass with the fix:
  - mounted cancellations: `Expected: <0>` / `Actual: <12>`;
  - root removal: `Expected: <1>` / `Actual: <2>`;
  - repeated arrival: `Expected: <1>` / `Actual: <2>`.
  The regression file was unchanged between these runs.
  [baseline/fixed test outputs, 2026-09-05]
- `flutter analyze --no-pub`: **No issues found!**
  [analyzer output, 2026-09-05]
- `flutter test --no-pub --reporter expanded`: **590 passed, 1 skipped**,
  exit **0**. The existing skip is `wipe_probe_test.dart`: “manual difficulty
  probe — run with --run-skipped”; no new skip or weaker assertion.
  [full suite output, 2026-09-05]
- `flutter build web --release --no-pub -t lib/main_webtest.dart`: exit **0**.
  `main.dart.js` SHA-256:
  `2ada1f6e726b8c7a2786f328bd270e4c0c1633d58557a6ea26d084033a72f05c`.
  Existing expected-CupertinoIcons-font warning retained.
  [release-harness build and file digest, 2026-09-05]
- That built harness booted in headless Chromium at **1280×720** and
  **915×412**. Real telemetry showed keyboard movement from **x=72** to
  **101.9977** / **102.2550** respectively, then Escape set `paused=true`;
  no JavaScript page exceptions. Screenshots captured but not visually reviewed.
  [local browser telemetry, 2026-09-05]

## Boundaries

The built target is the existing **test harness**, with in-memory save and
harness configuration—not the Android shipping entrypoint. No Android
package, physical low-end-device timing, touch-control sweep, full level
playthrough, audio listening or holistic visual review is claimed.

The first local browser launch could not find its default executable; one
corrected launch used the verified existing matching Chromium binary and
passed the unchanged smoke assertions.

Original test files, feature criteria, dependencies, game logic/tuning/levels,
signing and Android configuration remain unchanged. No public mirror sync,
tag, release, store action, purchase or deployment.
