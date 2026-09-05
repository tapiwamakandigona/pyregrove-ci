// meta/progress_state.dart — world/level registry + unlock rules.
// Pure Dart, unit-tested.

import '../core/save.dart';
import '../game/difficulty.dart';
import '../game/session.dart' show LevelResults;
import 'catalog.dart';

class LevelEntry {
  final String id; // matches assets/levels/<id>.txt
  final String title;
  final bool isBoss;

  /// Optional side content (alpha.23): not in the campaign order, never a
  /// prerequisite for anything, gated by its own rule.
  final bool isBonus;
  const LevelEntry(
    this.id,
    this.title, {
    this.isBoss = false,
    this.isBonus = false,
  });
}

/// World 1 — the Pyregrove. Order matters: each level unlocks the next;
/// the boss needs every prior level finished.
const List<LevelEntry> kWorld1 = [
  LevelEntry('w1_l1', 'Forest Edge'),
  LevelEntry('w1_l2', 'Old Orchard'),
  LevelEntry('w1_l3', 'Bramble Hollow'),
  LevelEntry('w1_l4', 'Charcoal Camp'),
  LevelEntry('w1_l5', 'Rootway Ruins'),
  LevelEntry('w1_boss', 'Grove Golem', isBoss: true),
];

/// World 2 — Cinder Depths. Unlocks once the World 1 boss falls.
const List<LevelEntry> kWorld2 = [
  LevelEntry('w2_l1', 'Ashen Gate'),
  LevelEntry('w2_l2', 'Ember Vault'),
  LevelEntry('w2_l3', 'Soot Falls'),
  LevelEntry('w2_l4', 'Magma Gallery'),
  LevelEntry('w2_l5', 'Kiln Works'),
  LevelEntry('w2_boss', 'Kiln Golem', isBoss: true),
];

/// World 1 bonus — Ember Hollow. Side content: opens once the Grove Golem
/// falls (same gate as World 2), sits outside the campaign order, and is
/// never required for anything. Coin-rich, harder platforming, the full
/// World 1 roster.
const List<LevelEntry> kBonusLevels = [
  LevelEntry('w1_bonus', 'Ember Hollow', isBonus: true),
  LevelEntry('w2_bonus', 'Slag Cellar', isBonus: true),
];

/// The boss each bonus level waits for (by bonus index): Ember Hollow opens
/// with the Grove Golem, Slag Cellar with the Kiln Golem.
const List<String> kBonusGates = ['w1_boss', 'w2_boss'];

bool isWorld2Unlocked(SaveData save) =>
    save.levels['w1_boss']?.finished ?? false;

/// Any bonus level available at all (drives the section header).
bool isBonusUnlocked(SaveData save) => isBonusGateMet(save, 0);

bool isBonusGateMet(SaveData save, int bonusIndex) {
  if (bonusIndex < 0 || bonusIndex >= kBonusGates.length) return false;
  return save.levels[kBonusGates[bonusIndex]]?.finished ?? false;
}

bool isLevelUnlocked(SaveData save, int index, {List<LevelEntry>? world}) {
  // World 2's first level additionally requires the World 1 boss.
  if (identical(world, kWorld2) && !isWorld2Unlocked(save)) return false;
  // Bonus levels: each one has its own boss gate, no chain between them.
  if (identical(world, kBonusLevels)) return isBonusGateMet(save, index);
  final w = world ?? kWorld1;
  if (index <= 0) return true;
  if (index >= w.length) return false;
  final entry = w[index];
  if (entry.isBoss) {
    return w.take(index).every((e) => save.levels[e.id]?.finished ?? false);
  }
  return save.levels[w[index - 1].id]?.finished ?? false;
}

/// Campaign order across both worlds (level select shows the same order).
/// Bonus levels are deliberately NOT in it: "Next level" never routes into
/// or out of side content, and nothing depends on a bonus clear.
List<LevelEntry> get kCampaignOrder => [...kWorld1, ...kWorld2];

/// Every playable level file the registry knows about (content tests).
List<LevelEntry> get kAllLevels => [...kCampaignOrder, ...kBonusLevels];

/// The level a "Next level" button should open after clearing [levelId],
/// or null when there is none to offer: unknown/daily ids, the final boss,
/// or a successor that is still locked (a boss whose prerequisites are not
/// all finished — the player skipped ahead via a replay). Comparables
/// (docs/research/b-comparables-first-10-minutes.md, Apple Knight) drop the
/// player straight into the next stage instead of a menu round-trip.
String? nextLevelId(SaveData save, String levelId) {
  final order = kCampaignOrder;
  final i = order.indexWhere((e) => e.id == levelId);
  if (i < 0 || i + 1 >= order.length) return null;
  final next = order[i + 1];
  final world = kWorld1.any((e) => e.id == next.id) ? kWorld1 : kWorld2;
  final idx = world.indexWhere((e) => e.id == next.id);
  return isLevelUnlocked(save, idx, world: world) ? next.id : null;
}

/// What a FIRST clear of [levelId] opens, as level-select labels for the
/// clear screen ("UNLOCKED" lines). Empty for everything that is not a gate.
/// Pure; the game decides "first" by reading the record before merging.
List<String> unlocksOnFirstClear(String levelId) => switch (levelId) {
  'w1_boss' => const ['World 2 — Cinder Depths', 'Bonus — Ember Hollow'],
  'w2_boss' => const ['Bonus — Slag Cellar'],
  _ => const [],
};

/// First run: the level PLAY should open directly instead of level select,
/// or null once any campaign level has been finished. Comparables (Apple
/// Knight) drop a new player straight into the tutorial stage — the menu
/// appears after it. Pyregrove's first level IS the tutorial (signs), so
/// PLAY → Forest Edge on a fresh save; PLAY → level select from then on.
/// Keyed on finished records, not `tutorialSeen`, so an abandoned first run
/// still lands in Forest Edge next time.
String? firstRunLevelId(SaveData save) =>
    save.levels.values.any((r) => r.finished) ? null : kCampaignOrder.first.id;

/// Merge one campaign run into the level's record (pure; the game calls it
/// exactly once at level end). Medals and chest/secret counts only ever go
/// up, best time only down, and a finish on Hard sets the replay mark.
void mergeLevelResult(LevelRecord rec, LevelResults r, Difficulty difficulty) {
  rec.finished = rec.finished || r.finished;
  rec.allChests = rec.allChests || r.allChests;
  rec.lowDamage = rec.lowDamage || r.lowDamage;
  if (r.chestsOpened > rec.chestsOpened) rec.chestsOpened = r.chestsOpened;
  if (r.secretsFound > rec.secretsFound) rec.secretsFound = r.secretsFound;
  if (rec.bestTimeMs == 0 || r.timeMs < rec.bestTimeMs) {
    rec.bestTimeMs = r.timeMs;
  }
  if (r.finished && difficulty == Difficulty.hard) rec.hardCleared = true;
}

/// Skin level from lifetime kills while wearing it (see Skin.killsForLevel).
int skinLevel(SaveData save, String skinId) {
  final kills = save.skinKills[skinId] ?? 0;
  var level = 1;
  while (level < Skin.maxLevel && kills >= Skin.killsForLevel(level)) {
    level++;
  }
  return level;
}

/// Effective melee damage multiplier: skin power x weapon-agnostic bonuses.
double meleePower(SaveData save) =>
    skinById(save.equippedSkin).powerAt(skinLevel(save, save.equippedSkin));

int maxHearts(SaveData save) {
  var hearts = 3;
  if (weaponById(save.equippedWeapon).special == WeaponSpecial.bonusHeart) {
    hearts += 1;
  }
  return hearts;
}

int appleCapacity(SaveData save) =>
    10 + (save.ownedAbilities.contains('apple_pouch') ? 3 : 0);
