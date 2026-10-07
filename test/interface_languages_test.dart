import 'dart:io';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/components/sign_bubble.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/game/session.dart';
import 'package:pyregrove/l10n/language.dart';
import 'package:pyregrove/main.dart';
import 'package:pyregrove/telemetry/telemetry_service.dart';
import 'package:pyregrove/ui/app_state.dart';
import 'package:pyregrove/ui/game_screen.dart';
import 'package:pyregrove/ui/settings_screen.dart';
import 'package:pyregrove/ui/title_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _fonts() async {
  for (final entry in {
    'Inter': 'Inter-Regular.ttf',
    'Cinzel': 'Cinzel-Variable.ttf',
  }.entries) {
    final bytes = File('assets/fonts/${entry.value}').readAsBytesSync();
    await (FontLoader(
      entry.key,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(568, 320);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 1.3;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> _frames(WidgetTester tester, [int n = 30]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Widget _host(String code, Widget child) => MaterialApp(
  supportedLocales: groveLocales,
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  locale: GroveLanguage.locale(code),
  theme: ThemeData(fontFamily: 'Inter', brightness: Brightness.dark),
  home: Scaffold(body: child),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    AppState.init(store: SaveStore(), save: SaveData());
    AppState.diskWrites = false;
    SharedPreferences.setMockInitialValues({});
    GroveLanguage.choice.value = 'system';
    TelemetryService.instance = TelemetryService();
    await TelemetryService.instance.setAnalyticsConsent(false);
  });
  tearDown(() {
    AppState.diskWrites = true;
    GroveLanguage.choice.value = 'system';
  });

  test('all four Forest Edge signs and every catalog value are covered', () {
    final signs = File('assets/levels/w1_l1.txt')
        .readAsLinesSync()
        .where((line) => RegExp(r'^meta: sign\d=').hasMatch(line))
        .map((line) => line.substring(line.indexOf('=') + 1));
    expect(signs.length, 4);
    for (final sign in signs) {
      expect(groveCatalog, contains(sign));
    }
    for (final entry in groveCatalog.entries) {
      expect(entry.value.length, 3);
      for (final translated in entry.value) {
        expect(translated.trim(), isNotEmpty);
      }
    }
    expect(groveText('w1_l1', 'fr'), 'w1_l1');
    expect(groveText('PLAY', 'zz'), 'PLAY');
  });

  test(
    'language preference is optional, persists and tolerates corrupt type',
    () async {
      await GroveLanguage.load();
      expect(GroveLanguage.choice.value, 'system');
      expect(await GroveLanguage.save('pt'), isTrue);
      GroveLanguage.choice.value = 'system';
      await GroveLanguage.load();
      expect(GroveLanguage.choice.value, 'pt');
      SharedPreferences.setMockInitialValues({'interfaceLanguage': 42});
      await GroveLanguage.load();
      expect(GroveLanguage.choice.value, 'system');
      expect(GroveLanguage.locale('xx'), isNull);
    },
  );

  testWidgets(
    'app uses French Canadian device locale and English unknown fallback',
    (tester) async {
      _phone(tester);
      await _fonts();
      tester.platformDispatcher.localesTestValue = const [Locale('fr', 'CA')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(const PyregroveApp());
      await _frames(tester);
      expect(find.text('JOUER'), findsOneWidget);
      await GroveLanguage.save('es');
      await _frames(tester);
      expect(find.text('JUGAR'), findsOneWidget);
      await GroveLanguage.save('system');
      tester.platformDispatcher.localesTestValue = const [Locale('zz')];
      await _frames(tester);
      expect(find.text('PLAY'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final code in ['fr', 'es', 'pt']) {
    testWidgets('$code title and forgiving settings at 568x320 / 1.3x', (
      tester,
    ) async {
      _phone(tester);
      await _fonts();
      await tester.pumpWidget(_host(code, const TitleScreen()));
      await _frames(tester);
      expect(find.text(groveText('PLAY', code)), findsOneWidget);
      await tester.ensureVisible(find.text(groveText('SETTINGS', code)));
      await tester.tap(find.text(groveText('SETTINGS', code)));
      await _frames(tester);
      expect(find.byType(SettingsScreen), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(groveText('Forgiving jumps', code)),
        100,
      );
      expect(AppState.save.forgivingJumps, isTrue);
      await tester.ensureVisible(find.text(groveText('Forgiving jumps', code)));
      await tester.tap(find.text(groveText('Forgiving jumps', code)));
      await _frames(tester);
      expect(AppState.save.forgivingJumps, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('$code pause and results controls scroll without overflow', (
      tester,
    ) async {
      _phone(tester);
      await _fonts();
      var resume = 0, restart = 0, leave = 0, next = 0;
      await tester.pumpWidget(
        _host(
          code,
          PauseOverlay(
            onResume: () => resume++,
            onRestart: () => restart++,
            onLeave: () => leave++,
          ),
        ),
      );
      await _frames(tester);
      for (final label in ['Resume', 'Restart level', 'Leave level']) {
        await tester.ensureVisible(find.text(groveText(label, code)));
        await tester.tap(find.text(groveText(label, code)));
      }
      expect((resume, restart, leave), (1, 1, 1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        _host(
          code,
          ResultsOverlay(
            results: const LevelResults(
              timeMs: 67000,
              parSeconds: 90,
              coinsEarned: 52,
              chestsOpened: 2,
              chestTotal: 2,
              secretsFound: 1,
              finished: true,
              allChests: true,
              lowDamage: true,
            ),
            onReplay: () {},
            onContinue: () {},
            onNext: () => next++,
          ),
        ),
      );
      await _frames(tester, 100);
      expect(find.text(groveText('LEVEL CLEAR!', code)), findsOneWidget);
      expect(find.text(groveText('All chests', code)), findsOneWidget);
      await tester.ensureVisible(find.text(groveText('Next level', code)));
      await tester.tap(find.text(groveText('Next level', code)));
      expect(next, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('language sheet is reachable and persists a manual choice', (
    tester,
  ) async {
    _phone(tester);
    await _fonts();
    await tester.pumpWidget(_host('en', const SettingsScreen()));
    await _frames(tester);
    await tester.tap(find.byKey(const Key('open-language-picker')));
    await _frames(tester);
    await tester.tap(find.byKey(const Key('interface-language')));
    await _frames(tester);
    await tester.tap(find.text('Français').last);
    await _frames(tester);
    expect(GroveLanguage.choice.value, 'fr');
    expect(
      (await SharedPreferences.getInstance()).getString('interfaceLanguage'),
      'fr',
    );
    expect(
      find.text(
        groveText(
          'Menus, main controls and Forest Edge lessons are translated. Item descriptions, later stories, legal notices and some summaries remain in English.',
          'fr',
        ),
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Fermer'));
    await tester.tap(find.text('Fermer'));
    await _frames(tester);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test(
    'real sign renderer fits translated bubble without changing session text',
    () async {
      final game = EmberGame(levelId: 'w1_l1', seedOverride: 42);
      game.onGameResize(Vector2(568, 320));
      await game.onLoad();
      game.mount();
      await game.ready();
      game.update(0);
      final bubble = game.world.children
          .whereType<SignBubbleComponent>()
          .single;
      final sign = game.session.signs.first;
      final body = game.session.player.body;
      body.x = sign.x - body.w / 2;
      body.y = sign.y - body.h / 2;
      final original = sign.text;
      for (final code in ['fr', 'es', 'pt', 'en']) {
        game.interfaceLanguage = code;
        final recorder = ui.PictureRecorder();
        game.render(ui.Canvas(recorder));
        recorder.endRecording().dispose();
        expect(bubble.lastRect, isNotNull);
        expect(
          bubble.lastRect!.width,
          lessThanOrEqualTo(EmberGame.viewWidth - 4),
        );
        expect(game.session.activeSign!.text, original);
      }
      game.onRemove();
    },
  );
}
