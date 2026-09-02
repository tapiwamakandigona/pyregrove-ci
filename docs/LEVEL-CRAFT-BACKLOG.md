# Level & content craft backlog — researched critique of the 12 shipped levels

Written 2026-09-01 under the post-alpha.21 freeze. **Nothing here is
implemented**; companion to FEEL- and AUDIO-POLISH-BACKLOG.md. Sources read
2026-09-01: teach-test-twist / kishotenketsu (Hayashida interviews,
GMTK 3D World analysis); platformer level-flow guides (solana.garden,
gamedesignskills.com); level-design theory glossary (jm-j.com — landmarks,
breadcrumbing, denial & reward, foreshadowing); Rayman Legends secrets
writeup; Apple Knight reviews ("secret-heavy level design" is its
signature praise). Level data below parsed from assets/levels/*.txt at
9d1ef391; balance evidence from the 144-run curve probe (progress.md,
2026-08): regular levels 4/4 pass at all difficulties, bosses wipe the
casual bot by design.

## A. What the data says we already do well (VERIFIED)

1. **Textbook enemy-introduction cadence** — one new element per level,
   then remixes: w1 T → +V → +N,O → +R → mix; w2 S → +D,H → +V(recall) →
   +O,W → six-type finale mix. This IS teach-test-twist at world scale.
2. **Onboarding fade**: signs 4→3 across w1, flat 2 in w2. Geometry takes
   over from text exactly as the craft says it should.
3. **Verticality finales**: one-way platform counts spike at each world's
   l4/l5 (w1_l5 = 78, w2_l4 = 87 vs ~11–36 elsewhere).
4. **Mercy placement**: hearts cluster where the probe shows pressure
   (w1_l5 ×2, w2_l4 ×4 — the two hardest regulars). Evidence-backed.
5. **Clean boss arenas**: no coins/chests in either boss room; 4 apples
   as ammo; campfire checkpoint. Focus is right.
6. **Chunking landmarks**: 2–3 campfires per level act as chunk
   boundaries; per-world palettes split the campaign visually.
7. **Speedrun affordance**: par_s + medals ship on every level.

## B. The uniform-template finding (main critique)

Every regular level has EXACTLY 2 chests, 2 secret chests, 1 feather,
8 cracked blocks (one 12), 1–2 apples. Two readings, both true:
- *Strength* (Rayman Legends model): a predictable secret COUNT teaches
  players to hunt — "every level has exactly 2 X" is a promise. Apple
  Knight's praise is literally "secret-heavy, consistent".
- *Risk*: when the container never varies, hunting becomes checklist
  work. Research says vary the *hiding idiom*, not the count.

Verdict: keep the 2C/2X/1f contract, vary the concealment. Current
idioms to audit at freeze lift: how many X's are behind cracked blocks
vs one-way drops vs out-of-camera nooks? If >60% share one idiom,
diversify (see L2).

## C. Backlog — prioritized

### L1. W2 mimic gap (known-deferred, now data-confirmed)
brambleMimic (N) appears ONLY in w1_l3 (×2) — zero in all of w2 despite
w2 shipping chest rooms. A mimic re-skin (soot chest) in w2_l3/w2_l5
recalls the learned element with a twist — pure kishotenketsu "ten".
Existing deferred item; this doc is its spec home now.

### L2. Secret-idiom audit + diversification
Catalog all 24 X/C placements by concealment idiom (cracked block /
one-way drop / off-camera nook / behind-waterfall equivalent). Target ≥3
idioms per world. Rayman-style "secret sound sting when near" (audio
backlog C-series hook) is the discoverability aid that keeps diverse
hiding fair. Audit is a capture-review task with existing harness
(?level=&spawn= + scene_cap.py), no code needed for the audit itself.

### L3. Coin breadcrumbing pass on w1_l1
Craft norm: teach jump apex with coin arcs; use coin lines as implied
path. CHECK whether w1_l1's 17 coins trace jump arcs or sit in flat
rows; re-lay as arcs where flat. Zero-risk asset edit, big onboarding
win — geometry teaching without one more sign.

### L4. Denial & reward / foreshadowing moments
Likely absent (nothing in the format encodes "visible but unreachable").
Cheapest honest version: place one X-chest visibly across an
uncrossable gap early in a level whose exit path loops back above it
(level loop). Needs one level re-layout, no engine work. Candidate:
w2_l2 (lowest hazard count, most room to grow).

### L5. Kishotenketsu per-level audit ("does it twist?")
Counts can't show whether each level's final third re-frames its
element. At freeze lift: one capture-review pass per level asking one
question — "what's this level's concept, and where does it twist?"
Levels with no answer get a targeted re-author (probe re-run after:
kDailyPool levels must stay 4/4).

### L6. Daily pool breadth
kDailyPool = [w1_l2..w1_l5] only — w2 never appears in Daily Delve.
Once L1/L5 settle, add w2_l2..w2_l5 (probe-verified 4/4 first). Ties
into RETENTION-SPINE Phase A modifiers.

## D. Explicitly rejected (with reasons)

- **More levels / World 3** — content breadth before retention spine +
  audience contradicts LAUNCH-WORTHINESS; polish the 12 we have.
- **Breaking the 2C/2X/1f contract** — the count-promise is a genre
  strength (Apple Knight's core praise); vary idiom, not contract.
- **Tutorial popups** — signs already fade correctly; geometry first.
- **Procedural levels for the campaign** — hand-authored identity is
  pillar 5's moat; procedural belongs only in Endless Grove (Phase B).

Order at freeze lift: L3 (asset-only) → L1 → L2 audit → L5 audit →
targeted re-authors from audits → L6 last (needs probe green).
