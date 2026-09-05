// back_gesture_test.dart — the system back gesture must never dump a live
// run back to the menu. GameScreen wraps the game in PopScope(canPop:false)
// and routes back through resolveBackIntent: playing -> pause menu, paused ->
// resume, results/fail -> leave. Also covers the pre-load crash guard:
// pauseGame() before onLoad (Home/lock or back on the loading screen) used to
// hit the late-initialized `session` and throw.
import 'dart:ui' show AppLifecycleState;

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart' show SizedBox;
import 'package:flutter_test/flutter_test.dart';

import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/ui/app_state.dart';
import 'package:pyregrove/ui/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('resolveBackIntent truth table', () {
    test('mid-run back opens the pause menu', () {
      expect(
          resolveBackIntent(
              loaded: true, endOverlayShown: false, pauseShown: false),
          BackIntent.pauseMenu);
    });

    test('back while paused resumes (closes the topmost UI)', () {
      expect(
          resolveBackIntent(
              loaded: true, endOverlayShown: false, pauseShown: true),
          BackIntent.resume);
    });

    test('back on results/fail leaves — that run is already over', () {
      expect(
          resolveBackIntent(
              loaded: true, endOverlayShown: true, pauseShown: false),
          BackIntent.leave);
      // Fail overlay + a stale pause flag still leaves: end state wins.
      expect(
          resolveBackIntent(
              loaded: true, endOverlayShown: true, pauseShown: true),
          BackIntent.leave);
    });

    test('back before the level finished loading just leaves', () {
      expect(
          resolveBackIntent(
              loaded: false, endOverlayShown: false, pauseShown: false),
          BackIntent.leave);
    });
  });

  group('pre-load pause guard', () {
    test('pauseGame and lifecycle backgrounding before onLoad do not throw',
        () {
      AppState.diskWrites = false;
      AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
      final game = EmberGame(levelId: 'w1_l1', seedOverride: 42);
      // No onLoad: `session` is still uninitialized. Both entry points that
      // can fire during the loading screen must be safe no-ops.
      expect(game.pauseGame, returnsNormally);
      expect(() => game.lifecycleStateChange(AppLifecycleState.paused),
          returnsNormally);
      expect(game.overlays.isActive(EmberGame.overlayPause), isFalse);
    });

    test('pauseGame still works normally after load', () async {
      AppState.diskWrites = false;
      AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
      final game = EmberGame(levelId: 'w1_l1', seedOverride: 42);
      game.overlays.addEntry(
          EmberGame.overlayPause, (context, game) => const SizedBox());
      game.onGameResize(Vector2(800, 450));
      await game.onLoad();
      game.mount();
      await game.ready();
      game.update(0);
      game.pauseGame();
      expect(game.overlays.isActive(EmberGame.overlayPause), isTrue);
      expect(game.paused, isTrue);
    });
  });
}
