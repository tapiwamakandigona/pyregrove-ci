// Boss dormancy intro: bosses spawn as statues and wake on proximity or a
// landed hit — never before the player can see them (readability fix; the
// old spawn-active golem sent its first shockwave in from off-camera).
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/core_loadout.dart';
import 'package:pyregrove/game/enemies/boss_core.dart';
import 'package:pyregrove/game/input_intent.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/session.dart';
import 'package:pyregrove/game/tuning.dart';

const dt = 1 / 120;

// A wide arena: player far left, golem 26 tiles (416px) away — outside
// kBossWakeDistance (208) so the golem must start dormant.
const wideArena = '''
############################################
#..........................................#
#..........................................#
#..........................................#
#.P..........................G...........E.#
############################################
''';

LevelSession wideSession({int seed = 5}) =>
    LevelSession(LevelData.parse(wideArena), Loadout.starter(), seed: seed);

void pump(LevelSession s, double seconds,
    {void Function(InputIntent)? config,
    void Function(SessionEvent)? onEvent}) {
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
    for (final e in s.takeEvents()) {
      onEvent?.call(e);
    }
    if (s.over) return;
  }
}

void main() {
  test('boss spawns dormant beyond wake distance: no attacks, no hazards', () {
    final s = wideSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    expect(boss.dormant, isTrue);
    final events = <SessionEventKind>[];
    pump(s, 5.0, onEvent: (e) => events.add(e.kind));
    expect(boss.dormant, isTrue,
        reason: 'player never approached — boss must stay a statue');
    expect(boss.hazards, isEmpty,
        reason: 'a dormant boss must never spawn hazards');
    expect(boss.bossState, BossState.dormant);
    expect(events, isNot(contains(SessionEventKind.bossAwakened)));
    expect(s.exitLocked, isTrue,
        reason: 'the door stays locked even while the boss sleeps');
  });

  test('walking into wake range wakes the boss exactly once, with the event',
      () {
    final s = wideSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    var awakened = 0;
    double gapAtWake = double.nan;
    pump(s, 6.0,
        config: (i) => i.dirX = 1,
        onEvent: (e) {
          if (e.kind == SessionEventKind.bossAwakened) {
            awakened++;
            gapAtWake = (s.player.body.centerX - boss.centerX).abs();
          }
        });
    expect(boss.dormant, isFalse);
    expect(awakened, 1, reason: 'bossAwakened must fire exactly once');
    // The wake must happen while the player can see it: AT the wake moment
    // the gap is <= kBossWakeDistance (camera half-view + margin).
    expect(gapAtWake, lessThanOrEqualTo(kBossWakeDistance + kRunSpeed * dt * 2));
  });

  test('no telegraph before the wake grace elapses; attacks follow after', () {
    final s = wideSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    // Walk in only until it wakes, then stop (player holds at ~wake range).
    final intent = InputIntent();
    var walked = 0.0;
    while (boss.dormant && walked < 6.0) {
      intent
        ..dirX = 1
        ..down = false
        ..jumpHeld = false;
      intent.clearEdges();
      s.update(dt, intent);
      walked += dt;
    }
    expect(boss.dormant, isFalse, reason: 'walk-in must wake the boss');
    // Wake grace: no telegraph for kBossWakeGrace after the roar.
    var t = 0.0;
    for (; t < kBossWakeGrace - dt * 2; t += dt) {
      intent
        ..dirX = 0
        ..down = false
        ..jumpHeld = false;
      intent.clearEdges();
      s.update(dt, intent);
      expect(boss.bossState, isNot(BossState.telegraph),
          reason: 'telegraph fired during the wake grace');
      expect(boss.hazards, isEmpty);
    }
    // Then the standard cycle: telegraph, then hazards, within a few seconds.
    var sawTelegraph = false;
    var sawHazard = false;
    for (var u = 0.0; u < 5.0; u += dt) {
      intent
        ..dirX = 0
        ..down = false
        ..jumpHeld = false;
      intent.clearEdges();
      s.update(dt, intent);
      if (boss.bossState == BossState.telegraph) sawTelegraph = true;
      if (boss.hazards.isNotEmpty) {
        sawHazard = true;
        break;
      }
      if (s.over) break;
    }
    expect(sawTelegraph, isTrue);
    expect(sawHazard, isTrue);
  });

  test('sinceWake clock: zero while dormant, counts up after the roar', () {
    final s = wideSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    pump(s, 2.0);
    expect(boss.sinceWake, 0,
        reason: 'the wake-fx clock must not run while the boss is a statue');
    boss.wake();
    pump(s, 1.0);
    expect(boss.sinceWake, greaterThan(0.9),
        reason: 'render layer keys the crossfade/tremble off this clock');
  });

  test('a landed hit wakes a dormant boss (thrown-apple opener)', () {
    final s = wideSession();
    final boss = s.enemies.whereType<GroveGolemCore>().single;
    expect(boss.dormant, isTrue);
    final landed = boss.damage(1);
    expect(landed, isTrue, reason: 'dormant bosses are not invulnerable');
    expect(boss.hp, GroveGolemCore.maxHp - 1);
    expect(boss.dormant, isFalse, reason: 'a hit must wake the statue');
    // Session should surface the wake event on the next tick.
    var awakened = 0;
    pump(s, 0.1, onEvent: (e) {
      if (e.kind == SessionEventKind.bossAwakened) awakened++;
    });
    expect(awakened, 1);
  });

  test('kiln golem (w2) also spawns dormant', () {
    const kilnArena = '''
############################################
#..........................................#
#..........................................#
#..........................................#
#.P..........................M...........E.#
############################################
''';
    final s = LevelSession(
        LevelData.parse(kilnArena), Loadout.starter(), seed: 5);
    final boss = s.enemies.whereType<BossCore>().single;
    expect(boss.dormant, isTrue);
    pump(s, 3.0);
    expect(boss.hazards, isEmpty);
  });
}
