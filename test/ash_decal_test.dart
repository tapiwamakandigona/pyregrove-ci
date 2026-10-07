// B4 kill permanence: grounded non-boss kills emit ashLeft at the feet; the
// decal registry caps live decals per level and evicts oldest-first.
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/components/ash_decal.dart';
import 'package:pyregrove/game/core_loadout.dart';
import 'package:pyregrove/game/input_intent.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/session.dart';
import 'package:pyregrove/game/tuning.dart';

const dt = 1 / 120;

// Player next to a thornling on flat ground; the exit is far right.
const arena = '''
############################
#..........................#
#..........................#
#..........................#
#.P..T...................E.#
############################
''';

void main() {
  test('grounded kill emits ashLeft at the foot point, after enemyDeath', () {
    final s = LevelSession(LevelData.parse(arena), Loadout.starter(), seed: 1);
    final seen = <SessionEvent>[];
    var t = 0.0;
    var frame = 0;
    while (t < 12 && s.kills == 0) {
      // Walk right and mash attack every 6th frame (edge-triggered).
      final intent = InputIntent()
        ..dirX = 1
        ..attackPressed = frame++ % 6 == 0;
      s.update(dt, intent);
      seen.addAll(s.takeEvents());
      t += dt;
    }
    expect(s.kills, 1, reason: 'the bot must kill the thornling');
    final death = seen.indexWhere((e) => e.kind == SessionEventKind.enemyDeath);
    final ash = seen.indexWhere((e) => e.kind == SessionEventKind.ashLeft);
    expect(death, isNonNegative);
    expect(ash, greaterThan(death));
    final a = seen[ash];
    // Floor row is y=5 tiles → foot point sits on the tile boundary.
    expect(a.y, closeTo(5 * kTileSize, 0.6));
    expect(a.w, greaterThan(0));
  });

  test('registry caps decals and evicts the oldest', () {
    final parent = Component();
    final reg = AshDecals(cap: 3);
    final first = reg.add(parent, Vector2(0, 0));
    reg.add(parent, Vector2(1, 0));
    reg.add(parent, Vector2(2, 0));
    expect(reg.count, 3);
    reg.add(parent, Vector2(3, 0));
    expect(reg.count, 3);
    expect(first.isRemoving || first.parent == null, isTrue,
        reason: 'oldest decal is evicted first');
  });

  test('decal removes itself after kAshDecalLife', () {
    final fx = AshDecalFx(Vector2.zero());
    final parent = Component()..add(fx);
    fx.update(kAshDecalLife - 0.01);
    expect(fx.isRemoving, isFalse);
    fx.update(0.02);
    expect(fx.isRemoving || fx.parent == null || parent.children.isEmpty,
        isTrue);
  });
}
