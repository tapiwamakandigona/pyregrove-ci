// Crash guard: uncaught async errors are absorbed and
// remembered; the error ring stays bounded; nothing is persisted or sent
// (the guard has no IO — verified by reading, asserted here by behavior).
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/crash_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('installCrashGuard absorbs uncaught platform errors + remembers them',
      () {
    final priorFlutter = FlutterError.onError;
    final priorPlatform = PlatformDispatcher.instance.onError;
    try {
      installCrashGuard();
      recentErrors.clear();

      final handled = PlatformDispatcher.instance.onError!(
          Exception('Codec failed to produce an image'), StackTrace.current);
      expect(handled, isTrue,
          reason: 'uncaught async errors must be marked handled');
      expect(recentErrors, hasLength(1));
      expect(recentErrors.single, contains('Codec failed'));

      // FlutterError path also remembers.
      FlutterError.onError!(FlutterErrorDetails(exception: Exception('boom')));
      expect(recentErrors, hasLength(2));

      // Ring buffer stays bounded.
      for (var i = 0; i < 50; i++) {
        PlatformDispatcher.instance.onError!(
            Exception('e$i'), StackTrace.current);
      }
      expect(recentErrors.length, lessThanOrEqualTo(20));
      expect(recentErrors.last, contains('e49'));
    } finally {
      FlutterError.onError = priorFlutter;
      PlatformDispatcher.instance.onError = priorPlatform;
    }
  });
}
