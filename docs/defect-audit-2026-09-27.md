# Defect audit — 2026-09-27 (games polish loop, P-BUGS)

The owner said Pyregrove "has become buggy" (2026-09-10). The idle crouch
jitter he described was fixed in PR #7 and built as alpha.28. This pass looked
for anything else a player would hit.

## What was checked

| Check | Result |
|---|---|
| Sim fuzz: all 14 levels x classic + forgiving jumps x 12 seeds, random inputs, variable dt, up to 120 s each | No exception, no NaN, player never embedded in solid tiles or out of bounds, no idle landing spam (VERIFIED, local) |
| Frame-rate probe through the real `EmberGame.update` splitter at 30/60/90/120/144 Hz and jittered dt | Jump height 36.0–37.4 px, airtime 0.55–0.57 s, attack 0.22–0.23 s; no frame-rate-dependent behaviour (VERIFIED) |
| Web harness (release build), title/select/shop/settings/credits + 5 levels played at 915x412 | No console or page errors besides the expected AudioContext autoplay notice (VERIFIED) |
| Enemy placement vs terrain | **Defect found (below)** |

## Defect: a hopper buried in the rock in Rootway Ruins (w1_l5)

`meta: hopper2=96,15` put the second hopper inside the 92–98 x 13–15 ledge
block. It sat there the whole run: drawn over the stone, never moving, and out
of reach. It has been like this since the World 1 rebuild (937ad16,
2026-07-25). Plate: `docs/visual/2026-09-27/w1_l5_hopper2_before.png`.

Fix: `hopper2=96,12`, so it now stands on top of that ledge (the column the
author meant). `tool/level_author.py` carries the same value. Plate:
`docs/visual/2026-09-27/w1_l5_hopper2_after.png`.

Test: `test/enemy_spawn_clearance_test.dart` (additive) checks every
shipped level. No enemy's centre may start in rock, and none may still be
there after 3 s of play. It failed on the old level (2 fails, both this hopper) and passes
with the fix. Full suite 684 passed / 2 existing skips, analyzer clean.

Side note: seven other spawns overlap a wall or floor edge by 2–4 px (slag
hounds, a diver, a mimic, a totem, a creeper). Physics settles these on the
first step, and the 3-second check shows none of them stays buried. Left alone.

Not verified: how the extra live hopper changes the difficulty of Rootway
Ruins on a phone. The existing fairness/survivability tests pass.
