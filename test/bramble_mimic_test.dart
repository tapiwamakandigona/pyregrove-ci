// Bramble Mimic: disguised-bush enemy. Reveal triggers (proximity / poke),
// the harmless shiver telegraph, the session contact-damage gate, and
// difficulty scaling of the reveal window.
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/core_loadout.dart';
import 'package:pyregrove/game/difficulty.dart';
import 'package:pyregrove/game/enemies/enemy_core.dart';
import 'package:pyregrove/game/input_intent.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/session.dart';

const dt = 1 / 120;

// Player at the left, one mimic bush mid-field, exit right.
const arena = '''
##############################
#............................#
#............................#
#............................#
#.P...........N............E.#
##############################
''';

LevelSession makeSession({int seed = 5, Difficulty diff = Difficulty.medium}) =>
    LevelSession(LevelData.parse(arena), Loadout.starter(),
        seed: seed, difficulty: diff);

void step(LevelSession s, double seconds,
    [void Function(InputIntent)? config]) {
  final frames = (seconds / dt).round();
  final intent = InputIntent();
  for (var i = 0; i < frames; i++) {
    intent
      ..dirX = 0
      ..jumpHeld = false;
    intent.clearEdges();
    config?.call(intent);
    s.update(dt, intent);
    if (s.over) return;
  }
}

void main() {
  test('legend N spawns a hidden, harmless, motionless mimic', () {
    final s = makeSession();
    final m = s.enemies.whereType<BrambleMimicCore>().single;
    expect(m.hidden, isTrue);
    expect(m.harmless, isTrue);
    final x0 = m.body.x;
    step(s, 1.0);
    expect(m.hidden, isTrue, reason: 'player far away — stays disguised');
    expect(m.body.x, x0, reason: 'a bush does not walk');
  });

  test('proximity reveals: one event, harmless shiver, then it hunts', () {
    final s = makeSession();
    final m = s.enemies.whereType<BrambleMimicCore>().single;
    final events = <SessionEventKind>[];
    // Walk toward the bush until the reveal fires.
    var walked = 0.0;
    while (m.hidden && walked < 10.0) {
      step(s, 0.1, (i) => i.dirX = 1);
      events.addAll(s.takeEvents().map((e) => e.kind));
      walked += 0.1;
    }
    expect(m.hidden, isFalse, reason: 'approach must trigger the reveal');
    expect(events.where((k) => k == SessionEventKind.mimicRevealed).length, 1);
    expect(m.harmless, isTrue, reason: 'shiver telegraph is harmless');
    // Ride out the telegraph without moving; then it must act.
    step(s, m.revealLeft + 0.2);
    expect(m.harmless, isFalse);
    final x0 = m.body.x;
    step(s, 0.5);
    expect(m.body.x, isNot(x0), reason: 'revealed mimic patrols/hunts');
  });

  test('contact while disguised or shivering never hurts; after, it does',
      () {
    final s = makeSession();
    final m = s.enemies.whereType<BrambleMimicCore>().single;
    // Force a body overlap while hidden: the gate must hold.
    m.body.x = s.player.body.x;
    m.body.y = s.player.body.y;
    s.update(dt, InputIntent());
    expect(s.hitsTaken, 0, reason: 'disguised mimic cannot deal contact');
    // The forced overlap also triggered the proximity reveal -> shiver.
    expect(m.hidden, isFalse);
    expect(s.hitsTaken, 0, reason: 'shivering mimic cannot deal contact');
    m.revealLeft = 0; // telegraph over
    s.update(dt, InputIntent());
    expect(s.hitsTaken, 1, reason: 'active mimic deals contact damage');
  });

  test('poking the bush reveals it and the damage lands', () {
    final s = makeSession();
    final m = s.enemies.whereType<BrambleMimicCore>().single;
    final hp0 = m.hp;
    expect(m.damage(3), isTrue);
    expect(m.hidden, isFalse);
    expect(m.hp, hp0 - 3);
    step(s, 0.05);
    expect(s.takeEvents().map((e) => e.kind),
        contains(SessionEventKind.mimicRevealed));
  });

  test('difficulty scales the shiver window (easy > hard)', () {
    final easy = makeSession(diff: Difficulty.easy);
    final hard = makeSession(diff: Difficulty.hard);
    final me = easy.enemies.whereType<BrambleMimicCore>().single..damage(1);
    final mh = hard.enemies.whereType<BrambleMimicCore>().single..damage(1);
    expect(me.revealLeft, greaterThan(mh.revealLeft));
  });

  test('respawn-clear re-disguises a nearby mimic (fresh ambush, fair)', () {
    final s = makeSession();
    final m = s.enemies.whereType<BrambleMimicCore>().single;
    m.damage(1); // revealed
    m.revealLeft = 0;
    expect(m.harmless, isFalse);
    // The mimic crowds the respawn point when the player dies: the
    // respawn-clear must send it home AND back into the bush.
    m.body.x = s.player.body.x;
    s.player.damage(3, from: m.centerX); // 3 hearts at once -> death
    s.update(dt, InputIntent()); // session sees died -> _onDeath -> clear
    expect(m.hidden, isTrue, reason: 'sent home -> back in the bush');
    expect(m.harmless, isTrue);
  });
}
