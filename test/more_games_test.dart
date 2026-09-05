// Owner directive 2026-09-05b: one quiet "More from Tsoro Studios" row at the
// bottom of Settings.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/ui/app_state.dart';
import 'package:pyregrove/ui/more_games.dart';
import 'package:pyregrove/ui/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('pyre_more_');
    AppState.init(store: SaveStore(baseDirOverride: tmp), save: SaveData());
    AppState.diskWrites = false;
  });
  tearDown(() {
    AppState.diskWrites = true;
    tmp.deleteSync(recursive: true);
  });

  test('entries and URLs', () {
    expect(kMoreGames.map((g) => g.name), ['Emberdelve', 'Fliptide']);
    expect(
      kEmberdelve.marketUri.toString(),
      'market://details?id=com.tsorostudios.emberdelve&referrer=utm_source%3Dpyregrove',
    );
    expect(kEmberdelve.httpsUri.toString(),
        'https://play.google.com/store/apps/details?id=com.tsorostudios.emberdelve');
    expect(kFliptide.httpsUri.toString(), 'https://tsorostudios.itch.io/fliptide');
    expect(kFliptide.preferWeb, isTrue, reason: 'not on Play yet');
  });

  test('Android tries market:// first and falls back to https', () async {
    final tried = <Uri>[];
    Future<bool> failMarket(Uri u,
        {LaunchMode mode = LaunchMode.platformDefault}) async {
      tried.add(u);
      expect(mode, LaunchMode.externalApplication);
      return u.scheme != 'market';
    }

    expect(
        await openMoreGame(kEmberdelve,
            launcher: failMarket, platform: TargetPlatform.android, isWeb: false),
        isTrue);
    expect(tried.map((u) => u.scheme), ['market', 'https']);
    tried.clear();
    expect(
        await openMoreGame(kFliptide,
            launcher: failMarket, platform: TargetPlatform.android, isWeb: false),
        isTrue);
    expect(tried, [kFliptide.httpsUri], reason: 'straight to itch while not on Play');
    tried.clear();
    expect(
        await openMoreGame(kEmberdelve,
            launcher: failMarket, platform: TargetPlatform.android, isWeb: true),
        isTrue);
    expect(tried.map((u) => u.scheme), ['https'], reason: 'web never market://');
  });

  testWidgets('Settings shows the row at the bottom, below Reset save',
      (tester) async {
    tester.view.physicalSize = const Size(412, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('MORE FROM TSORO STUDIOS'), findsOneWidget);
    expect(find.text('Emberdelve'), findsOneWidget);
    expect(find.text('Fliptide'), findsOneWidget);
    final reset = tester.getBottomLeft(find.text('Reset save'));
    final row = tester.getTopLeft(find.byKey(const Key('more-from-tsoro')));
    expect(row.dy, greaterThan(reset.dy), reason: 'row is the last section');
  });

  testWidgets('tapping an entry calls the opener once with that game',
      (tester) async {
    final opened = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MoreFromTsoro(onOpen: (g) async {
          opened.add(g.name);
          return true;
        }),
      ),
    ));
    await tester.tap(find.byKey(const Key('more-com.tsorostudios.fliptide')));
    await tester.pump();
    expect(opened, ['Fliptide']);
  });
}
