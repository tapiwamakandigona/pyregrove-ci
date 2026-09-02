// Grove Golem boss: phase thresholds, telegraphed attacks per phase,
// hazard damage windows, exit-door lock, and the victory burst.
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/core_loadout.dart';
import 'package:pyregrove/game/difficulty.dart';
import 'package:pyregrove/game/enemies/boss_core.dart';
import 'package:pyregrove/game/input_intent.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/session.dart';
import 'package:pyregrove/game/tuning.dart';

const dt = 1 / 120;

// A closed arena: player on the left, golem mid, door on the right.
const arena = '''
##############################
#............................#
#............................#
#............................#
#.P...........G............E.#
##############################
''';

LevelSession bossSession({int seed = 5}) {
  final s = LevelSession(LevelData.parse(arena), Loadout.starter(), seed: seed);
  // These suites exercise the attack cycle; skip the dormant intro (that
  // beat is covered by boss_wake_test.dart).
  s.enemies.whereType<BossCore>().single.wake();
  return s;
}

void step(LevelSession s, double seconds,
    [void Function(InputIntent)? config]) {
  final frames = (seconds / dt).round();
  final intent = InputIntent();
  for (var i = 0; i < frames; i++) {
    intent
      ..dirX = 0
      ..down = false
      ..jumpHeld = false;
    intent.clearEdges();
    config?.call(intent);
    s.update(dt, intent);
    if (s.over) return;
  }
}

void main() {
  test('legend G spawns the golem with full hp; exit is locked', () {
    final s = bossSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    expect(boss.hp, GroveGolemCore.maxHp);
    expect(boss.phase, 1);
    expect(s.exitLocked, isTrue);
    expect(s.bossPresent, isTrue);
  });

  test('phase thresholds: 2/3 -> phase 2, 1/3 -> phase 3, with events', () {
    final s = bossSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    final phases = <int>[];
    void pump() {
      final intent = InputIntent()..clearEdges();
      s.update(dt, intent);
      for (final e in s.takeEvents()) {
        if (e.kind == SessionEventKind.bossPhase) phases.add(e.x.round());
      }
    }

    boss.hp = (GroveGolemCore.maxHp * 2 / 3).floor(); // 100 -> phase 2
    pump();
    expect(boss.phase, 2);
    boss.hp = (GroveGolemCore.maxHp / 3).floor(); // 50 -> phase 3
    pump();
    expect(boss.phase, 3);
    expect(phases, [2, 3]);
  });

  test('every attack is telegraphed before hazards exist', () {
    final s = bossSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    var sawTelegraph = false;
    var telegraphBeforeHazard = false;
    final intent = InputIntent();
    for (var i = 0; i < (6.0 / dt).round(); i++) {
      intent.clearEdges();
      s.update(dt, intent);
      s.takeEvents();
      if (boss.bossState == BossState.telegraph) sawTelegraph = true;
      if (boss.hazards.isNotEmpty) {
        telegraphBeforeHazard = sawTelegraph;
        break;
      }
    }
    expect(sawTelegraph, isTrue);
    expect(telegraphBeforeHazard, isTrue,
        reason: 'hazards must never appear before a telegraph');
  });

  test('phase 1 slam: shockwave travels along the ground and can hit', () {
    final s = bossSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    final hearts0 = s.player.hearts;
    var sawShockwave = false;
    var waveMoved = false;
    double? waveX0;
    final intent = InputIntent();
    for (var i = 0; i < (10.0 / dt).round() && !s.over; i++) {
      intent.clearEdges();
      s.update(dt, intent);
      s.takeEvents();
      final waves = boss.hazards
          .where((h) => h.kind == BossHazardKind.shockwave)
          .toList();
      if (waves.isNotEmpty) {
        sawShockwave = true;
        waveX0 ??= waves.first.x;
        if ((waves.first.x - waveX0).abs() > 20) waveMoved = true;
      }
      if (s.player.hearts < hearts0) break;
    }
    expect(sawShockwave, isTrue);
    expect(waveMoved, isTrue);
    expect(s.player.hearts, lessThan(hearts0),
        reason: 'an idle player standing on the floor gets hit by the wave');
    expect(s.hitsTaken, greaterThanOrEqualTo(1));
  });

  test('phase 2 root spikes: harmless warning first, then harmful', () {
    final s = bossSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    // Stale-proof: derive the hp from the threshold and ASSERT the phase.
    // (This test sat at hp=30 after the 150-hp retune — that is phase 3,
    // which happens to also cycle root spikes, so it silently passed while
    // testing the wrong phase. Found in the 2026-09-02 suite audit.)
    boss.hp = (GroveGolemCore.maxHp * 2 / 3).floor();
    expect(boss.phase, 2, reason: 'this test must exercise phase 2');
    var sawWarning = false;
    var sawHarmful = false;
    final intent = InputIntent();
    for (var i = 0; i < (20.0 / dt).round() && !s.over; i++) {
      intent.clearEdges();
      s.update(dt, intent);
      s.takeEvents();
      for (final h in boss.hazards) {
        if (h.kind != BossHazardKind.rootSpike) continue;
        if (!h.harmful) sawWarning = true;
        if (h.harmful && sawWarning) sawHarmful = true;
      }
      if (sawHarmful) break;
    }
    expect(sawWarning, isTrue, reason: 'spikes must warn before erupting');
    expect(sawHarmful, isTrue);
  });

  test('phase 3 lobs rock arcs', () {
    final s = bossSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    boss.hp = (GroveGolemCore.maxHp / 3).floor();
    expect(boss.phase, 3, reason: 'this test must exercise phase 3');
    var sawRock = false;
    final intent = InputIntent();
    for (var i = 0; i < (20.0 / dt).round() && !s.over; i++) {
      intent.clearEdges();
      s.update(dt, intent);
      s.takeEvents();
      if (boss.hazards.any((h) => h.kind == BossHazardKind.rock)) {
        sawRock = true;
        break;
      }
    }
    expect(sawRock, isTrue);
  });

  test('door stays locked while the boss lives, opens on death with burst',
      () {
    final s = bossSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    // Teleport the player into the door while the boss is alive: no finish.
    s.player.body.x = s.exitX - s.player.body.w / 2;
    s.player.body.y = s.exitY - s.player.body.h - 1;
    final intent = InputIntent()..clearEdges();
    s.update(dt, intent);
    expect(s.completed, isFalse, reason: 'exit locked during the fight');

    // Kill the boss outright.
    boss.hp = 1;
    boss.damage(1);
    expect(boss.alive, isFalse);
    // Session notices the death through melee normally; here we emulate the
    // burn/death path by invoking a frame — death via damage() outside a
    // swing still needs the door unlock check to pass:
    expect(s.exitLocked, isFalse);
    s.update(dt, intent..clearEdges());
    expect(s.completed, isTrue, reason: 'door usable once the boss is dead');
  });

  test('boss death via melee grants a big coin+feather burst', () {
    final s = bossSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    boss.hp = 1;
    // Walk up and land one hit.
    final coinsBefore = s.coins.length;
    final feathersBefore =
        s.pickups.where((p) => p.kind == SpawnKind.feather).length;
    final events = <SessionEventKind>[];
    final intent = InputIntent();
    for (var i = 0; i < (20.0 / dt).round() && boss.alive && !s.over; i++) {
      intent.clearEdges();
      intent.dirX = (boss.centerX - s.player.body.centerX) > 40 ? 1.0 : 0.0;
      if (i % 25 == 0) intent.attackPressed = true;
      s.update(dt, intent);
      events.addAll(s.takeEvents().map((e) => e.kind));
    }
    expect(boss.alive, isFalse, reason: 'player should land the last hit');
    expect(events, contains(SessionEventKind.bossDefeated));
    expect(s.coins.length - coinsBefore, greaterThanOrEqualTo(45));
    final feathersAfter =
        s.pickups.where((p) => p.kind == SpawnKind.feather).length;
    expect(feathersAfter - feathersBefore, 3);
    expect(s.exitLocked, isFalse);
  });

  test('the killing blow freezes the frame longer than a normal hit', () {
    final s = bossSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    boss.hp = 1;
    boss.burnLeft = 1.5; // one burn tick lands the killing blow
    final intent = InputIntent();
    var frames = 0;
    while (boss.alive && frames < (3.0 / dt).round()) {
      intent.clearEdges();
      s.update(dt, intent);
      frames++;
    }
    expect(boss.alive, isFalse);
    expect(s.hitPause, greaterThan(kHitPause),
        reason: 'boss kill must hold the frame (kBossKillPause), '
            'not the normal 40ms connect pause');
  });

  group('difficulty mods', () {
    TileKind floorAt(int tx, int ty) =>
        ty >= 8 ? TileKind.solid : TileKind.empty;

    double timeToFirstAttack(DifficultyMods m) {
      final g = GroveGolemCore(x: 100, y: 76)..mods = m;
      g.wake();
      var t = 0.0;
      while (g.bossState != BossState.attack && t < 30) {
        g.behave(dt, floorAt, playerX: 100, playerY: 76);
        t += dt;
      }
      return t;
    }

    test('telegraph pacing: easy > medium > hard time-to-first-attack', () {
      final easy = timeToFirstAttack(DifficultyMods.easy);
      final medium = timeToFirstAttack(DifficultyMods.medium);
      final hard = timeToFirstAttack(DifficultyMods.hard);
      expect(easy, greaterThan(medium),
          reason: 'easy must give more reaction time than medium');
      expect(medium, greaterThan(hard),
          reason: 'hard must wind up faster than medium');
    });

    test('wake range scales with aggro', () {
      bool wakesAt(DifficultyMods m, double dist) {
        final g = GroveGolemCore(x: 200, y: 76)..mods = m;
        for (var i = 0; i < 60; i++) {
          g.behave(dt, floorAt, playerX: g.centerX - dist, playerY: 76);
        }
        return g.bossState != BossState.dormant;
      }

      // kBossWakeDistance 120: medium wakes at 110, easy (x0.8 = 96) not.
      expect(wakesAt(DifficultyMods.medium, 110), isTrue);
      expect(wakesAt(DifficultyMods.easy, 110), isFalse);
      expect(wakesAt(DifficultyMods.easy, 90), isTrue);
    });

    test('slam shockwave speed scales with mods.speed', () {
      double waveVx(DifficultyMods m) {
        final g = GroveGolemCore(x: 100, y: 76)..mods = m;
        g.pendingAttack = BossAttack.slam;
        g.executeAttack(160, 76, floorAt);
        return g.hazards
            .firstWhere((h) => h.kind == BossHazardKind.shockwave)
            .vx;
      }

      expect(waveVx(DifficultyMods.hard),
          closeTo(waveVx(DifficultyMods.medium) * 1.2, 0.001));
    });
  });
}
