# VERIFIED alpha.26 testing candidate — 2026-09-08

Private source `4ade20089e984dc2d42335f680617cdb0e5e3e9c`,
[PR #4](https://github.com/tapiwamakandigona/pyregrove/pull/4) to `main`.
Explicit public source-only mirror `f9c7aa206ac4b7197f3fb0d855512d50709154a9`,
[PR #2](https://github.com/tapiwamakandigona/pyregrove-ci/pull/2).
All 413 allowlisted files verified byte-identical. No private history, keys,
account documents or workflow changes copied; private paid Actions remain off.

## Checks and artifacts

Analyzer clean; 637 tests pass / 2 original manual skips. Original checks
and assertions preserved. Public headless34240643738 and existing signed
[CI34247076464](https://github.com/tapiwamakandigona/pyregrove-ci/actions/runs/34247076464)
both succeed. Signed workflow used the owner-authorized PAT and exact mirror
SHA; no alternative trigger or signing-secret enumeration.

GitHub artifact ZIP digests match. Independent Android apksigner,
JDK jarsigner, embedded PKCS7 certificate and bundletool structural/manifest
checks pass: `com.tsorostudios.pyregrove`, `1.0.0-alpha.26`, code38,
minSdk24, targetSdk36, non-debuggable.

Permanent upload certificate:
`286c4760f1801269550fe40658e6255c96107713690d0e4353cbe76bccee8ffd`.

| CI filename | Bytes | SHA256 |
|---|---:|---|
| app-release.aab | 55073484 | `ed65c9ef9559c86448d54a337b37f4003029490c8b049a738c6fcd88e58c7502` |
| app-release.apk | 55253748 | `783d5b6763a527c7f813c941f8970e73897aa978d1294d64886b5e2848913c6e` |

Release downloads use `pyregrove-v1.0.0-alpha.26.aab/.apk`; renaming does not
alter those bytes. The release checksum manifest uses the release filenames.

VERIFIED [private GitHub prerelease v1.0.0-alpha.26](https://github.com/tapiwamakandigona/pyregrove/releases/tag/v1.0.0-alpha.26)
targets exact private source `4ade200`, `prerelease=true`, `latest=false`.
Both uploaded binaries and `pyregrove-SHA256SUMS` were downloaded back from
the release; byte counts/SHA256/manifest contents match. The public CI mirror
contains no private repository history or signing material.

## Google Play

VERIFIED correct app/track/version before upload and before confirmation.
Native browser File transfer SHA256 matched the independent AAB check.
Internal preview Ready to release; zero newly unsupported devices across
all seven form factors. Saved/published and reloaded internal track:
**38 (1.0.0-alpha.26) — Available to internal testers**.

Promoted the same bundle to existing closed Alpha, not a new listing/track.
Preview Ready to release, zero device loss, 100% of that testing track.
Publishing overview was empty before this work; only the release change
was saved and submitted, with no tester-roster or listing change.
Initial reloaded overview: **Changes in review — Closed testing - Alpha —
38 (1.0.0-alpha.26) — Start full rollout**. Review subsequently cleared.
Final primary releases-overview readback shows **38 (1.0.0-alpha.26) —
Closed testing - Alpha — Available to testers on Google Play — Full
roll-out**, alongside internal38 available. Production access remains denied.

## Open gates and caveats

This is an alpha, not P-M10's beta. P-M7/P-M10 remain false. No physical
low-end FPS, cold-start measurement or touch review. Seven tap intervals
(50–350ms) clear >4.05 tiles and twelve non-boss exit-route geometry bots
pass, but those bots restore health to isolate movement. They do not prove
combat difficulty, every optional secret or forgiving boss strategies.
No new Pyregrove model roster or web deployment was made.
