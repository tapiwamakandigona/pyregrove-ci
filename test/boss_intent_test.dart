// boss_intent_test — permanent design gate: each boss's COACHED strategy
// must beat it with the starter loadout on every seed (2026-08-31 review).
//
// TTK recalibrated 2026-09-01: at 60 hp both bosses died in 9-17 s to ANY
// bot (a point-blank masher beat the Grove Golem in ~10 s taking 2 hits —
// slam waves used to spawn outside a hugging player). Now 150 hp + slam
// spawning at the fists: a face-hug masher pays ~2 deaths for its win and
// only survives on the lives buffer; the coached route wins on the first
// life's pace (bot deaths below are bot sloppiness — it strikes from
// inside the body's contact box). What must never regress is the coached route:
//   Grove Golem (w1): its sign says "watch its wind-up - then strike" —
//     approach in idle/recover, strike, retreat during telegraph/attack,
//     jump shockwaves and falling rocks, sidestep root marks.
//   Kiln Golem (w2): caged in its kiln pen — ground melee CANNOT reach it
//     (measured: every ground bot deals 0/60). The coached route is the
//     pillar-top perch (the apples up there are the breadcrumb): jump the
//     fire moat, double-jump to the pillar crown, poke its head, sidestep
//     mortar embers. If a level edit breaks the perch reach or the moat
//     jump, this gate goes red.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/core_loadout.dart';
import 'package:pyregrove/game/difficulty.dart';
import 'package:pyregrove/game/enemies/boss_core.dart';
import 'package:pyregrove/game/input_intent.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/session.dart';
import 'package:pyregrove/game/tuning.dart';

const dt = 1 / 60;
const seeds = [7, 13, 42, 99];

LevelData load(String id) =>
    LevelData.parse(File('assets/levels/$id.txt').readAsStringSync());

void main() {
  for (final target in const ['w1_boss', 'w2_boss']) {
    test(
      'coached strategy beats $target',
      () {
        for (final seed in seeds) {
          final s = LevelSession(
            load(target),
            Loadout.starter(),
            seed: seed,
            difficulty: difficultyFromId(
                const String.fromEnvironment('DIFF', defaultValue: 'medium')),
          );
          final input = InputIntent();
          var t = 0.0, attack = 0.0, hits = 0;
          var jumpHold = 0.0;
          final hitLog = <String>[];
          while (t < 300 && !s.over) {
            final boss = s.enemies
                .whereType<BossCore>()
                .where((e) => e.alive)
                .toList();
            if (s.hitsTaken != hits) {
              hits = s.hitsTaken;
              final px0 = s.player.body.centerX;
              final haz = boss.isEmpty
                  ? ''
                  : boss.first.hazards
                      .where((h) => h.active)
                      .map((h) =>
                          '${h.kind.name}@${(h.x - px0).toStringAsFixed(0)}')
                      .join(',');
              hitLog.add(
                't=${t.toStringAsFixed(1)} hearts=${s.player.hearts} '
                'bossState=${boss.isEmpty ? "dead" : boss.first.bossState} '
                'bossHp=${boss.isEmpty ? 0 : boss.first.hp} '
                'dist=${boss.isEmpty ? "-" : (boss.first.centerX - px0).abs().toStringAsFixed(0)} '
                'air=${!s.player.body.onGround} haz=[$haz]',
              );
            }
            input
              ..dirX = 0
              ..jumpPressed = false
              ..jumpHeld = jumpHold > 0
              ..attackPressed = false;
            if (jumpHold > 0) jumpHold -= dt;
            if (boss.isEmpty) {
              // Boss dead: run right to the exit; look where you walk — jump
              // fire moats proactively, double-jump climbs on stall.
              input.dirX = 1;
              final px = s.player.body.centerX;
              final footRow = (s.player.body.bottom / kTileSize).floor();
              var fireAhead = false;
              for (var k = 1; k <= 2; k++) {
                final cx = (px / kTileSize).floor() + k;
                for (var r = footRow; r <= footRow + 1; r++) {
                  if (r < 0 || r >= s.grid.length) continue;
                  if (cx < 0 || cx >= s.grid[r].length) continue;
                  final tk = s.grid[r][cx];
                  if (tk == TileKind.fire || tk == TileKind.spikes) {
                    fireAhead = true;
                  }
                }
              }
              if (s.player.body.onGround &&
                  (fireAhead || s.player.body.vx.abs() < 5)) {
                input
                  ..jumpPressed = true
                  ..jumpHeld = true;
                jumpHold = 0.35;
              } else if (!s.player.body.onGround &&
                  s.player.body.vy > -40 &&
                  jumpHold <= 0) {
                input.jumpPressed = true; // double jump to finish climbs
                jumpHold = 0.3;
              }
            } else {
              final b = boss.first;
              final px = s.player.body.centerX;
              final dx = b.centerX - px;
              final dist = dx.abs();
              // Hazard reads: shockwaves/pillars/rocks to hop, embers to sidestep.
              var hazJump = false;
              var sidestep =
                  0; // -1/1: move away from a predicted ember landing
              for (final h in b.hazards) {
                if (!h.active) continue;
                final hd = (h.x - px).abs();
                if (h.kind == BossHazardKind.shockwave) {
                  // Hop on ARRIVAL, not proximity: the wave chases a
                  // retreating player at |vx| - |player vx|, so a fixed
                  // 44 px trigger jumps too early on hard (1.2x waves)
                  // and the bot lands straight onto the wave.
                  final closing = (px - h.x).sign == h.vx.sign
                      ? (h.vx - s.player.body.vx).abs()
                      : 0.0;
                  if (closing > 1 && hd / closing < 0.32) hazJump = true;
                } else if (hd < 44 &&
                    ((h.kind == BossHazardKind.flamePillar &&
                            h.warning < 0.35) ||
                        (h.kind == BossHazardKind.rock &&
                            h.y > s.player.body.top))) {
                  hazJump = true;
                }
                if (h.kind == BossHazardKind.firePatch && hd < 26) {
                  sidestep = h.x > px ? -1 : 1;
                }
                if (h.kind == BossHazardKind.emberBomb && h.vy > -60) {
                  // Falling ember: project its landing x, step out from under it.
                  final landX = h.x + h.vx * 0.35;
                  if ((landX - px).abs() < 30) sidestep = landX > px ? -1 : 1;
                }
              }
              // Caged boss (Kiln): it cannot leave its pen — the level's own
              // breadcrumbs (apples on the pillar tops) coach a perch fight.
              final caged = b is KilnGolemCore;
              if (caged) {
                const perchX = 424.0; // right edge of the left pillar top
                final onPerch =
                    s.player.body.bottom <= 209 && px > 384 && px < 434;
                if (!onPerch) {
                  // Navigate: run right, jump the fire moat, double-jump to top.
                  input.dirX = px < perchX ? 1 : -1;
                  if (s.player.body.onGround && px > 290 && px < 384) {
                    input
                      ..jumpPressed = true
                      ..jumpHeld = true;
                    jumpHold = 0.35;
                  } else if (!s.player.body.onGround &&
                      s.player.body.vy > -40 &&
                      px < 410 &&
                      jumpHold <= 0) {
                    input.jumpPressed = true; // double jump onto the pillar top
                    jumpHold = 0.3;
                  }
                } else {
                  // Perched: poke the head, sidestep ember landings and patches.
                  if (sidestep != 0) {
                    input.dirX = px < 396 ? 1.0 : sidestep.toDouble();
                  } else if (px < perchX - 3) {
                    input.dirX = 1;
                  } else if (px > perchX + 3) {
                    input.dirX = -1;
                  }
                  attack += dt;
                  if (attack > 0.3 && (b.centerX - px).abs() < 56) {
                    attack = 0;
                    input.attackPressed = true;
                  }
                }
                s.update(dt, input);
                s.takeEvents();
                t += dt;
                continue;
              }

              // Root-spike marks bracket the player: commit one way (away
              // from the boss) until they erupt instead of standing on them.
              var spikeFlee = 0;
              for (final h in b.hazards) {
                if (h.active &&
                    h.kind == BossHazardKind.rootSpike &&
                    (h.x - px).abs() < 34) {
                  spikeFlee = dx > 0 ? -1 : 1;
                }
              }
              if (sidestep != 0) {
                input.dirX = sidestep.toDouble();
              } else if (spikeFlee != 0) {
                input.dirX = spikeFlee.toDouble();
              } else {
                // Hold the strike band and punish. (The old bot retreated
                // whenever the boss wound up ANY attack; the walking boss
                // slowly cornered it against the arena wall, where its
                // anti-stuck jump tossed it into the chasing shockwave —
                // that was every death on hard, 2026-09-01 hit logs.)
                if (dist > 52) {
                  input.dirX = dx > 0 ? 1 : -1;
                } else if (dist < 38) {
                  input.dirX = dx > 0 ? -1 : 1; // never share ground with it
                }
                attack += dt;
                if (dist < 52 && attack > 0.3) {
                  attack = 0;
                  input.attackPressed = true;
                }
              }
              // Airborne spacing: after hopping a shockwave, drift OUT, not
              // onto the boss (landing on its back was where every hard-mode
              // contact hit came from — hazards never touched the bot).
              if (!s.player.body.onGround) {
                // Wave-clear drift: a hopped shockwave must pass UNDER the
                // player before landing. Drift against its travel so the
                // overlap ends sooner (on easy the slowed wave lingered in
                // the landing column and tail-clipped every vertical hop).
                for (final h in b.hazards) {
                  if (h.active &&
                      h.kind == BossHazardKind.shockwave &&
                      (h.x - px).abs() < 26) {
                    input.dirX = h.vx > 0 ? -1 : 1;
                  }
                }
                // Boss spacing OUTRANKS wave drift: drifting against a wave
                // that already passed walked the bot straight into the hull
                // (every medium death, 2026-09-01). The wave leaves on its
                // own; the hull doesn't.
                if (dist < 48) input.dirX = dx > 0 ? -1 : 1;
                // Contact chain escape: knocked into the boss hull, double
                // jump out instead of trading a heart every iframe window.
                if (dist < 34 && jumpHold <= 0) {
                  input.jumpPressed = true;
                  jumpHold = 0.25;
                }
              }
              // Climb: trying to move but pinned against terrain -> jump.
              if (input.dirX != 0 &&
                  s.player.body.vx.abs() < 8 &&
                  s.player.body.onGround) {
                input
                  ..jumpPressed = true
                  ..jumpHeld = true;
                jumpHold = 0.3;
              }
              if (hazJump && s.player.body.onGround) {
                input
                  ..jumpPressed = true
                  ..jumpHeld = true;
                jumpHold = 0.3;
              }
            }
            s.update(dt, input);
            s.takeEvents();
            t += dt;
          }
          final bossLeft = s.enemies.whereType<BossCore>().where(
            (e) => e.alive,
          );
          // ignore: avoid_print
          print(
            '[$target seed=$seed] '
            '${s.completed
                ? "COMPLETED"
                : s.failed
                ? "WIPED"
                : "TIMEOUT"} '
            't=${t.toStringAsFixed(0)}s deaths=${s.deaths} hits=${s.hitsTaken} '
            'bossHp=${bossLeft.isEmpty ? 0 : bossLeft.first.hp}/${bossLeft.isEmpty ? '-' : bossLeft.first.maxHpTotal}',
          );
          for (final h in hitLog) {
            // ignore: avoid_print
            print('   hit $h');
          }
          expect(
            s.completed,
            isTrue,
            reason:
                '$target seed=$seed: the coached strategy must finish the '
                'level (got deaths=${s.deaths}, hits=${s.hitsTaken}, '
                't=${t.toStringAsFixed(0)}s)',
          );
          expect(
            s.deaths,
            lessThanOrEqualTo(2),
            reason:
                '$target seed=$seed: the coached strategy should win with '
                'a life to spare',
          );
        }
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );
  }
}
