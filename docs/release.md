# Release & signing — Pyregrove (Flutter)

Rewritten 2026-08-31 for the move to the private `tapiwamakandigona/pyregrove`
repo. The old Emberdelve/Emberwood signing model (keystore in GitHub Actions
secrets) is gone.

Package id: `com.tsorostudios.pyregrove`.

## Signing model (owner directive 2026-08-31)

This repo is **PRIVATE**, and the permanent upload key is **committed in it**
so any collaborator or AI with repo access can build signed releases with zero
extra setup:

| What | Where |
| --- | --- |
| Upload keystore (PKCS12, alias `upload`, RSA-2048, valid ~27 years) | `android/signing/upload.keystore` |
| Passwords + alias + path | `android/key.properties` (committed) |
| Cert SHA-256 pin | `EXPECTED_CERT_SHA256` in `.github/workflows/ci.yml`: `286c4760f1801269550fe40658e6255c96107713690d0e4353cbe76bccee8ffd` |

Rules:
- **Never make this repo public** while the keystore is committed.
- The key is **immutable** from 2026-08-31 on — never regenerate it, never
  change the CI pin. If the CI cert check fails, fix the plumbing.
- History note: prereleases alpha.8–.16 (old repo, Emberwood,
  `com.tsorostudios.emberwood`) were signed with the old key
  (`031acb42…d44b7a0d`). Different package + different signer → old installs
  coexist with Pyregrove; they do not upgrade in place.

## Building a signed release

Local (needs JDK + Android SDK): `flutter build apk --release` /
`flutter build appbundle --release` — gradle picks up `android/key.properties`
automatically.

Normal path is CI: every push to `main` runs analyze + full test suite, then
builds signed APK + AAB, verifies the cert against the pin with `apksigner`,
and uploads `pyregrove-release-apk` / `pyregrove-release-aab` artifacts.

**Where CI actually runs:** GitHub Actions is billing-blocked on this
account's PRIVATE repos (2026-08-31), so CI runs on the PUBLIC snapshot
mirror `tapiwamakandigona/pyregrove-ci`. Sync it with
`scripts/sync_public_ci.sh [tag]` from the commit to release — the script
strips `android/signing/` + `android/key.properties` and force-pushes an
orphan snapshot (keys can never leak; mirror history is not the real
history). The same `ci.yml` works in both repos: when the key files are
missing it restores them from the mirror's Actions secrets
`UPLOAD_KEYSTORE_B64` / `KEY_PROPERTIES_B64` (same permanent key, same pin).
If owner fixes GitHub billing, private-repo CI works again unchanged.
Releases (tags + GitHub prereleases + assets) still live on the PRIVATE repo.

## Release checklist (per prerelease)

1. Gates green locally: `flutter analyze` clean + `flutter test` full suite.
2. Bump `version:` in `pubspec.yaml` (semver-alpha + versionCode).
3. Commit (`git commit -F msg.txt`), tag `vX.Y.Z-alpha.N`, push main + tag.
4. `scripts/sync_public_ci.sh vX.Y.Z-alpha.N` → CI green on pyregrove-ci →
   download artifacts → androguard-verify versionName/versionCode/
   package `com.tsorostudios.pyregrove`/signer pin.
5. Create GitHub prerelease on the tag, upload renamed
   `pyregrove-vX.Y.Z-alpha.N.apk` / `.aab`.

## Play Store

NOT on any Play track. Going to Play is an **owner call** — never submit
unasked. When it happens it is a brand-new listing for
`com.tsorostudios.pyregrove` with this repo's upload key.

## Firebase note

`android/app/google-services.json` currently reuses the old Emberwood Firebase
app id with a duplicated client entry for the new package (works, but
analytics attribute to the old app entry). Owner follow-up: register
`com.tsorostudios.pyregrove` in the Firebase console
(project `gen-lang-client-0980262477`) and drop in the fresh json.
