// pixel_heart_test.dart — the rasterised heart (alpha.23 #37) is pixel-for-
// pixel the per-pixel drawing it replaced, and costs one op per heart.
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/pixel_heart.dart';

Future<List<int>> _bytes(ui.Image img) async =>
    (await img.toByteData())!.buffer.asUint8List().toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bitmask has 40 lit pixels (what one heart used to cost)', () {
    expect(heartPixelCount(), 40);
  });

  test('HUD heart image equals the per-pixel drawing byte for byte', () async {
    const fill = ui.Color(0xFFD53C3C);
    final img = rasterHeart(fill: fill);
    expect(img.width, 8);
    expect(img.height, 8);
    final rec = ui.PictureRecorder();
    paintHeartPixels(ui.Canvas(rec), ui.Paint()..color = fill);
    final ref = rec.endRecording().toImageSync(8, 8);
    expect(await _bytes(img), await _bytes(ref));
  });

  test(
    'pickup heart (shadow + shine, 1.5x) equals the per-pixel drawing',
    () async {
      const fill = ui.Color(0xFFD53C3C);
      const shine = ui.Color(0xFFF2917F);
      const shadow = ui.Color(0x66201826);
      final img = rasterHeart(
        fill: fill,
        shadow: shadow,
        shine: shine,
        scale: 1.5,
      );
      expect(img.width, 13); // ceil(8 * 1.5 + 1)
      final rec = ui.PictureRecorder();
      final c = ui.Canvas(rec);
      // The original ItemsComponent routine: shadow at (+1,+1), fill, shine.
      paintHeartPixels(c, ui.Paint()..color = shadow, scale: 1.5, dx: 1, dy: 1);
      paintHeartPixels(c, ui.Paint()..color = fill, scale: 1.5);
      c.drawRect(
        const ui.Rect.fromLTWH(1.5, 1.5, 1.5, 1.5),
        ui.Paint()..color = shine,
      );
      final ref = rec.endRecording().toImageSync(13, 13);
      expect(await _bytes(img), await _bytes(ref));
    },
  );
}
