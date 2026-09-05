// Jump-arc characterisation tests (owner directive 2026-09-01d).
// These pin the arc in TILES and MILLISECONDS. When tuning changes the arc,
// update these expected values IN THE SAME COMMIT so every arc change is
// visible in a diff and can never drift silently. Never loosen a tolerance
// to make a run pass.
//
// Current values (v after 2026-09-01 jump-feel tuning, measured in-engine):
//   full jump:  2.33 tiles high, apex 292 ms, airtime 558 ms
//   tap jump:   1.60 tiles high, airtime 350 ms
//   full+run:   4.12 tiles horizontal range
//   air (2nd):  4.20 tiles total rise, 6.33 tiles range at full run
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/game/input_intent.dart';
import 'package:pyregrove/game/level/level_data.dart';
import 'package:pyregrove/game/player/player_core.dart';
import 'package:pyregrove/game/tuning.dart';

const dt = 1 / 120;

final flat = LevelData.parse('''
....................................................................
....................................................................
....................................................................
....................................................................
....................................................................
....................................................................
....................................................................
.P................................................................E.
####################################################################
''');

PlayerCore mk() {
  final s = flat.playerSpawn;
  final c = PlayerCore(
    x: s.x * kTileSize + 2,
    y: (s.y + 1) * kTileSize - 20,
    tileAt: flat.tileAt,
  );
  final idle = InputIntent();
  for (var i = 0; i < 30; i++) {
    c.update(dt, idle);
  }
  c.takeEvents();
  return c;
}

class Arc {
  double heightTiles = 0, apexMs = 0, airtimeMs = 0, rangeTiles = 0;
}

Arc measure({required bool tap, bool air = false, bool run = false}) {
  final c = mk();
  final i = InputIntent();
  if (run) {
    final pre = InputIntent()..dirX = 1;
    for (var k = 0; k < 60; k++) {
      pre.clearEdges();
      c.update(dt, pre);
    }
  }
  final y0 = c.body.y, x0 = c.body.x;
  var t = 0.0;
  var minY = c.body.y;
  double apexT = 0;
  var jumped = false, airJumped = false;
  double landedAt = -1;
  while (t < 3.0) {
    i
      ..dirX = (run ? 1 : 0)
      ..down = false;
    i.clearEdges();
    if (!jumped) {
      i.jumpPressed = true;
      jumped = true;
    }
    i.jumpHeld = tap ? (t < 0.09) : true;
    if (air &&
        jumped &&
        !airJumped &&
        c.body.vy > -40 &&
        c.body.vy < 40 &&
        t > 0.05) {
      i.jumpPressed = true;
      airJumped = true;
    }
    c.update(dt, i);
    t += dt;
    if (c.body.y < minY) {
      minY = c.body.y;
      apexT = t;
    }
    if (t > 0.1 && c.body.onGround && landedAt < 0) {
      landedAt = t;
      break;
    }
  }
  return Arc()
    ..heightTiles = (y0 - minY) / kTileSize
    ..apexMs = apexT * 1000
    ..airtimeMs = landedAt * 1000
    ..rangeTiles = (c.body.x - x0) / kTileSize;
}

void main() {
  test('full jump: 2.33 tiles high, apex ~292 ms, airtime ~558 ms', () {
    final a = measure(tap: false);
    expect(a.heightTiles, closeTo(2.33, 0.05));
    expect(a.apexMs, closeTo(292, 10));
    expect(a.airtimeMs, closeTo(558, 10));
  });

  test('tap jump: 1.60 tiles high, airtime ~350 ms — still a real jump', () {
    final a = measure(tap: true);
    expect(a.heightTiles, closeTo(1.60, 0.05));
    expect(a.airtimeMs, closeTo(350, 10));
    // A tap must always clear one tile with margin (dropped-input guard).
    expect(a.heightTiles, greaterThan(1.25));
  });

  test('full jump at run speed: ~4.12 tiles of horizontal range', () {
    final a = measure(tap: false, run: true);
    expect(a.rangeTiles, closeTo(4.12, 0.08));
  });

  test('double jump at run speed: ~6.33 tiles of horizontal range', () {
    // This is the REAL "double-jump budget": the world content tests cap
    // level gaps at maxGapTiles = 6, which must stay below this measured
    // range. Nothing else in the suite measures double-jump reach.
    final a = measure(tap: false, air: true, run: true);
    expect(a.rangeTiles, closeTo(6.33, 0.10));
    expect(a.rangeTiles, greaterThan(6.0),
        reason: 'must cover the 6-tile gap budget in world*_levels_test');
  });

  test('double jump total rise: ~4.20 tiles', () {
    final a = measure(tap: false, air: true);
    expect(a.heightTiles, closeTo(4.20, 0.08));
  });

  test('ledge forgiveness: a 2 px miss lands on the lip', () {
    // Ledge top at row 5 (y=80), left lip at col 20 (x=320). Drop a player
    // whose right edge ends 2 px short of the lip: without forgiveness the
    // player scrapes past; with kLedgeLandNudge they are slid on and land.
    final l = LevelData.parse('''
.P..................................................................
....................................................................
....................................................................
....................................................................
....................................................................
....................##############..................................
....................................................................
...................................................................E
####################################################################
''');
    final c = PlayerCore(
      x: 320 - 12 - 2, // body w 12: right edge 2 px left of the lip
      y: 16.0,
      tileAt: l.tileAt,
    );
    final i = InputIntent();
    var t = 0.0;
    while (t < 1.5 && !c.body.onGround) {
      i.clearEdges();
      c.update(dt, i);
      t += dt;
    }
    expect(c.body.onGround, isTrue);
    expect(c.body.bottom, closeTo(80, 0.1),
        reason: 'should have landed ON the ledge top, not the floor');
  });

  test('ledge forgiveness: an 8 px miss still misses', () {
    final l = LevelData.parse('''
.P..................................................................
....................................................................
....................................................................
....................................................................
....................................................................
....................##############..................................
....................................................................
...................................................................E
####################################################################
''');
    final c = PlayerCore(
      x: 320 - 12 - 8,
      y: 16.0,
      tileAt: l.tileAt,
    );
    final i = InputIntent();
    var t = 0.0;
    while (t < 2.0 && !c.body.onGround) {
      i.clearEdges();
      c.update(dt, i);
      t += dt;
    }
    expect(c.body.onGround, isTrue);
    expect(c.body.bottom, closeTo(128, 0.1),
        reason: 'a real miss must still fall to the floor');
  });

  test('level-margin invariants: reach must not cross level-design lines', () {
    // From the 2026-09-01 gap audit (docs/JUMP-PHYSICS.md section 5): the
    // widest required flat/ascending gap in all 12 levels is < 4 tiles, and
    // 3-tile ledges must stay unmountable from the ground (secret gating).
    final ground = measure(tap: false, run: true);
    expect(ground.rangeTiles, lessThan(4.5),
        reason: 'range creep would trivialise gap set-pieces');
    final single = measure(tap: false);
    expect(single.heightTiles, lessThan(2.9),
        reason: '3-tile ledges must stay out of single-jump reach');
    final dbl = measure(tap: false, air: true);
    expect(dbl.heightTiles, lessThan(4.9),
        reason: '5-tile walls must stay out of double-jump reach');
  });
}
