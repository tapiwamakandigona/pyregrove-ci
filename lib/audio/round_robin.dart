// audio/round_robin.dart — sample round-robins for the most-fired one-shots
// (AUDIO-POLISH-BACKLOG C4). Pitch wobble alone cannot hide a single
// repeating sample; the fix is several samples that differ in timbre, picked
// so the same one never plays twice in a row. Pure Dart, unit-tested.

/// Base sfx id → the ids of its interchangeable variants (base included).
/// Variants come from tool/build_sfx_variants.py (same CC0 sources).
const Map<String, List<String>> kSfxVariants = {
  'coin': ['coin', 'coin_b', 'coin_c'],
  'enemy_hit': ['enemy_hit', 'enemy_hit_b', 'enemy_hit_c'],
};

/// Which variant of [id] to play. [last] is the index played previously
/// (-1 for none); [unit] a random draw in [0,1). Ids without variants return
/// index 0. With ≥2 variants the result is never [last].
int pickVariantIndex(String id, int last, double unit) {
  final n = kSfxVariants[id]?.length ?? 1;
  if (n < 2) return 0;
  // Draw from the n-1 indices that are not [last].
  var i = (unit * (n - 1)).floor().clamp(0, n - 2);
  if (last >= 0 && i >= last) i += 1;
  return i;
}

/// The variant sfx id for the chosen index (falls back to [id]).
String variantId(String id, int index) {
  final v = kSfxVariants[id];
  if (v == null || index < 0 || index >= v.length) return id;
  return v[index];
}

/// One-shots gameplay fires in the first minute of any level, in the order a
/// fresh player meets them (alpha.23 #36 warm-up). Loops (ambience, danger,
/// boss layer) and UI/meta sounds are not here: loops have their own
/// players, UI taps tolerate a first-shot load on a menu.
const List<String> kSfxWarmIds = [
  'step1',
  'step2',
  'jump',
  'double_jump',
  'land',
  'swing1',
  'swing2',
  'swing3',
  'coin',
  'enemy_hit',
  'enemy_death',
  'player_hit',
  'block',
  'whoosh',
  'chest_open',
  'feather',
  'heal',
  'secret',
];

/// Expands base ids to every concrete variant asset id, in order, no
/// duplicates — what the warm-up actually loads.
List<String> sfxWarmVariantIds(Iterable<String> ids) {
  final out = <String>[];
  for (final id in ids) {
    for (final v in kSfxVariants[id] ?? [id]) {
      if (!out.contains(v)) out.add(v);
    }
  }
  return out;
}
