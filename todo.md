# Emberwood → Pyregrove migration (2026-08-31, owner directive 18:01)

Owner: move the platformer to its own repo, rename entirely, keep store keys IN the repo (repo made PRIVATE for this — old repo is public, keys can never go there).

- [x] alpha.16 release finished (release 379953582, APK+AAB verified: 1.0.0-alpha.16/28, signer pin MATCH, assets uploaded, skill bumped)
- [x] Name picked: **Pyregrove** (web-checked: no game collision; alternates Cinderbough, Kilnfall also clear)
- [x] Create private repo tapiwamakandigona/pyregrove
- [x] Rename in code: pubspec name/desc, EmberwoodApp, title 'PYREGROVE', subtitle, world header, save/settings filenames, web manifest/index, AndroidManifest label, namespace+applicationId com.tsorostudios.pyregrove, MainActivity dir, __emberdelve → __pyregrove marker (+ sed harness scripts in /work/temp)
- [x] google-services.json: duplicate client block with new package (HACK — analytics attributes to old app id; owner follow-up: register new Android app in Firebase console, drop-in new json)
- [x] Fresh upload keystore (PKCS12 via python cryptography — no JDK in sandbox), commit android/signing/upload.keystore + key.properties, un-ignore in .gitignore
- [x] CI: read signing from repo files (no secrets), new EXPECTED_CERT_SHA256 pin, artifact names pyregrove-*
- [x] Living docs: README, DEMAND, PROJECT, docs/store/play-listing, HOW-TO-PLAY, release.md, web_testing.md (leave checkpoints/ + docs/legacy/ + progress.md history untouched)
- [x] Bump 1.0.0-alpha.17+29; gates: analyze + full suite; web harness look-pass phone+desktop
- [x] Push main → new repo; tag v1.0.0-alpha.17; CI green; androguard verify NEW pin; prerelease in pyregrove repo
- [x] Old repo: README note on main that the platformer moved (dice game branch untouched)
- [x] Rename worktree /work/repos/pyregrove; update personal skill + references + lock file name
- Follow-ups (owner): Firebase app registration for com.tsorostudios.pyregrove; privacy-policy page still hosted on old repo Pages URL (works, needs rebrand text)

**DONE 2026-08-31 18:3x:** all items complete. CI billing-blocked on private repos -> alpha.17 built+signed LOCALLY (JDK17 + Android SDK in /work/temp), androguard-verified (1.0.0-alpha.17/29, com.tsorostudios.pyregrove, pin 286c4760... MATCH), prerelease 379966012 live with APK+AAB. Owner follow-ups: GitHub billing, Firebase app registration.
