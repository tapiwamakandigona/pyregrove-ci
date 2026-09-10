// coin_fly_test.dart — alpha.23: coin pickups fly to the HUD counter.
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/components/coin_fly.dart';
import 'package:pyregrove/game/components/hud.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/ui/app_state.dart';

Future<EmberGame> bootGame() async {
  AppState.diskWrites = false;
  AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
  final game = EmberGame(levelId: 'w1_l1', seedOverride: 42);
  game.onGameResize(Vector2(800, 450));
  await game.onLoad();
  game.mount();
  await game.ready();
  game.update(0);
  return game;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('coinFlyPoint: starts at the pickup, lands on the counter, arcs up '
      'in between, eases in', () {
    final a = Vector2(200, 150), b = Vector2(10, 22);
    expect(coinFlyPoint(a, b, 0), a);
    final end = coinFlyPoint(a, b, 1);
    expect(end.x, closeTo(b.x, 1e-9));
    expect(end.y, closeTo(b.y, 1e-9));
    final mid = coinFlyPoint(a, b, 0.5);
    // Ease-in: at half time it has covered only a quarter of the x distance.
    expect(mid.x, closeTo(a.x + (b.x - a.x) * 0.25, 1e-9));
    // Arc: mid-flight sits above the straight-line interpolation.
    expect(mid.y, lessThan(a.y + (b.y - a.y) * 0.25));
  });

  test('a coin pickup launches one flight that lands on the readout and '
      'pulses it; flights are capped', () async {
    final game = await bootGame();
    for (var i = 0; i < 70; i++) {
      game.update(1 / 60);
    }
    final readout = game.camera.viewport.children
        .whereType<HudReadout>()
        .single;
    expect(readout.spritesReady, isTrue);
    CoinFlyFx.inFlight = 0;
    // Fire the real event path: session coin event -> _launchCoinFlight.
    game.session.debugEmitCoin(
      game.session.player.body.centerX,
      game.session.player.body.top,
    );
    game.update(1 / 60);
    game.update(1 / 60); // second tick: Flame mounts queued children
    var flights = game.camera.viewport.children.whereType<CoinFlyFx>();
    expect(flights.length, 1);
    expect(CoinFlyFx.inFlight, 1);
    // Fly to the end: removed, counter pulses.
    for (var i = 0; i < 30; i++) {
      game.update(1 / 60);
    }
    flights = game.camera.viewport.children.whereType<CoinFlyFx>();
    expect(flights, isEmpty);
    expect(CoinFlyFx.inFlight, 0);
    expect(readout.coinPulse, greaterThan(0));
    // Cap: 20 pickups in one frame -> at most CoinFlyFx.cap flights.
    for (var i = 0; i < 20; i++) {
      game.session.debugEmitCoin(100, 100);
    }
    game.update(1 / 60);
    game.update(1 / 60);
    expect(
      game.camera.viewport.children.whereType<CoinFlyFx>().length,
      CoinFlyFx.cap,
    );
  });
}
