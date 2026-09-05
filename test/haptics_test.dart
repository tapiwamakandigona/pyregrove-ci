// Haptics gating: impact haptics must respect the persisted setting and be
// silent (not crash) when audio/settings never initialized.
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/audio/audio_service.dart';
import 'package:pyregrove/audio/settings.dart';
import 'package:pyregrove/game/haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <String>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            calls.add(call.arguments as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    AudioService.instance = null;
  });

  test('no AudioService -> haptics are silently off', () {
    AudioService.instance = null;
    Haptics.medium();
    expect(calls, isEmpty);
  });

  test('setting off -> no vibration; on -> impact fires', () async {
    AudioService.instance = AudioService(AudioSettings(haptics: false));
    Haptics.light();
    Haptics.medium();
    Haptics.heavy();
    await null; // flush platform channel microtasks
    expect(calls, isEmpty);

    AudioService.instance!.settings.haptics = true;
    Haptics.light();
    Haptics.medium();
    Haptics.heavy();
    await null;
    expect(calls, [
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.heavyImpact',
    ]);
  });

  test('screenShake: default on, json roundtrip, legacy file -> on', () {
    expect(AudioSettings().screenShake, isTrue);
    final off = AudioSettings(screenShake: false);
    final back = AudioSettings.fromJson(
      jsonDecode(jsonEncode(off.toJson())) as Map<String, dynamic>,
    );
    expect(back.screenShake, isFalse);
    // Settings files written before the toggle existed must not turn it off.
    final legacy = AudioSettings.fromJson({'musicVolume': 0.5});
    expect(legacy.screenShake, isTrue);
  });

  test(
    'controlScale: default 1.0, roundtrip, clamped, legacy -> 1.0, snaps',
    () {
      expect(AudioSettings().controlScale, 1.0);
      final big = AudioSettings(controlScale: 1.2);
      final back = AudioSettings.fromJson(
        jsonDecode(jsonEncode(big.toJson())) as Map<String, dynamic>,
      );
      expect(back.controlScale, 1.2);
      expect(
        AudioSettings.fromJson({'controlScale': 9.0}).controlScale,
        AudioSettings.controlScaleMax,
      );
      expect(
        AudioSettings.fromJson({'controlScale': 0.1}).controlScale,
        AudioSettings.controlScaleMin,
      );
      expect(AudioSettings.fromJson({'haptics': true}).controlScale, 1.0);
      expect(nearestControlScale(0.9), 0.85);
      expect(nearestControlScale(1.11), 1.2);
      expect(nearestControlScale(1.05), 1.0);
    },
  );

  test('mirrorControls: default off, roundtrip, legacy file -> off', () {
    expect(AudioSettings().mirrorControls, isFalse);
    final m = AudioSettings(mirrorControls: true);
    final back = AudioSettings.fromJson(
      jsonDecode(jsonEncode(m.toJson())) as Map<String, dynamic>,
    );
    expect(back.mirrorControls, isTrue);
    expect(
      AudioSettings.fromJson({'controlScale': 1.0}).mirrorControls,
      isFalse,
    );
  });

  test('controlLift: default 0, roundtrip, clamped, legacy -> 0, snaps', () {
    expect(AudioSettings().controlLift, 0.0);
    final hi = AudioSettings(controlLift: 28.0);
    final back = AudioSettings.fromJson(
      jsonDecode(jsonEncode(hi.toJson())) as Map<String, dynamic>,
    );
    expect(back.controlLift, 28.0);
    expect(
      AudioSettings.fromJson({'controlLift': 900}).controlLift,
      AudioSettings.controlLiftMax,
    );
    expect(
      AudioSettings.fromJson({'controlLift': -5}).controlLift,
      AudioSettings.controlLiftMin,
    );
    expect(AudioSettings.fromJson({'haptics': true}).controlLift, 0.0);
    expect(nearestControlLift(10), 14.0);
    expect(nearestControlLift(5), 0.0);
    expect(nearestControlLift(40), 28.0);
  });

  test('clampedControlLift: honours headroom, never negative', () {
    expect(clampedControlLift(28, 100), 28);
    expect(clampedControlLift(28, 10), 10);
    expect(clampedControlLift(28, 0), 0);
    expect(clampedControlLift(28, -6), 0);
    expect(clampedControlLift(0, 100), 0);
  });
}
