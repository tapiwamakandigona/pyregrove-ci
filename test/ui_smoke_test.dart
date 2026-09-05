import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/main.dart';
import 'package:pyregrove/ui/app_state.dart';
import 'package:pyregrove/ui/game_screen.dart';
import 'package:pyregrove/ui/level_select_screen.dart';

void main() {
  late Directory tmp;
  setUp(() {
    tmp = Directory.systemTemp.createTempSync('ember_ui_');
    AppState.init(
      store: SaveStore(baseDirOverride: tmp),
      save: SaveData(),
    );
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  testWidgets('title screen renders; PLAY on a fresh save opens Forest Edge '
      'directly (alpha.23 first run)', (tester) async {
    await tester.pumpWidget(const PyregroveApp());
    expect(find.text('PYREGROVE'), findsOneWidget);
    await tester.tap(find.text('PLAY'));
    // M4 title runs a looping parallax drift — pumpAndSettle would never
    // settle; pump the route transition explicitly instead.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('WORLD 1 — THE PYREGROVE'), findsNothing);
    final screen = tester.widget<GameScreen>(find.byType(GameScreen));
    expect(screen.levelId, 'w1_l1');
  });

  testWidgets('PLAY navigates to level select once a level is finished', (
    tester,
  ) async {
    AppState.save.recordFor('w1_l1').finished = true;
    await tester.pumpWidget(const PyregroveApp());
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('WORLD 1 — THE PYREGROVE'), findsOneWidget);
    expect(find.text('Forest Edge'), findsOneWidget);
  });

  testWidgets('level select locks later levels', (tester) async {
    // Tall surface so the lazy ListView builds all three sections.
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(const MaterialApp(home: LevelSelectScreen()));
    await tester.pumpAndSettle();
    // 5 locked in W1 + all 6 locked in the gated W2 section + 2 bonus.
    expect(find.byIcon(Icons.lock), findsNWidgets(13));
    expect(find.text('Ember Hollow'), findsOneWidget);
    expect(
      find.text('Defeat the Grove Golem to open the hollow'),
      findsOneWidget,
    );
    AppState.save.recordFor('w1_l1').finished = true;
    await tester.pumpWidget(const MaterialApp(home: LevelSelectScreen()));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.lock), findsNWidgets(12));
    // Golem down: World 2's first level and the bonus open together.
    AppState.save.recordFor('w1_boss').finished = true;
    await tester.pumpWidget(const MaterialApp(home: LevelSelectScreen()));
    await tester.pumpAndSettle();
    expect(
      find.byIcon(Icons.star),
      findsOneWidget,
      reason: 'one bonus badge: Slag Cellar still waits for the Kiln Golem',
    );
    expect(find.text('BONUS — THE GROVE\'S PURSE'), findsOneWidget);
    expect(
      find.text('Defeat the Kiln Golem to open the cellar'),
      findsOneWidget,
    );
  });
}
