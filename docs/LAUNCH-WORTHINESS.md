# Verdict: do NOT launch Pyregrove — not now, and not until every flip condition in §4 is checked off with evidence. Launching today predictably repeats Emberdelve: ~38 installs, ~$4, and a burned cold-start window.

Rewritten 2026-09-01 per owner directive 2026-09-01b (DEMAND.md 4677607a):
verdict first, the case against launching as the stronger half, flip
conditions phrased so they can be checked off. Play distribution remains
frozen and an owner call regardless of this document. Market numbers are
third-party estimates unless marked; trust magnitudes, not precise values.

## 1. The case against launching (this is the load-bearing half)

### 1a. We already ran this experiment, and quality was not the variable

Emberdelve Classic launched working, polished, signed, and tested — 1,136
tests, verified signing — and got **38 lifetime installs, 2 ratings, USD 4.25**
[owner, DEMAND.md, 2026-09-01]. Nothing in the build caused that. The inputs
that were missing were an audience, a discovery plan, and a reason to reopen
the app on day 8. Pyregrove today has the same missing inputs with better
assets.

**The differ test (apply to any future launch plan):** name the input that is
different from Emberdelve 2026. "The game is better" fails the test — game
quality was already above the bar last time and contributed ~nothing to
distribution. Only a changed *distribution* input (audience, channel with
receipts, retention loop) passes.

### 1b. The market's default outcome is zero, and the algorithm punishes bad launches

- Median Play app: ~305 lifetime downloads; >⅓ never reach 100
  [testerscommunity.com, 2026-08-28]. Cold organic launch, no community:
  **30–150 installs in month one** [extensionbooster.net, 2026-05-18].
  Emberdelve's 38 was the median outcome, not bad luck.
- Ranking weight sits on install velocity, D1/D7/D30 retention, ratings
  (~25–30%), and vitals; **7-day uninstall rate is the heaviest negative**
  [vmobify.com 2026-05-24; asoagency.io 2026-06-12]. A launch that strangers
  try once and delete actively buries the listing for weeks. A bad launch is
  strictly worse than no launch, and each package name gets one cold-start
  window.
- The category winner's economics cap the upside: Apple Knight, 5M+ installs,
  4.7★, #1 for the keyword — estimated **<$10K/month, 72% ads**
  [appgoblin.info/bumetric.com, read 2026-09-01]. A no-ads entrant (our
  pillar) cannot expect meaningful revenue here even in the best case.
  Revenue is not an available launch goal; only players, craft, or portfolio.

### 1c. What we cannot know from here (recorded as unanswerable, per directive)

- Real D1/D7/D30 retention of the public build **cannot be measured without
  adding tracking to the app. We will not add it. Unanswerable.** The
  closest honest proxies are Play Console's own closed-testing metrics
  (owner-visible, no in-app tracking) and hand-run playtests (§4.3).
- Whether pillar 3 (60fps on 2GB) holds on real hardware is **unknown** until
  a device exists (docs/DEVICE-TEST-PROTOCOL.md). Launching before knowing
  means discovering vitals failures in public, where they do algorithmic harm.

## 2. The case for launching now (steelman, then why it loses)

- Real vitals and stranger-device data only exist post-launch; ratings age
  and keyword indexing compound from day one; the game is honest and free,
  so downside is only reputational — and there is no reputation yet.

Why it loses: "quiet launch for telemetry" and "launch that seeds durable
ranking" are mutually exclusive — the quiet launch's uninstall history
poisons the listing the loud launch would later need. Telemetry has a safer
container: a closed testing track is not a public launch, gets Play vitals,
and does not spend the cold-start window. Every argument for launching now is
actually an argument for a testing track later.

## 3. What Pyregrove verifiably is (kept short; quality is not the question)

Strengths (verified in repo/APK): 462-test suite; crash-guarded lifecycle;
per-ABI installs 18.6–21.6MB; no ads, no trackers, AD_ID removed; 100%
original assets; reproducible signed releases. Gaps (verified): ~1–2h of
content with nothing to reopen on day 8; zero audience; zero revenue model by
design; zero real-device evidence. The strengths are table stakes that
Emberdelve also had. The gaps are the exact inputs that decided Emberdelve's
outcome.

## 4. Flip conditions — each phrased to be checked off

Launch becomes worth discussing only when ALL of these are true:

1. **Channel receipt exists.** We can name ≥1 comparable no-budget indie
   platformer whose documented launch (devlog/postmortem with numbers) got
   **≥1,000 first-month installs via a channel the owner can actually
   execute**, and we can point at the receipt. If no such receipt can be
   found, that is itself the answer.
2. **Audience exists before launch day, with numbers.** In the 60 days before
   any launch decision: ≥3 Pyregrove posts with ≥1,000 organic views each on
   a channel we operate, AND ≥200 people in an owned space (Discord/mailing
   list) — per docs/AUDIENCE-PLAYBOOK.md. Owner-effort, not code.
3. **Retention proxy is green without in-app tracking.** Closed testing
   track: ≥12 external testers over ≥14 days with Play-Console-reported
   retention/vitals clean; or hand-run: ≥5 of 10 external playtesters start
   an unprompted second session within 72h. (Public-build D30 stays
   unanswerable, §1c.)
4. **One filled Class A row** in docs/DEVICE-TEST-PROTOCOL.md §6 (2GB-class
   device): janky <10%, p95 ≤22ms, memory within bar, wake-lock clean.
5. **The launch goal is one owner-written sentence with a number in it**
   (e.g. "success = N installs in 90 days" or "success = portfolio piece
   published, installs irrelevant"), so the outcome can be judged.

"Polish", "more content", and "World 3" are deliberately NOT flip
conditions: Emberdelve proves shipping quality does not move installs, and
content depth only matters after conditions 1–3 give anyone a reason to
arrive.

## 5. Owner-gated checklist (nothing here is actioned)

- [ ] Android developer verification/registration — **needed only if and when
      Pyregrove is actually distributed. Noted per DEMAND.md 2026-09-01b; do
      not action.**
- [ ] Owner decision: closed testing track first (recommended, §2) vs
      production.
- [ ] Play Console entry + data safety + content rating (listing draft in
      docs/store/play-listing.md; assets shipped in alpha.20).
- [ ] §4 conditions 1–5 checked off with evidence links.
- [ ] Re-check docs/PLAY-QUALITY-2027.md items 3/4/7 when Google publishes
      numeric thresholds (before Feb 2027 enforcement).

The honest exit remains available at any time: declare Pyregrove a finished
portfolio piece, publish the devlog retrospective, and never launch. That
satisfies condition 5 with "installs irrelevant" and is a legitimate outcome,
not a failure.
