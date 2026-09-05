// main.dart — boot: services up, landscape lock, straight to the title.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'audio/audio_service.dart';
import 'audio/settings.dart';
import 'core/crash_guard.dart';
import 'core/save.dart';
import 'game/asset_warmup.dart';
import 'telemetry/consent_dialog.dart';
import 'telemetry/telemetry_bootstrap.dart';
import 'telemetry/telemetry_service.dart';
import 'ui/app_state.dart';
import 'ui/title_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Global error containment: honest fallbacks instead of silent grey
  // screens (see lib/core/crash_guard.dart). Stores and sends nothing.
  installCrashGuard();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final settings = await SettingsStore.load();
  AudioService.instance = AudioService(settings);
  await AudioService.initPlatformAudio();

  final store = SaveStore();
  final save = await store.load();
  AppState.init(store: store, save: save);

  // Consent-gated, opt-in analytics (docs/telemetry-events.md). Silent
  // no-op if Firebase is unconfigured; nothing fires before opt-in.
  // alpha.23: initialised AFTER the first frame is scheduled. Firebase
  // init used to sit on the cold-start path before runApp — the one Play
  // "slow cold start" contributor here that gameplay never needed, since
  // collection is off by default and only turns on after an explicit
  // opt-in. Errors stay contained inside initTelemetry.
  // The consent choice itself is local prefs and MUST be known before the
  // first frame: TelemetryConsentGate decides on its first post-frame
  // callback, and a not-yet-loaded "null" would re-ask on every launch.
  await TelemetryService.instance.load();
  unawaited(_startTelemetryAfterFirstFrame());
  // alpha.23 #35: decode the level sprites on the title screen so the first
  // PLAY of a session does not pay the cold-cache decode inside the loading
  // state (lib/game/asset_warmup.dart). Off the cold-start path: kicks off
  // after the first frame is scheduled, IO-thread decodes, fail-open.
  unawaited(_warmUpAfterFirstFrame(save));

  // Background/foreground audio: Android keeps audioplayers running after
  // Home/lock/calls otherwise (Play-review killer). The engine itself is
  // paused by Flame's own lifecycle hook; surprise-unpause on return is
  // handled in EmberGame (pause overlay instead of silent resume).
  appLifecycleAudioGuard = AppLifecycleListener(
    onHide: () => AudioService.instance?.pauseAll(),
    onShow: () => AudioService.instance?.resumeAll(),
    onPause: () => AudioService.instance?.pauseAll(),
    onResume: () => AudioService.instance?.resumeAll(),
  );

  runApp(const PyregroveApp());
}

Future<void> _warmUpAfterFirstFrame(SaveData save) async {
  await Future<void>.delayed(Duration.zero);
  try {
    await warmUpLevelSprites(save);
  } catch (_) {
    // Never let a warm-up problem reach the user; the level loads cold.
  }
  // alpha.23 #36: then the one-shot voices (SoundPool sample loads), so the
  // first jump/step/swing/coin/hit of the session is not the one that pays
  // for its own player creation. Sequential after the sprites on purpose:
  // one warm-up at a time behind the title screen.
  try {
    await AudioService.instance?.warmSfx();
  } catch (_) {
    // fail-open: playSfx still creates voices lazily
  }
}

Future<void> _startTelemetryAfterFirstFrame() async {
  // Yield once so runApp's first build/raster is not queued behind us.
  await Future<void>.delayed(Duration.zero);
  await initTelemetry(loadPrefs: false);
  TelemetryService.instance.logEvent('app_open');
}

/// Root-scoped lifecycle listener: lives for the whole process (never
/// disposed by design — it must outlive every screen). Public so the
/// declaration is honestly reachable (and greppable) instead of a lint
/// suppression.
late final AppLifecycleListener appLifecycleAudioGuard;

class PyregroveApp extends StatelessWidget {
  const PyregroveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pyregrove',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF141420),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const TelemetryConsentGate(child: TitleScreen()),
    );
  }
}
