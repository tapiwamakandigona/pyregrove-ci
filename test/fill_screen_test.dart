// alpha.29 graphics pass: the game view fills wide phones (no black side
// bands) and the backdrop carries drifting embers / cave dust. These tests
// pin the width maths, the HUD/camera following the wider view, the classic
// framing when the setting is off, and the motes staying sane over time.
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:flutter_test/flutter_test.dart';

import 'package:pyregrove/audio/settings.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/components/ambient_motes.dart';
import 'package:pyregrove/game/components/parallax_bg.dart';
import 'package:pyregrove/game/components/hud.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/game/flex_viewport.dart';
import 'package:pyregrove/ui/app_state.dart';

Future<EmberGame> boot({
  required Vector2 canvas,
  bool? fill,
  String level = 'w1_l1',
}) async {
  AppState.diskWrites = false;
  AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
  final game = EmberGame(
    levelId: level,
    seedOverride: 42,
    fillScreenOverride: fill,
  );
  game.onGameResize(canvas);
  await game.onLoad();
  game.mount();
  await game.ready();
  game.update(0);
  return game;
}

double w(double cw, double ch, {bool fill = true}) =>
    FlexWidthViewport.widthFor(
      Vector2(cw, ch),
      height: EmberGame.viewHeight,
      minWidth: EmberGame.viewWidth,
      maxWidth: EmberGame.viewWidthMax,
      fill: fill,
    );

/// Records the point lists the motes hand to drawRawPoints; nothing else
/// may be drawn.
class _PointsCanvas extends Fake implements ui.Canvas {
  final List<Float32List> batches = [];

  @override
  void drawRawPoints(ui.PointMode mode, Float32List points, ui.Paint paint) =>
      batches.add(points);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('view width follows the phone shape between 16:9 and 21:9', () {
    expect(w(1920, 1080), closeTo(352, 1e-9)); // 16:9 = design view
    expect(w(2400, 1080), closeTo(440, 1e-9)); // 20:9 (itel S26 class)
    expect(w(2340, 1080), closeTo(429, 1e-9)); // 19.5:9
    expect(w(1024, 768), EmberGame.viewWidth); // 4:3 tablet: never narrower
    expect(w(3840, 1080), EmberGame.viewWidthMax); // 32:9: capped at 21:9
    expect(w(2400, 1080, fill: false), EmberGame.viewWidth); // classic
    expect(w(0, 0), EmberGame.viewWidth); // not laid out yet
  });

  test('settings default to fill; the flag round-trips through JSON', () {
    expect(AudioSettings().fillScreen, isTrue);
    expect(AudioSettings.fromJson(const {}).fillScreen, isTrue);
    final off = AudioSettings(fillScreen: false);
    expect(AudioSettings.fromJson(off.toJson()).fillScreen, isFalse);
  });

  test('20:9 canvas: no side bands, view is 440 wide, HUD hugs the real '
      'right edge', () async {
    final game = await boot(canvas: Vector2(2400, 1080), fill: true);
    expect(game.fillScreen, isTrue);
    expect(game.viewW, closeTo(440, 1e-9));
    final vp = game.camera.viewport;
    expect(vp.virtualSize.x, closeTo(440, 1e-9));
    expect(vp.virtualSize.y, EmberGame.viewHeight);
    // Uniform scale fills the whole canvas: no letterbox on either axis.
    expect(vp.size.x, closeTo(2400, 1e-6));
    expect(vp.size.y, closeTo(1080, 1e-6));
    // The jump button (bottom-right cluster) sits against the 440 edge, not
    // the old 352 one.
    final jump = vp.children.whereType<HudHoldButton>().firstWhere(
      (b) => b.iconPath == 'hud/icon_jump.png',
    );
    expect(jump.position.x + jump.size.x, greaterThan(400));
    expect(jump.position.x + jump.size.x, lessThanOrEqualTo(440));
    // With no bands, a side cutout costs HUD space straight away.
    game.setSafeArea(const EdgeInsets.only(left: 50));
    expect(game.hudSafeInsets.left, closeTo(50 / (1080 / 198), 0.01));
  });

  test('camera clamps to the wider view at the level start', () async {
    final game = await boot(canvas: Vector2(2400, 1080), fill: true);
    for (var i = 0; i < 90; i++) {
      game.update(1 / 60);
    }
    // Player spawns near the left wall, so the camera is clamped: its centre
    // is exactly half the (wider) view from the level's left edge.
    expect(game.cameraPos.x, closeTo(220, 1.0));
  });

  test('fill off keeps the classic 352 framing with side bands', () async {
    final game = await boot(canvas: Vector2(2400, 1080), fill: false);
    expect(game.viewW, EmberGame.viewWidth);
    final vp = game.camera.viewport;
    expect(vp.virtualSize.x, EmberGame.viewWidth);
    expect(vp.size.x, closeTo(1080 * 352 / 198, 1e-6)); // banded
  });

  test(
    'ambient motes stay on screen, finite and in bounds for a minute',
    () async {
      for (final level in ['w1_l1', 'w2_l1']) {
        final game = await boot(
          canvas: Vector2(2400, 1080),
          fill: true,
          level: level,
        );
        final motes = game.camera.backdrop.children
            .whereType<ParallaxBackground>()
            .single
            .motes;
        expect(motes.cave, level.startsWith('w2'));
        expect(
          motes.count,
          motes.cave ? AmbientMotes.caveCount : AmbientMotes.forestCount,
        );
        for (var f = 0; f < 3600; f++) {
          game.update(1 / 60);
        }
        var visible = 0;
        for (var i = 0; i < motes.count; i++) {
          final p = motes.positionOf(i, game.cameraPos.x);
          expect(p.dx.isFinite && p.dy.isFinite, isTrue);
          expect(
            p.dy,
            inInclusiveRange(
              -AmbientMotes.margin,
              EmberGame.viewHeight + AmbientMotes.margin,
            ),
          );
          if (p.dx >= 0 &&
              p.dx <= game.viewW &&
              p.dy >= 0 &&
              p.dy <= EmberGame.viewHeight) {
            visible++;
          }
        }
        // The field never drains: a healthy share is on screen after a minute.
        expect(visible, greaterThan(motes.count ~/ 4), reason: level);
      }
    },
  );

  test('ambient motes draw from point batches made up front: render() '
      'allocates no views per frame', () {
    for (final cave in [false, true]) {
      final motes = AmbientMotes(cave: cave, seed: 7);
      for (var f = 0; f < 90; f++) {
        motes.update(1 / 60);
        final a = _PointsCanvas();
        final b = _PointsCanvas();
        // Same state twice: the batches must be the very same objects, not
        // fresh views of the same buffers.
        motes.render(a, 40.0 * f, 462, 1);
        motes.render(b, 40.0 * f, 462, 1);
        expect(a.batches, isNotEmpty, reason: 'cave $cave frame $f');
        expect(b.batches.length, a.batches.length);
        for (var i = 0; i < a.batches.length; i++) {
          expect(
            identical(a.batches[i], b.batches[i]),
            isTrue,
            reason: 'cave $cave frame $f batch $i was rebuilt',
          );
          expect(a.batches[i].length, isPositive);
          expect(a.batches[i].length.isEven, isTrue);
        }
      }
    }
  });

  test('running knight holds still on screen while the camera follows '
      '(physical-pixel camera snap)', () async {
    final game = await boot(canvas: Vector2(2400, 1080), fill: true);
    final unit = game.pixelSnap; // world px per physical px
    expect(unit, lessThan(1.0));
    game.touchRight = true;
    // Let the run and the camera's exponential follow settle.
    for (var i = 0; i < 90; i++) {
      game.update(1 / 60);
    }
    double? last;
    var worst = 0.0;
    // 30 frames of steady running (w1_l1, seed 42: open ground until the
    // knight reaches the first bush near x=308 around frame 125).
    for (var i = 0; i < 30; i++) {
      final before = game.session.player.body.x;
      game.update(1 / 60);
      expect(game.session.player.body.x, greaterThan(before + 1));
      final sx = game.playerScreenRect().left / unit; // physical px
      if (last != null) worst = math.max(worst, (sx - last).abs());
      last = sx;
      // The camera itself only ever sits on the physical pixel grid.
      final cx = game.cameraPos.x / unit;
      expect((cx - cx.roundToDouble()).abs(), lessThan(1e-3));
    }
    // World-pixel snapping moved the knight by a whole world px (~5
    // physical px at this scale) on some frames; now it's at most ~1 px.
    expect(worst, lessThanOrEqualTo(1.5), reason: 'screen jitter $worst px');
  });
}
