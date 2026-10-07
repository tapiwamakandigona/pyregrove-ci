# Idle crouch / landing jitter — 2026-09-10

## Plan and scope

Owner report at 22:33 CAT: when the player is still, it starts a rapid
crouch-like animation. Fix the reproduced ground-contact fault, not the
appearance of its symptom. No new features, asset swap, version bump, tag,
Play submission or spending in this pass.

1. Add a regression for idle under real, non-exact frame intervals, including
   the actual EmberGame update → player event → squash path.
2. Observe red on the unchanged alpha.27 source. Preserve the test bytes.
3. Make the smallest physics correction. Verify the same new tests and all
   existing tests, analyzer and a release web build.
4. Record what remains unverified and deliver the patch through a branch.

## Initial primary-source findings

VERIFIED: GitHub's alpha.26 → alpha.27 comparison changes HUD sizes, save
backup validation, version and documentation, but not physics or player
animation code. Main read back as `affe082346c5fe202bebb8ad48364f00d528d62a`.
This is not evidence that the owner is running that exact build.

VERIFIED: a read-only Dart probe of that source produced 120 `landed`
events and 120 `fall` frame states during 120 stationary frames of 0.017 s.
Exact 1/60 s frames produced one initial landing and no falling frames.
0.01667, 0.0167, 1/59 and 0.03334 s also reproduce the fault.

The frame loop consumes the remainder after each 1/60 s simulation step.
`integrate` clears `onGround`; a tiny positive downward step then queries
`bottom - 0.001`, which is still above the supporting floor. Next step
rediscovers the floor and emits another landing. The actual event consumer
triggers landing SFX and resets the squash timer. The owner-described visual
symptom is consistent with this reproduced mechanism; phone confirmation is
still required.

## Verified fix and evidence

Raw red/green, full-suite, analyzer, build and browser telemetry outputs:
[`verification/idle-ground-contact-sep10/`](verification/idle-ground-contact-sep10/).
That directory also records original-test hashes and an evidence checksum manifest.

`_stepY` now queries the downward leading edge at `body.bottom`, rather than
subtracting 0.001 px. That detects the supporting tile even on a tiny positive
substep. There is no downward proximity probe or sticky-ground state; the
airborne, walk-off and platform-drop cases still behave normally.

- VERIFIED expected-red on unchanged alpha.27: 7 failed / 3 passed. Examples:
  `Expected: <0> Actual: <119>` repeated stationary landings,
  `Expected: <1> Actual: <162>` landings following one jump, and
  `Expected: <0> Actual: <89>` frames with active idle squash in the real game.
- VERIFIED green after the one-expression physics fix: 10/10 additive tests.
  New test SHA256 stayed
  `5de81ccf31a8f0e9a909540b67f4b680d0740f2f51537a4c879bddf07ce6dc5f`
  between red and green. All 83 pre-existing test files are byte-identical.
- VERIFIED full suite: **655 passed / 2 pre-existing skips**. Analyzer:
  **No issues found**. Reachability, jump, one-way-platform, drop-through,
  walk-off, save, HUD, lifecycle and existing animation tests stayed green.
- VERIFIED `flutter build web --release --no-pub -t lib/main_webtest.dart`
  succeeds. Existing missing-Cupertino-font warning remains; not a build
  failure and no font configuration was changed.
- VERIFIED private Browserbase run of that actual compiled web build at
  915x412, seed 42, Forest Edge: 60 idle telemetry samples over approximately
  three seconds; x=72/y=246 throughout, zero touch input, simulation time
  advanced beyond three seconds, no death/pause and no browser errors.
  This web telemetry does not expose squash; the real-game regression above
  checks that separately. Screenshot captured, not a human visual approval.
- NOT VERIFIED: the owner's installed version, actual Android device,
  subjective animation quality, audio listening, and wider alleged bugs.
  No Android build or Play release in this patch.

## Process failures retained

Initial worktree setup timed out before mutation:
`command timed out after 20000 milliseconds`.
The single rerun read the correct base, then failed because the parent
directory was absent:
`failed to make directory .../.worktrees/idle-ground-contact: No such file or directory`.
After creating the parent, a verified-empty administrative directory left by
that failure caused `AlreadyExistsError`. Removed only that empty residue,
then created the worktree at the already-verified base. No user work removed.

## Release and asset gates

This source fix is not proof that all reported bugs are resolved. Keep
production and further testing-track promotions on hold pending a same-key
Android candidate and actual-device idle/jump/run/pause checks. No changes
to physics timing, sprites, audio, saves, HUD sizes, Android config or signer
were combined with this fix.
