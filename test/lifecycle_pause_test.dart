// lifecycle_pause_test.dart — backgrounding mid-run must land on the pause
// menu, not silently resume gameplay when the app returns (Flame's default
// lifecycleStateChange auto-resumes the engine). Regression for the lost
// v0.3.1 F3 wiring: AudioService.pauseAll/resumeAll existed but nothing
// called them after the dice->platformer pivot; main.dart now owns that via
// AppLifecycleListener, and EmberGame owns the pause-menu behaviour tested
// here.
import 'dart:ui' show AppLifecycleState;

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart' show SizedBox;
import 'package:flutter_test/flutter_test.dart';

import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/ui/app_state.dart';

Future<EmberGame> bootGame() async {
  AppState.diskWrites = false;
  AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
  final game = EmberGame(levelId: 'w1_l1', seedOverride: 42);
  // GameWidget normally registers overlay builders; stub the pause overlay
  // so the headless game can open it.
  game.overlays.addEntry(
      EmberGame.overlayPause, (context, game) => const SizedBox());
  game.onGameResize(Vector2(800, 450));
  await game.onLoad();
  game.mount();
  await game.ready();
  game.update(0);
  return game;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('app lifecycle', () {
    test('backgrounding mid-run opens the pause menu and stays paused',
        () async {
      final game = await bootGame();
      expect(game.paused, isFalse);
      game.lifecycleStateChange(AppLifecycleState.hidden);
      expect(game.paused, isTrue);
      expect(game.overlays.isActive(EmberGame.overlayPause), isTrue,
          reason: 'player must come back to the pause menu');
      // App returns: Flame's auto-resume must NOT kick in (pauseGame reset
      // the backgrounded flag) — the run resumes only via the menu button.
      game.lifecycleStateChange(AppLifecycleState.resumed);
      expect(game.paused, isTrue,
          reason: 'no surprise unpause on foregrounding');
      game.resumeGame();
      expect(game.paused, isFalse);
      expect(game.overlays.isActive(EmberGame.overlayPause), isFalse);
    });

    test('backgrounding while already paused is a no-op', () async {
      final game = await bootGame();
      game.pauseGame();
      expect(game.paused, isTrue);
      game.lifecycleStateChange(AppLifecycleState.paused);
      game.lifecycleStateChange(AppLifecycleState.resumed);
      expect(game.paused, isTrue);
      expect(game.overlays.isActive(EmberGame.overlayPause), isTrue);
    });
  });
}
