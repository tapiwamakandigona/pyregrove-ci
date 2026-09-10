// audio/music_mix.dart — pure math for the music bed's live gain and the
// danger bed's level (AUDIO-POLISH-BACKLOG C1/C3/C6, alpha.23). No players
// here: AudioService owns the timers and pushes these numbers to
// setVolume(), so the behaviour is unit-testable without a platform channel.

import 'dart:math' as math;

/// Music fade-in length after a track switch (mirrors the ~0.4 s fade-out in
/// AudioService._fadeOutAndDispose, so a switch is a symmetric crossfade).
const double kMusicFadeInTime = 0.4;

/// Duck recovery time after a heavy moment (player hit, boss phase, boss
/// death). Short: the mix reacts, it does not pump.
const double kDuckTime = 0.35;

/// Music volume multiplier at the bottom of a duck.
const double kDuckFloor = 0.5;

/// Live gain multiplier for the music bed.
///
/// [sinceStart] seconds since the track began (fade-in; `null` = no fade,
/// used for stings), [duck] remaining duck amount 0..1 (1 = just triggered).
/// Ease-out on the duck so the dip is sudden and the recovery is soft.
double musicGain({double? sinceStart, double duck = 0}) {
  var g = 1.0;
  if (sinceStart != null && sinceStart < kMusicFadeInTime) {
    g *= (sinceStart / kMusicFadeInTime).clamp(0.0, 1.0);
  }
  final d = duck.clamp(0.0, 1.0);
  g *= 1.0 - (1.0 - kDuckFloor) * d * d; // d² = fast dip, soft return
  return g.clamp(0.0, 1.0);
}

/// Danger bed level relative to music volume (C6). Off above [onHearts];
/// grows as hearts fall — one heart left is louder than "just entered the
/// danger band", and a half heart (if the game ever has one) is loudest.
/// [maxHearts] scales the band for Easy's +1 heart.
double dangerLevel(double hearts, {int maxHearts = 3}) {
  if (hearts <= 0) return 0;
  const onHearts = 1.0; // the existing trigger: hearts <= 1
  if (hearts > onHearts) return 0;
  // 1 heart → 0.5 (the previous constant); approaching 0 → 0.8.
  final peril = (onHearts - hearts).clamp(0.0, 1.0);
  return 0.5 + 0.3 * math.sqrt(peril);
}

/// C5: whether the boss intensity layer should be playing. On from boss
/// phase 2, off once the boss is dead or the level is over. Pure.
bool bossLayerWanted({
  required int bossPhase,
  required bool bossDead,
  required bool over,
}) => bossPhase >= 2 && !bossDead && !over;
