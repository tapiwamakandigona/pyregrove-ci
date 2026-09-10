# Checkpoint 20 — v1.0.0-alpha.17 "The Rekindling" (2026-08-31)

Repo move + total rename, owner-directed: Emberwood → **Pyregrove**, own
PRIVATE repo tapiwamakandigona/pyregrove, upload keystore + key.properties
COMMITTED (owner: "keep the store keys in the repo so any other ai can work
on it too"). NEVER make this repo public.

- Package: com.tsorostudios.pyregrove (new app; old alphas coexist).
- New permanent signer pin (immutable from now):
  286c4760f1801269550fe40658e6255c96107713690d0e4353cbe76bccee8ffd
- Keystore: PKCS12, alias 'upload', RSA-2048, ~27y validity, generated with
  python cryptography (sandbox has no JDK/keytool). Gradle+apksigner accept
  PKCS12 fine.
- CI reads signing from repo files; secrets gone; artifacts pyregrove-*.
- Firebase google-services.json: duplicated client entry for new package
  reusing the old Emberwood app id — WORKS but attributes analytics to the
  old app entry. Owner follow-up: register com.tsorostudios.pyregrove in
  Firebase console (project gen-lang-client-0980262477), replace the json.
- Lore rename included (title, subtitle, world-1 header); historical docs
  (checkpoints/, docs/legacy/, progress.md, PROVENANCE, CREDITS) untouched.
- Privacy policy still hosted on old repo's GitHub Pages URL (new repo is
  private → no Pages); consent dialog URL unchanged and working.
- Gates: analyze clean; 421 passed + 1 skipped; look-pass PASS phone+desktop.
