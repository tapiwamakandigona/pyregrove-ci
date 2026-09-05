import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/session.dart';
import 'package:pyregrove/meta/progress_state.dart';
import 'package:pyregrove/ui/game_screen.dart';

LevelResults _results() => LevelResults(
  finished: true,
  allChests: false,
  lowDamage: false,
  timeMs: 61000,
  parSeconds: 120,
  coinsEarned: 10,
  chestsOpened: 1,
  chestTotal: 3,
  secretsFound: 0,
  hitsTaken: 2,
);

void main() {
  testWidgets('results overlay offers Next level when a successor exists', (
    tester,
  ) async {
    var next = 0, cont = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ResultsOverlay(
          results: _results(),
          onReplay: () {},
          onContinue: () => cont++,
          onNext: () => next++,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('Next level'), findsOneWidget);
    expect(find.text('Levels'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
    await tester.tap(find.text('Next level'));
    expect(next, 1);
    expect(cont, 0);
  });

  testWidgets('results overlay shows the hit count beside the medals', (
    tester,
  ) async {
    // A missed low-damage medal must explain itself the way a missed
    // all-chests medal does via "Chests 1/3": the stat line carries Hits.
    await tester.pumpWidget(
      MaterialApp(
        home: ResultsOverlay(
          results: _results(),
          onReplay: () {},
          onContinue: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.textContaining('Chests 1/3'), findsOneWidget);
    expect(find.textContaining('Hits 2'), findsOneWidget);
    expect(find.text('Low damage'), findsOneWidget);
  });

  testWidgets('results overlay falls back to Continue at the end', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultsOverlay(
          results: _results(),
          onReplay: () {},
          onContinue: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Next level'), findsNothing);
  });

  testWidgets('results overlay lists what a first boss clear unlocked', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultsOverlay(
          results: _results(),
          unlocks: unlocksOnFirstClear('w1_boss'),
          onReplay: () {},
          onContinue: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    expect(
      find.textContaining('UNLOCKED  World 2 — Cinder Depths'),
      findsOneWidget,
    );
    expect(
      find.textContaining('UNLOCKED  Bonus — Ember Hollow'),
      findsOneWidget,
    );
  });

  test('unlocksOnFirstClear: only the two gates open anything', () {
    expect(unlocksOnFirstClear('w1_boss').length, 2);
    expect(unlocksOnFirstClear('w2_boss'), ['Bonus — Slag Cellar']);
    for (final id in ['w1_l1', 'w1_l5', 'w2_l3', 'w1_bonus', 'w2_bonus']) {
      expect(unlocksOnFirstClear(id), isEmpty, reason: id);
    }
  });
}
