// World 2 content acceptance (P-M9): every Cinder Depths level parses +
// lints clean, meets the spec quotas, uses the cave environment, spawns the
// new enemies, is bot-completable, and the world unlocks only after the
// World 1 boss falls.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/core_loadout.dart';
import 'package:pyregrove/game/enemies/boss_core.dart';
import 'package:pyregrove/game/enemies/enemy_core.dart';
import 'package:pyregrove/game/input_intent.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/mimic_disguise.dart';
import 'package:pyregrove/game/session.dart';
import 'package:pyregrove/game/tuning.dart';
import 'package:pyregrove/meta/progress_state.dart';

import 'reachability_test.dart' as reach;

LevelData load(String id) =>
    LevelData.parse(File('assets/levels/$id.txt').readAsStringSync());

// Gap budget a level may require: MUST stay below the measured double-jump
// range at full run (6.33 tiles, pinned in test/jump_arc_test.dart
// "double jump at run speed"). Was 7 — above the measured range, i.e. the
// gate could certify an uncrossable gap; found in the 2026-09-02 suite
// audit. All shipped levels currently measure widestGap = 0 (every column
// has a floor), so this gate only bites future bottomless-gap content.
const maxGapTiles = 6;

int widestGap(LevelData l) {
  var widest = 0, run = 0;
  for (var x = 0; x < l.width; x++) {
    var standable = false;
    for (var y = 0; y < l.height; y++) {
      final t = l.tiles[y][x];
      if (t == TileKind.solid || t == TileKind.platform) {
        standable = true;
        break;
      }
    }
    if (standable) {
      run = 0;
    } else {
      run++;
      if (run > widest) widest = run;
    }
  }
  return widest;
}

void main() {
  test('registry and files agree (every kWorld2 level exists)', () {
    for (final e in kWorld2) {
      expect(
        File('assets/levels/${e.id}.txt').existsSync(),
        isTrue,
        reason: '${e.id} missing',
      );
    }
  });

  test('world 2 unlocks only after the World 1 boss', () {
    final fresh = SaveData();
    expect(isWorld2Unlocked(fresh), isFalse);
    expect(isLevelUnlocked(fresh, 0, world: kWorld2), isFalse);
    fresh.levels['w1_boss'] = LevelRecord()..finished = true;
    expect(isWorld2Unlocked(fresh), isTrue);
    expect(isLevelUnlocked(fresh, 0, world: kWorld2), isTrue);
    // ...but only the first level; the rest still chain-unlock.
    expect(isLevelUnlocked(fresh, 1, world: kWorld2), isFalse);
  });

  // The World 2 bonus level (alpha.23) is held to every World 2 rule.
  for (final entry in [...kWorld2, kBonusLevels[1]]) {
    group(entry.id, () {
      test('parses + lints clean, cave environment', () {
        final l = load(entry.id);
        expect(l.name, entry.title);
        expect(l.environment, 'cave');
      });

      test('door reachable: no gap wider than the double-jump budget', () {
        expect(widestGap(load(entry.id)), lessThanOrEqualTo(maxGapTiles));
      });

      if (!entry.isBoss) {
        test('content quotas: chests 2-7, secrets >=2, feathers 1-3', () {
          final l = load(entry.id);
          expect(l.chestCount, inInclusiveRange(2, 7));
          expect(l.secretCount, greaterThanOrEqualTo(2));
          expect(l.featherCount, inInclusiveRange(1, 3));
        });

        test('every secret chest sits behind cracked walls', () {
          final l = load(entry.id);
          for (final s in l.spawns.where(
            (s) => s.kind == SpawnKind.secretChest,
          )) {
            expect(
              _crackedNear(l, s.x, s.y),
              isTrue,
              reason: 'secret at (${s.x},${s.y}) unguarded',
            );
          }
        });

        test('scripted runner bot reaches the door (completable)', () {
          expect(
            botCanFinish(entry.id),
            isTrue,
            reason: '${entry.id} not completable by the runner bot',
          );
        });
      }

      test('spawns the expected entities in a live session', () {
        final l = load(entry.id);
        final s = LevelSession(l, Loadout.starter(), seed: 7);
        if (entry.isBoss) {
          // w2_boss fields the Kiln Golem — its own core, not a Grove reskin.
          expect(s.enemies.whereType<KilnGolemCore>().length, 1);
          expect(
            s.enemies.whereType<GroveGolemCore>(),
            isEmpty,
            reason: 'W2 boss must not reuse the World 1 boss core',
          );
          expect(s.exitLocked, isTrue);
        } else {
          expect(
            s.enemies.whereType<SootCreeperCore>(),
            isNotEmpty,
            reason: 'W2 signature walker missing in ${entry.id}',
          );
        }
      });
    });
  }

  test('divers appear from w2_l2 onward (progressive introduction)', () {
    for (final id in ['w2_l2', 'w2_l3', 'w2_l4', 'w2_l5']) {
      final s = LevelSession(load(id), Loadout.starter(), seed: 7);
      expect(
        s.enemies.whereType<CinderDiverCore>(),
        isNotEmpty,
        reason: '$id should field Cinder Divers',
      );
    }
  });

  // LEVEL-CRAFT-BACKLOG L1 (alpha.23): World 2 mimics. In caves the mimic
  // wears the shroom cluster, so every cave mimic must stand within a few
  // tiles of a real shroom decor — otherwise the disguise is a lone prop
  // that fools nobody (and the reveal is a cheap shot, not a twist).
  test('cave mimics stand near real shrooms and W2 fields at least two', () {
    var total = 0;
    for (final id in kWorld2.map((e) => e.id)) {
      final lv = load(id);
      if (lv.environment != 'cave') continue;
      final mimics = lv.spawns
          .where((sp) => sp.kind == SpawnKind.brambleMimic)
          .toList();
      total += mimics.length;
      for (final m in mimics) {
        final near = lv.decor.any(
          (d) =>
              d.kind == DecorKind.shrooms &&
              (d.x - m.x).abs() <= 4 &&
              (d.y - m.y).abs() <= 1,
        );
        expect(
          near,
          isTrue,
          reason: '$id mimic at (${m.x},${m.y}) has no shrooms within 4 cols',
        );
      }
    }
    expect(
      total,
      greaterThanOrEqualTo(2),
      reason: 'World 2 should field at least two Spore Mimics',
    );
  });

  test('mimic disguise follows the environment', () {
    expect(mimicDisguiseAsset('cave'), 'props/shrooms.png');
    expect(mimicDisguiseAsset('forest'), 'props/bush.png');
    expect(mimicRevealTint('cave'), isNot(mimicRevealTint('forest')));
  });

  // LEVEL-CRAFT-BACKLOG L4 (alpha.23): Ember Vault's high chest is a
  // denial-and-reward beat. It is on screen from the vault floor but sits
  // six rows up — beyond the double jump — and is only reached by climbing
  // the platforms outside, walking back along the vault roof and dropping
  // through the hole. Proof: with the hole sealed the same chest becomes
  // unreachable under the shipped reachability model.
  test('w2_l2 high chest is reachable only through the roof hole (L4)', () {
    final g = reach.loadGrid('w2_l2');
    const hole = [90, 91];
    const roofRow = 5;
    for (final x in hole) {
      expect(g[roofRow][x], '.', reason: 'roof hole at ($x,$roofRow)');
    }
    // The ledge below the hole: '#' at row 10, chest at (91,9) on it.
    expect(g[9][91], 'C');
    expect(g[10][90], '#');
    expect(g[10][91], '#');
    expect(reach.unreachableTargets(g), isEmpty);

    final sealed = List<String>.from(g);
    final row = sealed[roofRow].split('');
    for (final x in hole) {
      row[x] = '#';
    }
    sealed[roofRow] = row.join();
    expect(
      reach.unreachableTargets(sealed),
      contains('C@(91,9)'),
      reason: 'without the roof hole the reward must be denied',
    );
  });
}

bool _crackedNear(LevelData l, int x, int y) {
  for (var dy = -2; dy <= 2; dy++) {
    for (var dx = -3; dx <= 3; dx++) {
      final tx = x + dx, ty = y + dy;
      if (tx < 0 || tx >= l.width || ty < 0 || ty >= l.height) continue;
      if (l.tiles[ty][tx] == TileKind.crackedWall) return true;
    }
  }
  return false;
}

/// Same scripted runner bot as world1_levels_test (geometry-only check).
bool botCanFinish(String id) {
  final l = load(id);
  final s = LevelSession(l, Loadout.starter(), seed: 11);
  const dt = 1 / 60;
  final intent = InputIntent();
  var airJumped = false;
  const frames = 240 * 60;
  for (var i = 0; i < frames; i++) {
    final b = s.player.body;
    final dir = s.exitX >= b.centerX ? 1.0 : -1.0;
    intent
      ..dirX = dir
      ..down = false
      ..jumpHeld = true;
    intent.clearEdges();
    s.player.hearts = 3;
    bool solidish(TileKind t) =>
        t == TileKind.solid ||
        t == TileKind.platform ||
        t == TileKind.crackedWall;
    if (b.onGround) {
      airJumped = false;
      final tx = dir > 0
          ? ((b.right + 6) / kTileSize).floor()
          : ((b.left - 6) / kTileSize).floor();
      final footTy = ((b.bottom + 1) / kTileSize).floor();
      final gapAhead =
          !solidish(s.tileAt(tx, footTy)) &&
          !solidish(s.tileAt(tx, footTy + 1));
      final wallAhead =
          solidish(s.tileAt(tx, ((b.top + 2) / kTileSize).floor())) ||
          solidish(s.tileAt(tx, ((b.bottom - 2) / kTileSize).floor()));
      if (gapAhead || wallAhead) intent.jumpPressed = true;
    } else if (b.vy > 30 && !airJumped) {
      intent.jumpPressed = true;
      airJumped = true;
    }
    if (i % 12 == 0) intent.attackPressed = true;
    s.update(dt, intent);
    if (s.completed) return true;
    if (s.failed) return false;
  }
  return false;
}
