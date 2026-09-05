// asset_warmup_test.dart — the title-screen warm-up (alpha.23 #35) must
// (1) name only real bundled assets, (2) cover everything a level actually
// loads so the first PLAY of a session finds a warm cache, and (3) fail open.
//
// Measured (desktop VM): EmberGame.onLoad w1_l1 cold 143–153 ms vs warm
// 6–18 ms; this test asserts the coverage that makes "warm" hold, and prints
// the numbers so a run can be quoted.
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/asset_warmup.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/ui/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    AppState.diskWrites = false;
    AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
  });

  test('every warm-up path for the starter save is a bundled asset', () async {
    final save = SaveData();
    final paths = warmupImagesFor(
      skinId: save.equippedSkin,
      weaponId: save.equippedWeapon,
    );
    expect(paths.toSet().length, paths.length, reason: 'no duplicates');
    final cache = Images();
    final ok = await warmUpLevelSprites(save, images: cache);
    expect(
      ok,
      paths.length,
      reason:
          'a listed sprite failed to decode: '
          '${paths.where((p) => !cache.containsKey(p)).toList()}',
    );
  });

  test('non-starter skin adds exactly its nine sheets', () {
    final base = warmupImagesFor(skinId: 'red', weaponId: 'squire_blade');
    final skin = warmupImagesFor(
      skinId: 'ember_monk',
      weaponId: 'squire_blade',
    );
    expect(skin.length - base.length, kPlayerSheetNames.length);
    expect(skin, contains('player/skins/ember_monk/run.png'));
  });

  test('warm-up covers every sprite the campaign levels load', () async {
    // Flame.images is the global cache EmberGame uses; warm it, snapshot,
    // then boot representative levels of both worlds and assert nothing new
    // had to be decoded. Decodes here would be the black gap after PLAY.
    final save = SaveData(tutorialSeen: true);
    await warmUpLevelSprites(save);
    final warmed = Flame.images.keys.toSet();
    for (final id in [
      'w1_l1',
      'w1_l2',
      'w1_boss',
      'w2_l1',
      'w2_l5',
      'w2_boss',
    ]) {
      final game = EmberGame(levelId: id, seedOverride: 42);
      game.onGameResize(Vector2(800, 450));
      final sw = Stopwatch()..start();
      await game.onLoad();
      final extra = Flame.images.keys.toSet().difference(warmed);
      // ignore: avoid_print
      print('[warmup $id] onLoad=${sw.elapsedMilliseconds}ms extra=$extra');
      expect(
        extra,
        isEmpty,
        reason: '$id decoded sprites the warm-up did not cover',
      );
    }
  });

  test('fails open on a missing weapon sheet', () async {
    // Unlisted sheets are filtered against the asset manifest before any
    // load is attempted, so no asset error is ever raised (Flame's cache
    // would otherwise surface a missing file as an unhandled async error).
    final save = SaveData()..equippedWeapon = 'no_such_weapon';
    final cache = Images();
    final ok = await warmUpLevelSprites(save, images: cache);
    expect(ok, kWarmupSharedImages.length + kPlayerSheetNames.length);
    expect(
      cache.containsKey('player/weapons/no_such_weapon/idle.png'),
      isFalse,
    );
  });
}
