# Pyregrove

A crisp **pixel action-platformer** for Android. Fight through a cursed burning forest — slash beasts, loot chests, hunt secret rooms, and gear up in the shop. Apple-Knight-style loop, tighter feel, no ad spam.

**Tsoro Studios** · Flutter + Flame · **PRIVATE repo — the Android upload keystore + passwords are committed here (owner directive 2026-08-31) so any collaborator/AI can build signed releases. Never make this repo public.**

> **🎲 Looking for Emberdelve?** The dice roguelite is **live on Google Play worldwide** —
> [**Emberdelve: Dice Roguelite**](https://play.google.com/store/apps/details?id=com.tsorostudios.emberdelve)
> — its code lives on `legacy/dice-builder` in the old `tapiwamakandigona/emberdelve` repo.
>
> **Lineage:** began 2026-07-24 as an "Emberdelve v2" rewrite → renamed **Emberwood** 2026-08-11 →
> **moved to this repo and renamed Pyregrove** 2026-08-31 (owner-directed), new package
> `com.tsorostudios.pyregrove`, fresh upload keystore (old alpha installs are a different
> package + signer; they coexist, they don't upgrade in place). Prereleases alpha.8–.16
> shipped from the old repo under the Emberwood name.

## Start here (human or AI)
1. `PROJECT.md` — goal, standing decisions, session-start ritual
2. `features.json` — machine-readable definition of done
3. `progress.md` — history; `checkpoints/` — phase gates
4. `flutter pub get && flutter test` — environment up + test suite

## Layout
- `lib/game/` — Flame gameplay: player, enemies, levels, physics, HUD (`docs/architecture.md`)
- `lib/meta/` — economy, shop catalog, progression (pure Dart, headless-tested)
- `lib/ui/` — Flutter meta screens (title, level select, shop, settings)
- `lib/core/` — seeded RNG, atomic save system
- `lib/audio/` — music/SFX service
- `assets/levels/` — ASCII level grids (unit-tested)
- `docs/` — spec + architecture (`docs/spec.md` §7 Ethics is binding); `docs/legacy/` — dice-era docs

## Build
```
flutter pub get
flutter test        # full headless gate (levels, physics, economy, UI smoke)
flutter build apk --release
```
CI builds signed APK/AAB on `main` (see `.github/workflows/ci.yml` — signing config is immutable).

## Licensing
Code: see `LICENSE`. Art/audio: CC0/CC-BY only, cataloged in `PROVENANCE.md`, attribution shipped in-app (`CREDITS.md`).
