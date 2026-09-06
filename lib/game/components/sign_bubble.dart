// components/sign_bubble.dart — the active tutorial-sign bubble.
//
// Lives in its own layer above enemies (2), the player (3) and fx (4/5):
// while it was drawn by ItemsComponent (priority 1) an Ashbat weaving over
// the w1_l2 sign covered the last word of the very text explaining it.
// Text layout runs only when the active sign changes.
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show TextPainter, TextStyle;

import '../ember_game.dart';

class SignBubbleComponent extends PositionComponent
    with HasGameReference<EmberGame> {
  SignBubbleComponent() : super(priority: kPriority);

  /// Above damage numbers (5), below coin flights (9) and the HUD (10).
  static const int kPriority = 6;

  /// Max text width: camera view minus bubble chrome (2px screen margin and
  /// 3px horizontal padding per side).
  static const double kBubbleMaxWidth = EmberGame.viewWidth - 10;

  static final _bubbleText = TextPaint(
    style: const TextStyle(
      fontSize: 6,
      color: ui.Color(0xFF2B2B3A),
      fontFamily: 'Inter',
    ),
  );
  final _bubblePaint = ui.Paint()..color = const ui.Color(0xEEF4EAD5);

  String _bubbleFor = '';
  TextPainter? _bubbleTp;

  /// Layout box of the bubble last drawn (world space), for tests.
  ui.Rect? lastRect;

  @override
  void render(ui.Canvas canvas) {
    final active = game.session.activeSign;
    if (active == null || active.text.isEmpty) {
      lastRect = null;
      return;
    }
    if (!identical(active.text, _bubbleFor)) {
      _bubbleFor = active.text;
      // Wrap to the camera view. Root cause of the old w2_boss clip: the
      // painter laid out on one unbounded line, so any text wider than the
      // 352px view clipped regardless of the edge clamp below (the clamp can
      // only save bubbles NARROWER than the view).
      _bubbleTp = _bubbleText.toTextPainter(active.text)
        ..layout(maxWidth: kBubbleMaxWidth);
    }
    final tp = _bubbleTp!;
    final w = tp.width + 6, h = tp.height + 4;
    // Clamp the bubble inside the camera view: world-space centering used to
    // clip long sign text at the screen edge whenever the look-ahead camera
    // pushed the sign off-centre.
    final cam = game.cameraPos;
    final minLeft = cam.x - EmberGame.viewWidth / 2 + 2;
    final maxLeft = cam.x + EmberGame.viewWidth / 2 - w - 2;
    var left = active.x - w / 2;
    if (left > maxLeft) left = maxLeft;
    if (left < minLeft) left = minLeft;
    var top = active.y - 34 - h;
    final minTop = cam.y - EmberGame.viewHeight / 2 + 2;
    if (top < minTop) top = minTop;
    final rect = ui.Rect.fromLTWH(left, top, w, h);
    lastRect = rect;
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(rect, const ui.Radius.circular(2)),
      _bubblePaint,
    );
    tp.paint(canvas, ui.Offset(left + 3, top + 2));
  }
}
