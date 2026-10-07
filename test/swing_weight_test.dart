// B2 swing weight is feel-only: derived from damage, never changes timing.
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/swing_weight.dart';
import 'package:pyregrove/meta/catalog.dart';

void main() {
  test('catalog mapping: starter light, hammer heavy, the rest medium', () {
    expect(swingWeightFor(weaponById('squire_blade')), SwingWeight.light);
    expect(swingWeightFor(weaponById('wind_gods_hammer')), SwingWeight.heavy);
    for (final id in ['woodsman_axe', 'ember_fang', 'warden_blade', 'skypiercer']) {
      expect(swingWeightFor(weaponById(id)), SwingWeight.medium, reason: id);
    }
  });

  test('light and medium are exactly 1.0 — the starter feel is untouched', () {
    expect(hitPauseMul(SwingWeight.light), 1.0);
    expect(hitPauseMul(SwingWeight.medium), 1.0);
    expect(arcStrokeBonus(SwingWeight.light), 0);
    expect(connectBump(SwingWeight.medium), 0);
  });

  test('heavy is heavier but stays under the 120 ms lag threshold', () {
    expect(hitPauseMul(SwingWeight.heavy), greaterThan(1.0));
    expect(0.070 * hitPauseMul(SwingWeight.heavy), lessThan(0.12));
    expect(arcStrokeBonus(SwingWeight.heavy), greaterThan(0));
    expect(connectBump(SwingWeight.heavy), greaterThan(0));
  });
}
