// Additive regressions: interrupted coin flights release exactly their slots.
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/components/coin_fly.dart';
import 'package:pyregrove/game/components/hud.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/ui/app_state.dart';

Future<EmberGame> bootFlightGame() async {
  AppState.diskWrites = false;
  AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
  final game = EmberGame(levelId: 'w1_l1', seedOverride: 42);
  game.onGameResize(Vector2(800, 450));
  await game.onLoad();
  game.mount();
  await game.ready();
  for (var i = 0; i < 70; i++) {
    game.update(1 / 60);
  }
  addTearDown(game.onRemove);
  return game;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('interrupting every mounted flight restores all capacity', () async {
    CoinFlyFx.inFlight = 0;
    final game = await bootFlightGame();
    for (var i = 0; i < CoinFlyFx.cap; i++) {
      game.session.debugEmitCoin(100, 100);
    }
    game.update(1 / 60);
    game.update(1 / 60);
    final flights = game.camera.viewport.children
        .whereType<CoinFlyFx>()
        .toList();
    expect(flights.length, CoinFlyFx.cap);
    expect(CoinFlyFx.inFlight, CoinFlyFx.cap);

    for (final flight in flights) {
      flight.removeFromParent();
    }
    game.update(0);
    game.update(0);
    expect(CoinFlyFx.inFlight, 0);

    // A stale update/removal must neither hold nor release a second slot.
    for (final flight in flights) {
      flight.update(CoinFlyFx.life * 2);
      flight.onRemove();
    }
    expect(CoinFlyFx.inFlight, 0);

    for (var i = 0; i < CoinFlyFx.cap; i++) {
      game.session.debugEmitCoin(100, 100);
    }
    game.update(1 / 60);
    game.update(1 / 60);
    expect(CoinFlyFx.inFlight, CoinFlyFx.cap);
    for (var i = 0; i < 60; i++) {
      game.update(1 / 60);
    }
    expect(CoinFlyFx.inFlight, 0);
  });

  test(
    'root removal cancels queued flights without stealing another owner',
    () async {
      CoinFlyFx.inFlight = 0;
      final game = await bootFlightGame();
      final readout = game.camera.viewport.children
          .whereType<HudReadout>()
          .single;
      final otherOwner = Component();
      var arrivals = 0;
      CoinFlyFx flight() => CoinFlyFx(
        start: Vector2.zero(),
        target: () => Vector2.all(10),
        sprite: readout.coinSprite,
        onArrive: () => arrivals++,
      );
      final queued = flight();
      final independent = flight();
      addTearDown(independent.removeFromParent);
      expect(CoinFlyFx.tryAdd(game.camera.viewport, queued), isTrue);
      expect(CoinFlyFx.tryAdd(otherOwner, independent), isTrue);
      expect(queued.isMounted, isFalse);
      expect(CoinFlyFx.inFlight, 2);

      game.onRemove();
      expect(CoinFlyFx.inFlight, 1);
      queued.update(CoinFlyFx.life * 2);
      queued.onRemove();
      expect(arrivals, 0);
      expect(CoinFlyFx.inFlight, 1);
      independent.removeFromParent();
      expect(CoinFlyFx.inFlight, 0);
    },
  );

  test('arrival and pre-mount cancellation are each idempotent', () async {
    CoinFlyFx.inFlight = 0;
    final game = await bootFlightGame();
    final readout = game.camera.viewport.children
        .whereType<HudReadout>()
        .single;
    var arrivals = 0;
    CoinFlyFx flight() => CoinFlyFx(
      start: Vector2.zero(),
      target: () => Vector2.all(10),
      sprite: readout.coinSprite,
      onArrive: () => arrivals++,
    );
    final arrived = flight();
    expect(CoinFlyFx.tryAdd(game.camera.viewport, arrived), isTrue);
    arrived.update(CoinFlyFx.life * 2);
    arrived.update(CoinFlyFx.life * 2);
    arrived.onRemove();
    expect(arrivals, 1);
    expect(CoinFlyFx.inFlight, 0);

    final cancelled = flight();
    expect(CoinFlyFx.tryAdd(game.camera.viewport, cancelled), isTrue);
    cancelled.removeFromParent();
    cancelled.removeFromParent();
    cancelled.update(CoinFlyFx.life * 2);
    expect(arrivals, 1);
    expect(CoinFlyFx.inFlight, 0);
  });
}
