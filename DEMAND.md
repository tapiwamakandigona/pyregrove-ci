# DEMAND — Pyregrove (`main`, the v2 action-platformer; formerly Emberwood)

What "good" means for every Gauntlet session on this branch. Edited only when
standards genuinely change. Never contains diagnosis of the current build —
that lives in progress.md.

## Owner directive 2026-09-01 — one major update, ONE GitHub prerelease, then research

Same instruction as emberdelve, scaled to where pyregrove actually is.

- **AUTHORISED: exactly ONE GitHub prerelease** after the next major update.
  Tag `v1.0.0-alpha.21`. Not a series — one. The last three alphas (18, 19, 20)
  landed inside a single hour on 2026-08-31; that pattern does not return.
- **STILL FROZEN: Google Play.** `com.tsorostudios.pyregrove` is not on Play and
  is not going on Play without an owner call.
- Keep syncing config changes into `pyregrove-ci`. Firebase is settled: the app
  is registered as `1:598659800964:android:10bf75455070410d1047d1` in project
  `gen-lang-client-0980262477`. **Do not regenerate `google-services.json`.**

### Scope

One cohesive update, chosen and justified in writing before you build it. Then
tag, then stop.

### Then research

After the prerelease, no new features. Produce written artifacts in `docs/`:

1. **Sharpen `docs/PLAY-QUALITY-2027.md` into a checklist with evidence.** Every
   line should be either verified-met, verified-unmet, or explicitly unknown —
   no line should be an assumption wearing a checkmark.
2. **What does pyregrove have to be, to be worth a launch?** Emberdelve is the
   honest cautionary tale here: 38 installs, 2 ratings, USD 4.25 lifetime. A
   good build is not a business. Research what actually drives discovery in this
   category and write the case for or against launching at all — including the
   case against. A well-argued "not yet, and here is what would change that" is
   a more useful deliverable than a launch plan nobody can execute.
3. **Registration reminder, not urgent:** Android developer verification is
   satisfied for everything currently shipping (emberdelve is registered with 3
   keys). pyregrove needs registering **only if and when it is distributed** —
   on Play or anywhere off-Play. Note it in the launch checklist; do not action
   it now.

## Owner directive 2026-08-31 — RELEASE FREEZE (read this first)

**Stop cutting public releases.** No new git tags, no GitHub releases, no Play
Store submissions, no store-listing edits. This supersedes the earlier
"one improvement per release, version bump per release" rule, which is what
produced the churn described below.

The freeze is on **publishing**, not on work. Keep building, keep merging, keep
the suite green. Accumulate changes.

Why: this repo cut 177 releases, several within minutes of each other, and
release notes were being published before binaries were attached. The "Direct
APK" button on tapiwa.me/emberdelve points at `/releases/latest`, so during
those gaps visitors landed on a release with nothing to download. Verified
2026-08-31: `v0.176.0` (19:31:39Z) and `v0.177.0` (19:44:55Z) were both
published with **zero assets**, and v0.176.0 was superseded 13 minutes later.

The next public release will be a **single consolidated release**, cut by the
owner together with his operations agent, published to GitHub and Google Play
together. When that happens the existing standards still apply: tag at the
release sha, signed APK+AAB from CI (`workflow_dispatch` on the ship branch),
sha256s in the notes, plain player-facing notes plus a short technical section,
and the signer cert must match the pin already recorded in this file.

If you believe something genuinely must ship immediately — a crash, data loss,
or a security issue — **do not cut the release yourself.** Write it at the top
of `progress.md`, state the severity and the evidence, and stop.

## Where to spend effort during the freeze (owner-set, 2026-08-31)

Ranked. Do these instead of releasing.

1. **Per-device download size.** Product pillar 3 requires < 30 MB. The current
   split APKs measure 33-37 MB, so the branch is out of compliance with its own
   standard. Measure per-ABI, find what is actually large, and reduce it.
2. **Google Play quality requirements, enforced February 2027.** Google now
   requires DEX optimization of at least 25% coverage across optimization,
   shrinking and obfuscation via R8, plus thresholds on memory (anonymous RSS
   + swap) and bitmap memory, plus a secure device-migration standard.
   - Emberdelve already sets `isMinifyEnabled` and `isShrinkResources` (commit
     `8f756dd8`).
   - **Pyregrove sets neither, so R8 is off and it fails the DEX item.** Fix it,
     but do not flip the flag blind: reflection-heavy plugins break *only* in
     minified release builds. Copy the keep rules from emberdelve's
     `android/app/proguard-rules.pro`, then build a release APK and launch it.
   - Neither app declares `allowBackup`, `dataExtractionRules` or
     `fullBackupContent`. Full detail and exact patches:
     `docs/PLAY-QUALITY-2027.md` in the pyregrove repo.
   - **Do not change what is included in backup for paid-entitlement state
     without the owner's sign-off** — it decides whether a purchase survives a
     phone upgrade, so it is a monetization decision, not a technical one.
3. **Do not regenerate `android/app/google-services.json`.** It was corrected on
   2026-08-31; before that, both client blocks carried the wrong app id and
   analytics were attributed to the wrong app. Any Android config change must
   land in **both** `pyregrove` and the public CI mirror `pyregrove-ci` — a fix
   in one alone does nothing.
4. **Do not regress the in-app review charter.** One ask ever, stamped on
   request, sticky across cloud merge, never during the tour, no incentives, no
   pre-filtering by sentiment, official API only.
5. Keep the full test suite green and `flutter analyze` clean. No skipped tests.

## Product pillars

1. **Tighter, fairer Apple Knight.** Run / double-jump / dash, 3-hit melee,
   apple throw, coins/feathers/chests/secrets, 3-medal mastery loop, meta
   shop. Better game-feel than AK (coyote time, buffers, hit-pause), none of
   its dark patterns. Banned forever: energy timers, decaying streaks,
   FOMO-expiring content, loss-framed notifications, pay-to-win,
   interstitial ads.
2. **Headless-testable engine.** `lib/game/` logic (level parsing, physics
   resolution, economy, saves) has zero rendering dependencies and is covered
   by `flutter test`. Determinism where it matters via seeded RNG. Tuning
   constants live in `lib/game/tuning.dart`, never inlined.
3. **Performance before spectacle.** 60 fps in `--release` on a 2 GB Android;
   zero allocations in `update()` hot paths; pooled projectiles/particles;
   APK ≤ 60 MB. Perf claims are measured (bench harness / traces), not felt.
4. **Honest presentation.** A stranger looking at any screen for 3 seconds
   should never call it fake, empty, or confusing. Store copy, HUD counters,
   and results screens state facts.
5. **Original assets only.** CC0/CC-BY with in-app attribution
   (PROVENANCE.md + CREDITS.md); nothing that forbids redistribution; no
   traced/ripped art.

## Release standards

- Ship improvements as GitHub prereleases cut from `main`: version bump per
  release (`1.0.0-alpha.N+code`, patch cadence one improvement at a time),
  tag at the release sha, signed APK+AAB from CI (workflow_dispatch), sha256s
  in the notes, player-facing notes + short technical section.
- Package id `com.tsorostudios.pyregrove`. NOT on any Play track yet; going
  to Play is an owner call (P-M10). Never submit to Play without an explicit
  owner instruction.
- Signer: the committed upload keystore (`android/signing/`); CI pin
  `EXPECTED_CERT_SHA256`
  (286c4760f1801269550fe40658e6255c96107713690d0e4353cbe76bccee8ffd) never
  changes. Never regenerate keys. (Old Emberwood alphas .8–.16 used
  031acb42…d44b7a0d — history only, see docs/release.md.)
- If GitHub auth is down, keep the train moving locally: gates green, version
  bumped, notes written, progress.md entry appended, commit made — tag/CI/
  release published as soon as auth returns.

## Quality gates (all VERIFIED, evidence in progress.md)

- `flutter analyze` clean; full test suite green; no skipped tests.
- New behavior has tests; a bug fix has a regression test that fails on the
  old code.
- Gameplay/UI changes: web-harness look pass (build `lib/main_webtest.dart`,
  landscape-phone ~915×412 AND desktop viewports, spawn + mid-level shots,
  close and wide) — actually LOOK at the shots and log what a stranger would
  flag. Overflow sweep for Flutter UI screens at small phone + 1.3× text.
- Physics/feel changes: telemetry-driven browser verification (assert on
  `window.__pyregrove`, not pixels); reachability/jump-height contracts in
  tests stay green.
- progress.md is append-only and written as you go; open issues carry
  forward verbatim until actually fixed.
