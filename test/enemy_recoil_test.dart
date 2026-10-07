// enemy_recoil_test.dart — hit recoil is render-layer only: a small jolt
// away from the player that eases out with the hurt flash. The core body
// must never move (gameplay untouched); bosses don't recoil (mass read).
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/components/enemy_component.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/ui/app_state.dart';

Future<EmberGame> bootGame(String levelId) async {
  AppState.diskWrites = false;
  AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
  final game = EmberGame(levelId: levelId, seedOverride: 42);
  game.onGameResize(Vector2(800, 450));
  await game.onLoad();
  game.mount();
  await game.ready();
  game.update(0);
  return game;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('enemy hit recoil', () {
    test('jolts away from the player, eases out, body never moves', () async {
      final game = await bootGame('w1_l1');
      final comp = game.world.children
          .whereType<EnemyComponent>()
          .firstWhere((c) => !c.core.sleeping,
              orElse: () =>
                  game.world.children.whereType<EnemyComponent>().first);
      final core = comp.core;
      // Freeze the enemy's own AI (behave is gated on !sleeping) so any body
      // movement in this test could only come from recoil bookkeeping.
      core.sleeping = true;
      final bodyX = core.body.x;
      // Put the player to the enemy's LEFT: recoil must point RIGHT (+).
      game.session.player.body.x = core.body.x - 40;
      core.damage(1);
      comp.update(0); // detect the fresh flash
      expect(comp.recoilDx, greaterThan(0),
          reason: 'recoil must push away from the player');
      final first = comp.recoilDx;
      // Flash decays in core.update; recoil must ease out with it.
      core.update(0.1, game.session.tileAt,
          playerX: game.session.player.body.centerX,
          playerY: game.session.player.body.centerY);
      comp.update(0.1);
      expect(comp.recoilDx, lessThan(first));
      expect(comp.recoilDx, greaterThanOrEqualTo(0));
      // And fully gone once the flash ends.
      core.hurtFlash = 0;
      expect(comp.recoilDx, 0);
      // The CORE body must be untouched: recoil is render-only.
      expect(core.body.x, bodyX,
          reason: 'recoil must never displace the physics body');
    });

    test('player on the right pushes the enemy left', () async {
      final game = await bootGame('w1_l1');
      final comp =
          game.world.children.whereType<EnemyComponent>().first;
      final core = comp.core;
      game.session.player.body.x = core.body.x + 40;
      core.damage(1);
      comp.update(0);
      expect(comp.recoilDx, lessThan(0));
    });
  });
}
