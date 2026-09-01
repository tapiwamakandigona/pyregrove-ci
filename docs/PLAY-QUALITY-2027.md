# Play quality requirements — memory + device migration (enforced Feb 2027)

Written 2026-08-31. Every fact below was read from the source named next to it;
nothing here is from memory. Owner asked for this after the Play Console email
"Introducing new quality requirements to optimize app memory and secure device migration".

## What Google actually announced

Source: Android Developers Blog, "Elevating app quality: Reducing memory usage and
improving device migration" (announced ~26 Aug 2026), plus the Play Console
notification on the app dashboard.

Two new requirements:

1. **Performance thresholds** across three metrics:
   - Memory usage (**anonymous RSS + swap**)
   - **Bitmap** memory usage
   - **DEX code optimization** — apps must ship "a minimum of 25% coverage across
     optimization, shrinking, and obfuscation using a tool such as R8".
2. **Secure device migration / onboarding standard** — simplify and secure login
   and data carry-over during device upgrades.

**Enforcement starts February 2027.** Apps that miss the thresholds "may see reduced
app visibility and publishing capabilities". Play Console will warn on the Android
vitals overview page before then. So: real, but not urgent — there is time to do it properly.

## Where each app stands (verified 2026-08-31)

| Item | Emberdelve | Pyregrove |
|---|---|---|
| `isMinifyEnabled` (R8) | **true** (since commit `8f756dd8`, 2026-08-23, PR #94/#96) | **not set → defaults false** |
| `isShrinkResources` | **true** | **not set → defaults false** |
| `android:allowBackup` | not declared | not declared |
| `android:dataExtractionRules` | not declared | not declared |
| `android:fullBackupContent` | not declared | not declared |

Play Console → Vitals → metrics for Emberdelve currently shows **"-"** for both
"Memory usage (anonymous RSS and swap)" and "Bitmap memory usage", with a
"Limited data" warning: the install base is too small for Play to compute these yet.
Policy center is clean — no warnings, no enforcement.

**So the only thing measurable in code today is the DEX/R8 item, and Pyregrove fails it.**

## Fix 1 — R8 (Pyregrove)

Do NOT just flip the flag. Flutter plugins that use reflection break *only* in
minified release builds, which is the worst way to find out. Emberdelve hit this in
issue #94 and the keep rules that resolved it are in
`android/app/proguard-rules.pro` in the emberdelve repo (branch `legacy/dice-builder`) —
copy that file and trim it to the plugins Pyregrove actually uses.

```kotlin
// android/app/build.gradle.kts, inside buildTypes { release { ... } }
isMinifyEnabled = true
isShrinkResources = true
proguardFiles(
    getDefaultProguardFile("proguard-android-optimize.txt"),
    "proguard-rules.pro",
)
```

Then build a **release** APK and actually launch it. Test anything reflective:
billing, notifications, any Gson/JSON round-trip, any plugin channel.

## Fix 2 — device migration (both apps)

Neither app declares any backup configuration, so both silently inherit
"back up everything".

Source: developer.android.com "Back up user data with Auto Backup" and
"Changes to backup and restore in Android 12":
- `android:allowBackup` defaults to **true**; Google explicitly recommends setting
  it in the manifest rather than relying on the default.
- Apps targeting Android 12+ must point `android:dataExtractionRules` at an XML file
  with separate `<cloud-backup>` and `<device-transfer>` sections. `fullBackupContent`
  is ignored on Android 12+, but is still needed for Android 11 and lower.
- **Important:** on some manufacturers' devices, `allowBackup="false"` disables Google
  Drive backup but does **not** disable device-to-device transfer. Anything that must
  not be copied has to be excluded explicitly in `<device-transfer>`.

```xml
<!-- android/app/src/main/res/xml/data_extraction_rules.xml (Android 12+) -->
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <exclude domain="file" path="cache/" />
    </cloud-backup>
    <device-transfer>
        <exclude domain="file" path="cache/" />
    </device-transfer>
</data-extraction-rules>
```
```xml
<!-- android/app/src/main/res/xml/backup_rules.xml (Android 11 and lower) -->
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <exclude domain="file" path="cache/" />
</full-backup-content>
```
```xml
<!-- AndroidManifest.xml, on <application> -->
android:allowBackup="true"
android:dataExtractionRules="@xml/data_extraction_rules"
android:fullBackupContent="@xml/backup_rules"
```

## Decision needed before applying Fix 2 to Emberdelve

Emberdelve's paid **Ember Forge** entitlement (`forgeUnlocked`) and the redeemed
unlock-code nonces are stored in `MetaState`, persisted to `emberdelve_meta.json`
in the app documents directory (`lib/meta/meta.dart`). That path is inside the
default backup set, so **the purchase currently rides along with both cloud backup
and device-to-device transfer**.

Two defensible positions, and it is a product call, not a technical one:
- **Keep it portable** (recommended): a player who upgrades their phone keeps what
  they paid for. This is what users expect and it prevents refund requests.
- **Exclude it**: prevents one redeemed offline unlock code from being restored onto
  several devices. Matters more if direct unlock-code sales outside Play ever become
  a real revenue line.

Do not silently change this — it changes monetization behaviour. Ask the owner.

## Correction (alpha.21, 2026-08-31)

The table above says Pyregrove's `isMinifyEnabled` "defaults false" — that's
wrong for Flutter apps. The Flutter Gradle plugin enables R8 minification and
resource shrinking **by default** for release builds even when the app's
`build.gradle.kts` doesn't set them. Evidence: the alpha.21 build made the
flags explicit (+ keep rules) and its `classes.dex` came out **byte-identical**
to alpha.20's (sha256 prefix `b5244d9c363bec91`, 1,985 classes, 1,306 with
obfuscated short names in BOTH builds). So Pyregrove already met the DEX/R8
requirement; alpha.21 just makes the config explicit and auditable.

What alpha.21 actually added is Fix 2: `android:allowBackup` +
`dataExtractionRules` + `fullBackupContent` with saves/settings INCLUDED
(progress follows the player to a new phone — Pyregrove has no paid
entitlements, so the Emberdelve monetization question does not apply here)
and cache excluded.
