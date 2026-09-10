import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';

void main() {
  late Directory directory;
  late SaveStore store;
  late File live;
  late File backup;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('pyregrove_backup_');
    store = SaveStore(baseDirOverride: directory);
    live = File('${directory.path}/pyregrove_save.json');
    backup = File('${directory.path}/pyregrove_save.json.bak');
  });
  tearDown(() => directory.deleteSync(recursive: true));

  for (final damaged in <String>[
    '{interrupted',
    '[]',
    '{"version":2,"coins":"damaged"}',
    '{"version":2,"ownedWeapons":[77]}',
  ]) {
    test('saving after fallback preserves readable backup for $damaged',
        () async {
      final original = SaveData(coins: 350, feathers: 4)
        ..ownedWeapons.add('ember_fang')
        ..equippedWeapon = 'ember_fang'
        ..difficulty = 'hard'
        ..forgivingJumps = false
        ..dailyBestDate = '2026-09-09'
        ..dailyBestTimeMs = 62000;
      original.recordFor('w1_l1')
        ..finished = true
        ..hardCleared = true
        ..bestTimeMs = 50000;
      await store.save(original);
      final readableBytes = await live.readAsString();
      await store.save(SaveData(coins: 999));
      expect(await backup.readAsString(), readableBytes);

      await live.writeAsString(damaged);
      final recovered = await store.load();
      expect(recovered.toJson(), original.toJson());
      recovered.coins += 17;
      await store.save(recovered);

      expect(await backup.readAsString(), readableBytes,
          reason: 'an unreadable live file must not replace the good backup');
      expect((await store.load()).coins, 367);
      await live.writeAsString('{another interrupted live save');
      expect((await store.load()).toJson(), original.toJson(),
          reason: 'the earlier full progression must remain recoverable');
    });
  }

  test('backup protection also applies without calling load first', () async {
    await store.save(SaveData(coins: 10));
    final readableBytes = await live.readAsString();
    await store.save(SaveData(coins: 20));
    await live.writeAsString('{broken');

    await store.save(SaveData(coins: 30));
    expect(await backup.readAsString(), readableBytes);
    expect((await store.load()).coins, 30);
  });

  test('readable live saves still rotate the previous progress normally',
      () async {
    await store.save(SaveData(coins: 10));
    await store.save(SaveData(coins: 20));
    final previousBytes = await live.readAsString();
    await store.save(SaveData(coins: 30));

    expect(await backup.readAsString(), previousBytes);
    expect((await store.load()).coins, 30);
    await live.writeAsString('{broken');
    expect((await store.load()).coins, 20);
  });

  test('readable legacy save is still backed up and migrates unchanged',
      () async {
    final legacyBytes = jsonEncode({'version': 1, 'embers': 900});
    await live.writeAsString(legacyBytes);
    final migrated = await store.load();
    expect(migrated.coins, 250);
    expect(migrated.legacyBonusGranted, isTrue);

    await store.save(migrated);
    expect(await backup.readAsString(), legacyBytes);
    expect((await store.load()).toJson(), migrated.toJson());
  });
}
