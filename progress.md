# progress.md — Pyregrove (append-only)

Rotated 2026-10-03. The previous log (236072 bytes, past the 64 KiB rotation
threshold) was moved byte-for-byte with `git mv` to
`archive/progress-segment-1.md`:

- path: `archive/progress-segment-1.md`
- size: 236072 bytes
- SHA-256: `9b8ee95df4c04a1398169142d346b8e5981b58669a8d98e83fc5bfcb9809fcae`

Any older reference to "progress.md" (in PROJECT.md, features.json evidence,
docs or checkpoints) means that archive segment. New entries are appended
below; each claim is labelled VERIFIED or ASSUMED.

## 2026-10-03 — October 2026 quality pass starts

VERIFIED: `sha256sum` of `progress.md` before the move and of
`archive/progress-segment-1.md` after the move both print
`9b8ee95df4c04a1398169142d346b8e5981b58669a8d98e83fc5bfcb9809fcae`; both are
236072 bytes.

VERIFIED baseline on `main` @ 47ab0e0 with Flutter 3.44.9 (Dart 3.12.2):
`flutter analyze` → "No issues found!"; full `flutter test` → "+655 ~2: All tests passed!" (655 passed, 2 pre-existing skips).

Standing decision recorded: owner 2026-10-03 14:33 UTC "no need for playstore
now just work on the games" — no Play Console/API/listing action in this pass.
Plan for the pass is in PROJECT.md ("October 2026 quality pass").

## 2026-10-03 — Iteration 1: reviewed PR #9 work ported (fill screen, pixel camera, embers/dust, w1_l5 hopper)

PR #9 (`experimental/polish-loop`) stays unmerged. I reviewed its three commits
and ported by path from d741c9e (which contains 75cd5a6 and 7cfa135):
level fix `assets/levels/w1_l5.txt` + `tool/level_author.py` (hopper2 96,15 →
96,12, on the ledge top), `lib/game/flex_viewport.dart`,
`lib/game/components/ambient_motes.dart`, the ember_game/hud/parallax/
sign_bubble/settings/l10n/webtest changes, the two new test files,
`docs/defect-audit-2026-09-27.md`, the 2026-09-27 plates and the alpha.28
release readback. NOT ported: the alpha.29 version bump (pubspec,
lib/version.dart), `docs/releases/v1.0.0-alpha.29.md` (never shipped) and
the branch's progress.md lines (the log was rotated).

VERIFIED red before green (new tests on pre-port main code):
`test/enemy_spawn_clearance_test.dart` → "+27 -2: Some tests failed"
(w1_l5: no enemy spawns buried in solid tiles / still buried after 3 s);
`test/fill_screen_test.dart` → load failure (flex_viewport.dart and
ambient_motes.dart missing, no `fillScreenOverride`, no `viewWidthMax`).
After the port both files: "+36: All tests passed!".

VERIFIED gate on the branch head: `flutter analyze` → No issues found!;
full `flutter test` → "+691 ~2: All tests passed!" (655 + 36 new, 2
pre-existing skips).

VERIFIED save compatibility: `fillScreen` is read as `j['fillScreen'] as
bool? ?? true`, so settings files without the key load with the default.

VERIFIED captures (headless, not a device): `flutter build web --release -t
lib/main_webtest.dart`, Chromium headless shell via Playwright, 915×412,
`?level=w1_l1&seed=1&fill=1|0` and `?level=w2_l2&seed=1&fill=1`, 2.5 s after
`window.__pyregrove.loaded`: `docs/visual/2026-10-03/`. Fill on: scene runs
edge to edge, HUD and touch buttons at the edges, no side bands. Fill off:
the classic 16:9 frame with black side bands. Forest embers visible as small
orange points over the backdrop.

ASSUMED: the physical-pixel camera snap reads smoother on a phone; a headless
still cannot show motion and no device is available. `AmbientMotes.render`
creates small `Float32List.sublistView` views per draw bucket per frame
(render path, not update); judged negligible, not measured on a device.

## 2026-10-03 — Packaging: 1.0.0-alpha.30+42 candidate (source only)

VERIFIED: PR #11 merged as f627ee7, PR #12 merged as 8237e7f (merge commits).
I stopped feature work after one iteration because the workspace credit guard
for this run left no room for a second feature plus packaging; the remaining
backlog is in PROJECT.md.

VERIFIED: `pubspec.yaml` → `version: 1.0.0-alpha.30+42`; `lib/version.dart`
→ `kAppVersion = '1.0.0-alpha.30+42'`; `flutter test test/version_test.dart`
→ "+1: All tests passed!". Notes: `docs/releases/v1.0.0-alpha.30.md`.

VERIFIED gate on this branch: `flutter analyze` → No issues found!; full
`flutter test` → "+691 ~2: All tests passed!".

No tag, GitHub release, mirror sync, signed build or Play action in this
step (Play hold, owner 2026-10-03 14:33 UTC). Device gates stay false.

## 2026-10-03 — Release: 1.0.0-alpha.30+42 private prerelease (no Play)

VERIFIED review: an independent read-only review of `47ab0e0..a5032cf`
returned PASS with no blocking or major findings. Minor findings and what I
did with them: the release notes said "No ads, no tracking" while the app
ships opt-in analytics that are off by default, so I reworded the line;
P-OCT-FILL-SCREEN claimed "render without per-frame allocation" but
`AmbientMotes.render` creates up to 12 `Float32List.sublistView` views per
frame, so I set that feature back to `passes: false` (acceptance unchanged)
and added backlog row 9; `tool/level_author.py` no longer reproduces the
shipped w1_l2–w1_boss grids, backlog row 10; the line in `docs/release.md`
that named the agent product now names the managed GitHub integration.

VERIFIED mirror: I made `sync/alpha30` on `pyregrove-ci` from its `main`
(`7cc7eb2`), replaced only the allowlisted paths with `git archive a5032cf`
output minus `android/signing/` and `android/key.properties`, and compared
the result with `git ls-tree` against `a5032cf`: 417 paths, mode and blob
identical; no key material. PR CI run 37132770059: "No issues found!",
"691 tests passed, 2 skipped." PR #6 merged as `5eb16f0`; its tree equals
the reviewed branch tree.

VERIFIED trigger: `workflow_dispatch` on the mirror returned HTTP 403
"Resource not accessible by integration" (CLI and one REST retry). I did not
change workflows or secrets. The workflow also builds on a push to `main`,
so the merge above started signed run 37133160031 (same path as alpha.28,
run 35287963465). It succeeded: analyze "No issues found!", "691 tests
passed, 2 skipped.", apksigner certificate SHA-256 equal to the pin.

VERIFIED artifacts: I downloaded `pyregrove-release-apk` and
`pyregrove-release-aab` and checked them with apksigner, aapt2,
jarsigner/keytool and bundletool: `com.tsorostudios.pyregrove`, versionCode
42, versionName 1.0.0-alpha.30, minSdk 24, targetSdk 36, not debuggable,
signer `286c4760…8ffd` on both. APK 55,319,284 B sha256 `08c04b18…8ebd7d`;
AAB 55,110,113 B sha256 `5a4d1861…992bb3`.

VERIFIED release: `v1.0.0-alpha.30` on this repo, tag →
`a5032cf2d3f6277f52ff66feb9c9a30760515d20`, prerelease, not latest, title
"Pyregrove 1.0.0-alpha.30 — Edge to edge", assets APK, AAB and
`pyregrove-SHA256SUMS`. I downloaded the assets again from the release and
`sha256sum -c pyregrove-SHA256SUMS` printed OK for both.

ASSUMED / not verified: behaviour on a physical phone and camera smoothness
in motion (no device). No Google Play action (owner hold, 2026-10-03 14:33
UTC). Mirror PR #5 (`sync/alpha29`, superseded) and private PR #9 stay open.

## 2026-10-03 17:10 UTC — Review finding: ambient motes allocate nothing per frame

- The read-only review of alpha.30 left one clause of `P-OCT-FILL-SCREEN`
  unmet: `AmbientMotes.render()` made up to 12 `Float32List.sublistView`
  views every frame. Its findings are this pass's first task.
- Fix (`fix/motes-no-alloc-20261003`): the constructor builds every batch's
  views once (count + 1 per slot) and `render()` hands `drawRawPoints` the
  ready view for the current fill. Same points, same paints, same order.
- VERIFIED red→green: the new test in `test/fill_screen_test.dart` renders
  the same state twice for 90 frames (forest and cave) and requires the
  identical batch objects. Before the fix it failed with "cave false frame 0
  batch 0 was rebuilt"; after it, `flutter test test/fill_screen_test.dart`
  printed "+8: All tests passed!".
- VERIFIED gate (Flutter 3.44.9): `flutter analyze` "No issues found!";
  `flutter test` "+692 ~2: All tests passed!" (691 before, plus the new test).
- `P-OCT-FILL-SCREEN` passes again; backlog row 9 is done.
- ASSUMED: no visible change. The motes draw from the same buffers in the
  same order. Not in a build yet.
