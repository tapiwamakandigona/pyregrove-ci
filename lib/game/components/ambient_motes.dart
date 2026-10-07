// Ambient motes (alpha.29 graphics pass): drifting embers in the burning
// forest, slow dust in the caves. Pure decoration drawn by the parallax
// backdrop after its layers (over the far scenery, under the level), so it
// never hides a hazard and never adds a component to the tree.
//
// Cheap by construction: state lives in typed lists, every frame is at most
// a dozen batched drawRawPoints calls (2 layers x 2 sizes x 3 alpha buckets,
// empty buckets skipped) instead of one drawRect per mote, render() allocates
// nothing (each batch's point views are made once, up front), and positions
// are snapped to the physical pixel grid like the camera. Deterministic per
// level (seeded), so screenshots and tests are repeatable.
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

class AmbientMotes {
  AmbientMotes({required this.cave, required int seed})
    : count = cave ? caveCount : forestCount,
      _rng = math.Random(seed) {
    _x = Float64List(count);
    _y = Float64List(count);
    _vx = Float64List(count);
    _vy = Float64List(count);
    _phase = Float64List(count);
    _freq = Float64List(count);
    _factor = Float64List(count);
    _base = Float64List(count);
    _size = Uint8List(count);
    // Hot pale core + orange halo: reads on the dark trunks AND on the
    // amber forest backdrop (a plain orange ember vanished against it).
    final coreRgb = cave
        ? const ui.Color(0xFFF2E6C8)
        : const ui.Color(0xFFFFEDB0);
    final glowRgb = cave
        ? const ui.Color(0xFFB9A57E)
        : const ui.Color(0xFFFF7A2F);
    for (var layer = 0; layer < 2; layer++) {
      for (var size = 1; size <= 2; size++) {
        for (var b = 0; b < _buckets; b++) {
          final a = (b + 1) / _buckets;
          final glow = layer == 0;
          _paints.add(
            ui.Paint()
              ..isAntiAlias = false
              ..strokeCap = ui.StrokeCap.square
              ..strokeWidth = glow ? size + 2.0 : size.toDouble()
              ..color = glow
                  ? glowRgb.withValues(alpha: a * (cave ? 0.2 : 0.45))
                  : coreRgb.withValues(alpha: a),
          );
          final points = Float32List(count * 2);
          _points.add(points);
          _views.add(
            List<Float32List>.generate(
              count + 1,
              (k) => Float32List.sublistView(points, 0, k * 2),
              growable: false,
            ),
          );
          _fill.add(0);
        }
      }
    }
    for (var i = 0; i < count; i++) {
      _spawn(i, initial: true);
    }
  }

  final bool cave;
  final int count;
  final math.Random _rng;

  static const int forestCount = 34;
  static const int caveCount = 24;
  static const double viewHeight = 198; // EmberGame.viewHeight
  static const double margin = 16; // spawn/wrap band outside the view
  static const int _buckets = 3;

  /// Width of the wrap-around strip the motes live in (covers the widest
  /// fill-screen view, 462 = EmberGame.viewWidthMax, plus both margins).
  static const double spanWidth = 462 + margin * 2;

  late final Float64List _x, _y, _vx, _vy, _phase, _freq, _factor, _base;
  late final Uint8List _size;
  double _t = 0;

  // Batches indexed [layer][size-1][bucket] flattened; see _slot.
  final List<ui.Paint> _paints = [];
  final List<Float32List> _points = [];
  final List<int> _fill = [];
  // _views[slot][k] = the first k points of _points[slot], made in the
  // constructor so render() hands drawRawPoints a ready view every frame.
  final List<List<Float32List>> _views = [];

  static int _slot(int layer, int size, int bucket) =>
      (layer * 2 + (size - 1)) * _buckets + bucket;

  void _spawn(int i, {bool initial = false}) {
    _x[i] = _rng.nextDouble() * spanWidth;
    // Initial fill covers the whole view; respawns enter from below (embers
    // rise) or anywhere (dust drifts), so the field never visibly resets.
    _y[i] = initial || cave
        ? _rng.nextDouble() * viewHeight
        : viewHeight + _rng.nextDouble() * margin;
    if (cave) {
      _vx[i] = (_rng.nextDouble() - 0.5) * 6; // px/s, lazy sideways drift
      _vy[i] = (_rng.nextDouble() - 0.5) * 4;
      _base[i] = 0.35 + _rng.nextDouble() * 0.35;
      _size[i] = 1;
    } else {
      _vx[i] = (_rng.nextDouble() - 0.5) * 5;
      _vy[i] = -(7 + _rng.nextDouble() * 12); // embers rise
      _base[i] = 0.5 + _rng.nextDouble() * 0.5;
      _size[i] = _rng.nextDouble() < 0.45 ? 2 : 1;
    }
    _phase[i] = _rng.nextDouble() * math.pi * 2;
    _freq[i] = 1.2 + _rng.nextDouble() * 2.4;
    _factor[i] = 0.55 + _rng.nextDouble() * 0.35; // mid..front parallax
  }

  void update(double dt) {
    if (dt <= 0) return;
    _t += dt;
    for (var i = 0; i < count; i++) {
      // Gentle sway on top of the drift: embers flutter, dust breathes.
      final sway = math.sin(_t * _freq[i] * 0.5 + _phase[i]) * (cave ? 1.5 : 4);
      _x[i] = (_x[i] + (_vx[i] + sway) * dt) % spanWidth;
      _y[i] += _vy[i] * dt;
      if (_y[i] < -margin || _y[i] > viewHeight + margin) _spawn(i);
    }
  }

  /// View-space top-left of mote [i] for a camera x (unsnapped).
  ui.Offset positionOf(int i, double camX) {
    var sx = (_x[i] - camX * _factor[i]) % spanWidth;
    if (sx < 0) sx += spanWidth;
    return ui.Offset(sx - margin, _y[i]);
  }

  /// Draws every visible mote. [snap] = world px per physical pixel.
  void render(ui.Canvas canvas, double camX, double viewW, double snap) {
    for (var k = 0; k < _fill.length; k++) {
      _fill[k] = 0;
    }
    final unit = snap > 0 ? snap : 1.0;
    for (var i = 0; i < count; i++) {
      var sx = (_x[i] - camX * _factor[i]) % spanWidth;
      if (sx < 0) sx += spanWidth;
      final x = ((sx - margin) / unit).roundToDouble() * unit;
      if (x < -4 || x > viewW + 4) continue;
      final y = (_y[i] / unit).roundToDouble() * unit;
      final flicker = 0.6 + 0.4 * math.sin(_t * _freq[i] + _phase[i]);
      final a = (_base[i] * flicker).clamp(0.0, 1.0);
      final bucket = (a * _buckets).ceil().clamp(1, _buckets) - 1;
      final s = _size[i];
      // Point = square centre (square caps): top-left (x, y), side s.
      final cx = x + s / 2, cy = y + s / 2;
      for (var layer = 0; layer < 2; layer++) {
        final slot = _slot(layer, s, bucket);
        final n = _fill[slot];
        _points[slot]
          ..[n] = cx
          ..[n + 1] = cy;
        _fill[slot] = n + 2;
      }
    }
    for (var slot = 0; slot < _fill.length; slot++) {
      final n = _fill[slot];
      if (n == 0) continue;
      canvas.drawRawPoints(
        ui.PointMode.points,
        _views[slot][n ~/ 2],
        _paints[slot],
      );
    }
  }
}
