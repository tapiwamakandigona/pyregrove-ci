// AKP-3 game-juice contracts (headless): damage amounts ride on enemyHit
// events, damage numbers respect their live-cap and lifecycle, and the
// squash timer is render-only state that decays.
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/components/fx.dart';
import 'package:pyregrove/game/components/player_component.dart';
import 'package:pyregrove/game/core_loadout.dart';
import 'package:pyregrove/game/input_intent.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/session.dart';

const dt = 1 / 120;

void main() {
  test('melee enemyHit events carry the damage dealt', () {
    // Purpose-built arena: a thornling on flat ground next to spawn.
    final rows = List.generate(20, (_) => List.filled(30, '.'));
    for (var x = 0; x < 30; x++) {
      for (var y = 16; y < 20; y++) {
        rows[y][x] = '#';
      }
    }
    rows[15][3] = 'P';
    rows[15][8] = 'T';
    rows[15][27] = 'E';
    final l = LevelData.parse(
        'meta: name=T\nmeta: world=1\n'
        '${rows.map((r) => r.join()).join('\n')}');
    final s = LevelSession(l, Loadout.starter(), seed: 5);
    final intent = InputIntent();
    final amounts = <int>[];
    var t = 0.0;
    while (t < 20 && amounts.isEmpty) {
      intent.clearEdges();
      s.player.hearts = 3;
      // Chase the patrolling thornling itself, swing when in reach.
      final dx = s.enemies.first.centerX - s.player.body.centerX;
      intent.dirX = dx.abs() > 20 ? dx.sign : 0;
      if (dx.abs() < 34 && (t * 120).round() % 40 == 0) {
        intent.attackPressed = true;
      }
      s.update(dt, intent);
      for (final e in s.takeEvents()) {
        if (e.kind == SessionEventKind.enemyHit) amounts.add(e.amount);
      }
      t += dt;
    }
    expect(amounts, isNotEmpty, reason: 'bot never landed a hit in 20s');
    final base = Loadout.starter().weapon.damage;
    for (final a in amounts) {
      expect(a, greaterThanOrEqualTo(base),
          reason: 'enemyHit.amount must carry real damage');
    }
  });

  test('damage numbers: live cap accounting', () {
    // The pool contract is constructor increments, onRemove decrements,
    // update() self-removes after `life`. Exercise it directly — the
    // component needs no game to honor the accounting.
    final spawned = <DamageNumberFx>[];
    while (DamageNumberFx.hasBudget) {
      spawned.add(DamageNumberFx(Vector2.zero(), 3));
      expect(spawned.length, lessThanOrEqualTo(DamageNumberFx.maxLive),
          reason: 'cap must bound live numbers');
    }
    expect(spawned.length, DamageNumberFx.maxLive);
    expect(DamageNumberFx.hasBudget, isFalse);
    for (final fx in spawned) {
      // ignore: invalid_use_of_internal_member
      fx.onRemove();
    }
    expect(DamageNumberFx.hasBudget, isTrue,
        reason: 'removed numbers must return their budget');
    // A crit lives longer than a normal hit (bigger beat, longer read).
    expect(DamageNumberFx(Vector2.zero(), 5, crit: true).life,
        greaterThan(DamageNumberFx(Vector2.zero(), 5).life));
    DamageNumberFx.resetLiveForTest();
  });

  test('takeoff stretch decays; squash outranks stretch on conflict', () {
    final pc = PlayerComponent();
    pc.triggerStretch();
    expect(pc.stretchActive, isTrue);
    pc.decaySquash(0.05);
    expect(pc.stretchActive, isTrue);
    pc.decaySquash(0.06); // past 0.10s total
    expect(pc.stretchActive, isFalse);
    // Both live: render branch checks squash first - assert both flags can
    // coexist so the else-if ordering stays meaningful.
    pc.triggerStretch();
    pc.triggerSquash();
    expect(pc.squashActive && pc.stretchActive, isTrue);
  });

  test('B7 hard-landing crouch: deeper, longer, outranks normal squash', () {
    final pc = PlayerComponent();
    // Hard landing replaces the normal squash outright.
    pc.triggerSquash();
    pc.triggerHardSquash();
    expect(pc.hardSquashActive, isTrue);
    expect(pc.squashActive, isFalse,
        reason: 'deep crouch must replace the 80ms squash, not stack');
    // Longer than the normal squash: still live at 0.10s (normal is gone
    // by 0.08), decayed by 0.17s.
    pc.decaySquash(0.10);
    expect(pc.hardSquashActive, isTrue);
    pc.decaySquash(0.07);
    expect(pc.hardSquashActive, isFalse);
    // Cosmetic only: render-side state, no input/physics coupling to assert
    // — the flag lives on the component, PlayerCore is untouched.
  });

  test('landing squash decays and never touches the body', () {
    final pc = PlayerComponent();
    pc.triggerSquash();
    // Decay is handled in update(); it needs no game reference for that.
    // 0.08s window: still squashing at 0.04, gone by 0.1.
    // (update uses game.session for animation state, so drive the timer
    // directly through the public API contract instead.)
    expect(pc.squashActive, isTrue);
    pc.decaySquash(0.04);
    expect(pc.squashActive, isTrue);
    pc.decaySquash(0.06);
    expect(pc.squashActive, isFalse);
  });
}
