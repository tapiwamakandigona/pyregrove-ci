import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/core_loadout.dart';
import 'package:pyregrove/game/input_intent.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/player/player_core.dart';
import 'package:pyregrove/game/session.dart';
import 'package:pyregrove/game/tuning.dart';
import 'package:pyregrove/ui/app_state.dart';
import 'package:pyregrove/ui/settings_screen.dart';

const _dt = 1 / 120;

PlayerCore _player({bool forgiving = true, int extraAirJumps = 0}) {
  final player = PlayerCore(
    x: 32,
    y: 300,
    tileAt: (x, y) => y >= 20 ? TileKind.solid : TileKind.empty,
    forgivingJumps: forgiving,
    extraAirJumps: extraAirJumps,
  );
  for (var i = 0; i < 30; i++) {
    player.update(_dt, InputIntent());
  }
  player.takeEvents();
  return player;
}

({double rise, double airtime, int airEvents}) _tapArc({
  double? secondTap,
  bool forgiving = true,
}) {
  final player = _player(forgiving: forgiving);
  final start = player.body.y;
  var top = start;
  var airEvents = 0;
  var secondPressed = false;
  var landed = 0.0;
  for (var n = 0; n < 360; n++) {
    final time = n * _dt;
    final input = InputIntent();
    if (n == 0 || (secondTap != null && !secondPressed && time >= secondTap)) {
      input.jumpPressed = true;
      input.jumpHeld = true; // real one-frame press/release, not a held bot
      if (n != 0) secondPressed = true;
    }
    player.update(_dt, input);
    top = math.min(top, player.body.y);
    airEvents += player
        .takeEvents()
        .where((event) => event == PlayerEvent.airJumped)
        .length;
    if (n > 5 && player.body.onGround) {
      landed = (n + 1) * _dt;
      break;
    }
  }
  return (
    rise: (start - top) / kTileSize,
    airtime: landed,
    airEvents: airEvents,
  );
}

void main() {
  test('old and new saves select forgiving traversal; classic persists', () {
    expect(SaveData().forgivingJumps, isTrue);
    expect(SaveData.fromJson({'version': 2}).forgivingJumps, isTrue);
    expect(
      SaveData.fromJson({
        'version': 2,
        'forgivingJumps': 'invalid',
      }).forgivingJumps,
      isTrue,
    );
    final classic = SaveData(forgivingJumps: false);
    expect(SaveData.fromJson(classic.toJson()).forgivingJumps, isFalse);
    expect(Loadout.fromSave(classic).forgivingJumps, isFalse);
    expect(Loadout.fromSave(SaveData()).forgivingJumps, isTrue);
  });

  test('real session receives the persisted player preference', () {
    final level = LevelData.parse(
      File('assets/levels/w1_l1.txt').readAsStringSync(),
    );
    expect(
      LevelSession(level, Loadout.fromSave(SaveData())).player.forgivingJumps,
      isTrue,
    );
    expect(
      LevelSession(
        level,
        Loadout.fromSave(SaveData(forgivingJumps: false)),
      ).player.forgivingJumps,
      isFalse,
    );
  });

  test(
    'one-frame tap clears two tiles without holding or changing classic',
    () {
      final gentle = _tapArc();
      final classic = _tapArc(forgiving: false);
      expect(gentle.rise, greaterThan(2.25));
      expect(gentle.rise, lessThan(2.9));
      expect(gentle.airtime, greaterThan(classic.airtime));
      expect(gentle.airEvents, 0);
    },
  );

  for (final delay in [0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35]) {
    test('two short taps ${delay}s apart clear four tiles with margin', () {
      final arc = _tapArc(secondTap: delay);
      expect(arc.rise, greaterThan(4.05));
      expect(
        arc.rise,
        lessThan(4.9),
        reason: 'five-tile walls still gate exploration',
      );
      expect(arc.airEvents, 1);
      expect(arc.airtime, greaterThan(0));
      // ignore: avoid_print
      print(
        '[tap-window] delay=$delay rise=${arc.rise.toStringAsFixed(3)} '
        'airtime=${arc.airtime.toStringAsFixed(3)}',
      );
    });
  }

  test('rapid repeat presses cannot mint extra jumps', () {
    final player = _player();
    var events = 0;
    for (var n = 0; n < 70; n++) {
      player.update(
        _dt,
        InputIntent()
          ..jumpPressed = n.isEven
          ..jumpHeld = n.isEven,
      );
      events += player
          .takeEvents()
          .where((event) => event == PlayerEvent.airJumped)
          .length;
    }
    expect(events, 1);
    expect(player.airJumpsUsed, 1);
  });

  test('queued jump is cancelled by damage and by checkpoint respawn', () {
    for (final damage in [false, true]) {
      final player = _player();
      for (var n = 0; n < 12; n++) {
        player.update(
          _dt,
          InputIntent()
            ..jumpPressed = n == 0 || n == 8
            ..jumpHeld = n == 0 || n == 8,
        );
      }
      expect(player.airJumpQueued, isTrue);
      if (damage) {
        player.damage(1, from: 0);
      } else {
        player.reviveAt(32, 300);
      }
      expect(player.airJumpQueued, isFalse);
      player.takeEvents();
      for (var n = 0; n < 90; n++) {
        player.update(_dt, InputIntent());
      }
      expect(player.takeEvents(), isNot(contains(PlayerEvent.airJumped)));
    }
  });

  test('descent is softer and terminal speed is bounded', () {
    PlayerCore falling(bool forgiving) => PlayerCore(
      x: 0,
      y: 0,
      tileAt: (x, y) => TileKind.empty,
      forgivingJumps: forgiving,
    )..body.vy = 150;
    final gentle = falling(true);
    final classic = falling(false);
    for (var n = 0; n < 100; n++) {
      gentle.update(_dt, InputIntent());
      classic.update(_dt, InputIntent());
    }
    expect(gentle.body.vy, kForgivingMaxFallSpeed);
    expect(gentle.body.vy, lessThan(classic.body.vy));
    expect(gentle.body.y, lessThan(classic.body.y));
  });

  testWidgets('jump preference is visible and reversible without audio', (
    tester,
  ) async {
    AppState.diskWrites = false;
    AppState.init(store: SaveStore(), save: SaveData());
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    final setting = find.widgetWithText(SwitchListTile, 'Forgiving jumps');
    await tester.ensureVisible(setting);
    expect(tester.widget<SwitchListTile>(setting).value, isTrue);
    await tester.tap(setting);
    await tester.pump();
    expect(AppState.save.forgivingJumps, isFalse);
    await tester.tap(setting);
    await tester.pump();
    expect(AppState.save.forgivingJumps, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
