# Retention spine — design research (NOT for implementation while frozen)

Written 2026-09-01. This is the groundwork for flip-condition #1 in
docs/LAUNCH-WORTHINESS.md ("a retention spine exists"). It is a research
artifact per the post-alpha.21 directive (DEMAND.md fb5f70bc): **no code here
is authorised; nothing in this doc is a feature commitment.** It exists so
that if/when the owner lifts the freeze, the highest-leverage retention work
is already designed and costed.

## 1. Why a spine, and how big it needs to be

- Pyregrove's campaign is ~1–2 h (ASSUMED from pars). After the Kiln Golem
  falls there is no day-8 reason to open the app. Late churn (D14–D30) is
  content exhaustion, and D30 is the retention input Play weights hardest
  [secondstage.io; solsten.io, read 2026-09-01].
- Reality check on targets: median mobile D30 is **~0.7%**, top-quartile only
  1.6–1.8% [investgame.net 2026 benchmark report]. Single-player games are
  *expected* to have low D30 — "players finish and move on" is normal; D7
  tracking completion is the healthier lens [secondstage.io]. The spine's job
  is not to fake live-service numbers; it is to give the minority who liked
  the game a repeatable reason to return, which is what seeds ratings,
  Explore sampling, and word of mouth.
- The category proof: Apple Knight's loop is exactly this duality — a
  ~4 h campaign you *learn*, plus a procedurally generated Endless Adventure
  you *compete* in, with leaderboards; fully offline, network only for
  leaderboards/cloud saves [browsergamers.gg 2026-02; Play listing]. That is
  the shape to copy, not the content.

## 2. The daily-run pattern (researched)

Canonical design facts from Spelunky / Dead Cells / Caveblazers postmortems
[gamedeveloper.com 2013 & 2017; spelunky.wiki]:
- Only two hard rules: **shared seed, rolls over every 24 h**. Everything
  else is a dial.
- One-attempt-per-day (Spelunky) maximises stakes and de-advantages
  time-rich players, and measurably *teaches* better play; unlimited
  attempts + best-score (Dead Cells) is friendlier and mobile-typical, but
  video-scouting makes it less fair. For an offline game with no global
  leaderboard, fairness-vs-scouting is moot → **unlimited attempts, record
  best** is the right dial for Pyregrove.
- Shared modifier sets on top of the seed (Caveblazers "blessings/curses")
  make dailies feel distinct from the campaign at near-zero content cost.
- Randomness that isn't skill should be neutralised in dailies (Spelunky
  locks the gambling wheel). Pyregrove equivalent: fixed chest contents for
  the daily seed.

## 3. What Pyregrove already has (verified in repo)

- **Daily Delve exists** (a973dc26): date-keyed level from kDailyPool
  (w1_l2..w1_l5), best-time persistence, harness param `?dailybest=MS`. It is
  a thin picker — no modifiers, no streak, no seed-driven variation.
- **DifficultyMods** (speed/telegraph/aggro/hearts) — a ready-made modifier
  vocabulary for daily mutators.
- **Deterministic seeds** already flow through the harness (`?seed=`).
- **A player bot + wipe probe** (test/wipe_probe_test.dart, live-bot
  scripts) — i.e. an automated feasibility checker, which is the hard part
  of procedural platformer generation. Cloudberry Kingdom's core insight is
  that the design AI must query a player AI for feasibility
  [gamedeveloper.com 2012]; Pyregrove already owns that machinery.
- **ASCII level format + legend** — hand-authorable chunks for free.

## 4. Proposed spine (two phases, if ever unfrozen)

**Phase A — Daily Delve, deepened (small; days not weeks).**
Date-seeded daily = level from pool × modifier set (2–3 drawn from:
DifficultyMods presets, one-heart, no-apples, time-attack par, coin-goal) ×
fixed chest rolls. Streak counter + 7-day best history on the daily card.
Purely local, offline, no backend. This is the cheapest honest answer to
"why open the app tomorrow" and follows §2's dials.

**Phase B — Endless Grove (the Apple Knight analogue; weeks).**
Chunk-stitched endless mode: a hand-authored library of ~24-col chunks in
the existing legend (entry/exit heights annotated in meta lines), stitched
by compatible edges — the Dead Cells "hand-made templates + structure graph"
approach [Edgar/Unity writeup], not free-form generation. Difficulty ramps
by depth via DifficultyMods; score = depth + coins; death is final (run
ends, no lives). Every chunk and every stitch rule is validated headlessly
by the existing wipe-probe bot across all difficulty ramps before shipping.
Local leaderboard first; online leaderboards (Play Games Services) are a
separate owner/infra decision — not required for the spine to function.

**Explicitly out:** push notifications, FOMO timers, login rewards — they
conflict with pillar 4 (honest presentation) and the no-tracking posture.
Retention here = "the game is worth reopening", not engagement mechanics.

## 5. What this does NOT solve

The spine addresses flip-condition #1 only. Conditions 2 (audience — owner
effort, months of devlogs), 3 (real-device evidence) and 4 (written launch
goal) are untouched by any of this. Building Phase B before condition 2 has
started would be polishing a game no one is waiting for — sequencing matters
as much as scope.
