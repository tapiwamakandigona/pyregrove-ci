// Forest parallax backdrop: hand-rolled (full control over factors, no
// Parallax API surprises). Lives in camera.backdrop, so it draws in viewport
// space; layer offsets derive from the camera position each frame.
import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../ember_game.dart';
import 'ambient_motes.dart';

class ParallaxBackground extends Component with HasGameReference<EmberGame> {
  static const _factors = [
    ('back', 0.15),
    ('middle', 0.35),
    ('lights', 0.5),
    ('front', 0.7),
  ];

  // Per-layer draw state, precomputed at load: image, parallax factor,
  // full-image src rect, and view-scaled width (render stays allocation-lean:
  // only the moving dst Rect is built per draw call, as the canvas API needs).
  final List<(ui.Image, double, ui.Rect, double)> _images = [];
  final _paint = ui.Paint()..filterQuality = ui.FilterQuality.none;

  /// Drifting embers (forest) / dust (caves), drawn over the layers.
  late final AmbientMotes motes;

  /// Stable per-level seed (not String.hashCode, which differs on web).
  static int seedFor(String id) {
    var h = 0x811C9DC5;
    for (final c in id.codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0x7fffffff;
    }
    return h;
  }

  @override
  Future<void> onLoad() async {
    const viewH = EmberGame.viewHeight;
    final family = game.session.level.environment == 'cave' ? 'cave' : 'forest';
    motes = AmbientMotes(cave: family == 'cave', seed: seedFor(game.levelId));
    for (final (layer, factor) in _factors) {
      final path = 'bg/${family}_$layer.png';
      final img = await game.images.load(path);
      final src = ui.Rect.fromLTWH(
        0,
        0,
        img.width.toDouble(),
        img.height.toDouble(),
      );
      final w = img.width * (viewH / img.height);
      _images.add((img, factor, src, w));
    }
  }

  @override
  void update(double dt) => motes.update(dt);

  @override
  void render(ui.Canvas canvas) {
    final viewW = game.viewW;
    const viewH = EmberGame.viewHeight;
    final camX = game.cameraPos.x;
    final snap = game.pixelSnap;
    for (final (img, factor, src, w) in _images) {
      // Scroll opposite to camera, wrapped for infinite tiling; the offset
      // lands on the physical pixel grid like the camera (alpha.29).
      var offset = (-camX * factor) % w;
      if (offset > 0) offset -= w;
      offset = (offset / snap).roundToDouble() * snap;
      for (var x = offset; x < viewW; x += w) {
        canvas.drawImageRect(
          img,
          src,
          ui.Rect.fromLTWH(x, 0, w + 0.5, viewH),
          _paint,
        );
      }
    }
    motes.render(canvas, camX, viewW, snap);
  }
}
