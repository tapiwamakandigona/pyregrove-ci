import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../tuning.dart';

/// B4 kill permanence (FEEL-POLISH-BACKLOG): a defeated grounded enemy
/// leaves a small ash smudge at its feet so a cleared room *looks* cleared
/// instead of the enemy vanishing with the death pop.
///
/// Budget (2 GB devices): no sprite asset, no animation — three flat
/// ellipses per decal, alpha only decays over the last [kAshDecalFade]
/// seconds, and [AshDecals] caps live decals per level (oldest evicted).
class AshDecalFx extends PositionComponent {
  AshDecalFx(Vector2 at, {this.footprint = 14})
      : super(position: at, priority: 1);

  /// Decal width in world px (not the component's size).
  final double footprint;
  double _t = 0;
  final _paint = ui.Paint();

  static const _dark = ui.Color(0xB03A312C);
  static const _mid = ui.Color(0x9A5A4F44);

  @override
  void update(double dt) {
    _t += dt;
    if (_t >= kAshDecalLife) removeFromParent();
  }

  @override
  void render(ui.Canvas canvas) {
    final left = kAshDecalLife - _t;
    final k = left >= kAshDecalFade ? 1.0 : (left / kAshDecalFade).clamp(0.0, 1.0);
    final w = footprint;
    _paint.color = _dark.withValues(alpha: _dark.a * k);
    canvas.drawOval(
        ui.Rect.fromCenter(center: ui.Offset.zero, width: w, height: 3), _paint);
    _paint.color = _mid.withValues(alpha: _mid.a * k);
    canvas.drawOval(
        ui.Rect.fromCenter(
            center: ui.Offset(-w * 0.18, -1), width: w * 0.5, height: 2.4),
        _paint);
    canvas.drawOval(
        ui.Rect.fromCenter(
            center: ui.Offset(w * 0.22, -0.6), width: w * 0.35, height: 2),
        _paint);
  }
}

/// Per-level registry that owns the decal cap. Dropped with the game world.
class AshDecals {
  AshDecals({this.cap = kAshDecalCap});
  final int cap;
  final List<AshDecalFx> _live = [];

  int get count {
    _live.removeWhere((d) => d.isRemoved || d.parent == null && !d.isMounted);
    return _live.length;
  }

  /// Adds a decal under [parent]; evicts the oldest when over [cap].
  AshDecalFx add(Component parent, Vector2 at, {double footprint = 14}) {
    _live.removeWhere((d) => d.isRemoved);
    while (_live.length >= cap) {
      _live.removeAt(0).removeFromParent();
    }
    final fx = AshDecalFx(at, footprint: footprint);
    _live.add(fx);
    parent.add(fx);
    return fx;
  }
}
