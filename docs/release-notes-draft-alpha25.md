# v1.0.0-alpha.25 — release notes

Version on `main`: `1.0.0-alpha.25+37`.

## Working title: "World Map"

## Changes since v1.0.0-alpha.24 (224578f)

1. **Level select is a world map, not a settings list (PR #3).** Per-world
   banner with a medal-count chip, 72 px level cards with a tinted world
   thumbnail strip (forest / cave / sunny), Cinzel numerals, ember styling on
   boss levels, and gold medallions for finished / all chests / low damage
   instead of bare Material icons. Strings and keys unchanged, so every
   existing test still holds. Tests: `test/level_select_screens_test.dart`.
2. **Title screen reflow (PR #1).** The menu reflows on narrow phones instead
   of shrinking text; PLAY label is white on green (was purple — low
   contrast); Daily Delve / build labels larger; every control ≥ 48 px;
   honours reduced motion. Tests: `test/title_visual_review_test.dart`.

## Build

1.0.0-alpha.25+37 · 600 tests (2 skips) · analyzer clean.
