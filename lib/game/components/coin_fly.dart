// game/components/coin_fly.dart — "coin flies to the counter" (alpha.23).
//
// On pickup a small coin sprite launches from where the coin was and eases
// into the HUD coin readout, which pulses on arrival. Pure feedback: the
// wallet is credited by the session at pickup time as before. One sprite
// draw per coin in flight, capped so a coin chain can't pile up work on a
// low-end phone.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../ember_game.dart';

/// Pure path: quadratic ease-in from [start] to [end] with a small upward
/// arc that peaks mid-flight. k ∈ [0, 1]. Tested directly.
Vector2 coinFlyPoint(Vector2 start, Vector2 end, double k, {double arc = 18}) {
  final e = k * k; // ease-in: hangs at the pickup, then rushes the counter
  final x = start.x + (end.x - start.x) * e;
  final y = start.y + (end.y - start.y) * e - arc * math.sin(k * math.pi);
  return Vector2(x, y);
}

class CoinFlyFx extends PositionComponent with HasGameReference<EmberGame> {
  static const life = 0.42;
  static const cap = 12; // concurrent flights (a chain past this just counts)
  static int inFlight = 0;
  // Track queued flights too: Flame does not call onRemove before onMount,
  // and removing a GameWidget does not recursively remove its components.
  static final _flights = <Component, Set<CoinFlyFx>>{};

  final Vector2 _start;
  final Vector2 Function() _target;
  final Sprite _sprite;
  final void Function() _onArrive;
  double _t = 0;
  bool _slotHeld = false;
  bool _finished = false;
  Component? _owner;
  final _paint = ui.Paint()..filterQuality = ui.FilterQuality.none;

  CoinFlyFx({
    required Vector2 start,
    required Vector2 Function() target,
    required Sprite sprite,
    required void Function() onArrive,
  }) : _start = start.clone(),
       _target = target,
       _sprite = sprite,
       _onArrive = onArrive,
       super(position: start.clone(), size: Vector2.all(10), priority: 9);

  /// Spawns a flight if under the cap; returns whether one was spawned.
  static bool tryAdd(Component into, CoinFlyFx fx) {
    if (inFlight >= cap || fx._slotHeld || fx._finished) return false;
    fx._slotHeld = true;
    fx._owner = into;
    (_flights[into] ??= <CoinFlyFx>{}).add(fx);
    inFlight++;
    into.add(fx);
    return true;
  }

  void _releaseSlot() {
    if (!_slotHeld) return;
    _slotHeld = false;
    inFlight = math.max(0, inFlight - 1);
    final owned = _flights[_owner];
    owned?.remove(this);
    if (owned?.isEmpty ?? false) _flights.remove(_owner);
    _owner = null;
  }

  /// Discard this viewport's mounted AND queued flights on game removal.
  /// Do not reset a global count: a replacement route may already own flights.
  static void cancelAllIn(Component into) {
    final flights = _flights[into]?.toList(growable: false);
    if (flights == null) return;
    for (final flight in flights) {
      flight.removeFromParent();
    }
  }

  @override
  void removeFromParent() {
    _finished = true;
    _releaseSlot();
    super.removeFromParent();
  }

  @override
  void onRemove() {
    // Also handle removal through the mounted parent component.
    _finished = true;
    _releaseSlot();
    super.onRemove();
  }

  @override
  void update(double dt) {
    if (_finished) return;
    _t += dt;
    final k = (_t / life).clamp(0.0, 1.0);
    position.setFrom(coinFlyPoint(_start, _target(), k));
    // Shrinks into the counter.
    final s = 10 - 4 * k;
    size.setValues(s, s);
    if (_t >= life) {
      _finished = true;
      _releaseSlot();
      _onArrive();
      removeFromParent();
    }
  }

  @override
  void render(ui.Canvas canvas) {
    _sprite.render(canvas, size: size, overridePaint: _paint);
  }
}
