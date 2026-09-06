# (a) What a 2D action-platformer needs to pass Play's 2027 quality bar before its first listing

Directive 2026-09-02b item 3(a). Pyregrove-scoped. Written 2026-09-02 against
the shipped `pyregrove-v1.0.0-alpha.22.apk` (sha256 `38cbe6d6…8fc3`, prerelease
380982465), read with androguard/zipalign — not from source. Every row names
its source and read date; a cell says `unknown` where no source exists. Tags:
`[SOURCE]` fetched page · `[ARTIFACT]` read from the APK · `[REPO]` read from
this tree · `[INFERENCE]`.

## 0. The one-paragraph answer

For a game with no sign-in, no ads and no purchases, "the 2027 bar" is four
things: (1) the **Feb-2027 memory/bitmap/DEX thresholds** — DEX is met and
measurable now, the two memory metrics can only be measured from Play vitals
after launch, so the pre-listing work is a low-RAM device profile, not a code
change; (2) the **existing core-vitals thresholds** (crash 1.09 %, ANR 0.47 %,
slow sessions at 30/20 FPS) which likewise only exist once players exist;
(3) the **listing-time paperwork** — target API 36, 16 KB pages, Data safety
form, IARC questionnaire, privacy policy URL — all met or ready today; (4) the
**closed-test gate** (12 testers / 14 days) if the account is a post-2023-11-13
personal account. Nothing in the build blocks a listing. What blocks a
*confident* listing is that every field-measured metric is `unknown` until
there is a field.

## 1. Thresholds that are published — and where Pyregrove stands

| # | Requirement | Threshold (verbatim where possible) | Pyregrove alpha.22 | Source (read 2026-09-02) |
|---|---|---|---|---|
| 1 | Target API level | "Starting August 31, 2026: New apps and app updates must target Android 16 (API level 36) or higher" | **MET** — `targetSdkVersion 36`, `minSdk 24` `[ARTIFACT]` | support.google.com/googleplay/android-developer/answer/11926878 `[SOURCE]` |
| 2 | 16 KB page-size support (apps targeting API 35+) | required for new apps and updates on Play since 2025-11-01 | **MET** — `zipalign -c -P 16 -v 4` → "Verification successful" on the shipped APK; ABIs arm64-v8a, armeabi-v7a, x86_64 `[ARTIFACT]` | developer.android.com/guide/practices/page-sizes `[SOURCE]`; prior verification on alpha.20 in docs/research-2026-09.md `[REPO]` |
| 3 | DEX code optimization ≥ 25 % (R8) — Feb 2027 | "a minimum of 25% coverage across optimization, shrinking, and obfuscation" | **MET** — 93.8 % obfuscated classes measured on alpha.21 (docs/PLAY-QUALITY-2027.md row 1); no Android/gradle change since `89af754`, so alpha.22 inherits it `[REPO]` | Android Developers Blog 2026-08 "Elevating app quality…" as cited in PLAY-QUALITY-2027.md `[SOURCE]` |
| 4 | Dynamic memory usage — Feb 2027 | numeric per-RAM-bucket thresholds **unpublished**; games get distinct criteria | **unknown** — no vitals exist pre-launch. Emulator partial: 83–90 MB PSS at title/menus on a 2 GB AVD; gameplay unmeasured (docs/EMULATOR-LIMITS.md) `[REPO]` | owner Play email 2026-08-26 (docs/research/owner-inbox-evidence.md), blog as above `[SOURCE]` |
| 5 | Bitmap memory usage — Feb 2027 | unpublished; violation = bitmaps held in background/cached states | **unknown** — content bound 6.34 MiB RGBA for all 179 bundled PNGs `[REPO]`; Flutter image-cache accounting undocumented | Android vitals bitmap page as cited in PLAY-QUALITY-2027.md `[SOURCE]` |
| 6 | User-perceived crash rate | "At least 1.09% of daily users experience a user-perceived crash" = bad behavior; per-device 8 % | **unknown** (no field data). Repo-side: crash guard exists only on the unmerged branch; main has none `[REPO]` | support.google.com/googleplay/android-developer/answer/9844486 `[SOURCE]` |
| 7 | User-perceived ANR rate | "At least 0.47% of daily active users experience a user-perceived ANR" | **unknown** (no field data) | same page `[SOURCE]` |
| 8 | Slow sessions (games only) | "percentage of daily sessions where users experienced more than 25% of frames running slower than either 30 FPS or 20 FPS … Most games on Google Play should aim for 30 FPS or higher" | **unknown** in the field. Repo-side: fixed-step sim holds true game speed down to ~15 fps (alpha.21 notes); Skia renderer chosen over Impeller for low-end GPUs (manifest comment, `[REPO]`) | same page `[SOURCE]` |
| 9 | Slow cold start | "Slow cold start: 5 seconds or more" | **unknown** on device; web harness cold start to gameplay is two taps (docs/research on branch, not merged) — not a device number | same page `[SOURCE]` |
| 10 | Backup / device-migration data carry-over | declared `allowBackup`, `dataExtractionRules`, `fullBackupContent` | **MET (declared)**, end-to-end untested — needs two phones (PLAY-QUALITY-2027.md rows 5–6) `[REPO]` | blog (Zero-Tap Sign-In: "games are currently exempt") as cited `[SOURCE]` |

## 2. Listing-time paperwork (not thresholds, but a first listing fails without them)

| Item | Rule | Pyregrove | Source |
|---|---|---|---|
| Data safety form | "All developers must declare how they collect and handle user data" | **Ready but needs an owner decision**: the APK bundles `firebase_analytics` (properties files present `[ARTIFACT]`), collection disabled by manifest and opt-in-only via consent dialog `[REPO]`. The form must either declare optional analytics collection honestly, or the SDK is removed to match "no analytics" in DEMAND.md. Already flagged in `b351235`. | support.google.com/googleplay/android-developer/answer/10787469 `[SOURCE]` |
| Content rating (IARC) | questionnaire per app, mandatory before publish | not started (no Console entry); expected outcome for stylised pixel violence, no blood, no chat: low tier — `[INFERENCE]`, the questionnaire decides | support.google.com/googleplay/android-developer/answer/9859655 `[SOURCE]` |
| Privacy policy URL | required for every listing | **MET** — live URL covers all Tsoro Studios games (directive 2026-09-01e) `[REPO]` | DEMAND.md 2026-09-01e |
| Closed-test gate | "personal accounts created after November 13, 2023, must run a closed test … minimum of 12 testers … opted in continuously for at least 14 days" | **Binds or is the recommended first step anyway** — docs/CLOSED-TRACK-GATE.md; account creation date is the one fact to confirm at flip time `[REPO]` | support.google.com/googleplay/android-developer/answer/14151465 `[SOURCE]` |
| Permissions hygiene | least privilege | APK requests INTERNET, ACCESS_NETWORK_STATE, WAKE_LOCK, VIBRATE + the Firebase install-referrer bind `[ARTIFACT]`. INTERNET/NETWORK_STATE exist only for the opt-in analytics path; if the SDK goes, they can go. AD_ID is force-removed in the manifest `[REPO]` | `[ARTIFACT]` |

## 3. What the genre adds on top of the platform rules

Play's rules are genre-blind; a 2D action-platformer is exposed on three of
them specifically `[INFERENCE from the rows above]`:

1. **Slow sessions** is *the* metric for this genre — a platformer at 20 fps
   is unplayable in a way a card game is not. Pyregrove's protections
   (fixed-step simulation, Skia, 16 px tiles, SpriteBatch) are in the build;
   the number that matters is field P75 frame rate and it cannot be known
   before launch. The pre-listing proxy is a real low-end device run
   (docs/DEVICE-TEST-PROTOCOL.md) — still blocked on hardware (P-M7).
2. **Memory in gameplay, not menus.** The only measured PSS is title/menus.
   Gameplay adds tilemap, enemy sprites, particles and the music decoder;
   content-side bound says ≤ ~15 MiB on top, engine overhead unknown.
3. **Cold start** — a platformer's first impression is the first jump, and
   Play measures time-to-first-frame. Nothing in the build is known to be
   slow; nothing is measured on a phone either.

## 4. Pre-listing checklist that follows (owner decides order; none started)

1. Owner decision on `firebase_analytics`: keep (declare in Data safety) or
   remove (matches "no analytics" and drops INTERNET). This is the only
   *code* item and it is a removal, not a feature.
2. One physical low-end device (≤ 3 GB RAM, Adreno 5xx/6xx or Mali-G5x
   class) run per docs/DEVICE-TEST-PROTOCOL.md: `dumpsys meminfo` in
   gameplay, `dumpsys gfxinfo` frame histogram, cold-start stopwatch. Moves
   rows 4, 8, 9 from `unknown` to a measured proxy.
3. Confirm the Play account's creation date → closed-test path fixed.
4. IARC questionnaire and Data safety form drafted offline from the
   artifact facts above, so listing day is paste-in.
5. Two-device backup/restore test if two phones ever coexist (row 10).

"Pass" in 2027 terms is therefore not a build state; it is a build state
**plus 28 days of field data below three thresholds**. Pyregrove can enter
that window today; it cannot exit it before it enters.
