// Guards lib/version.dart against drifting from pubspec.yaml. The corner
// label on the title screen must always describe the actual build.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/version.dart';

void main() {
  test('kAppVersion matches pubspec.yaml version', () {
    final pubspec = File('pubspec.yaml').readAsLinesSync();
    final line = pubspec.firstWhere((l) => l.startsWith('version:'));
    final version = line.substring('version:'.length).trim();
    expect(kAppVersion, version,
        reason: 'Bump lib/version.dart together with pubspec.yaml');
  });
}
