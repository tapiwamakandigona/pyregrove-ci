// pixel_heart.dart — the 8x8 procedural heart shared by the HUD (hearts +
// lives) and the in-level heart pickup, rasterised ONCE into an image.
//
// alpha.23 #37: both places used to draw the heart pixel by pixel every
// frame — 40 drawRect calls per heart, 81 per pickup (shadow + fill + shine).
// With three hearts, the lives heart and a couple of pickups that was 160–320
// canvas ops per frame for shapes that never change (measured with a
// counting canvas: w1_l1 244 draw ops/frame of which 160 were heart pixels;
// w1_l5 409 of which 323). One drawImage per heart replaces them; the
// bitmask, colours and 1.5x pickup scale are unchanged so the pixels on
// screen are identical.
import 'dart:ui' as ui;

/// Row bitmasks, top to bottom (bit 7 = leftmost column).
const List<int> kHeartRows = [
  0x66, // .##..##.
  0xFF, // ########
  0xFF, // ########
  0xFF, // ########
  0x7E, // .######.
  0x3C, // ..####..
  0x18, // ...##...
  0x00,
];

/// Number of lit pixels in [kHeartRows] (what one heart used to cost in
/// drawRect calls).
int heartPixelCount() {
  var n = 0;
  for (final bits in kHeartRows) {
    for (var col = 0; col < 8; col++) {
      if ((bits >> (7 - col)) & 1 == 1) n++;
    }
  }
  return n;
}

/// Draws the heart's lit pixels at [scale] with [paint], origin at (0, 0),
/// offset by ([dx], [dy]). This is the original per-pixel routine; it is
/// what gets recorded into the cached image.
void paintHeartPixels(
  ui.Canvas canvas,
  ui.Paint paint, {
  double scale = 1,
  double dx = 0,
  double dy = 0,
}) {
  for (var row = 0; row < 8; row++) {
    final bits = kHeartRows[row];
    for (var col = 0; col < 8; col++) {
      if ((bits >> (7 - col)) & 1 == 1) {
        canvas.drawRect(
          ui.Rect.fromLTWH(dx + col * scale, dy + row * scale, scale, scale),
          paint,
        );
      }
    }
  }
}

/// Rasterises one heart into a GPU-resident image via
/// [ui.Picture.toImageSync]. [fill] is the heart colour; an optional
/// [shadow] is drawn first offset by (+1, +1) px and an optional [shine]
/// pixel sits on the top-left lobe (the pickup look). The image is
/// `ceil(8 * scale + (shadow ? 1 : 0))` square; draw it with
/// `canvas.drawImage(img, Offset(left, top), paint)` where (left, top) is
/// where the heart's top-left pixel used to go. Caller owns the image
/// (dispose in onRemove).
ui.Image rasterHeart({
  required ui.Color fill,
  ui.Color? shadow,
  ui.Color? shine,
  double scale = 1,
}) {
  final size = (8 * scale + (shadow != null ? 1 : 0)).ceil();
  final rec = ui.PictureRecorder();
  final c = ui.Canvas(rec);
  if (shadow != null) {
    paintHeartPixels(c, ui.Paint()..color = shadow, scale: scale, dx: 1, dy: 1);
  }
  paintHeartPixels(c, ui.Paint()..color = fill, scale: scale);
  if (shine != null) {
    c.drawRect(
      ui.Rect.fromLTWH(1 * scale, 1 * scale, scale, scale),
      ui.Paint()..color = shine,
    );
  }
  return rec.endRecording().toImageSync(size, size);
}
