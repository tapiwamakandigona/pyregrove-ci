# Pyregrove — Google Play listing draft

Draft copy for the Play Console listing (owner to review before submitting —
going to Play at all is an owner call, P-M10). The previous contents of this
file were the dice game's listing (that game ships from the old repository's
`legacy/dice-builder` branch); this draft describes **this** game, the
action platformer, package `com.tsorostudios.pyregrove`.

## App name (30 chars max)

Pyregrove: Pixel Platformer

## Short description (80 chars max)

Run, dash and delve a burning grove. Fair pixel platforming — no ads, ever.

## Full description (4000 chars max)

Delve the burning grove.

Pyregrove is a single-player pixel action platformer built on one promise:
every death is fair. Tight controls (coyote time, jump buffering, a real
air dash), enemies with readable tells, and hazards you can always see
coming — no cheap hits, no hidden timers.

RUN, JUMP, DASH
Double-jump, air-dash and roll through two worlds of handcrafted levels —
sun-dappled woods above, cinder depths below. Movement is the game: fast,
precise, and forgiving where it should be.

FIGHT WITH INTENT
A three-hit melee combo, arcing apple throws, and bosses that telegraph
every move. Learn the fight, find the opening, strike the crown.

MASTER EVERY LEVEL
Three medals per level — finish, treasure, and flawless. Crack hidden walls,
spring secret chests, and chase a perfect-clear bonus on every run.

SPEND YOUR SPOILS
Coins and feathers buy new weapons with real identity — wall-breakers,
igniters, lunging blades — plus skins, spells and abilities in the Ember
Shop. Earned in play, never bought with money.

DELVE DAILY
A date-seeded Daily Delve remixes the grove every day — same seed for
everyone, no streaks, no FOMO, nothing expires.

FAIR BY DESIGN
• Zero ads. Zero in-app purchases.
• No energy timers, no streaks, no expiring content, no dark patterns.
• Offline play; optional anonymous analytics are strictly opt-in and off by
  default. [REVIEW BEFORE SUBMITTING: this bullet matches the shipped code
  (consent-gated telemetry, Firebase collection off by default), but the
  owner directive of 2026-09-01 says "no in-app tracking ever" — if the
  telemetry module is removed when the freeze lifts, replace this bullet
  with "No analytics. No tracking. Nothing leaves your device." Do not ship
  the listing until this matches the build.]
• Deterministic, learnable rules — fair deaths only.

Made for landscape play with thumb-friendly touch controls (and full
keyboard support). Delve in.

## Category / tags

- Category: Games > Action (or Games > Arcade > Platformer)
- Tags: platformer, action, pixel art, offline, single player

## Content rating questionnaire (IARC) — expected answers

- Violence: mild fantasy violence (stylized pixel creatures, no gore) → likely
  Everyone 10+ / PEGI 7
- No user interaction/communication, no purchases
- No gambling

## Data safety form

- **Optional, opt-in analytics only** (off by default): anonymous app
  interactions (level plays/finishes, settings) via Google Firebase
  Analytics; no personal data, no ads identifiers, collection can be
  disabled any time in Settings. Declare "App interactions — optional" in
  the form; everything else: not collected, not shared.
- Privacy policy URL:
  https://tapiwamakandigona.github.io/emberdelve/store/privacy-policy.html
  (GitHub Pages, served from the old public repository's `main:/docs` — the
  page text covers Pyregrove; the markdown source
  `docs/store/privacy-policy.md` in this repo stays the canonical text).

## Still needed (owner-gated)

- [x] 6 landscape screenshots 1920×1080 (`docs/store/screenshots/01..06`,
      captured from the real game via the web harness at alpha.20 — capture
      scripts in `tool/store_shots/`; all screens are genuine gameplay/UI,
      nothing staged outside the engine)
- [x] Feature graphic 1024×500 (`docs/store/feature-graphic-1024x500.png` —
      real title-screen backdrop + the in-app Cinzel wordmark, composed by
      `tool/store_shots/make_feature.py`)
- [x] App icon 512×512 (`docs/store/app-icon-512.png`, exported from
      `assets/icon/app_icon_master_1024.png`)
- [x] Hosted privacy policy URL (see above)
- [ ] Console: content rating questionnaire + data safety form submission
