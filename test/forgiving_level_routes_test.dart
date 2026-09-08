// Additive geometry check: same door-seeking intent as the existing World 1
// and World 2 tests, but using the real default SaveData -> Loadout path.
// Infinite health deliberately isolates geometry; this is NOT combat balance
// evidence or a proof that every optional secret is reachable.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/core_loadout.dart';
import 'package:pyregrove/game/input_intent.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/session.dart';
import 'package:pyregrove/game/tuning.dart';
import 'package:pyregrove/meta/progress_state.dart';

void main() {
  for (final entry in [
    ...kWorld1,
    ...kWorld2,
    ...kBonusLevels,
  ].where((level) => !level.isBoss)) {
    test('forgiving traversal reaches ${entry.id} exit', () {
      final level = LevelData.parse(
        File('assets/levels/${entry.id}.txt').readAsStringSync(),
      );
      final session = LevelSession(
        level,
        Loadout.fromSave(SaveData()),
        seed: 11,
      );
      final intent = InputIntent();
      var airJumped = false;
      for (var frame = 0; frame < 240 * 60 && !session.over; frame++) {
        final body = session.player.body;
        final direction = session.exitX >= body.centerX ? 1.0 : -1.0;
        intent
          ..dirX = direction
          ..down = false
          ..jumpHeld = true;
        intent.clearEdges();
        session.player.hearts = 3;
        bool standable(TileKind tile) =>
            tile == TileKind.solid ||
            tile == TileKind.platform ||
            tile == TileKind.crackedWall;
        if (body.onGround) {
          airJumped = false;
          final x = direction > 0
              ? ((body.right + 6) / kTileSize).floor()
              : ((body.left - 6) / kTileSize).floor();
          final feet = ((body.bottom + 1) / kTileSize).floor();
          final gap =
              !standable(session.tileAt(x, feet)) &&
              !standable(session.tileAt(x, feet + 1));
          final wall =
              standable(
                session.tileAt(x, ((body.top + 2) / kTileSize).floor()),
              ) ||
              standable(
                session.tileAt(x, ((body.bottom - 2) / kTileSize).floor()),
              );
          if (gap || wall) intent.jumpPressed = true;
        } else if (body.vy > 30 && !airJumped) {
          intent.jumpPressed = true;
          airJumped = true;
        }
        if (frame % 12 == 0) intent.attackPressed = true;
        session.update(1 / 60, intent);
      }
      expect(
        session.completed,
        isTrue,
        reason:
            '${entry.id}: x=${session.player.body.x} '
            'y=${session.player.body.y} deaths=${session.deaths}',
      );
    });
  }
}
