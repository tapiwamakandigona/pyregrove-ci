import '../meta/catalog.dart';

/// B2 swing weight (FEEL-POLISH), feel-only. Dead Cells sells mass through
/// the anticipation:strike:recovery ratio; Pyregrove keeps the B6 rule
/// (press == hit for every weapon, no timing change) and sells mass with
/// the *receipt* instead: heavier hitstop, a wider arc stroke, a small
/// camera thud on connect. Damage/range/timing are untouched, so TTK,
/// par_s and every combat probe stay as tuned.
enum SwingWeight { light, medium, heavy }

/// Derived from damage so the catalog needs no new field: the 9-dmg hammer
/// is the only heavy; the 3-dmg starter is light; the rest medium.
SwingWeight swingWeightFor(Weapon w) {
  if (w.damage >= 8) return SwingWeight.heavy;
  if (w.damage <= 3) return SwingWeight.light;
  return SwingWeight.medium;
}

/// Multiplier on kHitPause/kKillPause at a melee connect. Light and medium
/// are 1.0 on purpose: the starter blade must feel exactly as tuned.
double hitPauseMul(SwingWeight w) => switch (w) {
      SwingWeight.heavy => 1.35,
      _ => 1.0,
    };

/// Extra arc stroke width (world px) drawn on top of the combo stroke.
double arcStrokeBonus(SwingWeight w) => switch (w) {
      SwingWeight.heavy => 1.0,
      _ => 0.0,
    };

/// Camera bump on a plain (non-crit, non-finisher) connect; 0 = none.
double connectBump(SwingWeight w) => switch (w) {
      SwingWeight.heavy => 1.6,
      _ => 0.0,
    };
