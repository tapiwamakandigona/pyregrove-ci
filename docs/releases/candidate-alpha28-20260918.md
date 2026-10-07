# Pyregrove alpha.28+40 — candidate, not a store release

## Scope

Carry the already-merged idle-ground-contact fix into the public build mirror
and a signed Android candidate. The current alpha.27+39 build predates that fix.
No new gameplay, audio, graphics, Android settings or save changes.

## Verification gates

- Original analyzer and full suite, including the exact idle regression.
- Private/public runtime, assets, tests, Android-without-signing and dependency parity.
- Unchanged CI builds APK/AAB with the permanent upload-certificate pin.
- Independently inspect downloaded package/version/signer and SHA-256.
- Actual affected-phone save-preserving update and idle/run/jump/drop/pause/resume.

The final gate is separate: no physical owner phone is reachable from this
environment. Do not mark P-IDLE-DEVICE-20260910, P-M7 or P-M10 passing from a
green build or a web test. No tag, GitHub release, Play upload or rollout.
