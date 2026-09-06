// Screenshot generator for the world map (real Cinzel/Inter fonts). Runs only with
//   flutter test test/level_select_screens_test.dart --dart-define=SCREENS=true --update-goldens
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/ui/app_state.dart';
import 'package:pyregrove/ui/level_select_screen.dart';

const _on = bool.fromEnvironment('SCREENS');

Future<void> _font(String family, String path) async {
  final data = File(path).readAsBytesSync();
  await (FontLoader(family)..addFont(Future.value(ByteData.view(data.buffer)))).load();
}

void main() {
  setUpAll(() async {
    await _font('Cinzel', 'assets/fonts/Cinzel-Variable.ttf');
    await _font('Inter', 'assets/fonts/Inter-Regular.ttf');
  });
  setUp(() {
    final tmp = Directory.systemTemp.createTempSync('pyre_screens_');
    AppState.init(store: SaveStore(baseDirOverride: tmp), save: SaveData());
    AppState.diskWrites = false;
  });
  tearDown(() => AppState.diskWrites = true);

  testWidgets('world map, landscape phone, partial progress', (tester) async {
    tester.view.physicalSize = const Size(2340, 1080);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final save = AppState.save;
    save.coins = 300;
    for (final id in ['w1_l1', 'w1_l2', 'w1_l3']) {
      save.recordFor(id)
        ..finished = true
        ..allChests = id != 'w1_l3'
        ..lowDamage = id == 'w1_l1'
        ..bestTimeMs = 61000;
    }
    save.recordFor('w1_l4').finished = true;
    await tester.pumpWidget(const MaterialApp(debugShowCheckedModeBanner: false, home: LevelSelectScreen()));
    await tester.pumpAndSettle();
    await expectLater(find.byType(LevelSelectScreen), matchesGoldenFile('../docs/screens/level-select-v2.png'));
  }, skip: !_on);
}
