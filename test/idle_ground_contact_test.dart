// Owner-reported rapid crouch while idle (2026-09-10).
// Pin both collision contact and the real EmberGame -> landing squash path.
// The important cases are *not* exact multiples of 1/60: a tiny trailing
// substep must not manufacture a fall and another landing every frame.
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/components/player_component.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/game/input_intent.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/physics.dart';
import 'package:pyregrove/game/player/player_core.dart';
import 'package:pyregrove/ui/app_state.dart';

void frame(PlayerCore player, double dt, InputIntent input) {
  var remaining = math.min(dt, 4 / 60);
  while (remaining > 1e-9) {
    final step = math.min(remaining, 1 / 60);
    player.update(step, input);
    input.clearEdges();
    remaining -= step;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final floor in [TileKind.solid, TileKind.platform]) {
    TileKind tileAt(int x, int y) => y == 10 ? floor : TileKind.empty;
    for (final forgiving in [false, true]) {
      test(
        'idle stays grounded on $floor, forgiving=$forgiving, jittered dt',
        () {
          for (final dt in [
            1 / 60,
            1 / 90,
            1 / 120,
            0.01667,
            0.0167,
            0.017,
            1 / 59,
            1 / 30,
            0.03334,
          ]) {
            final player = PlayerCore(
              x: 64,
              y: 140,
              tileAt: tileAt,
              forgivingJumps: forgiving,
            );
            frame(player, 1 / 60, InputIntent());
            expect(player.body.onGround, isTrue);
            player.takeEvents(); // Initial placement is one honest landing.
            var landings = 0;
            var airborneFrames = 0;
            var idleFrames = 0;
            for (var i = 0; i < 120; i++) {
              frame(player, dt, InputIntent());
              landings += player
                  .takeEvents()
                  .where((event) => event == PlayerEvent.landed)
                  .length;
              if (!player.body.onGround) airborneFrames++;
              if (player.state == PlayerState.idle) idleFrames++;
            }
            expect(
              landings,
              0,
              reason: 'idle dt=$dt must not retrigger landing SFX/squash',
            );
            expect(airborneFrames, 0, reason: 'supported feet at dt=$dt');
            expect(idleFrames, 120, reason: 'no fall animation at dt=$dt');
            expect(player.body.y, 140, reason: 'no drift into the floor');
          }
        },
      );
    }
  }

  test(
    'a downward step shorter than collision epsilon still contacts floor',
    () {
      final b = Body(x: 64, y: 140, w: 12, h: 20)
        ..vy = 0.01
        ..onGround = true;
      integrate(
        b,
        0.00001,
        (x, y) => y == 10 ? TileKind.solid : TileKind.empty,
      );
      expect(b.onGround, isTrue);
      expect(b.y, 140);
      expect(b.vy, 0);
    },
  );

  test('tiny downward steps do not snap an airborne body onto a floor', () {
    final b = Body(x: 64, y: 139.9, w: 12, h: 20)..vy = 0.01;
    integrate(b, 0.00001, (x, y) => y == 10 ? TileKind.solid : TileKind.empty);
    expect(b.onGround, isFalse);
    expect(b.bottom, lessThan(160));
  });

  test('jittered jump lands once and then remains idle', () {
    final player = PlayerCore(
      x: 64,
      y: 140,
      tileAt: (x, y) => y == 10 ? TileKind.solid : TileKind.empty,
    );
    frame(player, 1 / 60, InputIntent());
    player.takeEvents();
    frame(
      player,
      0.017,
      InputIntent()
        ..jumpHeld = true
        ..jumpPressed = true,
    );
    expect(player.takeEvents(), contains(PlayerEvent.jumped));
    expect(player.body.onGround, isFalse);
    var landings = 0;
    for (var i = 0; i < 180; i++) {
      frame(player, i.isEven ? 0.01667 : 0.017, InputIntent());
      landings += player
          .takeEvents()
          .where((event) => event == PlayerEvent.landed)
          .length;
    }
    expect(landings, 1);
    expect(player.state, PlayerState.idle);
  });

  test('walking off a ledge still loses ground contact under jitter', () {
    final player = PlayerCore(
      x: 64,
      y: 140,
      tileAt: (x, y) => y == 10 && x < 6 ? TileKind.solid : TileKind.empty,
    );
    frame(player, 1 / 60, InputIntent());
    for (var i = 0; i < 35; i++) {
      frame(player, 0.017, InputIntent()..dirX = 1);
    }
    expect(player.body.left, greaterThan(96));
    expect(player.body.onGround, isFalse);
    expect(player.body.y, greaterThan(140));
  });

  test('down+jump still drops through a one-way platform under jitter', () {
    final player = PlayerCore(
      x: 64,
      y: 140,
      tileAt: (x, y) => y == 10 ? TileKind.platform : TileKind.empty,
    );
    frame(player, 1 / 60, InputIntent());
    player.takeEvents();
    frame(
      player,
      0.017,
      InputIntent()
        ..down = true
        ..jumpPressed = true,
    );
    expect(player.takeEvents(), contains(PlayerEvent.droppedThrough));
    for (var i = 0; i < 30; i++) {
      frame(player, 0.017, InputIntent()..down = true);
    }
    expect(player.body.onGround, isFalse);
    expect(player.body.y, greaterThan(160));
  });

  test(
    'real game idle lets squash expire instead of repeatedly crouching',
    () async {
      AppState.diskWrites = false;
      AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
      final game = EmberGame(levelId: 'w1_l1', seedOverride: 42);
      game.onGameResize(Vector2(800, 450));
      await game.onLoad();
      game.mount();
      await game.ready();
      // The shipped spawn is the fixture; no fake grounded/render flags.
      // Stay stationary and avoid long runs into the patrolling enemy.
      for (var i = 0; i < 30; i++) {
        game.update(1 / 60);
      }
      final component = game.world.children.whereType<PlayerComponent>().single;
      expect(component.squashActive, isFalse);
      final restY = game.session.player.body.y;
      var squashFrames = 0;
      for (var i = 0; i < 90; i++) {
        game.update(i.isEven ? 0.01667 : 0.017);
        if (component.squashActive) squashFrames++;
      }
      expect(
        squashFrames,
        0,
        reason: 'idle must not keep resetting the landing animation',
      );
      expect(game.session.player.state, PlayerState.idle);
      expect(game.session.player.body.y, restY);
      expect(component.hardSquashActive, isFalse);
      expect(component.stretchActive, isFalse);
    },
  );
}
