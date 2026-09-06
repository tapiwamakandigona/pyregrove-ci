# Sandbox emulator: what it can and cannot verify (2026-09-01)

One session of real evidence from running the shipped alpha.21 APK on an
Android emulator inside the build sandbox. Written so nobody re-burns hours
rediscovering these limits — and so nobody mistakes an emulator artifact for
a game bug (or vice versa).

## Setup that works

- SDK: `sdkmanager` needs `JAVA_HOME` pointed at JDK 17. Installed
  `emulator` + `system-images;android-34;default;x86_64` (AOSP image).
- AVD: 2048 MB RAM, 800×480 @ 240 dpi, `vm.heapSize=128`.
- No `/dev/kvm` in the sandbox → TCG software emulation, 1 vCPU:
  boot ≈ 6.5 min, debug-build first frame ≈ 1–2 min, constant system-process
  ANRs ("System UI isn't responding") that must be dismissed with "Wait".
- The alpha.21 universal APK installs and runs **because it ships x86_64
  libs**; per-ABI arm64 artifacts would not.
- `dumpsys meminfo` needs `dumpsys -t 120` (default 10 s service timeout
  expires under TCG).

## Verified findings (alpha.21, sha256-matched APK)

- Title screen: TOTAL PSS 83.4 MB. Menus/level-select: 89.6 MB.
  Native heap 31–33 MB, Dalvik 1.7–2.7 MB, RSS 211–222 MB, swap 0.
  Memory numbers under TCG are meaningful; fps numbers are NOT.
- Consent flow, save persistence across force-stop, title/menu rendering,
  navigation — all work on a real Android 14 stack (these screens are
  font/vector-only).

## The PNG decode wall (environment bug, NOT a game bug)

**Symptom:** entering any level → solid grey screen in release
(release-mode `ErrorWidget`), red-grid error boxes in debug. Logcat spams
`Codec failed to produce an image, possibly due to invalid image data`
(release) / `Could not decompress image` (debug, via VM-service
`Flutter.Error` events — logcat shows nothing in debug).

**Root cause isolation (scratch probe app `decodeprobe`,
five control-asset classes + a size sweep):**

| Asset | Engine decode on this AVD |
|---|---|
| Any pyregrove PNG (byte-identical to repo) | FAIL |
| PIL re-encode of same pixels | FAIL |
| ffmpeg re-encode of same pixels | FAIL |
| Fresh PIL solid/noise 16×16 … 272×160 | FAIL |
| Fresh PIL 8×8 (any content) | OK |

Every PNG larger than 8×8 fails through BOTH `instantiateImageCodec`
(Flame's path) and `Image.asset`/`AssetImage` (UI path) **on this system
image**, regardless of origin. Meanwhile all 179 bundled PNGs decode
through the desktop engine codec (`test/asset_decode_test.dart`, added
2026-09-01) and are byte-identical between repo and APK (sha256, all 179).
Known class of x86-emulator image-codec failures (e.g. flutter/flutter
#42065). Conclusion: the AOSP x86_64 android-34 `default` image + software
GL cannot decode our textures; the game and its assets are exonerated.
`google_apis` image swap is the standard next attempt if emulator gameplay
is ever needed again.

## Two REAL app-side facts this surfaced (candidates, not emulator noise)

1. **No global error handling.** The app has no `FlutterError.onError` /
   `runZonedGuarded` / custom `ErrorWidget.builder`. Any unhandled build/load
   error in release = silent full-screen grey. On a real device an asset-load
   hiccup would look exactly like this emulator session: game dead, no
   message, no recovery. Candidate hardening for the next authorized
   game-code window.
2. **RenderFlex overflow, 692 px on the right** at 800×480 (5:3, 240 dpi) —
   caught as a real `Flutter.Error` during menu navigation on this AVD.
   `overflow_sweep_test` does not cover this canvas/density combination.
   Reproduce + fix in the next game-code window.

## VM-service introspection recipe (debug builds)

`adb forward tcp:PORT tcp:PORT` (port from logcat "Dart VM service"),
websocket JSON-RPC: `getVM` → `streamListen` on `Stderr`/`Stdout`/
`Extension` → `Flutter.Error` extension events carry `renderedErrorText`
with the failing asset name even when logcat is silent. Debug-build
exceptions may not reach logcat at all — listen on the VM service instead.
