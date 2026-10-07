# Audience playbook — groundwork for launch flip-condition #2

Written 2026-09-01. Research artifact per the post-alpha.21 directive: no new
features, nothing here actions itself. Flip-condition #2 in
docs/LAUNCH-WORTHINESS.md ("an audience exists before launch day") is
**owner effort by nature** — accounts, posting, and being the face of the
game cannot be delegated to the repo. This doc turns that effort into a
checklist with Pyregrove-specific content, so the cost is as low as possible
if the owner decides to run it.

Sources: madoctopus.fun launch checklist 2026-08; gtstu.com devlog guide
2026-06; strayspark.studio devlog-marketing 2026-03; gamosy.com checklist
2026-03 (all read 2026-09-01). Consistent findings across all four are
treated as consensus.

## 1. The consensus model (what the data says works)

- **Timeline:** successful devlog-driven launches run 6–18 months of content
  before release. Closer than that → compress, don't skip: make each post a
  single concrete milestone so newcomers can join without backstory.
- **Cadence:** 1 short-form clip/week minimum (TikTok + YouTube Shorts +
  Reels — same clip, reposted), 1 long-form devlog/month (8–15 min),
  2–3 GIF posts/week on X/Bluesky. Consistency beats polish at every stage.
- **What performs:** before/after comparisons, satisfying single mechanics,
  funny bugs, "how I solved X" arcs (problem → solution retains viewers),
  honest process. NOT trailers, NOT logo intros, NOT marketing speak.
- **Conversion path:** short-form = discovery → long-form = trust →
  Discord/mailing list = ownership. One call-to-action per platform.
- **Community:** a small Discord (channels: announcements/devlog/feedback is
  enough) + 60 days of *non-promotional* Reddit participation in target subs
  before ever posting the game.
- **Milestone sanity:** first goal is existence, not size — a three-digit
  Discord and a four-digit follower count is already far beyond the median
  launch (38 installs, we know this one personally).

## 2. Pyregrove's honest angles (what we actually have to show)

The game's true differentiators, all verifiable, all pillar-4-safe:
1. **Original everything** — every sprite, tile, and track is original in a
   store category drowning in asset flips. This is a story, not a bullet.
2. **No ads, no trackers, ever** — analytics off, AD_ID stripped from the
   manifest. Privacy-respecting games are a genuine niche angle in 2026.
3. **Low-end-first engineering** — 60fps-on-a-2GB-phone as a design pillar,
   sub-stepped pacing, ≤22 MB per-device installs. "We made it run on the
   phone you actually have" is relatable content.
4. **The AI-assisted build process itself** — 460+ tests, a bot that
   playtests every level at every difficulty, evidence-graded release
   checklists. Unusual, honest, and highly clippable.

## 3. Ready-to-cut clip bank (mapped to existing captures/tooling)

The web harness + capture scripts already produce broadcast-quality frames;
each item below is recordable today with existing tooling (no game changes):

| # | Clip (15–60s) | Source |
|---|---|---|
| 1 | Grove Golem full fight, no commentary, raw | boss capture flow |
| 2 | "Our bot plays every level so you don't rage-quit" — wipe-probe montage | headless probe runs |
| 3 | Before/after: sign text clipping bug → wrap fix | pre_00 caps + old build |
| 4 | Before/after: slow-motion-on-weak-phones bug → sub-step fix | perf_throttle scenes |
| 5 | Hit-feel stack breakdown: hit-pause + recoil + flash, frame by frame | recoil caps |
| 6 | "Every enemy is hand-pixelled" — 12-enemy roster showcase | harness per-level |
| 7 | Kiln Golem coached route (pillar-perch strategy) | boss scripts |
| 8 | Parallax layers peeled apart (0.15/0.35/0.5/0.7) | harness + layer toggle* |
| 9 | Level speedrun with input overlay (Bramble Hollow) | live-bot replay |
| 10 | "How big is a level?" — full-map pan of w1_l2 (24×73) | scene_cap |
| 11 | Daily Delve concept tease (when/if Phase A ever ships) | — future |
| 12 | Squash/stretch + dust + thud landing feel, 4× slow-mo | feel captures |

*#8 needs a debug toggle — that is code, so it waits for the freeze to lift
or gets cut without the peel.

Long-form arcs already in the repo's history (each = one devlog episode):
the boss TTK disaster and retune; the back-gesture crash; "why we turned
Impeller off"; the sign-wrap root cause; shipping a signed release from CI.

## 4. Division of labour

**Owner-only (cannot be delegated):** account creation (TikTok/YT/X/
Discord/Reddit), posting identity and voice, replying to comments, any
face/voice-over, the decision to start at all.

**Repo/AI side (ready when asked, within whatever directives then apply):**
recording and editing clips from the harness, writing devlog scripts/post
copy, GIF/thumbnail production, maintaining a content calendar, drafting the
press kit (screenshots + feature graphic already exist from alpha.20 store
work).

## 5. Sequencing note

Per LAUNCH-WORTHINESS §5, this playbook only matters if the owner intends to
launch eventually. Starting it costs ~2–4 h/week of owner time. If that time
does not exist, the honest alternative is to keep Pyregrove a portfolio
piece — which is a legitimate outcome and should then be written down as the
launch goal (flip-condition #4), closing the question.
