// core/crash_guard.dart — global error containment (alpha.23, ported from update/delvers).
//
// Origin (docs/EMULATOR-LIMITS.md, 2026-09-01): a burst of image-decode
// exceptions on one emulator produced a SILENT full-screen grey box in
// release — Flutter's default release ErrorWidget — with no message and no
// way out. On a real device any unexpected build/load error would look the
// same: game dead, no explanation. This guard keeps failures visible,
// small, and honest instead of grey and total. It stores NOTHING and sends
// NOTHING — pillar: nothing leaves the device.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Ring buffer of recent error one-liners (newest last). In-memory only;
/// readable by future diagnostics UI. Never persisted, never transmitted.
final List<String> recentErrors = <String>[];
const int _kMaxRecentErrors = 20;

void _remember(Object error) {
  final line = error.toString().split('\n').first;
  recentErrors.add(line);
  if (recentErrors.length > _kMaxRecentErrors) recentErrors.removeAt(0);
}

/// Install the guards. Called once from main() before runApp.
void installCrashGuard() {
  final prior = FlutterError.onError;
  FlutterError.onError = (details) {
    _remember(details.exception);
    // Keep the framework's own reporting (console in debug, crash-safe
    // no-op in release).
    prior?.call(details);
  };

  // Uncaught async errors (the emulator codec burst was exactly this):
  // remember them and mark handled so they can never take the app down.
  PlatformDispatcher.instance.onError = (error, stack) {
    _remember(error);
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(
          FlutterErrorDetails(exception: error, stack: stack));
    }
    return true;
  };

  // Release ErrorWidget: a compact, honest notice instead of a silent
  // full-screen grey rectangle. Debug keeps Flutter's detailed red box.
  if (kReleaseMode) {
    ErrorWidget.builder = (details) {
      _remember(details.exception);
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        color: const Color(0xFF141420),
        child: const Text(
          'Something failed to draw here.\n'
          'Backing out and retrying usually clears it.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFE8A33D), fontSize: 12),
        ),
      );
    };
  }
}
