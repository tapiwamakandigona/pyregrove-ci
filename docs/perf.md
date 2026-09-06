# Performance notes (P-M7)

Status legend: **VERIFIED** = measured/audited with evidence in this repo.
**OPEN** = requires real hardware; cannot be honestly measured in a headless
CI/sandbox environment and is deliberately left unclaimed.

## 1. Allocation audit — `Session.update` hot path (VERIFIED, code audit)

Audited 2026-07-25 against `lib/game/session.dart` and everything it calls per
frame (`PlayerCore.update`, every `EnemyCore.update` incl. boss, `physics.dart`).
Method: exhaustive read of the update call graph + pattern grep for
allocation sites (`List(`, `List.from/of`, collection literals, `map/where/
firstWhere/toList`, `cast<>`, `Vector2(`, spreads, string ops).

Findings and resolutions:

| Site | Frequency | Resolution |
| --- | --- | --- |
| `PlayerCore.takeEvents()` copied `_events` even when empty | every frame | fixed: returns `const []` when empty |
| `LevelSession.takeEvents()` / `takePlayerEvents()` same pattern | every frame (Flame layer calls both) | fixed: `const []` fast path |
| `tileAt` instance tear-off passed to `e.update(...)` (tear-offs allocate a fresh closure per evaluation) | per enemy, per frame | fixed: cached `late final TileQuery _tileQuery` |
| `_applePool.cast<...>().firstWhere(...)` (CastList + closure) | on throw press only | fixed anyway: plain loop, zero-alloc |
| `_emberPool.cast<...>().firstWhere(...)` | on totem shot request only | fixed anyway: plain loop, zero-alloc |
| `SessionEvent` / `CoinEntity` / FX objects | event-driven (hits, pickups, chest bursts) | acceptable by design; bounded by `kMaxLiveParticles`/`kMaxPooledProjectiles` pools |
| `attackHitbox` record | per frame only during the 60% damage window of a swing (~10 frames) | acceptable: single small record, event-bounded |

Steady-state result: **zero per-frame allocations** in the pure-Dart sim while
idle/walking/jumping; allocations occur only on discrete gameplay events.
Enemy/player/physics update bodies were already allocation-free (they mutate
pre-built `Body`/state objects; projectiles and coins are pooled or reused).

## 1b. Allocation audit — Flame render layer (VERIFIED, code audit)

Follow-up to §1, audited 2026-07-25 across `lib/game/components/*`. The
worst offender was not allocation but **text layout**: `TextPaint.render`
builds + lays out a `TextPainter` behind a 10-entry LRU keyed by string —
with 5+ HUD readouts and a once-a-second timer churning values, slots evicted
each other and re-ran text layout every frame.

| Site | Frequency | Resolution |
| --- | --- | --- |
| `HudReadout.render` text (coins/apples/chests/feathers/timer/boss name) | every frame | `_HudText` slots: layout only when the underlying value changes; steady-state frame is pure `TextPainter.paint` |
| `HudReadout.render` icon positions/sizes, boss-bar RRect + ticks | every frame | precomputed statics (geometry is constant) |
| `ItemsComponent` sign bubble `toTextPainter` | every frame while a sign is active | cached painter, rebuilt on sign change only |
| `ItemsComponent` coin/feather `Vector2(...)` per entity | per entity, per frame | shared scratch vectors (`Sprite.render` copies into its own temps — verified against Flame 1.35.1 source; it never stores the reference) |
| `PlayerComponent.render` / `EnemyComponent.render` position+size `Vector2` | per entity, per frame | shared scratch vectors |
| `TileLayerComponent` fire draw positions | per fire tile, per frame | positions precomputed (pre-offset) in `rebuild()` |
| `ParallaxBackground` per-layer src `Rect` + scaled width | per layer, per frame | precomputed at load |
| Moving-value rects (boss HP fill, parallax dst, puff circles) | per frame | left as-is: the canvas API takes fresh `Rect`/`Offset` values; these are unavoidable small value objects |

Steady-state result: no text layout, no `Vector2` churn, and no rebuilt
static geometry in the render path; remaining per-frame allocations are the
irreducible `Rect`/`Offset` values the `dart:ui` canvas API requires.

Re-audited 2026-09-02 on alpha.23 code (ash decals, coin flights, mimic
disguise, boss layer, creeper hazards added since): the steady-state result
above still holds — the only string work in any `render` is the timer's
once-a-second `_HudText` rebuild and the debug perf overlay; every `Paint`
in a render body is a field. Draw-call shape: tiles/platforms/spikes are
three `drawAtlas` batches per frame (whole level, uncullled); individual
world-space `drawImageRect`s per level are decor 2–6 + cracked walls 0–10 +
fire 0–9 (max 22, `w2_l2`), so horizontal culling would save at most ~18
ops/frame — tried, measured as op counts, reverted as not worth the code.
`Session.update` event lists return `const []` on quiet frames; the only
per-frame `Vector2` in an update body is the footstep puff spawn, which
fires once per `kFootstepInterval`, not per frame.

## 1c. Sim hot-path cost — measured (VERIFIED, headless benchmark)

`test/session_bench_test.dart` drives the door-seeking bot through the two
worst levels while timing every `LevelSession.update` (VM JIT, sandbox CPU,
warmup excluded; 2026-07-25):

| Level | n | avg | p50 | p95 | p99 | max |
| --- | --- | --- | --- | --- | --- | --- |
| `w1_l5` (densest) | 2022 | 23.4 µs | 15 µs | 37 µs | 123 µs | 1.55 ms |
| `w1_boss` (all phases) | 3516 | 6.3 µs | 3 µs | 10 µs | 75 µs | 0.95 ms |

Re-run 2026-09-02 on alpha.23 code (creeper hazard check, boss-layer
gating, coin chain, ash decals all in the hot path), World 2 added
(same VM, same sandbox class; three runs, worst shown):

| Level | n | avg | p50 | p95 | p99 | max |
| --- | --- | --- | --- | --- | --- | --- |
| `w1_l5` | 2034 | 27.2 µs | 18 µs | 42 µs | 132 µs | 1.4 ms |
| `w1_boss` | 5160 | 6.8 µs | 3 µs | 12 µs | 45 µs | 1.2 ms |
| `w1_bonus` | 2700 | 9.4 µs | 6 µs | 14 µs | 34 µs | 1.4 ms |
| `w2_l5` (8 enemies, 7 kinds) | 3090 | 19.1 µs | 6 µs | 17 µs | 123 µs | 8.3 ms |
| `w2_boss` | 5160 | 6.8 µs | 3 µs | 10 µs | 75 µs | 1.3 ms |
| `w2_bonus` | 2820 | 14.0 µs | 8 µs | 18 µs | 106 µs | 3.3 ms |

`w2_l5` avg is within 4 µs of the 2026-07-25 `w1_l5` figure, so the W2
roster and the alpha.23 additions did not move the hot path. Its 5–8 ms
**max** recurs across runs but not at a fixed frame (a simpler driver on
the same level peaks at 2.1 ms once in 5,400 frames, no event attached)
— VM GC pause class, not a sim cost; p99 stays 123 µs. Bounds unchanged.

The pure-Dart sim uses ~0.1–0.2% of the 16 ms frame budget — frame cost on
device will be dominated by build/raster, not gameplay logic. The test also
acts as a **regression guard** (generous bounds: avg < 2 ms, p99 < 8 ms);
if it ever fails, something expensive landed in the hot path. Device AOT
numbers will differ, but the order of magnitude carries.

## 1d. Render-side canvas ops per frame — measured (VERIFIED, counting canvas)

`test/render_ops_test.dart` renders a booted `EmberGame` into a Canvas
implementation that counts every call, at spawn and after 300 frames of
running right. This is the UI-thread recording half of raster cost (each
`draw*` is a Dart→engine call and a display-list entry); GPU time still needs
a device (§2).

| level | draw ops/frame before #37 (spawn / run300) | after | of which drawRect before → after |
|---|---|---|---|
| w1_l1 | 244 / 241 | 88 / 85 | 160 → 0 |
| w1_l5 | 409 / 400 | 93 / 84 | 323 → 1 / 0 |
| w2_l5 | 253 / 243 | 97 / 87 | 161 → 1 / 0 |
| w1_boss | 202 / 212 | 46 / 56 | 160 → 0 / 3 |
| w2_bonus | 351 / 340 | 115 / 104 | 242 → 1 / 0 |

Finding: the HUD drew each heart (3 hearts + the lives heart) pixel by
pixel every frame — 40 `drawRect` per heart from the 8×8 bitmask — and the
in-level heart pickup 81 (shadow + fill + shine at 1.5×). Fixed in alpha.23
#37 (`lib/game/pixel_heart.dart`): rasterised once per colour with
`Picture.toImageSync`, one `drawImage` per heart; byte-identical to the
per-pixel drawing at 1:1 (`test/pixel_heart_test.dart`), and at the phone's
non-integer scale the seams between the 40 separate rects are gone. What
remains per frame is sprites (`drawImageRect` 35–98: player, enemies, items,
HUD icons — every item is drawn, no camera culling; Skia quick-rejects
off-screen quads on the raster side, so the remaining cost is recording
only), three tile atlases (`drawAtlas`), and 4–7 text paragraphs. Bounds in
the test are regression guards with ~50 % headroom. [measured 2026-09-02]

## 2. Frame budget on 2GB-class device — **OPEN**

Acceptance requires a profile-mode timeline (`flutter run --profile`) on real
or emulated low-end hardware for `w1_l5` and `w1_boss`, avg frame
build+raster ≤ 16ms. The CI sandbox has no GPU/device; running an Android
emulator headlessly would not produce honest raster numbers. **Not claimed.**
How to run when hardware is available:

```
flutter run --profile
# DevTools -> Performance -> record w1_l5 full run + w1_boss all 3 phases
# record avg/max build and raster times here
```

Tester-friendly alternative (no DevTools): build with the in-game overlay
and read the numbers off the screen —

```
flutter build apk --release --dart-define=PERF_OVERLAY=true
# bottom-left: "60 fps  avg 12.3ms  worst 15.1ms"; amber = a frame in the
# last second blew the 16.7ms budget. Compiled out of normal builds.
```

## 3. Cold start ≤ 3s — **OPEN**

Same constraint: needs a physical device stopwatch/`adb shell am start -W`
measurement. Not claimed.

## 4. APK size / split-per-abi / tree-shake-icons — decision

- CI already builds with `--release`; icon tree-shaking is **on by default**
  for release builds since Flutter 3.x (MaterialIcons subset only).
- Universal APK at v1.0.0-alpha.1: **36.8 MB**; AAB: **55.8 MB**.
- **Decision: ship the AAB to Play (Play serves per-ABI splits automatically),
  keep the universal APK on GitHub releases for sideloading testers.**
  `--split-per-abi` on the GitHub artifact would roughly halve sideload size
  but triples artifact count and confuses non-technical testers picking the
  wrong ABI; the Play pipeline already gets split benefits from the AAB.
  Revisit only if the universal APK passes ~60 MB.
