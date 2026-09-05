# (c) Is Pyregrove a Play release or a free itch.io title? — both sides, one page

Directive 2026-09-02b item 3(c). Written 2026-09-02. **The owner decides.**
This note argues each side as strongly as the evidence allows and then names
the facts that would settle it. Sources read 2026-09-02 unless noted;
`[REPO]` = this tree; `[RECEIPTS]` = docs/CHANNEL-RECEIPTS.md (third-party
postmortems, magnitudes only). No Emberdelve numbers are used as evidence
here; where the other game is mentioned it is as a precedent the owner already
knows, not as data.

## The facts both sides share

- Pyregrove is a finished 12-level premium-style game with no ads, no IAP, no
  analytics collection by default, one upload key, one prerelease pipeline
  that works (alpha.22, 2026-09-02) `[REPO]`.
- Play: US$25 one-time registration (support.google.com/…/answer/6112435);
  service fee 15 % on the first US$1M for developers enrolled in the
  reduced-fee tier (…/answer/112622); new personal accounts must run a
  12-tester / 14-day closed test before production (…/answer/14151465);
  Feb-2027 quality thresholds apply from listing day (note (a)).
- itch.io: "costs nothing to use … Advertisements will never be placed on
  any of your pages … open revenue sharing" — the creator picks the platform
  cut, including 0 % (itch.io/docs/creators/faq); pricing is "pay what you
  want" or a minimum (…/pricing). Android builds ship as an APK the player
  sideloads after enabling unknown sources; there is no itch app install
  path on Android (itch.io community thread 2022-03-17, player-reported).
- Cold launches with no audience land in the tens of installs on **either**
  store — the receipts table has Play at 11 installs / 78 store views for a
  2022 free indie whose itch page was its best performer `[RECEIPTS]`.

## The case for Play

1. **It is the only store the target player already has.** A sideloaded
   APK requires a settings change that Android warns against; a Play listing
   is one tap. For a game aimed at "people who do not hold a flagship phone"
   (owner-inbox-evidence.md), the install friction difference is the whole
   audience.
2. **Play is where the quality work pays.** Every verified row in note (a) —
   target API 36, 16 KB pages, R8 coverage, backup rules, the signer pin —
   is Play compliance. On itch.io none of it is checked or rewarded.
3. **Play generates the only field data the project can ethically get.**
   The repo forbids in-app tracking; Play vitals (crash, ANR, slow sessions,
   memory from 2027) are collected by the platform, not the app, and are the
   only way rows 4–9 of note (a) ever leave `unknown`. itch.io gives download
   counts and nothing about play.
4. **The closed-test requirement is a feature here, not a cost.** It forces
   the 12-tester / 14-day playtest that flip condition 3 in
   LAUNCH-WORTHINESS.md already demands, and Console reports the retention
   for free.
5. **A Play listing is the portfolio artefact.** If the owner's success
   sentence (flip condition 5) is "published, installs irrelevant", Play is
   the line on a CV that itch.io is not.

## The case for free on itch.io

1. **It matches what the game is.** No IAP, no ads, no accounts, no
   telemetry — a *free* Pyregrove has zero tension with the DEMAND.md rules,
   and the Data-safety / analytics-SDK question in note (a) §2 dissolves
   (the SDK can simply be removed).
2. **Zero fixed cost, zero compliance clock.** No US$25, no IARC
   questionnaire, no Feb-2027 thresholds, no closed-test gate, no vitals to
   fall below. A Play listing that trips a 2027 threshold gets "reduced
   visibility"; an itch page cannot be demoted.
3. **The cold-launch outcome is the same on both stores, so pay nothing for
   it.** Every no-audience receipt lands in the tens `[RECEIPTS]`. If flip
   conditions 1–2 (channel receipt, pre-built audience) are not met, Play's
   distribution advantage is theoretical: nobody searches for a game they
   have never heard of.
4. **itch.io is the indie-audience channel.** The people who sideload APKs
   from itch are the people who watch devlogs, leave comments and post
   clips — the audience flip condition 2 needs *before* a Play launch. A
   free itch build is audience-building; a Play listing is audience-
   spending.
5. **It preserves the option.** Nothing about an itch release prevents a
   later Play release with the same signing key; the reverse — pulling a
   Play listing — reads as failure.

## What would settle it (facts, not opinions)

| Fact | If true → | Status |
|---|---|---|
| Owner's one-sentence success goal names installs/revenue | Play (only store that can deliver volume) | unwritten (flip cond. 5) |
| Owner's goal names "portfolio / shipped credit" | Play | unwritten |
| Owner's goal names "learn what players do / build audience" | itch first | unwritten |
| Any owned channel with ≥1,000-view Pyregrove posts exists | Play becomes viable | none yet (flip cond. 2) |
| Owner wants to keep `firebase_analytics` opt-in in the build | Play (needs the Data-safety declaration anyway) | owner decision pending (`b351235`) |
| Owner is fine removing it | either; itch simpler | — |
| Play account creation date after 2023-11-13 | Play adds a 14-day closed test (cost or feature, see above) | unknown — one Console look |

## The sequencing option neither side owns

The two are not exclusive. "Free itch.io build now → closed Play test when 12
people exist who want in → Play production when flip conditions 1–3 are
checked" uses itch to build exactly the audience Play needs, and costs the
US$25 only when there is a reason to spend it. The argument against it is
honest too: two release surfaces are two sets of pages, two sets of update
posts, and a game that looks "already out" when it finally hits Play.

The owner decides. Nothing in this note is actioned; no listing exists on
either store today.
