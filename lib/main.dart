// main.dart — boot: services up, landscape lock, straight to the title.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'audio/audio_service.dart';
import 'audio/settings.dart';
import 'core/save.dart';
import 'telemetry/consent_dialog.dart';
import 'telemetry/telemetry_bootstrap.dart';
import 'telemetry/telemetry_service.dart';
import 'ui/app_state.dart';
import 'ui/title_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  await initTelemetry();
  TelemetryService.instance.logEvent('app_open');

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
