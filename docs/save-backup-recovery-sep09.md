# Keep the last readable save backup — iteration 4/6

## Finding and scope

**VERIFIED source:** `SaveStore.load` tries the live save then its backup,
but `SaveStore.save` copies any existing live file over that backup, including
an unreadable file. The first save after recovery therefore destroys the last
known-readable backup. A subsequent live-file failure can lose earned progress.
This is source evidence, not a report of an actual player's data loss.

## Plan and immutable acceptance

1. Add regression cases for malformed JSON, wrong JSON root, invalid scalar
   field and invalid collection members. Recover from a valid backup, save
   again and verify that the backup bytes survive unchanged; damage the new
   live file and prove the original progress can still be recovered.
2. Test saving without an intervening `load` call, normal readable-live
   rotation, and the established legacy-save migration.
3. Run the existing public-mirror PR analyzer/full suite on unchanged source,
   expecting only the new corruption-preservation assertions to fail.
4. Before rotating a live save into backup, validate it with the same JSON/
   SaveData decoder used by loading. Skip unreadable live data, then finish the
   existing flushed-temp/rename save. Preserve the schema and AppState's
   already-implemented write serialization.
5. Keep the regression byte-identical and rerun the full analyzer/test suite.

Hard cap: expected-red and green CI only, with one evidence-based retry only
if an environment failure prevents execution. Do not modify any existing test,
check, workflow, dependency, signing key, version, Android backup rule or
purchase behavior. Private Actions stay disabled; Android builds are skipped.
No Play update or guarantee against every filesystem/power-loss failure.

## Evidence

**VERIFIED expected red:** public CI34323313039 at `b2c485c` has clean analyzer,
**639 passed / five new failures / two existing skips**. All four bad-data
cases and save-without-load replace readable backup bytes with corrupt bytes.
Example exact failure: `Actual: '{interrupted'`; the expectation is the
unaltered readable full-progression JSON. Normal rotation/legacy tests and
every original test pass. Android build skipped.
Regression SHA256 `65d13ab910083ead7029e1045382301ed9d2bb341b21db9293e234842b327bca`.
[primary Actions logs, 2026-09-09]

Existing physical-device and production features remain false. The new feature
passes only after the unchanged regressions and full suite pass on the fix.

**VERIFIED green:** public CI34323537255 at
`66f8f3d5213d8ef819a66439bae88e60d61c382b` has clean analyzer,
**644 passed / two existing skips**. All seven new tests pass, unchanged from
red. Full application/test/assets/Android-source parity checked between
private and public task trees; all old tests/checks/dependencies unchanged.
The existing crash-guard test deliberately prints a codec exception and passes;
it is not an unhandled new test failure. Android build skipped.
[primary Actions logs, source diff and byte comparison, 2026-09-09]

The source fix uses the exact same decoder for loading and backup eligibility,
then preserves the existing flushed-temp/rename sequence. Readable legacy
saves still back up and migrate. No schema, backup-inclusion/entitlement,
write-serialization, version or signing change. Not yet in the Play binary;
not a guarantee against disk failure or every interrupted filesystem operation.
