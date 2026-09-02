// Asset decode gate: every bundled PNG must decode through Flutter's OWN
// image codec (ui.instantiateImageCodec — the same Skia decode path
// game.images.load() uses at runtime), not merely through an external tool.
//
// Origin (2026-09-01): the shipped alpha.21 APK, installed on a 2 GB
// Android 14 emulator, spammed "Codec failed to produce an image" unhandled
// exceptions on first level entry and rendered a grey screen. All 179 APK
// PNGs decode fine with PIL and are byte-identical to the repo copies
// (verified by sha256), so this gate discriminates: if it passes on the
// desktop engine, Skia can decode our bytes and the emulator failure is
// environment-side (decode-to-texture under swiftshader / TCG), not asset
// corruption. If it ever fails, an asset regression would grey-screen real
// devices — fail loud here, before any release.
//
// This decodes repo files directly (no pumping, no GameWidget) and is
// test-only: freeze-compatible.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

Future<List<File>> _bundledPngs() async {
  // Everything under assets/images is bundled via pubspec (verified: the
  // pubspec asset list covers assets/images/**; assets/icon is NOT bundled
  // and NOT listed here).
  final root = Directory('assets/images');
  expect(root.existsSync(), isTrue,
      reason: 'run from repo root: assets/images missing');
  final files = root
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.png'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return files;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every bundled PNG decodes through the engine codec', () async {
    final files = await _bundledPngs();
    // Count pin: 179 bundled PNGs as of alpha.21. If this drifts, update it
    // deliberately — a silent drop means an asset went missing from the set
    // this gate protects.
    expect(files.length, 179,
        reason: 'bundled PNG count changed — update pin deliberately');

    final failures = <String>[];
    for (final f in files) {
      final Uint8List bytes = f.readAsBytesSync();
      try {
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        if (frame.image.width <= 0 || frame.image.height <= 0) {
          failures.add('${f.path}: decoded to empty image');
        }
        frame.image.dispose();
        codec.dispose();
      } catch (e) {
        failures.add('${f.path}: $e');
      }
    }
    expect(failures, isEmpty,
        reason: 'engine codec failed on:\n${failures.join('\n')}');
  });
}
