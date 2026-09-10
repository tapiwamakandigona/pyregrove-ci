# Jump physics — measured, researched, retuned (owner directive 2026-09-01d)

Deliverable for "make the jumping a little easier and balanced… research how
normal game devs do it and the physics." Method: measure the shipped arc
in-engine, compare against genre references with citations, change the fewest
constants that address the actual suspects, and prove the levels survive.

## 1. Before — the arc as shipped in alpha.21, verified in-engine

The owner's DEMAND table was integrated from constants at 240 Hz; these are
the engine's own numbers (PlayerCore stepped at 120 Hz on a flat fixture,
now pinned in `test/jump_arc_test.dart`):

| | height | apex | airtime | range at full run |
|---|---|---|---|---|
| full ground jump | 2.27 tiles | 275 ms | 517 ms | 3.81 tiles* |
| tap jump (cut at 0.09 s) | 1.51 tiles | 158 ms | 325 ms | — |
| air (2nd) jump, total rise | 4.05 tiles | — | — | — |

Discrepancies vs the DEMAND table (2.31/283/500/3.69): all ≤3%, explained by
integration-rate differences and, for range, by the DEMAND figure assuming
instant full run speed — the engine number above uses a real running start.
No engine/maths divergence worth chasing. *The owner's 3.69 was
standing-start; a running start measured 3.81.

## 2. References, with sources (read 2026-09-01)

- **Celeste** ships 5-frame (~83 ms) coyote and ~0.15 s buffering, stacking
  into a ~300 ms combined forgiveness window, ON PC WITH A KEYBOARD
  [celeste.ink/wiki/Tech; maddymakesgames.com "Celeste & Forgiveness";
  rockpapershotgun.com 2020-03-15].
- **Touch input adds ~50–100 ms** of latency over keyboards; mobile guidance
  is 0.20–0.25 s buffers where PC uses 0.12–0.15 s [solana.garden
  "Game Input Handling Explained" 2026-06; github raduacg/
  game-mechanics-optimizations §72].
- **Apple Knight** (same genre, same controls, frame-measured in this repo,
  `docs/reference/apple-knight/feel-notes.md` §1): full-jump airtime
  **~0.72 s** vs our 0.52 s; fall ≈1.5× rise (ours 1.6×); **~0.2 s of visible
  apex hang**; tap jump only slightly lower than full — "AK's tap jump still
  reads as a real jump", with the 0.45→~0.55 cut change recommended there
  since 2026-07.
- **SMB1** documents the fall-gravity convention at the genre's root: falling
  gravity is 2–3.5× rise gravity depending on speed class [SMBpedia movement
  page; datacrystal.tcrf.net SMB notes].
- **Jump maths**: v₀ = 2h/tₐ, g = −2h/tₐ² — tune from desired height and
  time-to-apex, not from raw constants [J. Kyle Pittman, GDC 2016 "Building
  a Better Jump"; piratehearts.com/blog/2026/08/jump-metrics-math].

## 3. Hypotheses chosen (from DEMAND 2026-09-01d)

1. **Forgiveness windows are PC-calibrated on a touch game** — coyote 0.10 s
   (0.74 tiles of run) and buffer 0.12 s sit at the keyboard end of every
   cited range. ACCEPTED.
2. **The apex-hang window is narrow** — |vy|<40 px/s ≈ 45 ms of reduced
   gravity per flight; AK hangs ~200 ms. Widening makes landing ON platforms
   easier without adding height. ACCEPTED.
3. **No horizontal landing forgiveness exists** — verified: `physics.dart`
   had ceiling corner correction only; a landing one pixel short of a ledge
   got nothing. ACCEPTED — this asymmetry is now fixed.
4. Jump height/gravity wrong — REJECTED. Heights match AK ratios and every
   level was authored against them; kJumpSpeed and kGravity are untouched.

## 4. The change (4 values + 1 mechanism, `lib/game/tuning.dart` / `physics.dart`)

| constant | old | new | why (source) |
|---|---|---|---|
| kCoyoteTime | 0.10 | **0.12** | touch latency compensation; between Celeste-PC (0.083) and mobile guidance [solana.garden] |
| kJumpBufferTime | 0.12 | **0.16** | same; Celeste ships 0.15 on keyboard [celeste.ink] |
| kApexHangSpeed | 40 | **64** | ~doubles the reduced-gravity apex window; direction from AK's ~0.2 s hang [feel-notes.md §1] |
| kJumpCutMultiplier | 0.45 | **0.55** | tap jumps read as real jumps, not dropped inputs; AK-recommended in-repo since 2026-07 |
| kLedgeLandNudge | — | **4.0 px** | NEW: falling mirror of kCeilingCornerNudge — a committed fall (vy ≥ 120) that misses a **solid** ledge lip by ≤ ~3 px slides onto it. One-way platform lips deliberately excluded: they are drop-down routes, and including them trapped the w1_l3 completability bot on the lip above the exit (verified, then excluded). |

All values are our own choices; the tables above supply the direction, not
the numbers. Nothing else moved — height, gravity, run speed, air-jump
untouched.

## 5. After — measured in-engine (pinned in `test/jump_arc_test.dart`)

| | height | apex | airtime | range at full run |
|---|---|---|---|---|
| full ground jump | 2.33 tiles (+0.06) | 292 ms | 558 ms (+41) | 4.12 tiles (+0.31) |
| tap jump | 1.60 tiles (+0.09) | 175 ms | 350 ms | — |
| air (2nd) jump, total rise | 4.20 tiles (+0.15) | — | — | — |

## 6. The "balanced" gate — level margins checked

Gap audit over all 12 `assets/levels/*.txt` (platform-edge pairs, ≤8 tiles
apart, clear corridor):

- **Widest required gap anywhere: 4 tiles, descending (dy+2), w1_l2 col 38.**
  Old range 3.81 + fall = comfortable; new 4.12 = more so.
- w1_l5's 8-tile gap is a **drop** (dy+6), not a ranged jump.
- **No flat/ascending gap ≥4 tiles exists**, so the +0.31-tile range creep
  cannot unlock any skip: nothing in any level was gated on a 3.8–4.2-tile
  jump. Vertical reach: single 2.33 (<3 tiles — ledge gating intact), double
  total 4.20 (<5 tiles — wall gating intact).
- These three lines are now **enforced as invariants** in
  `test/jump_arc_test.dart` ("level-margin invariants"): range <4.5, single
  <2.9, double <4.9 tiles.
- Completability bots re-run: all 10 regular levels + both coached boss
  fights pass on all 4 seeds. Two bot scripts needed re-coaching to the new
  arc (w2_boss perch approach: earlier air-brake, hold release over the
  pillar, anchor 424→418) — deaths-per-run unchanged vs old-arc baseline
  (1), hits-to-win improved (5→4). Recorded honestly: those were bot-routing
  updates, not level changes; no level relies on the old tight arc.

## 7. What cannot be verified from here

On-device *feel* — whether the new windows actually read as "easier" under
real touch latency on a real phone — is untestable in this sandbox. The
constants move in the direction every cited source says touch needs, and no
level got easier to break, but the judgment call needs thumbs on glass:
w1_l3's spike hops and w2_l4's one-way climbs are the sensitive spots to
try first.
