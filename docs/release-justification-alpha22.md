# v1.0.0-alpha.22 — update definition & justification

Written 2026-09-02 before tagging, per owner directive 2026-09-02b: "The
'one major update' is what is already merged on `main` since alpha.20 …
Cut it as **one** prerelease `v1.0.0-alpha.22`."

## What this update is

**"The Forgiving Jump"** — everything merged to `main` since `v1.0.0-alpha.21`
(157b9cf → this tag). alpha.21 already shipped the boss-fight overhaul, the
R8/backup rules and the Skia manifest opt-out that the directive lists;
alpha.22 adds the last item on that list and its safety net:

1. **Jump retune per directive 2026-09-01d** (`ec994eb`, `docs/JUMP-PHYSICS.md`)
   — measured in-engine before and after, four constants plus one new
   mechanism. Coyote time 0.10→0.12 s, jump buffer 0.12→0.16 s, apex hang
   speed 40→64, jump-cut multiplier 0.45→0.55, new 4 px ledge-land nudge on
   solid lips. Full-run jump range 3.81→4.12 tiles, tap jump 1.51→1.60 tiles.
   Bots re-coached; wipe-probe baseline deaths unchanged; difficulty probe
   120/120 curve preserved (`7c1ffae`).
2. **Gap-budget gate tightened to what the arc can actually clear**
   (`daf8276`): the level gate allowed 7-tile gaps while the measured
   double-jump range is 6.33 tiles — now 6, with the range pinned in
   `test/jump_arc_test.dart` so any movement nerf fails loud. All shipped
   levels have widestGap = 0, so no level changed.
3. **Hard-landing recovery crouch** (`076bd4e`): cosmetic 25 % / 160 ms squash
   on `landedHard`, pairing with the takeoff stretch shipped in alpha.21.

Everything else since alpha.21 is tests, docs and research (34 commits): the
suite-audit series (4 real test finds, no gameplay change), licensing texts
for the two fonts, claims-audit doc corrections, emulator memory partials.

## Why it is one update

All three code changes are the same idea: the jump the player *meant* is the
jump they get. It is the smallest coherent unit on `main` that the owner has
not yet been able to install.

## What it is not

- No new content, enemies, characters or levels. Branch `update/delvers`
  (unmerged) is not in this build.
- No Android configuration change since alpha.21 — the last Android/gradle
  commit is `89af754` (alpha.21), so the pyregrove-ci mirror's signing path
  is unchanged.
- No store listing edits; not on any Play track.

## Verification plan (directive 2026-09-02b item 2)

1. `flutter analyze` clean + full `flutter test` on the release sha.
2. Tag `v1.0.0-alpha.22` on `main`, push main + tag.
3. `scripts/sync_public_ci.sh v1.0.0-alpha.22` → CI on `pyregrove-ci` builds
   signed APK + AAB, apksigner check against the pin.
4. Download artifacts; androguard: versionName `1.0.0-alpha.22`, versionCode
   `34`, package `com.tsorostudios.pyregrove`, signer
   `286c4760f1801269550fe40658e6255c96107713690d0e4353cbe76bccee8ffd`.
5. GitHub prerelease on the tag with `pyregrove-v1.0.0-alpha.22.apk` / `.aab`
   and both sha256s in the body.
6. Re-download one asset **unauthenticated** and confirm its sha256 matches.
   Only then is it logged as released.
