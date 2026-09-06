// Economy pacing: does the shop's price ladder line up with what the levels
// actually pay out? Computed from the shipped level files + tuning constants,
// so a level edit or a price change that breaks the pacing fails here.
//
// Income model (per clear, everything on the map collected):
//   coins   = coin glyphs * kCoinValue
//           + chests * [kChestCoinsMin..kChestCoinsMax]  (avg = midpoint)
//           + boss burst 45..60 coins (session.dart, boss kill)
//   perfect = +kPerfectClearBonus on a 3-medal run (counted separately)
//   feathers = feather glyphs + 3 per boss kill
// Enemies drop nothing; Daily Delve pays like a normal run.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/tuning.dart';
import 'package:pyregrove/meta/catalog.dart';
import 'package:pyregrove/meta/progress_state.dart';

// Boss victory burst, mirrors session.dart `dropsRng.range(45, 60)` and the
// three feather pickups. Kept as literals on purpose: if the burst changes,
// this test should be re-read, not silently follow.
const int _bossCoinsMin = 45;
const int _bossCoinsMax = 60;
const int _bossFeathers = 3;

class _Income {
  final String id;
  final int coinsMin, coinsAvg, coinsMax, feathers;
  const _Income(
    this.id,
    this.coinsMin,
    this.coinsAvg,
    this.coinsMax,
    this.feathers,
  );
}

_Income _incomeFor(LevelEntry e) {
  final l = LevelData.parse(
    File('assets/levels/${e.id}.txt').readAsStringSync(),
  );
  final coins =
      l.spawns.where((s) => s.kind == SpawnKind.coin).length * kCoinValue;
  final chests = l.spawns
      .where(
        (s) => s.kind == SpawnKind.chest || s.kind == SpawnKind.secretChest,
      )
      .length;
  final feathers =
      l.spawns.where((s) => s.kind == SpawnKind.feather).length +
      (e.isBoss ? _bossFeathers : 0);
  final bossMin = e.isBoss ? _bossCoinsMin : 0;
  final bossMax = e.isBoss ? _bossCoinsMax : 0;
  final min = coins + chests * kChestCoinsMin + bossMin;
  final max = coins + chests * kChestCoinsMax + bossMax;
  return _Income(e.id, min, (min + max) ~/ 2, max, feathers);
}

int _sumAvg(Iterable<_Income> xs) => xs.fold(0, (a, x) => a + x.coinsAvg);
int _sumFeathers(Iterable<_Income> xs) => xs.fold(0, (a, x) => a + x.feathers);

void main() {
  final world1 = kWorld1.map(_incomeFor).toList();
  final world2 = kWorld2.map(_incomeFor).toList();
  final bonus = kBonusLevels.map(_incomeFor).toList();
  final all = [...world1, ...world2, ...bonus];

  final coinPrices = <String, int>{
    for (final w in kWeapons)
      if (w.currency == Currency.coins && w.price > 0) w.id: w.price,
    for (final s in kSkins)
      if (s.currency == Currency.coins && s.price > 0) s.id: s.price,
    for (final a in kAbilities)
      if (a.currency == Currency.coins) a.id: a.price,
    for (final s in kSpells)
      if (s.currency == Currency.coins) s.id: s.price,
  };
  final featherPrices = <String, int>{
    for (final w in kWeapons)
      if (w.currency == Currency.feathers) w.id: w.price,
    for (final s in kSkins)
      if (s.currency == Currency.feathers) s.id: s.price,
    for (final a in kAbilities)
      if (a.currency == Currency.feathers) a.id: a.price,
    for (final s in kSpells)
      if (s.currency == Currency.feathers) s.id: s.price,
  };

  test('income table (printed for progress.md)', () {
    // ignore: avoid_print
    print('level     coins min/avg/max  feathers');
    for (final x in all) {
      // ignore: avoid_print
      print(
        '${x.id.padRight(9)} ${x.coinsMin.toString().padLeft(3)}/'
        '${x.coinsAvg.toString().padLeft(3)}/'
        '${x.coinsMax.toString().padLeft(3)}        ${x.feathers}',
      );
    }
    // ignore: avoid_print
    print(
      'W1 avg total ${_sumAvg(world1)}  W2 avg total ${_sumAvg(world2)}  '
      'bonus ${_sumAvg(bonus)}  feathers/playthrough ${_sumFeathers(all)}',
    );
    expect(all.length, 14);
  });

  test('a full-clear of World 1 (pre-boss) affords the cheapest coin item', () {
    // First-purchase pacing: a player who clears w1_l1..w1_l5 with every
    // chest should be able to buy *something* before the first boss — the
    // shop is not a wall the first world cannot climb.
    final preBoss = world1.where(
      (x) => !kWorld1.firstWhere((e) => e.id == x.id).isBoss,
    );
    final cheapest = coinPrices.values.reduce((a, b) => a < b ? a : b);
    expect(
      _sumAvg(preBoss),
      greaterThanOrEqualTo(cheapest),
      reason:
          'W1 pre-boss avg income ${_sumAvg(preBoss)} < cheapest '
          'coin item $cheapest',
    );
  });

  test('every shop item is affordable within two full playthroughs', () {
    // Honest presentation: nothing on sale is out of reach. Two campaign
    // playthroughs (bonus levels included, no perfect bonuses, no Daily) must
    // cover the most expensive coin item and the most expensive feather item.
    final coins2 = 2 * _sumAvg(all);
    final feathers2 = 2 * _sumFeathers(all);
    for (final e in coinPrices.entries) {
      expect(
        e.value,
        lessThanOrEqualTo(coins2),
        reason:
            '${e.key} costs ${e.value} coins; two playthroughs pay '
            '$coins2',
      );
    }
    for (final e in featherPrices.entries) {
      expect(
        e.value,
        lessThanOrEqualTo(feathers2),
        reason:
            '${e.key} costs ${e.value} feathers; two playthroughs pay '
            '$feathers2',
      );
    }
    // And a single full playthrough covers the cheapest feather item early:
    // World 1 alone (boss + bonus) must pay for it.
    final w1Feathers = _sumFeathers(world1) + _sumFeathers(bonus.take(1));
    final cheapestFeather = featherPrices.values.reduce(
      (a, b) => a < b ? a : b,
    );
    expect(w1Feathers, greaterThanOrEqualTo(cheapestFeather));
  });

  test('every combat level pays within a narrow band (no dud levels)', () {
    // Coins are the only progression currency; a level paying half of its
    // neighbours reads as a chore. Band: every non-boss level's avg income is
    // within 60%..140% of the non-boss mean.
    final combat = all.where((x) => !x.id.endsWith('boss')).toList();
    final mean = _sumAvg(combat) / combat.length;
    for (final x in combat) {
      expect(
        x.coinsAvg,
        inInclusiveRange((mean * 0.6).floor(), (mean * 1.4).ceil()),
        reason: '${x.id} avg ${x.coinsAvg} vs mean ${mean.toStringAsFixed(0)}',
      );
    }
  });
}
