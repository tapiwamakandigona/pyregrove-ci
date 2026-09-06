# v1.0.0-alpha.24 — release notes

**Status: RELEASED 2026-09-05 — https://github.com/tapiwamakandigona/pyregrove/releases/tag/v1.0.0-alpha.24. Further edits belong to alpha.25.**
Version on `main`: `1.0.0-alpha.24+36`.

## Working title: "Neighbours"

## Changes since v1.0.0-alpha.23 (11ea8a5)

1. **More from Tsoro Studios (Settings).** One quiet row at the bottom of
   Settings, under Reset save, listing the studio's other games with a
   one-line hook and a button. Today: Emberdelve (Play) and Fliptide (itch.io
   until its Play listing is public). Android tries `market://…` with an
   install-referrer first and falls back to https; web opens a new tab. No
   badge, no modal, never auto-opens, no telemetry. New dependency
   `url_launcher`; manifest `<queries>` for VIEW market:// and https://.
   Tests: `test/more_games_test.dart`.
2. **Coin flights release their slot when interrupted (PR #2).** Leaving a
   level mid-effect (or the game widget being removed) used to leak
   concurrent-flight capacity, so later chains "just counted" without the
   coin animation. Queued and mounted flights are now tracked per owner and
   cancelled on game removal; the global count is never reset blindly.
   Tests: `test/coin_fly_lifecycle_test.dart`.

## Build

1.0.0-alpha.24+36 · 594 tests (1 manual-probe skip) · analyzer clean.
