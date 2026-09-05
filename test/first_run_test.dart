// first_run_test.dart — alpha.23: PLAY on a fresh save opens Forest Edge
// directly; once any campaign level is finished it opens level select.
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/meta/progress_state.dart';

void main() {
  test('fresh save -> first campaign level', () {
    expect(firstRunLevelId(SaveData()), 'w1_l1');
    expect(firstRunLevelId(SaveData()), kCampaignOrder.first.id);
  });

  test('an abandoned first run (record exists, unfinished) still -> w1_l1', () {
    final s = SaveData();
    s.recordFor('w1_l1').chestsOpened = 1; // touched but never finished
    s.tutorialSeen = true; // legacy flag alone does not count
    expect(firstRunLevelId(s), 'w1_l1');
  });

  test('any finished level -> null (level select)', () {
    final s = SaveData();
    s.recordFor('w1_l1').finished = true;
    expect(firstRunLevelId(s), isNull);
    final t = SaveData();
    t.recordFor('w2_l3').finished =
        true; // migrated / odd save: still a veteran
    expect(firstRunLevelId(t), isNull);
  });
}
