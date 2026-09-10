# Audio polish backlog — researched critique of the current sound stack

Written 2026-09-01 under the post-alpha.21 freeze. **Nothing here is
implemented**; companion to FEEL-POLISH-BACKLOG.md. Sources read
2026-09-01: Winifred Phillips GDC 2021 series (vertical layering /
horizontal resequencing, gamedeveloper.com); Krotos indie SFX workflow
guides; SonusGearFlow layering workflow (transient/body/detail/tail,
frequency separation, mono compat); Lena Raine Celeste interview; Chris
Larkin Hollow Knight interview. Code facts verified by reading
lib/audio/audio_service.dart at b73a3faa; loudness measured locally with
ffmpeg ebur128/astats on the shipped assets (commands in §D).

## A. What we already have (VERIFIED — don't re-add)

| Technique | Where | Notes |
|---|---|---|
| Per-family music beds + dedupe (no mid-phrase restarts) | playMusic | title/map/combat/cave_combat/boss_combat + victory/defeat stings |
| Fade-out on music switch (timer per faded player) | _fadeOutAndDispose | orphan-safe on rapid switches |
| Ambience bed (ember crackle ×0.35 under title/rest) | setAmbience | |
| **Danger heartbeat bed at low HP** | setDanger | this IS vertical layering, first layer already proven |
| Low-latency SoundPool voices, 2 per id, source set once | playSfx | the 2026-07-25 stutter fix — load-bearing, keep |
| Pitch wobble 0.94–1.06 on high-repeat SFX | sfxRateFor | unit-tested |
| Round-robin samples: steps ×2, swings ×3 (combo-mapped) | sfxPaths | |
| mixWithOthers focus config (settings-tap kills music, fixed) | initPlatformAudio | |
| Lifecycle pauseAll/resumeAll; live settings push | | Play-review relevant |

Honest assessment: the *engine plumbing* is in genuinely good shape (the
danger bed proves the layering pattern end-to-end). The gaps are craft-level:
transitions are asymmetric, the mix never reacts to big moments, and the
most-repeated one-shots rely on pitch wobble alone.

## B. Measured mix state (2026-09-01, shipped assets)

Music, integrated LUFS: boss_combat −21.3 · map −21.4 · victory −21.6 ·
combat −21.8 · defeat −23.1 · **cave_combat −23.3** · title −23.9.
Spread 2.6 LU. Norm: beds within ~1 LU. Finding: **W2's bed is ~1.5 LU
quieter than W1's** — W2 reads as flatter for a mixing reason, not a
composition one. title/defeat being quieter is fine (rest states).

SFX peaks (dBFS): hottest boss_death −0.8, land −1.3, enemy_hit −2.0,
swings −1.4..−4.5; quietest repeaters coin −13.9 (peak) and steps −9.2..−9.8
(RMS ≈ −30, correct for something firing every 0.26 s). No clipping
anywhere; hierarchy (movement quiet → combat mid → rare events hot) is
broadly right. Sub-400 ms files gate to −70 LUFS under ebur128 — use
astats peak/RMS for one-shots, ebur128 only for music/loops.

## C. Backlog — prioritized

### C1. Symmetric crossfade (music fade-IN) — DONE 2026-09-02 (music_mix.dart kMusicFadeInTime 0.4 s; loops only, stings hit at full volume)
VERIFIED gap: old track fades out over ~0.4 s, but the new one starts at
full volume instantly — every music change front-loads a hard edge.
Mirror _fadeOutAndDispose with a ramp-in on the new player (~8 lines).

### C2. Re-level cave_combat +1.5 LU — DONE 2026-09-02 (ffmpeg volume=1.5dB re-export, q5: −23.3 → −21.8 LUFS = combat.ogg exactly; phoneRms −26.0 → −24.4 dB (bed ceiling −24.0 — do not push further); peak −5.8 dBFS; duration unchanged 49.5625 s so the loop point holds. Note: re-encoded from the shipped ogg because the CC0 source mp3 is not in the repo — one extra lossy generation at q5; tool/build_music_v3.py remains the from-source recipe.)
Bring W2's bed within 1 LU of combat.ogg (`ffmpeg -af volume=1.5dB`
re-export, then re-measure). No code. Cheapest real improvement here.

### C3. Music ducking on heavy moments — DONE 2026-09-02 (AudioService.duckMusic(): floor 0.5×, d² ease-out over 0.35 s; wired to player hurt, boss phase, boss defeated — not coins/swings)
The mix never reacts. Duck _music to ~0.5× for ~0.35 s with an eased
recovery on: player_hit, boss_death, boss phase-change, victory-sting
handoff. One timer on _music volume (~15 lines), pattern already exists
in _fadeOutAndDispose. Do NOT duck for coins/swings (constant pumping).

### C4. Sample round-robins for coin + enemy_hit — DONE 2026-09-02 (coin_b/c, enemy_hit_b/c from tool/build_sfx_variants.py: EQ tilt + rate + envelope, phone-band RMS matched to the source within 1.1 dB; lib/audio/round_robin.dart never repeats the last variant; tests in round_robin_test; mix report updated; +23 KB assets; CREDITS unchanged — same CC0 sources)
The two most-fired one-shots have ONE sample each; wobble alone can't
hide that (research: repetition needs sample variation first, pitch
second). Generate 2–3 variants each with tool/build_platformer_sfx.py,
extend sfxPaths + a tiny pick-random in playSfx. Steps/swings already
comply.

### C5. Boss intensity layer — DONE 2026-09-02 ('Wrath Rising', assets/audio/sfx/boss_layer.ogg from tool/build_boss_layer.py: original synthesis with the score's kit — ember-wind tremolo noise, free taiko rolls, faint D rumble; tempo/chord-agnostic on purpose because a second player cannot be beat-aligned; 5.8 s seamless, 56 KB, phoneRms −31.0 dB, above500 0.59. AudioService.setBossLayer() mirrors setDanger; ember_game drives it from bossLayerWanted(): phase ≥2, boss alive, level not over. Test in music_mix_test. On-device listen NOT done.)
Add a percussion/texture loop over boss_combat when bossPhase ≥ 2 —
setDanger is the exact plumbing pattern (own player, relative volume,
failed-start-frees-slot). One new asset + ~20 lines. This is the
Sackboy/Spyder technique at minimum viable scale.

### C6. Danger bed scales with peril — DONE 2026-09-02 (dangerLevel(): 0.5 at one heart (the old constant), up to 0.8 as hearts approach 0; pushed live via setDanger(level:))
setDanger is binary. Scale volume (and optionally rate 1.0→1.15) as
hearts drop 2→1→half. ~6 lines, no assets.

### C7. CHECK: victory/defeat double-trigger — CHECKED 2026-09-02: only playMusic('victory'/'defeat') fires (ember_game.dart); the sfx copies are unreferenced. Single path, no bug.
'victory'/'defeat' exist as BOTH music stings and sfx one-shots. Verify
only one path fires per end-screen; if both, that's a mud-mix bug.

## D. Measurement commands (re-run after any asset change)

- Music/loops: `ffmpeg -nostats -i F -af ebur128 -f null - 2>&1 | grep -A12 Summary:`
- One-shots: `ffmpeg -nostats -i F -af astats=measure_overall=RMS_level+Peak_level:measure_perchannel=none -f null -` (astats prints Peak before RMS)

## E. Explicitly rejected (with reasons)

- **FMOD/Wwise middleware** — plumbing already does what we need at our
  scale; a migration risks the SoundPool stutter fix for zero player value.
- **Horizontal resequencing** — needs segment-composed music we don't
  have; vertical layering (C5) gives the payoff without recomposition.
- **Positional/panned SFX** — 352×198 viewport, everything is near-field.
- **48 kHz re-export pass** — no evidence of artifacts; asset churn for
  its own sake violates the freeze spirit and APK-size pillar.
- **More simultaneous loops than music+ambience+danger+1 layer** — each
  decoded loop costs RAM on the 2 GB floor; cap at 4.

Order of attack when freeze lifts: C2 (asset-only) → C1 → C3 → C6 (pure
code, near-zero risk) → C4 → C5 (need new assets) → C7 whenever.
