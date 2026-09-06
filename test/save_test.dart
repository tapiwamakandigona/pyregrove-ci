import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/difficulty.dart';
import 'package:pyregrove/game/session.dart';
import 'package:pyregrove/meta/progress_state.dart';

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('ember_save_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('fresh save has starter loadout', () async {
    final store = SaveStore(baseDirOverride: tmp);
    final s = await store.load();
    expect(s.coins, 0);
    expect(s.ownedWeapons, {'squire_blade'});
    expect(s.equippedSkin, 'red');
  });

  test('round-trip preserves everything', () async {
    final store = SaveStore(baseDirOverride: tmp);
    final s = SaveData(coins: 123, feathers: 4)
      ..ownedWeapons.add('ember_fang')
      ..equippedWeapon = 'ember_fang'
      ..skinKills['red'] = 77
      ..tutorialSeen = true;
    s.recordFor('w1_l1')
      ..finished = true
      ..allChests = true
      ..chestsOpened = 3
      ..bestTimeMs = 61250;
    await store.save(s);

    final back = await store.load();
    expect(back.coins, 123);
    expect(back.feathers, 4);
    expect(back.equippedWeapon, 'ember_fang');
    expect(back.skinKills['red'], 77);
    expect(back.tutorialSeen, isTrue);
    final rec = back.levels['w1_l1']!;
    expect(rec.finished, isTrue);
    expect(rec.medals, 2);
    expect(rec.bestTimeMs, 61250);
  });

  test('corrupt live file falls back to backup', () async {
    final store = SaveStore(baseDirOverride: tmp);
    await store.save(SaveData(coins: 50));
    await store.save(SaveData(coins: 99)); // 50-coin save becomes .bak
    final live = File('${tmp.path}/pyregrove_save.json');
    live.writeAsStringSync('{corrupt!!!');
    final back = await store.load();
    expect(back.coins, 50, reason: 'backup should win over corrupt live file');
  });

  test(
    'corrupt live AND corrupt backup still boot: fresh save, no crash',
    () async {
      // save.dart promises "corrupt backup -> fresh save"; only the
      // corrupt-live half was tested. If this path regressed, a player with
      // both files damaged would crash at boot instead of starting over.
      final store = SaveStore(baseDirOverride: tmp);
      await store.save(SaveData(coins: 50));
      await store.save(SaveData(coins: 99)); // creates the .bak too
      File('${tmp.path}/pyregrove_save.json').writeAsStringSync('{corrupt!!!');
      File(
        '${tmp.path}/pyregrove_save.json.bak',
      ).writeAsStringSync('also corrupt');
      final back = await store.load();
      expect(back.coins, 0, reason: 'both corrupt -> fresh save');
      expect(back.ownedWeapons, {'squire_blade'});
    },
  );

  test('legacy v1 dice save migrates to fresh save + bonus', () async {
    final live = File('${tmp.path}/pyregrove_save.json');
    live.writeAsStringSync(
      jsonEncode({
        'version': 1,
        'embers': 900,
        'unlockedCharacters': ['ascetic'],
      }),
    );
    final store = SaveStore(baseDirOverride: tmp);
    final s = await store.load();
    expect(s.legacyBonusGranted, isTrue);
    expect(s.coins, 250);
    expect(s.ownedWeapons, {'squire_blade'});
  });

  group('progression rules', () {
    test('levels unlock sequentially, boss needs all', () {
      final s = SaveData();
      expect(isLevelUnlocked(s, 0), isTrue);
      expect(isLevelUnlocked(s, 1), isFalse);
      s.recordFor('w1_l1').finished = true;
      expect(isLevelUnlocked(s, 1), isTrue);
      expect(isLevelUnlocked(s, 5), isFalse, reason: 'boss locked');
      for (final e in kWorld1.where((e) => !e.isBoss)) {
        s.recordFor(e.id).finished = true;
      }
      expect(isLevelUnlocked(s, 5), isTrue);
    });

    test('bonus level (Ember Hollow): gated on the Grove Golem, outside the '
        'campaign order, never a Next-level target or prerequisite', () {
      final s = SaveData();
      expect(kBonusLevels.map((e) => e.id), ['w1_bonus', 'w2_bonus']);
      expect(kBonusLevels.every((e) => e.isBonus), isTrue);
      expect(
        isLevelUnlocked(s, 0, world: kBonusLevels),
        isFalse,
        reason: 'index 0 is normally free; the bonus list has its own gate',
      );
      for (final e in kWorld1.where((e) => !e.isBoss)) {
        s.recordFor(e.id).finished = true;
      }
      expect(
        isLevelUnlocked(s, 0, world: kBonusLevels),
        isFalse,
        reason: 'all five regular levels are not enough',
      );
      s.recordFor('w1_boss').finished = true;
      expect(isBonusUnlocked(s), isTrue);
      expect(isLevelUnlocked(s, 0, world: kBonusLevels), isTrue);
      // Slag Cellar has its own gate — the Kiln Golem — not a chain from
      // Ember Hollow.
      expect(isLevelUnlocked(s, 1, world: kBonusLevels), isFalse);
      s.recordFor('w1_bonus').finished = true;
      expect(
        isLevelUnlocked(s, 1, world: kBonusLevels),
        isFalse,
        reason: 'clearing the first bonus does not open the second',
      );
      s.recordFor('w2_boss').finished = true;
      expect(isLevelUnlocked(s, 1, world: kBonusLevels), isTrue);
      expect(isLevelUnlocked(s, 2, world: kBonusLevels), isFalse);
      // Side content stays out of the campaign spine.
      expect(kCampaignOrder.any((e) => e.id == 'w1_bonus'), isFalse);
      expect(kAllLevels.any((e) => e.id == 'w1_bonus'), isTrue);
      expect(
        nextLevelId(s, 'w1_boss'),
        'w2_l1',
        reason: 'Next level after the golem is Ashen Gate, not the bonus',
      );
      expect(nextLevelId(s, 'w1_bonus'), isNull);
      expect(nextLevelId(s, 'w2_bonus'), isNull);
      // A bonus clear changes nothing about World 2 access.
      final t = SaveData()..recordFor('w1_bonus').finished = true;
      expect(isWorld2Unlocked(t), isFalse);
      expect(
        firstRunLevelId(t),
        isNull,
        reason: 'any finished record counts as a veteran',
      );
    });

    test('mergeLevelResult: medals/counts only rise, time only falls, '
        'Hard finish sets the replay mark; json roundtrip + legacy', () {
      final rec = LevelRecord();
      LevelResults run({
        bool finished = true,
        bool chests = false,
        bool low = false,
        int t = 90000,
        int opened = 1,
      }) => LevelResults(
        timeMs: t,
        parSeconds: 120,
        coinsEarned: 5,
        chestsOpened: opened,
        chestTotal: 3,
        secretsFound: 0,
        finished: finished,
        allChests: chests,
        lowDamage: low,
      );
      mergeLevelResult(rec, run(), Difficulty.medium);
      expect(rec.finished, isTrue);
      expect(rec.bestTimeMs, 90000);
      expect(rec.hardCleared, isFalse);
      mergeLevelResult(
        rec,
        run(t: 120000, chests: true, opened: 3),
        Difficulty.easy,
      );
      expect(rec.bestTimeMs, 90000, reason: 'slower run keeps best');
      expect(rec.allChests, isTrue);
      expect(rec.chestsOpened, 3);
      mergeLevelResult(rec, run(finished: false, t: 1000), Difficulty.hard);
      expect(rec.hardCleared, isFalse, reason: 'unfinished Hard run');
      expect(rec.bestTimeMs, 1000);
      mergeLevelResult(rec, run(t: 80000), Difficulty.hard);
      expect(rec.hardCleared, isTrue);
      final back = LevelRecord.fromJson(
        jsonDecode(jsonEncode(rec.toJson())) as Map<String, dynamic>,
      );
      expect(back.hardCleared, isTrue);
      expect(LevelRecord.fromJson({'finished': true}).hardCleared, isFalse);
    });

    test('nextLevelId chains the campaign and stops at locks/ends', () {
      final s = SaveData();
      // Fresh save, first clear: w1_l1 -> w1_l2 (unlocked by that clear).
      s.recordFor('w1_l1').finished = true;
      expect(nextLevelId(s, 'w1_l1'), 'w1_l2');
      // Replaying a level whose successor is a still-locked boss: no offer.
      for (final id in ['w1_l2', 'w1_l3', 'w1_l4']) {
        s.recordFor(id).finished = true;
      }
      expect(nextLevelId(s, 'w1_l4'), 'w1_l5');
      s.recordFor('w1_l1').finished = false; // pretend l1 never finished
      s.recordFor('w1_l5').finished = true;
      expect(nextLevelId(s, 'w1_l5'), isNull, reason: 'boss still locked');
      s.recordFor('w1_l1').finished = true;
      expect(nextLevelId(s, 'w1_l5'), 'w1_boss');
      // World boundary: beating the W1 boss offers W2's first level.
      s.recordFor('w1_boss').finished = true;
      expect(nextLevelId(s, 'w1_boss'), 'w2_l1');
      // Final boss and unknown ids: nothing to offer.
      expect(nextLevelId(s, 'w2_boss'), isNull);
      expect(nextLevelId(s, 'daily'), isNull);
      expect(kCampaignOrder.length, 12);
    });

    test('skin levels from kills; melee power grows', () {
      final s = SaveData();
      expect(skinLevel(s, 'red'), 1);
      s.skinKills['red'] = 25; // killsForLevel(1)
      expect(skinLevel(s, 'red'), 2);
      expect(meleePower(s), closeTo(1.03, 1e-9));
    });

    test('warden blade grants a heart; apple pouch grows capacity', () {
      final s = SaveData();
      expect(maxHearts(s), 3);
      s.equippedWeapon = 'warden_blade';
      expect(maxHearts(s), 4);
      expect(appleCapacity(s), 10);
      s.ownedAbilities.add('apple_pouch');
      expect(appleCapacity(s), 13);
    });
  });
}
