// Boss-arena camera framing (alpha.23): midpoint between player and boss,
// player never closer than `margin` to a frame edge.
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/camera_frame.dart';

void main() {
  const view = 352.0;

  test('close boss: camera sits on the midpoint', () {
    final x = bossCameraTargetX(playerX: 100, bossX: 200, viewWidth: view);
    expect(x, 150);
  });

  test('both stay on screen while separation fits the frame', () {
    // 352 wide, margin 48 → the player may sit up to 128 px from center,
    // so a 256 px gap still frames both exactly at the margins.
    final x = bossCameraTargetX(playerX: 100, bossX: 356, viewWidth: view);
    expect(x, 228);
    expect((x - 100).abs(), lessThanOrEqualTo(view / 2 - 48));
    expect((356 - x).abs(), lessThanOrEqualTo(view / 2));
  });

  test('wide separation: player clamps to the margin, not off-screen', () {
    final x = bossCameraTargetX(playerX: 60, bossX: 500, viewWidth: view);
    expect(x, 60 + 128); // player 128 px left of center = 48 px from edge
    // Symmetric when the boss is on the left.
    final y = bossCameraTargetX(playerX: 500, bossX: 60, viewWidth: view);
    expect(y, 500 - 128);
  });

  test('degenerate view: falls back to the player', () {
    expect(bossCameraTargetX(playerX: 10, bossX: 90, viewWidth: 80), 10);
  });
}
