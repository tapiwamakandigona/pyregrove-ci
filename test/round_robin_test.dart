// Sample round-robins (AUDIO-POLISH C4): the same variant never plays twice
// in a row, every variant is reachable, and every variant id has an asset.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/audio/audio_service.dart';
import 'package:pyregrove/audio/round_robin.dart';

void main() {
  test('never repeats the previous variant', () {
    for (final id in kSfxVariants.keys) {
      var last = -1;
      for (var i = 0; i < 500; i++) {
        final u = (i * 0.6180339887) % 1.0;
        final next = pickVariantIndex(id, last, u);
        expect(next, isNot(last), reason: '$id repeated at step $i');
        expect(next, inInclusiveRange(0, kSfxVariants[id]!.length - 1));
        last = next;
      }
    }
  });

  test('every variant is reachable', () {
    final seen = <int>{};
    for (var i = 0; i < 200; i++) {
      seen.add(pickVariantIndex('coin', i % 3, (i * 0.37) % 1.0));
    }
    expect(seen, {0, 1, 2});
  });

  test('ids without variants always pick index 0 and their own id', () {
    expect(pickVariantIndex('jump', 0, 0.9), 0);
    expect(variantId('jump', 0), 'jump');
    expect(variantId('jump', 5), 'jump');
  });

  test('every variant has a path and the asset exists on disk', () {
    for (final list in kSfxVariants.values) {
      for (final vid in list) {
        final path = AudioService.sfxPaths[vid];
        expect(path, isNotNull, reason: '$vid missing from sfxPaths');
        expect(
          File('assets/$path').existsSync(),
          isTrue,
          reason: 'assets/$path missing',
        );
      }
    }
  });
}
