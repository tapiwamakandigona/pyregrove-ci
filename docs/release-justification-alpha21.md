# v1.0.0-alpha.21 — update definition & justification

Written 2026-09-01, before tagging, per the owner directive of the same date
("one cohesive update, chosen and justified in writing before you build it —
then tag, then stop").

## What this update is

**"Real Fights, Real Phones"** — one consolidated update spanning everything
merged to `main` since `v1.0.0-alpha.20` (57 commits, accumulated under the
2026-08-31 release freeze exactly as that directive instructed: keep building,
don't publish). It has two cohesive themes:

1. **Boss fights become real fights.** Dormant wake-up, phase presentation,
   death presentation, honest HP pools (60→150), slam hitboxes that match the
   animation, difficulty that actually reaches boss behaviour (speed /
   telegraph / wake range), and an arena geometry fix (head-bonk ledges →
   one-way). Verified by the 24-combo coached-bot matrix and a 144-run
   full-game wipe probe.
2. **Correct on real phones.** The sub-30 fps slow-motion bug fixed with
   sub-stepped frame pacing (full speed to ~15 fps); backgrounding now pauses
   audio and lands on the pause menu; the system back gesture pauses instead
   of killing the run (plus a pre-load crash guard); R8/resource shrinking +
   backup rules for the Feb-2027 Play bar; Impeller opt-out for low-end
   Adreno/Mali stability; per-ABI split APKs 18.6–21.6 MB (<30 MB pillar).

Plus the supporting content/feel batch built alongside: Bramble Mimic (12th
enemy) with fair-warning signage, difficulty-curve fixes (w1_l4 mound, w1_l2
ashbat stack), screen-shake toggle, hit recoil, takeoff stretch, landing thud,
run dust, pitch-varied SFX, sign-wrap fix, credits-page fix, title build label.

## Why this is the right single update

- Every change is already merged, suite-green (462 tests + 1 deliberate
  probe-harness skip, `flutter analyze` clean) and documented in progress.md.
- A signed local release build of this exact content was verified 2026-09-01:
  package `com.tsorostudios.pyregrove`, versionCode 33, versionName
  `1.0.0-alpha.21`, signer matches the pinned cert.
- Cutting anything out would ship a build that differs from the tested tree;
  adding anything more restarts the churn the freeze existed to stop.
- Version `1.0.0-alpha.21+33` has been the working version since `89af754`;
  the tag lands on the sha that carries it.

## What happens after the tag

Per the directive: no further releases, no new features. Work moves to the
research phase — evidence-based PLAY-QUALITY-2027 checklist and the
launch-worthiness case (including the case against). Play remains frozen.
