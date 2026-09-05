// hud_layout_test.dart — AKP-5 acceptance: AK-style control layout.
//
// Verifies the plan's DoD (docs/ak-parity-plan.md §5) against the REAL
// mounted HUD, not constants: every touch target >= 44 view px (~51dp on a
// 411dp phone at the 352x198 view — STRONGER than the 48dp guideline; the
// header used to cite the pre-2026-07-25 384x216 view), no two buttons
// overlap, the new dash and
// down buttons actually drive their verbs through the full tap-routing
// pipeline, and the spawn-fade keeps the movement cluster translucent for
// the first second.
import 'dart:io' show File;
import 'dart:ui' as ui;
import 'dart:ui' show Rect;

import 'package:flame/components.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:flutter_test/flutter_test.dart';

import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/components/hud.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/game/player/player_core.dart' show PlayerState;
import 'package:pyregrove/ui/app_state.dart';

Future<EmberGame> bootGame({
  double? hudScale,
  bool? mirrored,
  double? lift,
}) async {
  AppState.diskWrites = false;
  AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
  final game = EmberGame(
    levelId: 'w1_l1',
    seedOverride: 42,
    hudScaleOverride: hudScale,
    hudMirroredOverride: mirrored,
    hudLiftOverride: lift,
  );
  game.onGameResize(Vector2(800, 450));
  await game.onLoad();
  game.mount();
  await game.ready();
  game.update(0);
  return game;
}

List<HudHoldButton> buttons(EmberGame game) =>
    game.camera.viewport.children.whereType<HudHoldButton>().toList();

HudHoldButton byPath(EmberGame game, String spritePath) =>
    buttons(game).firstWhere((b) => b.spritePath == spritePath);

HudHoldButton byIcon(EmberGame game, String iconPath) =>
    buttons(game).firstWhere((b) => b.iconPath == iconPath);

Rect rectOf(HudHoldButton b) =>
    Rect.fromLTWH(b.position.x, b.position.y, b.size.x, b.size.y);

Offset canvasPoint(double vx, double vy) =>
    Offset(vx * 800 / EmberGame.viewWidth, vy * 800 / EmberGame.viewWidth);

Offset centreOf(HudHoldButton b) =>
    canvasPoint(b.position.x + b.size.x / 2, b.position.y + b.size.y / 2);

TapDownDetails tapDown(Offset global) =>
    TapDownDetails(globalPosition: global, localPosition: global);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every touch target is >= 44 logical px and inside the view', () async {
    final game = await bootGame();
    final all = buttons(game);
    expect(
      all.length,
      9,
      reason: 'left, right, down, dash, sword, jump, apple, spell, pause',
    );
    for (final b in all) {
      expect(
        b.size.x,
        greaterThanOrEqualTo(44),
        reason: '${b.spritePath}/${b.iconPath} narrower than 44px',
      );
      expect(b.size.y, greaterThanOrEqualTo(44));
      final r = rectOf(b);
      expect(r.left, greaterThanOrEqualTo(0));
      expect(r.top, greaterThanOrEqualTo(0));
      expect(r.right, lessThanOrEqualTo(EmberGame.viewWidth));
      expect(r.bottom, lessThanOrEqualTo(EmberGame.viewHeight));
    }
  });

  test('control size Large/Small: every button scales, none overlap or leave '
      'the view, pause stays fixed', () async {
    final normal = await bootGame();
    for (final scale in [0.85, 1.2]) {
      final game = await bootGame(hudScale: scale);
      expect(game.hudScale, scale);
      final all = buttons(game);
      for (var i = 0; i < all.length; i++) {
        final r = rectOf(all[i]);
        expect(r.right, lessThanOrEqualTo(EmberGame.viewWidth));
        expect(r.bottom, lessThanOrEqualTo(EmberGame.viewHeight));
        expect(r.left, greaterThanOrEqualTo(0));
        for (var j = i + 1; j < all.length; j++) {
          expect(
            r.overlaps(rectOf(all[j])),
            isFalse,
            reason:
                'scale $scale: ${all[i].spritePath} overlaps '
                '${all[j].spritePath}',
          );
        }
      }
      final jump = byIcon(game, 'hud/icon_jump.png');
      expect(jump.size.x, closeTo(EmberGame.hudJumpBtnBase * scale, 1e-3));
      expect(
        byPath(game, 'hud/icon_pause.png').size.x,
        byPath(normal, 'hud/icon_pause.png').size.x,
        reason: 'pause never scales',
      );
    }
  });

  test('control height Raised/High: both clusters rise by the lift, pause and '
      'readout stay, nothing overlaps or leaves the view', () async {
    final flush = await bootGame();
    for (final lift in [14.0, 28.0]) {
      final game = await bootGame(lift: lift);
      expect(game.hudLift, lift);
      final all = buttons(game);
      for (final b in all) {
        final isPause = b.spritePath == 'hud/icon_pause.png';
        final ref = buttons(flush).firstWhere(
          (f) =>
              f.runtimeType == b.runtimeType &&
              f.spritePath == b.spritePath &&
              f.iconPath == b.iconPath,
        );
        expect(b.position.x, ref.position.x, reason: 'lift is vertical only');
        expect(
          ref.position.y - b.position.y,
          closeTo(isPause ? 0 : lift, 1e-6),
          reason: '${b.spritePath}/${b.iconPath} at lift $lift',
        );
      }
      for (var i = 0; i < all.length; i++) {
        final r = rectOf(all[i]);
        expect(r.top, greaterThanOrEqualTo(0));
        expect(r.bottom, lessThanOrEqualTo(EmberGame.viewHeight));
        for (var j = i + 1; j < all.length; j++) {
          expect(rectOf(all[j]).overlaps(r), isFalse);
        }
      }
    }
  });

  test('control height is clamped inside the top pad at Large size', () async {
    // At scale 1.2 the spell button already sits 10 px from the top: the
    // requested 28 px cannot all be honoured. The clamp must keep the spell
    // inside the top pad and never push anything off the view.
    final game = await bootGame(hudScale: 1.2, lift: 28.0);
    final spell = byIcon(game, 'hud/icon_spell.png');
    expect(
      spell.position.y,
      greaterThanOrEqualTo(EmberGame.hudPad),
      reason: 'spell must not rise past the top pad',
    );
    final flush = await bootGame(hudScale: 1.2);
    final flushSpell = byIcon(flush, 'hud/icon_spell.png');
    final applied = flushSpell.position.y - spell.position.y;
    expect(applied, greaterThan(0), reason: 'some lift is still applied');
    expect(applied, lessThan(28.0), reason: 'but less than requested');
  });

  test('no two HUD buttons overlap', () async {
    final game = await bootGame();
    final all = buttons(game);
    for (var i = 0; i < all.length; i++) {
      for (var j = i + 1; j < all.length; j++) {
        final a = rectOf(all[i]), b = rectOf(all[j]);
        expect(
          a.overlaps(b),
          isFalse,
          reason:
              '${all[i].spritePath}/${all[i].iconPath} overlaps '
              '${all[j].spritePath}/${all[j].iconPath}',
        );
      }
    }
  });

  test('diamond reads AK-style: jump biggest, bottom-right corner', () async {
    final game = await bootGame();
    final jump = byIcon(game, 'hud/icon_jump.png');
    final sword = byIcon(game, 'hud/icon_sword.png');
    final dash = byIcon(game, 'hud/icon_dash.png');
    for (final other in buttons(game)) {
      if (identical(other, jump)) continue;
      expect(
        jump.size.x,
        greaterThanOrEqualTo(other.size.x),
        reason: 'jump must be the biggest button',
      );
    }
    // Jump anchors the corner; sword sits left of it, dash above the sword.
    expect(rectOf(jump).right, EmberGame.viewWidth - 8);
    expect(rectOf(sword).right, lessThanOrEqualTo(rectOf(jump).left));
    expect(rectOf(dash).bottom, lessThanOrEqualTo(rectOf(sword).top));
  });

  test('dash button press rolls the player (full routing pipeline)', () async {
    final game = await bootGame();
    // Land + settle first so the player is grounded.
    for (var i = 0; i < 30; i++) {
      game.update(1 / 60);
    }
    game.session.player.takeEvents();
    final dash = byIcon(game, 'hud/icon_dash.png');
    game.handleTapDown(9, tapDown(centreOf(dash)));
    game.update(1 / 60);
    game.update(1 / 60);
    // NOTE: EmberGame.update drains PlayerEvents for sfx/fx every frame,
    // so assert on the state machine, not takeEvents().
    expect(
      game.session.player.state,
      PlayerState.roll,
      reason: 'dash button must start the commit-dodge',
    );
  });

  test(
    'down button holds touchDown (peek/drop-through verb, AKP-2c)',
    () async {
      final game = await bootGame();
      final down = byPath(game, 'hud/btn_down.png');
      game.handleTapDown(11, tapDown(centreOf(down)));
      expect(
        game.touchDown,
        isTrue,
        reason: 'down chevron must finally wire touchDown',
      );
      game.handleTapUp(
        11,
        TapUpDetails(
          kind: PointerDeviceKind.touch,
          globalPosition: centreOf(down),
          localPosition: centreOf(down),
        ),
      );
      expect(game.touchDown, isFalse);
    },
  );

  test('movement cluster fades for the first second after spawn', () async {
    final game = await bootGame();
    final left = byPath(game, 'hud/btn_left.png');
    final jump = byIcon(game, 'hud/icon_jump.png');
    game.update(1 / 60);
    final fadedAlpha = left.paint.color.a;
    expect(
      fadedAlpha,
      lessThan(0.3),
      reason: 'arrows must fade while the player spawns behind them',
    );
    expect(
      jump.paint.color.a,
      greaterThan(0.5),
      reason: 'non-movement buttons do not spawn-fade',
    );
    // After the fade window the idle opacity (~0.55, AKP-5c) is restored —
    // eased back over ~0.3 s (alpha.23 ghost rule), so allow 1.5 s here.
    for (var i = 0; i < 90; i++) {
      game.update(1 / 60);
    }
    expect(left.paint.color.a, closeTo(0.55, 0.02));
  });

  // -- alignment + safe-area pass (owner-reported, 2026-07-25) --------------

  test('dash and apple are centered on their diamond columns', () async {
    final game = await bootGame();
    final jump = byIcon(game, 'hud/icon_jump.png');
    final sword = byIcon(game, 'hud/icon_sword.png');
    final dash = byIcon(game, 'hud/icon_dash.png');
    final apple = buttons(game).whereType<HudThrowButton>().single;
    expect(
      rectOf(dash).center.dx,
      closeTo(rectOf(sword).center.dx, 0.01),
      reason: 'dash must sit centered above the sword column',
    );
    expect(
      rectOf(apple).center.dx,
      closeTo(rectOf(jump).center.dx, 0.01),
      reason: 'apple must sit centered above the jump column',
    );
  });

  test('safe-area insets keep every control inside the safe region', () async {
    final game = await bootGame();
    // Landscape phone: display cutout on the left, gesture bar bottom,
    // small cutout spill on the right — screen logical px.
    game.setSafeArea(const EdgeInsets.fromLTRB(59, 0, 24, 34));
    final ins = game.hudSafeInsets;
    // 800x450 canvas over a 352x198 view = uniform x2.2727, no letterbox:
    // the full inset must survive the conversion.
    expect(ins.left, closeTo(59 / (800 / 352), 0.01));
    expect(ins.bottom, closeTo(34 / (800 / 352), 0.01));
    for (final b in buttons(game)) {
      final r = rectOf(b);
      expect(
        r.left,
        greaterThanOrEqualTo(ins.left),
        reason: '${b.spritePath}/${b.iconPath} under the left cutout',
      );
      expect(
        r.right,
        lessThanOrEqualTo(EmberGame.viewWidth - ins.right),
        reason: '${b.spritePath}/${b.iconPath} under the right inset',
      );
      expect(r.top, greaterThanOrEqualTo(ins.top));
      expect(
        r.bottom,
        lessThanOrEqualTo(EmberGame.viewHeight - ins.bottom),
        reason: '${b.spritePath}/${b.iconPath} under the nav bar',
      );
    }
    // And clearing the insets restores the flush layout.
    game.setSafeArea(EdgeInsets.zero);
    final jump = byIcon(game, 'hud/icon_jump.png');
    expect(rectOf(jump).right, EmberGame.viewWidth - 8);
  });

  test('swap control sides: exact mirror image, LEFT stays left of RIGHT, '
      'pause and readout fixed, no overlaps', () async {
    final normal = await bootGame();
    final mirror = await bootGame(mirrored: true);
    expect(mirror.hudMirrored, isTrue);
    // Cluster buttons: mirrored rect == reflection of the normal rect.
    const cluster = <String>[
      'hud/icon_dash.png',
      'hud/icon_sword.png',
      'hud/icon_jump.png',
    ];
    for (final icon in cluster) {
      final n = rectOf(byIcon(normal, icon)), m = rectOf(byIcon(mirror, icon));
      expect(
        m.left,
        closeTo(EmberGame.viewWidth - n.right, 1e-3),
        reason: '$icon is not the mirror image',
      );
      expect(m.top, n.top);
      expect(m.width, n.width);
    }
    final down = byPath(mirror, 'hud/btn_down.png');
    expect(
      rectOf(down).left,
      closeTo(
        EmberGame.viewWidth - rectOf(byPath(normal, 'hud/btn_down.png')).right,
        1e-3,
      ),
    );
    // Move-pad now bottom-right, diamond bottom-left...
    final l = rectOf(byPath(mirror, 'hud/btn_left.png'));
    final r = rectOf(byPath(mirror, 'hud/btn_right.png'));
    final jump = rectOf(byIcon(mirror, 'hud/icon_jump.png'));
    expect(jump.left, 8, reason: 'jump hugs the left edge when mirrored');
    expect(l.left, greaterThan(EmberGame.viewWidth / 2));
    // ...but the arrows keep their reading order.
    expect(
      l.right,
      lessThanOrEqualTo(r.left),
      reason: 'LEFT arrow must stay left of RIGHT arrow',
    );
    expect(
      r.right,
      EmberGame.viewWidth - 8,
      reason: 'RIGHT arrow hugs the right edge when mirrored',
    );
    // Pause and readout never move.
    expect(
      rectOf(byPath(mirror, 'hud/icon_pause.png')),
      rectOf(byPath(normal, 'hud/icon_pause.png')),
    );
    // No overlaps, everything inside the view.
    final all = buttons(mirror);
    for (var i = 0; i < all.length; i++) {
      final a = rectOf(all[i]);
      expect(a.left, greaterThanOrEqualTo(0));
      expect(a.right, lessThanOrEqualTo(EmberGame.viewWidth));
      for (var j = i + 1; j < all.length; j++) {
        expect(
          a.overlaps(rectOf(all[j])),
          isFalse,
          reason:
              'mirrored: ${all[i].spritePath}/${all[i].iconPath} '
              'overlaps ${all[j].spritePath}/${all[j].iconPath}',
        );
      }
    }
  });

  test('any button ghosts while the player is behind it, recovers after, '
      'never while pressed', () async {
    final game = await bootGame();
    // Past the spawn-fade window.
    for (var i = 0; i < 70; i++) {
      game.update(1 / 60);
    }
    final jump = byIcon(game, 'hud/icon_jump.png');
    final idle = jump.paint.color.a;
    expect(idle, greaterThan(0.5));
    // Park the player's body exactly under the jump button by placing it at
    // the button's screen rect relative to the current camera.
    final cam = game.camera.viewfinder.position;
    final r = rectOf(jump);
    final body = game.session.player.body;
    body.x = r.center.dx - body.w / 2 + cam.x - EmberGame.viewWidth / 2;
    body.y = r.center.dy - body.h / 2 + cam.y - EmberGame.viewHeight / 2;
    expect(game.playerScreenRect().overlaps(r), isTrue);
    jump.update(1 / 60);
    expect(
      jump.paint.color.a,
      lessThan(0.3),
      reason: 'button must ghost the frame the player is behind it',
    );
    // Move the player away: alpha EASES back (not a snap) and reaches idle
    // within ~0.5 s.
    body.x -= 200;
    jump.update(1 / 60);
    final firstBack = jump.paint.color.a;
    expect(firstBack, greaterThan(0.26));
    expect(
      firstBack,
      lessThan(idle - 0.1),
      reason: 'recovery is eased, not a one-frame snap',
    );
    for (var i = 0; i < 30; i++) {
      jump.update(1 / 60);
    }
    expect(jump.paint.color.a, closeTo(idle, 0.01));
    // A pressed button stays solid even with the player behind it.
    body.x += 200;
    game.handleTapDown(21, tapDown(centreOf(jump)));
    jump.update(1 / 60);
    expect(jump.paint.color.a, greaterThan(0.9));
    game.handleTapUp(
      21,
      TapUpDetails(
        kind: PointerDeviceKind.touch,
        globalPosition: centreOf(jump),
        localPosition: centreOf(jump),
      ),
    );
    jump.update(1 / 60);
    expect(
      jump.paint.color.a,
      lessThan(0.3),
      reason: 'released with the player still behind it -> ghost again',
    );
  });

  test('coversRect: pad grows the target, edge-touch does not count', () {
    const btn = Rect.fromLTWH(100, 100, 50, 50);
    expect(coversRect(btn, const Rect.fromLTWH(120, 120, 10, 10)), isTrue);
    expect(coversRect(btn, const Rect.fromLTWH(150, 100, 10, 10)), isFalse);
    expect(
      coversRect(btn, const Rect.fromLTWH(154, 100, 10, 10), pad: 6),
      isTrue,
    );
    expect(
      coversRect(btn, const Rect.fromLTWH(156, 100, 10, 10), pad: 6),
      isFalse,
    );
  });

  test(
    'swap control sides: the spawn-fade follows the left-edge cluster',
    () async {
      final game = await bootGame(mirrored: true);
      game.update(1 / 60);
      expect(
        byIcon(game, 'hud/icon_jump.png').paint.color.a,
        lessThan(0.3),
        reason: 'mirrored: the diamond now covers the spawn, so it fades',
      );
      expect(
        byPath(game, 'hud/btn_left.png').paint.color.a,
        greaterThan(0.5),
        reason: 'mirrored: arrows sit on the right, no fade needed',
      );
    },
  );

  test('swap control sides respects an asymmetric safe area', () async {
    final game = await bootGame(mirrored: true);
    // Cutout left (59px), spill right (24px), nav bar bottom: the diamond now
    // lives under the cutout and must clear it; the arrows must clear the
    // right spill.
    game.setSafeArea(const EdgeInsets.fromLTRB(59, 0, 24, 34));
    final ins = game.hudSafeInsets;
    for (final b in buttons(game)) {
      final r = rectOf(b);
      expect(
        r.left,
        greaterThanOrEqualTo(ins.left - 1e-3),
        reason: '${b.spritePath}/${b.iconPath} under the left cutout',
      );
      expect(
        r.right,
        lessThanOrEqualTo(EmberGame.viewWidth - ins.right + 1e-3),
        reason: '${b.spritePath}/${b.iconPath} under the right inset',
      );
      expect(
        r.bottom,
        lessThanOrEqualTo(EmberGame.viewHeight - ins.bottom + 1e-3),
      );
    }
    final jump = rectOf(byIcon(game, 'hud/icon_jump.png'));
    expect(
      jump.left,
      closeTo(ins.left + 8, 1e-3),
      reason: 'mirrored jump is flush with the cutout edge',
    );
  });

  test('letterbox bands absorb safe insets before the HUD moves', () async {
    final game = await bootGame();
    // 900x450 canvas: scale stays 450/198 -> 800px of world width, 50px
    // black band each side. A 50px cutout lives entirely in the band.
    game.onGameResize(Vector2(900, 450));
    game.setSafeArea(const EdgeInsets.only(left: 50));
    expect(game.hudSafeInsets.left, closeTo(0, 1e-9));
    // Only the part of the inset that crosses the band costs HUD space.
    game.setSafeArea(const EdgeInsets.only(left: 73));
    expect(game.hudSafeInsets.left, closeTo(23 / (450 / 198), 0.01));
  });

  test(
    'button icons are optically centered in their art (drift guard)',
    () async {
      // The dash icon shipped 6px left of center once (owner-reported);
      // decode every glyph icon and assert its opaque bbox is centered.
      for (final name in ['icon_dash', 'icon_jump', 'icon_sword']) {
        final bytes = File('assets/images/hud/$name.png').readAsBytesSync();
        final codec = await ui.instantiateImageCodec(bytes);
        final img = (await codec.getNextFrame()).image;
        final data = (await img.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        int minX = img.width, maxX = -1, minY = img.height, maxY = -1;
        for (var y = 0; y < img.height; y++) {
          for (var x = 0; x < img.width; x++) {
            final a = data.getUint8((y * img.width + x) * 4 + 3);
            if (a > 20) {
              if (x < minX) minX = x;
              if (x > maxX) maxX = x;
              if (y < minY) minY = y;
              if (y > maxY) maxY = y;
            }
          }
        }
        final cx = (minX + maxX + 1) / 2, cy = (minY + maxY + 1) / 2;
        expect(
          cx,
          closeTo(img.width / 2, 1.5),
          reason: '$name glyph is horizontally off-center',
        );
        expect(
          cy,
          closeTo(img.height / 2, 1.5),
          reason: '$name glyph is vertically off-center',
        );
      }
    },
  );

  test('HUD text carries a full ink outline '
      '(readable over World 1 sunburst sky)', () {
    // 2026-08-31 look pass: counters/timer/lore were ivory-on-pale-sky with
    // no outline — unreadable on every World 1 shot. Pin the pixel outline:
    // four cardinal 1px shadows, fully opaque ink, zero blur (crisp at 8px).
    final shadows = HudReadout.hudTextStyle.shadows;
    expect(
      shadows,
      isNotNull,
      reason: 'HUD text has no outline shadows at all',
    );
    final offsets = shadows!.map((s) => s.offset).toSet();
    for (final o in const [
      ui.Offset(1, 0),
      ui.Offset(-1, 0),
      ui.Offset(0, 1),
      ui.Offset(0, -1),
    ]) {
      expect(offsets, contains(o), reason: 'missing outline shadow on side $o');
    }
    for (final s in shadows) {
      expect(
        s.color.a,
        1.0,
        reason: 'outline must be fully opaque to guarantee contrast',
      );
      expect(s.blurRadius, 0.0, reason: 'blur would smear an 8px pixel font');
      // Ink must be dark enough to contrast with the ivory glyph fill.
      expect(
        s.color.computeLuminance() < 0.05,
        isTrue,
        reason: 'outline ink is not dark',
      );
    }
  });
}
