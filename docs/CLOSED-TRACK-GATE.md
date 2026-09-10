# Verdict: the closed testing track is either MANDATORY (if the Play account is a personal account created after 2023-11-13) or the receipts-recommended first step anyway — both branches lead to the same sequence, so no decision hangs on the unknown. One fact to confirm at flip time: the account's creation date.

Written 2026-09-01. Research question: does Google still gate production
access behind a mandatory closed test for new personal developer accounts —
and does it apply to us? Sources: Google Play Console Help, "App testing
requirements for new personal developer accounts"
(support.google.com/googleplay/android-developer/answer/14151465, read
2026-09-01); primetestlab.com 2026-04-03 (rule history); testmyapps.app
2026-07-16 (application process).

## 1. The rule, verified against Google's own help center (2026-09-01)

- Personal developer accounts **created after November 13, 2023** must run a
  **closed test with ≥12 testers opted in continuously for the preceding 14
  days** before they can apply for production access — per app.
- Until that is met, **Production AND Pre-registration are disabled** in
  Play Console for the app.
- Meeting the threshold unlocks an *application*, not automatic access:
  Google asks questions about the app, the testing process, and readiness.
- History: announced Nov 2023 at 20 testers; **reduced 20 → 12 on
  2024-12-11** [primetestlab 2026-04-03]. Still in force as of 2026.
- Organization accounts and accounts that already hold production access for
  the app in question follow different paths.

## 2. Does it bind Pyregrove?

**Unknown — depends on the owner's Play account creation date**, which is not
knowable from inside the repo. Two branches:

- **Account created after 2023-11-13**: the gate binds. Pyregrove (a new app
  on the account) cannot reach production — or even pre-registration — until
  a 12-tester/14-day closed test passes. The fact that Emberdelve is in
  production on the same account means either the account predates the
  cutoff or Emberdelve itself already cleared this gate once.
- **Account predates 2023-11-13**: the gate does not bind; closed testing
  stays optional.

## 3. Why the answer doesn't change the plan (the decision-collapsing part)

The launch sequence is identical in both branches:

1. LAUNCH-WORTHINESS.md flip condition #3 already names a closed track with
   ≥12 external testers / ≥14 days of clean vitals as the retention proxy —
   the same numbers Google mandates. If Google forces it, we were doing it
   anyway; if Google doesn't, the receipts say do it anyway.
2. CHANNEL-RECEIPTS.md's one Play-native tactic with a receipt —
   **pre-registration** — is itself locked behind this gate for affected
   accounts. So even the distribution tactic requires the closed test first
   on the affected branch.
3. Therefore: **no owner question needs asking now** (asking would violate
   the freeze's spirit for zero decision value). At flip time, the first
   checklist item is "confirm account creation date in Play Console"; it
   determines paperwork, not path.

## 4. What would change this verdict

- Google raising/lowering the tester bar again (it moved once, 20→12) —
  re-verify against answer/14151465 at flip time, not from this file.
- Google extending the requirement to pre-2023 accounts (no sign of this).
- The owner using an organization account (different rules entirely).
