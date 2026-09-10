// sfx_warmup_test.dart — the title-screen SFX voice warm-up (alpha.23 #36)
// names only playable ids, expands round-robin variants without duplicates,
// and fails open where there is no audio platform (this test binding).
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/audio/audio_service.dart';
import 'package:pyregrove/audio/round_robin.dart';
import 'package:pyregrove/audio/settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every warm id and every expanded variant is a known sfx path', () {
    for (final id in kSfxWarmIds) {
      expect(AudioService.sfxPaths, contains(id), reason: id);
    }
    final vids = sfxWarmVariantIds(kSfxWarmIds);
    for (final v in vids) {
      expect(AudioService.sfxPaths, contains(v), reason: v);
    }
    expect(vids.toSet().length, vids.length, reason: 'no duplicate loads');
    // Round-robins expand: coin → 3, enemy_hit → 3, everything else 1:1.
    expect(vids.length, kSfxWarmIds.length + 2 + 2);
    expect(vids, containsAll(['coin', 'coin_b', 'coin_c', 'enemy_hit_c']));
  });

  test('loops and UI sounds are not warmed (they have their own paths)', () {
    for (final id in [
      'ember_ambience_loop',
      'danger_loop',
      'boss_layer',
      'ui_tap',
      'ui_back',
    ]) {
      expect(kSfxWarmIds, isNot(contains(id)), reason: id);
    }
  });

  test(
    'fails open without an audio platform: no throw, no dead voices',
    () async {
      final a = AudioService(AudioSettings());
      final created = await a.warmSfx(ids: const ['jump', 'coin']);
      expect(created, 0);
      for (final v in ['jump', 'coin', 'coin_b', 'coin_c']) {
        expect(
          a.sfxVoiceCount(v),
          0,
          reason: 'a failed setup must not occupy a voice slot',
        );
      }
    },
  );
}
