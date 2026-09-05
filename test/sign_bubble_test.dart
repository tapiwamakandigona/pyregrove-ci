// The tutorial-sign bubble must never be covered by the things it explains.
// Found on the w1_l2 Ashbat sign (2026-09-02): the bubble was drawn by
// ItemsComponent at priority 1, the bat at 2 — the last word was under the
// bat's wing. SignBubbleComponent now draws above enemies, player and fx.
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/components/enemy_component.dart';
import 'package:pyregrove/game/components/items_component.dart';
import 'package:pyregrove/game/components/player_component.dart';
import 'package:pyregrove/game/components/sign_bubble.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/game/tuning.dart';
import 'package:pyregrove/ui/app_state.dart';

Future<EmberGame> _boot(String id) async {
  final game = EmberGame(levelId: id, seedOverride: 42);
  game.onGameResize(Vector2(800, 450));
  await game.onLoad();
  game.mount();
  await game.ready();
  game.update(0);
  return game;
}

/// Teleport the player onto tile (tx, ty) exactly like the web harness.
void _teleport(EmberGame game, int tx, int ty) {
  final b = game.session.player.body;
  b.x = tx * kTileSize + (kTileSize - b.w) / 2;
  b.y = (ty + 1) * kTileSize - b.h;
  b.vx = 0;
  b.vy = 0;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    AppState.diskWrites = false;
    AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
  });

  test('bubble layer sits above every enemy, the player and items', () async {
    final game = await _boot('w1_l2');
    final bubbles = game.world.children.whereType<SignBubbleComponent>();
    expect(bubbles.length, 1, reason: 'exactly one bubble layer per level');
    final bubble = bubbles.single;
    final enemies = game.world.children.whereType<EnemyComponent>().toList();
    expect(enemies, isNotEmpty);
    for (final e in enemies) {
      expect(
        bubble.priority,
        greaterThan(e.priority),
        reason: 'enemy ${e.core.kind} would draw over the sign text',
      );
    }
    final player = game.world.children.whereType<PlayerComponent>().single;
    expect(bubble.priority, greaterThan(player.priority));
    final items = game.world.children.whereType<ItemsComponent>().single;
    expect(bubble.priority, greaterThan(items.priority));
  });

  test(
    'w1_l2 Ashbat sign: bubble is drawn and stays inside the view',
    () async {
      final game = await _boot('w1_l2');
      // Sign 3 (row-major) stands at col 76, row 15 — the Ashbat sign.
      _teleport(game, 75, 15);
      game.update(1 / 60);
      final active = game.session.activeSign;
      expect(active, isNotNull);
      expect(active!.text, contains('Ashbats'));

      final bubble = game.world.children
          .whereType<SignBubbleComponent>()
          .single;
      final rec = ui.PictureRecorder();
      game.render(ui.Canvas(rec));
      rec.endRecording();
      final r = bubble.lastRect;
      expect(r, isNotNull, reason: 'bubble did not draw');
      final cam = game.cameraPos;
      expect(r!.left, greaterThanOrEqualTo(cam.x - EmberGame.viewWidth / 2));
      expect(r.right, lessThanOrEqualTo(cam.x + EmberGame.viewWidth / 2));
      expect(r.top, greaterThanOrEqualTo(cam.y - EmberGame.viewHeight / 2));
      expect(
        r.width,
        lessThanOrEqualTo(SignBubbleComponent.kBubbleMaxWidth + 6),
      );
    },
  );

  test('no sign: nothing drawn, no stale rect', () async {
    final game = await _boot('w1_l2');
    // Spawn is not next to a sign in w1_l2 (sign 1 is at col 9).
    _teleport(game, 20, 15);
    game.update(1 / 60);
    expect(game.session.activeSign, isNull);
    final bubble = game.world.children.whereType<SignBubbleComponent>().single;
    final rec = ui.PictureRecorder();
    game.render(ui.Canvas(rec));
    rec.endRecording();
    expect(bubble.lastRect, isNull);
  });
}
