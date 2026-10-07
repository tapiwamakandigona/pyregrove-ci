// first_frame_complete_test.dart — the first rendered frame of a level is
// complete: EmberGame.onLoad must not return until every component it adds
// (parallax, decor, tiles, items, player, enemies, HUD) has finished its own
// onLoad (sprite decode). GameWidget ends the loading state the moment
// onLoad resolves, so anything still decoding pops in over the next frames —
// worst on a cold image cache (first level of the session) and on slow
// decoders (low-end phones).
//
// Measured before the hold (2026-09-02, desktop VM, cold cache, w1_l1):
// 4/7 world children, 10/10 HUD children and the parallax were still
// unloaded when onLoad returned. After: 0 everywhere.
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/ui/app_state.dart';

List<Component> _unloaded(EmberGame game) => [
  ...game.camera.backdrop.children,
  ...game.world.children,
  ...game.camera.viewport.children,
].where((c) => !c.isLoaded).toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    AppState.diskWrites = false;
    AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
  });

  for (final id in ['w1_l1', 'w2_l5', 'w1_boss']) {
    test('$id: every level component is loaded when onLoad resolves', () async {
      final game = EmberGame(levelId: id, seedOverride: 42);
      game.onGameResize(Vector2(800, 450));
      await game.onLoad();
      final missing = _unloaded(game);
      expect(
        missing,
        isEmpty,
        reason:
            'still decoding at onLoad return: '
            '${missing.map((c) => c.runtimeType).toList()}',
      );
      // Sanity: the tree is populated (the assertion above is not vacuous).
      expect(game.world.children.length, greaterThanOrEqualTo(5));
      expect(game.camera.viewport.children.length, greaterThanOrEqualTo(10));
      expect(game.camera.backdrop.children.length, 1);
    });
  }

  test(
    'headless boot without a layout still resolves (no held futures)',
    () async {
      // Tests and probes call onLoad before any onGameResize; Flame then hands
      // back null from add() and the hold list must simply be empty.
      final game = EmberGame(levelId: 'w1_l1', seedOverride: 1);
      await game.onLoad().timeout(const Duration(seconds: 10));
      expect(game.sessionReady, isTrue);
    },
  );
}
