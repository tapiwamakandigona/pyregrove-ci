// Soot Creepers never stop at ledges — so what happens when the ledge ends
// in spikes or lava? Before alpha.23 they dropped in and wandered the trench
// forever (Ashen Gate shipped all three of its creepers that way). Now the
// hazard kills them (an ash puff, a kill), and they wake late enough that
// the player is there to see it.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/core_loadout.dart';
import 'package:pyregrove/game/difficulty.dart';
import 'package:pyregrove/game/enemies/enemy_core.dart';
import 'package:pyregrove/game/input_intent.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/session.dart';
import 'package:pyregrove/game/tuning.dart';

const dt = 1 / 60;

/// Creeper on a floor that ends in a 2-wide lava trench to its right.
final lavaRun = LevelData.parse('''
########################
........................
........................
........................
.P......S..........E....
##########..############
##########~~############
########################
''');

void run(LevelSession s, double seconds, {double? cameraX}) {
  for (var i = 0; i < (seconds / dt).round(); i++) {
    s.cameraX = cameraX ?? s.player.body.centerX;
    s.update(dt, InputIntent());
  }
}

void main() {
  test('a creeper that walks into lava dies and counts as a kill', () {
    final s = LevelSession(lavaRun, Loadout.starter(), seed: 1);
    final creeper = s.enemies.whereType<SootCreeperCore>().single;
    expect(creeper.hazardsKill, isTrue);
    // Awake (camera on top of it): walks to the player-side wall, turns,
    // then straight off the ledge into the trench.
    run(s, 12.0, cameraX: creeper.centerX);
    expect(creeper.alive, isFalse, reason: 'walked off into the trench');
    expect(s.kills, 1);
    final kinds = s.takeEvents().map((e) => e.kind).toSet();
    expect(kinds, contains(SessionEventKind.enemyDeath));
  });

  test('creepers keep the default patrol facing at spawn', () {
    // alpha.23 #33: spawning creepers turned toward the player flattened or
    // wiped the W2 ramp for the casual bot at every wake distance >= 20
    // tiles (w2_l5 medium 8 hits / 3 deaths). Patrol facing + 24-tile wake
    // gives medium 2/5/2/3/4/2 hits across w2_l1..bonus with no wipes.
    final s = LevelSession(lavaRun, Loadout.starter(), seed: 1);
    final creeper = s.enemies.whereType<SootCreeperCore>().single;
    expect(creeper.facing, 1);
  });

  test('other walkers keep ignoring hazards (only ledge-droppers opt in)', () {
    expect(ThornlingCore(x: 0, y: 0).hazardsKill, isFalse);
    expect(RotshieldCore(x: 0, y: 0).hazardsKill, isFalse);
  });

  test('creepers wake about a screen out, not 1.5 screens out', () {
    final s = LevelSession(lavaRun, Loadout.starter(), seed: 1);
    final creeper = s.enemies.whereType<SootCreeperCore>().single;
    final x0 = creeper.centerX;
    // Camera 30 tiles away: a thornling would be awake, a creeper is not.
    run(s, 2.0, cameraX: x0 - 30 * kTileSize);
    expect(creeper.sleeping, isTrue);
    expect(creeper.centerX, x0);
    expect(kCreeperWakeDistance, lessThan(kEnemySleepDistance));
    expect(
      kCreeperWakeDistance,
      greaterThan(176),
      reason: 'must wake before it is fully on screen (half-width 176)',
    );
    // Hard mode wakes them earlier (aggro 1.25), easy later (0.8).
    creeper.mods = DifficultyMods.hard;
    expect(creeper.wakeDistance, greaterThan(kCreeperWakeDistance));
  });

  test('Ashen Gate: the first creeper is a fight, the last one burns', () {
    final txt = File('assets/levels/w2_l1.txt').readAsStringSync();
    final s = LevelSession(LevelData.parse(txt), Loadout.starter(), seed: 1);
    final creepers = s.enemies.whereType<SootCreeperCore>().toList()
      ..sort((a, b) => a.centerX.compareTo(b.centerX));
    expect(creepers.length, 3);
    // Camera parked on #1 for 30 s: it stays on the upper floor
    // (cols 27..42) thanks to the lip — it is the level's real fight.
    for (var i = 0; i < (30 / dt).round(); i++) {
      s.cameraX = 34 * kTileSize;
      s.update(dt, InputIntent());
      final c1 = creepers[0].centerX / kTileSize;
      expect(
        c1,
        inInclusiveRange(27, 43),
        reason: 'creeper #1 left its patrol at t=${i * dt}',
      );
      expect(creepers[0].alive, isTrue);
    }
    // Camera on #2, then #3: they crawl into the spike trench / the lava
    // and burn — no creeper is left wading in a hazard (the pre-alpha.23
    // bug). #3 first comes at the player (wall at col 74), turns, then
    // marches 14 tiles into the lava — about 11 s from waking.
    run(s, 15.0, cameraX: 60 * kTileSize);
    expect(creepers[1].alive, isFalse);
    run(s, 14.0, cameraX: 84 * kTileSize);
    expect(creepers[2].alive, isFalse);
    expect(s.kills, 2);
    // Three signs: the third names the lesson on the gate approach.
    expect(s.signs.length, 3);
    expect(s.signs.last.text, contains('lava'));
  });
}
