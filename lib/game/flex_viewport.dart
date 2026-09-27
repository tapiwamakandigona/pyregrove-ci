// Fixed virtual HEIGHT, flexible width: the game view fills wide phones
// edge to edge instead of letterboxing the 16:9 design view.
//
// Flame's FixedResolutionViewport keeps one aspect ratio forever, so on a
// 20:9 phone a 352x198 view left a black band down each side (~12% of the
// screen each). This viewport keeps the owner-confirmed vertical framing
// (198 world px tall, so the 24 px knight stays 12.1% of screen height) and
// widens the visible world to the phone's shape, between [minWidth] (the
// 16:9 design view, still letterboxed on 4:3 tablets) and [maxWidth]
// (21:9; anything wider gets thin bands again). The scale stays uniform.
//
// With [fill] off it behaves exactly like FixedResolutionViewport at
// [minWidth] x [height] (Settings > Fill screen off = the classic framing).
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';

/// A Viewport (not a FixedResolutionViewport: that class re-imposes its
/// construction-time aspect ratio on every resize) with a uniform scale from
/// the flexible virtual resolution to the fitted on-screen box.
class FlexWidthViewport extends Viewport {
  FlexWidthViewport({
    required this.height,
    required this.minWidth,
    required this.maxWidth,
    required this.fill,
    super.children,
  }) : resolution = Vector2(minWidth, height);

  final double height;
  final double minWidth;
  final double maxWidth;
  final bool fill;

  /// Current virtual size in world px (width follows the canvas shape).
  final Vector2 resolution;

  /// Visible world width for a canvas: pure, shared with EmberGame so the
  /// HUD layout and the viewport can never disagree.
  static double widthFor(
    Vector2 canvas, {
    required double height,
    required double minWidth,
    required double maxWidth,
    required bool fill,
  }) {
    if (!fill || canvas.x <= 0 || canvas.y <= 0) return minWidth;
    final w = height * canvas.x / canvas.y;
    if (w.isNaN) return minWidth;
    return w.clamp(minWidth, maxWidth).toDouble();
  }

  double _scale = 1;
  Rect _clipRect = Rect.zero;

  /// Uniform on-screen px per world px.
  double get scaleFactor => _scale;

  @override
  Vector2 get virtualSize => resolution;

  @override
  void onLoad() {
    _fit(findGame()!.canvasSize);
  }

  @override
  void onGameResize(Vector2 size) {
    if (isLoaded) {
      super.onGameResize(size);
    }
    _fit(size);
  }

  void _fit(Vector2 canvas) {
    resolution.setValues(
      widthFor(
        canvas,
        height: height,
        minWidth: minWidth,
        maxWidth: maxWidth,
        fill: fill,
      ),
      height,
    );
    final aspect = resolution.x / resolution.y;
    // The size setter resets the viewfinder's visible rect, runs
    // onViewportResize (scale) and tells the HUD children the virtual size.
    size = (canvas.y * aspect > canvas.x)
        ? Vector2(canvas.x, canvas.x / aspect)
        : Vector2(canvas.y * aspect, canvas.y);
    position.x = (canvas.x - size.x) / 2 + anchor.x * size.x;
    position.y = (canvas.y - size.y) / 2 + anchor.y * size.y;
    _clipRect = Rect.fromLTRB(0, 0, size.x, size.y);
  }

  @override
  void onViewportResize() {
    if (resolution.x <= 0 || resolution.y <= 0) return;
    _scale = math.min(size.x / resolution.x, size.y / resolution.y);
  }

  @override
  void clip(Canvas canvas) => canvas.clipRect(_clipRect, doAntiAlias: false);

  @override
  bool containsLocalPoint(Vector2 point) {
    final x = point.x;
    final y = point.y;
    return x >= 0 && y >= 0 && x <= virtualSize.x && y <= virtualSize.y;
  }

  @override
  Vector2 globalToLocal(Vector2 point, {Vector2? output}) {
    final local = super.globalToLocal(point, output: output);
    return local..scale(1 / _scale);
  }

  @override
  Vector2 localToGlobal(Vector2 point, {Vector2? output}) {
    final scaled = (output ?? Vector2.zero())
      ..setValues(point.x * _scale, point.y * _scale);
    return super.localToGlobal(scaled, output: scaled);
  }

  @override
  void transformCanvas(Canvas canvas) {
    super.transformCanvas(canvas); // identity: this class never sets it
    canvas.scale(_scale);
  }
}
