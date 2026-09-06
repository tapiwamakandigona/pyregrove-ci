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

### L1. W2 mimic gap — SHIPPED 2026-09-02 (alpha.23 #23): Spore Mimic
No new sprite needed: in `env=cave` levels the mimic wears the existing
shroom-cluster prop (`props/shrooms.png`, original asset) and its revealed
thornling strip is tinted spore-violet instead of leaf-green
(lib/game/mimic_disguise.dart, pure and unit-tested). Two placed: w2_l3
(22,10) two tiles from the real shrooms just past the first checkpoint —
the low-stakes teaching beat; w2_l5 (48,11) on the chest platform beside
the chest, with a real shroom decor added at (44,11) so the platform has
two clusters. world2_levels_test: every cave mimic must have shrooms
within 4 cols (the disguise has to blend) and W2 fields ≥2. Probe: w2_l3
and w2_l5 medium 4/4 COMPLETED (both stay in the daily pool).

brambleMimic (N) appears ONLY in w1_l3 (×2) — zero in all of w2 despite
w2 shipping chest rooms. A mimic re-skin (soot chest) in w2_l3/w2_l5
recalls the learned element with a twist — pure kishotenketsu "ten".
Existing deferred item; this doc is its spec home now.

### L2. Secret-idiom audit + diversification — AUDITED 2026-09-02, diversification is an owner call
Measured (script over the 10 combat levels, 20 X): **20/20 are the
cracked-wall idiom** (a B within 3 cols of the chest); 6 of them are also
high/off-camera from the floor (rows 4–8). One idiom per world, not ≥3.
Why not just diversify: `secret_vault_test` requires every X within
5 cols / 3 rows of a B — that is the discoverability contract from the
alpha.5 sky-vault lesson (a cracked block is the only "something is here"
tell the game has). A second idiom (drop-in nook, one-way underside)
means loosening that test or adding a new tell (near-secret sound sting,
audio backlog). Not done unasked; owner decides whether the tell may
change. w2_l2's new roof-drop chest (L4) is a C, not an X, so it is not
bound by the rule.

Catalog all 24 X/C placements by concealment idiom (cracked block /
one-way drop / off-camera nook / behind-waterfall equivalent). Target ≥3
idioms per world. Rayman-style "secret sound sting when near" (audio
backlog C-series hook) is the discoverability aid that keeps diverse
hiding fair. Audit is a capture-review task with existing harness
(?level=&spawn= + scene_cap.py), no code needed for the audit itself.

### L3. Coin breadcrumbing pass on w1_l1 — CHECKED 2026-09-02, no change
Parsed w1_l1: two six-coin jump arcs (cols 9–14 and 34–39, rows 13→11→13),
a walking line on the first block (cols 22–24), and two coins on the
row-12 platform at cols 52–56 that only a double jump reaches — the coins
already trace arcs and imply the path. Closed as verified; nothing re-laid.

Craft norm: teach jump apex with coin arcs; use coin lines as implied
path. CHECK whether w1_l1's 17 coins trace jump arcs or sit in flat
rows; re-lay as arcs where flat. Zero-risk asset edit, big onboarding
win — geometry teaching without one more sign.

### L4. Denial & reward / foreshadowing moments — SHIPPED 2026-09-02 (alpha.23 #22), w2_l2
Ember Vault's free pillar chest moved to a ledge six rows up inside the
vault (visible from the floor, beyond the double jump). Route: outside
platforms → new bridge (cols 97–101) → vault roof → drop through a
2-wide roof hole (cols 90–91). Proof in world2_levels_test: sealing the
hole makes the chest unreachable under the shipped reachability model.
Chest economy unchanged (2 + 2). Casual probe 12/12 completes (all
difficulties). Spec text kept below for the next candidate.

Likely absent (nothing in the format encodes "visible but unreachable").
Cheapest honest version: place one X-chest visibly across an
uncrossable gap early in a level whose exit path loops back above it
(level loop). Needs one level re-layout, no engine work. Candidate:
w2_l2 (lowest hazard count, most room to grow).

### L5. Kishotenketsu per-level audit — AUDITED 2026-09-02, one re-author shipped (alpha.23 #27)
Method: enemy composition per level third + a 30 s headless drift probe
of every walker (where does each enemy end up if left alone?). Ten levels;
nine have a readable ki/sho/ten (the twist is usually the level's enemy in
a new relation to terrain: totems over the pillar in w2_l4, mimics on the
chest platform in w2_l5, rotshields facing the wrong way in w1_l4). The
one with no answer was **w2_l1 Ashen Gate**, the level whose concept is
"Soot Creepers never stop at ledges": the drift probe showed all three
creepers walking into the spike trench (cols 47–49) or the lava (88–89)
within 5–10 s of waking — and they woke 45 tiles out, so by the time the
player arrived every creeper was wading in a hazard, invisible or a
hidden contact hit while jumping the pit. The concept literally fell in a
hole. Re-author (code + level, both tested):
- creepers wake about a screen out (`kCreeperWakeDistance` 24 tiles ×
  aggro; first cut 12) instead of 1.5 screens out, so what they do is
  *seen*;
- creepers die in spikes/fire (ash puff, counts as a kill) —
  `EnemyCore.hazardsKill`, opt-in, only creepers. The first cut also
  spawned them facing the player; the full probe matrix (alpha.23 #33)
  showed 12-tile wake flattened W2 medium to W1 hit counts and
  face-toward-player wiped w2_l5 at any wake ≥ 20 tiles — reverted to
  patrol facing, wake 24;
- w2_l1: a one-tile lip at (42,13) turns creeper #1 into a real patrol on
  the upper floor (ki: fight it); #2 comes at you from the checkpoint wall
  and, if you let it pass, drops into the spike pit (sho); #3 charges from
  the gate approach, turns at the col-74 wall and marches into the lava
  (ten) — sign3 names it: "Creepers do not stop for lava either."
Probes after: w2_l1–l5 + w2_bonus medium 24/24 COMPLETED; w2_l4 now also
12/12 across easy/medium/hard (was 0/4 medium). Original enemy art only.

Counts can't show whether each level's final third re-frames its
element. At freeze lift: one capture-review pass per level asking one
question — "what's this level's concept, and where does it twist?"
Levels with no answer get a targeted re-author (probe re-run after:
kDailyPool levels must stay 4/4).

### L6. Daily pool breadth — SHIPPED 2026-09-02 (alpha.23 #20), partial
`kDailyPoolWorld2 = [w2_l2, w2_l3, w2_l5]`, used only once the Grove
Golem is down; W1-only players keep their previous pick. **w2_l4 is
out**: the casual-bot probe wiped it 4/4 on medium the same day (easy and
hard 0 deaths / 4 hits each — a bot route desync at the col-94 pillar
under the totem at col 98, not a difficulty bug; see progress.md). It
joins the pool when the probe is 4/4. Ties into RETENTION-SPINE Phase A.
**Update 2026-09-02 (#28):** after the creeper rework (#27) w2_l4 probes 4/4
on easy, medium and hard → listed. Pool is now every non-tutorial,
non-boss W2 level.

## D. Explicitly rejected (with reasons)

- **More levels / World 3** — content breadth before retention spine +
  audience contradicts LAUNCH-WORTHINESS; polish the 12 we have.
  *Reconciled 2026-09-02:* owner directive 02d orders curve work "before
  adding any new level" and then "content". Two **bonus** levels shipped
  in alpha.23 (Ember Hollow, Slag Cellar) as optional side content behind
  boss gates — outside the 12-level campaign this doc audits, so the
  "polish the 12" stance stands for the campaign. World 3 remains rejected.
- **Breaking the 2C/2X/1f contract** — the count-promise is a genre
  strength (Apple Knight's core praise); vary idiom, not contract.
- **Tutorial popups** — signs already fade correctly; geometry first.
- **Procedural levels for the campaign** — hand-authored identity is
  pillar 5's moat; procedural belongs only in Endless Grove (Phase B).

Order at freeze lift: L3 (asset-only) → L1 → L2 audit → L5 audit →
targeted re-authors from audits → L6 last (needs probe green).
