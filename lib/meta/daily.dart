// meta/daily.dart — Daily Delve: a deterministic daily remix of a World 1
// level. The date alone decides the level and the run seed, so every player
// gets the same remix on the same day. Pure Dart, unit-tested.
//
// Deliberately no dark patterns (spec §7): no streaks, no decay, no expiring
// rewards. Miss a day and nothing is lost — tomorrow is just a new delve.

import '../core/rng.dart';

/// Non-tutorial, non-boss World 1 levels eligible for the daily remix.
const List<String> kDailyPool = ['w1_l2', 'w1_l3', 'w1_l4', 'w1_l5'];

/// World 2 levels that join the rotation once the Grove Golem is down
/// (alpha.23, LEVEL-CRAFT-BACKLOG L6). Each entry must clear the casual-bot
/// wipe probe 4/4 on medium before it is listed. `w2_l4` (Magma Gallery)
/// was held out on 2026-09-02 (medium probe wiped 4/4, easy/hard clean — a
/// bot route desync at the col-94 pillar); after the creeper rework
/// (alpha.23 #27) it probes 4/4 on all three difficulties, so it is in.
const List<String> kDailyPoolWorld2 = ['w2_l2', 'w2_l3', 'w2_l4', 'w2_l5'];

/// Canonical local-date key, e.g. '2026-07-25'.
String dailyKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Deterministic run seed for the date — same for all players, stable
/// across app restarts (derived only from the date string).
int dailySeed(DateTime d) => hashDomainString('daily:${dailyKey(d)}');

/// Which level today's delve remixes.
///
/// Players without World 2 get a uniform pick from [kDailyPool] — the exact
/// pick this function returned before World 2 joined, so nobody's daily
/// changed underneath them. With [world2Unlocked], about half the days swap
/// that pick for one from [kDailyPoolWorld2]. Both decisions depend only on
/// the date, so everyone at the same unlock state plays the same remix.
String dailyLevelId(DateTime d, {bool world2Unlocked = false}) {
  final rng = Rng.create(dailySeed(d), 'daily-pick');
  final w1 = kDailyPool[rng.range(0, kDailyPool.length - 1)];
  if (!world2Unlocked) return w1;
  final w2 = Rng.create(dailySeed(d), 'daily-w2');
  if (w2.range(0, 1) == 0) return w1;
  return kDailyPoolWorld2[w2.range(0, kDailyPoolWorld2.length - 1)];
}
