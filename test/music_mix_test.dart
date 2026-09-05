// music_mix_test.dart — pure gain math behind the audio backlog items
// C1 (fade-in), C3 (ducking) and C6 (danger bed scales with peril).
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/audio/music_mix.dart';

void main() {
  bossLayerTests();
  group('musicGain', () {
    test('fade-in ramps 0 -> 1 over kMusicFadeInTime, then holds', () {
      expect(musicGain(sinceStart: 0), 0);
      expect(musicGain(sinceStart: kMusicFadeInTime / 2), closeTo(0.5, 1e-9));
      expect(musicGain(sinceStart: kMusicFadeInTime), 1);
      expect(musicGain(sinceStart: 99), 1);
    });

    test('stings skip the fade (sinceStart null = full volume)', () {
      expect(musicGain(), 1);
      expect(musicGain(sinceStart: null), 1);
    });

    test('duck dips to the floor and recovers monotonically', () {
      expect(musicGain(duck: 1), closeTo(kDuckFloor, 1e-9));
      var last = musicGain(duck: 1);
      for (var d = 0.9; d >= 0; d -= 0.1) {
        final g = musicGain(duck: d);
        expect(g, greaterThanOrEqualTo(last));
        last = g;
      }
      expect(musicGain(duck: 0), 1);
      // Ease-out: half-way through the recovery the music is already most
      // of the way back (d² curve), so it never reads as a slow swell.
      expect(musicGain(duck: 0.5), greaterThan(0.85));
    });

    test('fade and duck multiply and stay within 0..1', () {
      final g = musicGain(sinceStart: kMusicFadeInTime / 2, duck: 1);
      expect(g, closeTo(0.5 * kDuckFloor, 1e-9));
      expect(musicGain(sinceStart: -1, duck: 5), inInclusiveRange(0.0, 1.0));
    });
  });

  group('dangerLevel', () {
    test('silent above one heart, and when dead', () {
      expect(dangerLevel(3), 0);
      expect(dangerLevel(2), 0);
      expect(dangerLevel(1.01), 0);
      expect(dangerLevel(0), 0);
    });

    test('one heart keeps the historical 0.5; less is louder, capped', () {
      expect(dangerLevel(1), closeTo(0.5, 1e-9));
      expect(dangerLevel(0.5), greaterThan(dangerLevel(1)));
      expect(dangerLevel(0.25), greaterThan(dangerLevel(0.5)));
      expect(dangerLevel(0.01), lessThanOrEqualTo(0.8));
    });
  });
}

// C5: boss intensity layer gating.
void bossLayerTests() {
  test('boss layer on from phase 2, off when dead or over', () {
    expect(
      bossLayerWanted(bossPhase: 1, bossDead: false, over: false),
      isFalse,
    );
    expect(bossLayerWanted(bossPhase: 2, bossDead: false, over: false), isTrue);
    expect(bossLayerWanted(bossPhase: 3, bossDead: false, over: false), isTrue);
    expect(bossLayerWanted(bossPhase: 3, bossDead: true, over: false), isFalse);
    expect(bossLayerWanted(bossPhase: 2, bossDead: false, over: true), isFalse);
    expect(
      bossLayerWanted(bossPhase: 0, bossDead: true, over: false),
      isFalse,
      reason: 'no boss → no layer',
    );
  });
}
