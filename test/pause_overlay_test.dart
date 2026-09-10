// pause_overlay_test.dart — alpha.23: the pause menu offers Restart level
// between Resume and Leave, and each button fires exactly its own callback.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/ui/game_screen.dart';

void main() {
  testWidgets('pause menu: Resume / Restart level / Leave level, each wired', (
    tester,
  ) async {
    var resume = 0, restart = 0, leave = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: PauseOverlay(
          onResume: () => resume++,
          onRestart: () => restart++,
          onLeave: () => leave++,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('PAUSED'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Restart level'), findsOneWidget);
    expect(find.text('Leave level'), findsOneWidget);
    // Order top-to-bottom: Resume, Restart, Leave.
    double y(String t) => tester.getCenter(find.text(t)).dy;
    expect(y('Resume'), lessThan(y('Restart level')));
    expect(y('Restart level'), lessThan(y('Leave level')));
    await tester.tap(find.text('Restart level'));
    expect((resume, restart, leave), (0, 1, 0));
    await tester.tap(find.text('Resume'));
    expect((resume, restart, leave), (1, 1, 0));
    await tester.tap(find.text('Leave level'));
    expect((resume, restart, leave), (1, 1, 1));
  });

  testWidgets('pause menu without onRestart hides the button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PauseOverlay(onResume: () {}, onLeave: () {}),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Restart level'), findsNothing);
  });
}
