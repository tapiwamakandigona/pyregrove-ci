// Every enemy in every shipped level must start (and stay) out of the rock. Rootway Ruins' second hopper was placed at hopper2=96,15, inside
// the 92-98 x 13-15 ledge block: it sat buried in the rock for the whole
// run, drawn over the stone and impossible to reach (polish loop P-BUGS,
// 2026-09-27).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/core_loadout.dart';
import 'package:pyregrove/game/input_intent.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/session.dart';
import 'package:pyregrove/game/tuning.dart';

bool _solid(TileKind t) => t == TileKind.solid || t == TileKind.crackedWall;

/// True when the body's centre sits inside a solid tile: the enemy is
/// buried, not merely touching a wall or floor edge (a few px of spawn
/// contact is resolved by physics on the first step).
bool _buried(LevelSession s, double cx, double cy) =>
    _solid(s.tileAt((cx / kTileSize).floor(), (cy / kTileSize).floor()));

void main() {
  final ids =
      Directory('assets/levels')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.txt'))
          .map((f) => f.uri.pathSegments.last.replaceAll('.txt', ''))
          .toList()
        ..sort();

  test('the campaign has levels to check', () {
    expect(ids.length, greaterThanOrEqualTo(14));
  });

  for (final id in ids) {
    test('$id: no enemy spawns buried in solid tiles', () {
      final level = LevelData.parse(
        File('assets/levels/$id.txt').readAsStringSync(),
      );
      final s = LevelSession(level, Loadout.starter(), seed: 1);
      for (final e in s.enemies) {
        final b = e.body;
        expect(
          _buried(s, b.centerX, b.centerY),
          isFalse,
          reason:
              '${e.runtimeType} at (${b.x.toStringAsFixed(0)},'
              '${b.y.toStringAsFixed(0)}) spawns inside rock in $id',
        );
      }
    });

    test('$id: no enemy is still buried after 3 s of play', () {
      final level = LevelData.parse(
        File('assets/levels/$id.txt').readAsStringSync(),
      );
      final s = LevelSession(level, Loadout.starter(), seed: 1);
      final input = InputIntent();
      for (var f = 0; f < 180; f++) {
        s.player.hearts = s.player.maxHearts;
        s.update(1 / 60, input);
      }
      for (final e in s.enemies.where((e) => e.alive)) {
        final b = e.body;
        expect(
          _buried(s, b.centerX, b.centerY),
          isFalse,
          reason:
              '${e.runtimeType} is still inside rock at '
              '(${b.centerX.toStringAsFixed(0)},${b.centerY.toStringAsFixed(0)}) '
              'in $id',
        );
      }
    });
  }
}
