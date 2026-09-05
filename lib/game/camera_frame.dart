/// Pure camera-target helpers for EmberGame._followCamera.
///
/// Boss arenas: once a boss is awake the camera frames the midpoint between
/// player and boss instead of chasing the player with look-ahead, so a
/// retreating player never loses sight of what is throwing shockwaves at
/// them (alpha.20 observation: golem off-camera during the opener). The
/// player is always kept at least [margin] px inside the frame, so a very
/// wide separation degrades to "player near the edge, boss just off" rather
/// than "player off-screen".
double bossCameraTargetX({
  required double playerX,
  required double bossX,
  required double viewWidth,
  double margin = 48,
}) {
  final mid = (playerX + bossX) / 2;
  final reach = viewWidth / 2 - margin;
  if (reach <= 0) return playerX;
  return mid.clamp(playerX - reach, playerX + reach);
}
