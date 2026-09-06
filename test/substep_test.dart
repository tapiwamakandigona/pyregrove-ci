// substep_test.dart — low-end frame pacing: EmberGame.update must simulate
// the REAL elapsed wall time in <=1/60 sub-steps instead of clamping a slow
// frame to a single 1/30 step (which played the whole game in slow motion on
// sub-30fps devices). Catch-up is capped at 4/60s per frame, and input edges
// are delivered on the first sub-step only.
import 'package:flame/components.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/components/hud.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/ui/app_state.dart';

/// Canvas point of the centre of the HUD button with [iconPath] (see
/// hud_routing_test.dart for the transform derivation).
Offset buttonCentre(EmberGame game, String iconPath) {
  final b = game.camera.viewport.children
      .whereType<HudHoldButton>()
      .firstWhere((c) => c.iconPath == iconPath);
  final vx = b.position.x + b.size.x / 2;
  final vy = b.position.y + b.size.y / 2;
  return Offset(vx * 800 / EmberGame.viewWidth, vy * 800 / EmberGame.viewWidth);
}

Future<EmberGame> bootGame() async {
  AppState.diskWrites = false;
  AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
  final game = EmberGame(levelId: 'w1_l1', seedOverride: 42);
  game.onGameResize(Vector2(800, 450));
  await game.onLoad();
  game.mount();
  await game.ready();
  game.update(0);
  return game;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('sub-stepped frame pacing', () {
    test('a 20fps frame simulates its full 50ms, not a 1/30 slow-mo step',
        () async {
      final game = await bootGame();
      final t0 = game.session.time;
      game.update(0.05); // 20fps frame
      expect(game.session.time - t0, closeTo(0.05, 1e-9),
          reason: 'slow frames must not run the game in slow motion');
    });

    test('catch-up is capped at 4/60s per frame (no death spiral)', () async {
      final game = await bootGame();
      final t0 = game.session.time;
      game.update(0.5); // absurd hitch
      expect(game.session.time - t0, closeTo(4 / 60, 1e-9));
    });

    test('a normal 60fps frame is exactly one step', () async {
      final game = await bootGame();
      final t0 = game.session.time;
      game.update(1 / 60);
      expect(game.session.time - t0, closeTo(1 / 60, 1e-9));
    });

    test('slow-frame jump edge triggers exactly one jump', () async {
      final game = await bootGame();
      // Let spawn settle so the player is grounded.
      for (var i = 0; i < 60; i++) {
        game.update(1 / 60);
      }
      expect(game.session.player.body.vy.abs() < 1, isTrue,
          reason: 'player should be grounded before the jump test');
      // Tap the HUD jump button (full routing pipeline) and release before
      // the slow frame so only the press edge is in flight.
      final jumpBtn = buttonCentre(game, 'hud/icon_jump.png');
      game.handleTapDown(
          1, TapDownDetails(globalPosition: jumpBtn, localPosition: jumpBtn));
      game.handleTapUp(
          1,
          TapUpDetails(
              kind: PointerDeviceKind.touch,
              globalPosition: jumpBtn,
              localPosition: jumpBtn));
      game.update(0.05); // 3 sub-steps; edge must be consumed once
      final vyAfter = game.session.player.body.vy;
      expect(vyAfter, lessThan(0), reason: 'jump should have fired');
      // If the edge were re-delivered each sub-step, the jump buffer would
      // re-arm and a second takeoff could trigger after landing without any
      // new press. Land and verify no ghost jump occurs.
      for (var i = 0; i < 120; i++) {
        game.update(1 / 60);
      }
      expect(game.session.player.body.vy.abs() < 1, isTrue,
          reason: 'no ghost jump after landing');
    });
  });
}
