// Daily Delve determinism + save round-trip (P-M8).
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/rng.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/meta/daily.dart';

void main() {
  final jul25 = DateTime(2026, 7, 25, 14, 30); // time of day must not matter
  final jul25b = DateTime(2026, 7, 25, 3, 1);
  final jul26 = DateTime(2026, 7, 26);

  test('dailyKey is a zero-padded local date', () {
    expect(dailyKey(DateTime(2026, 7, 5)), '2026-07-05');
    expect(dailyKey(DateTime(2026, 12, 31)), '2026-12-31');
  });

  test('same date -> same seed and same level, regardless of time', () {
    expect(dailySeed(jul25), dailySeed(jul25b));
    expect(dailyLevelId(jul25), dailyLevelId(jul25b));
  });

  test('seed is stable across calls (pure function of the date)', () {
    expect(dailySeed(jul25), dailySeed(DateTime(2026, 7, 25)));
  });

  test('different dates give different seeds', () {
    expect(dailySeed(jul25), isNot(dailySeed(jul26)));
  });

  test('seed is in valid Rng range', () {
    for (var d = 0; d < 60; d++) {
      final s = dailySeed(DateTime(2026, 1, 1).add(Duration(days: d)));
      expect(s, inInclusiveRange(0, rngMod - 1));
    }
  });

  test(
    'level always comes from the daily pool; pool excludes tutorial/boss',
    () {
      expect(kDailyPool, isNot(contains('w1_l1')));
      expect(kDailyPool, isNot(contains('w1_boss')));
      final seen = <String>{};
      for (var d = 0; d < 60; d++) {
        final id = dailyLevelId(DateTime(2026, 1, 1).add(Duration(days: d)));
        expect(kDailyPool, contains(id));
        seen.add(id);
      }
      // Over two months the rotation should not be stuck on one level.
      expect(seen.length, greaterThan(1));
    },
  );

  test(
    'World 2 pool: never before the unlock, and the W1 pick is unchanged',
    () {
      expect(kDailyPoolWorld2, isNot(contains('w2_l1')));
      expect(kDailyPoolWorld2, isNot(contains('w2_boss')));
      expect(
        kDailyPoolWorld2,
        containsAll(['w2_l2', 'w2_l3', 'w2_l4', 'w2_l5']),
        reason: 'every non-tutorial, non-boss W2 level probes 4/4 (#27)',
      );
      var w2Days = 0;
      final seenW2 = <String>{};
      for (var d = 0; d < 120; d++) {
        final date = DateTime(2026, 1, 1).add(Duration(days: d));
        final locked = dailyLevelId(date);
        expect(kDailyPool, contains(locked));
        final open = dailyLevelId(date, world2Unlocked: true);
        if (kDailyPoolWorld2.contains(open)) {
          w2Days++;
          seenW2.add(open);
        } else {
          expect(
            open,
            locked,
            reason: 'a non-W2 day is the same W1 level for everyone',
          );
        }
      }
      // Roughly half the days, and the W2 rotation is not stuck on one level.
      expect(w2Days, inInclusiveRange(30, 90));
      expect(seenW2.length, kDailyPoolWorld2.length);
    },
  );

  test('daily best fields survive a save round-trip', () {
    final save = SaveData()
      ..dailyBestDate = '2026-07-25'
      ..dailyBestTimeMs = 61250;
    final loaded = SaveData.fromJson(
      (save.toJson()).map((k, v) => MapEntry(k, v)),
    );
    expect(loaded.dailyBestDate, '2026-07-25');
    expect(loaded.dailyBestTimeMs, 61250);
  });

  test('old saves without daily fields load with empty defaults', () {
    final loaded = SaveData.fromJson({'version': 2, 'coins': 10});
    expect(loaded.dailyBestDate, '');
    expect(loaded.dailyBestTimeMs, 0);
  });
}
