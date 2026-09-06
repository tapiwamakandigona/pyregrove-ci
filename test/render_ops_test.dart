// render_ops_test.dart — canvas draw operations per rendered frame, counted
// through a recording Canvas. This is the render-side half of the frame
// budget we CAN measure without a device (docs/perf.md): UI-thread recording
// cost scales with the number of canvas calls, and a static shape drawn
// pixel-by-pixel every frame is a defect this catches.
//
// alpha.23 #37 baseline → after: w1_l1 spawn 244 → 88 draw ops, w1_l5 409 →
// 93, w2_l5 253 → 97, w1_boss 202 → 46, w2_bonus 351 → 115 (hearts and
// heart pickups rasterised once). Bounds below are regression guards with
// headroom, not targets.
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/game/ember_game.dart';
import 'package:pyregrove/ui/app_state.dart';

/// Counts every Canvas call by name; draw* calls are the ones that cost.
class CountingCanvas implements ui.Canvas {
  final Map<String, int> counts = {};
  int _saves = 0;

  @override
  dynamic noSuchMethod(Invocation i) {
    final name = i.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');
    counts[name] = (counts[name] ?? 0) + 1;
    if (name == 'save' || name == 'saveLayer') _saves++;
    if (name == 'restore') _saves--;
    if (name == 'getSaveCount') return _saves + 1;
    if (name == 'getTransform') return Float64List(16);
    if (name == 'getLocalClipBounds' || name == 'getDestinationClipBounds') {
      return ui.Rect.largest;
    }
    return null;
  }

  int get draws => counts.entries
      .where((e) => e.key.startsWith('draw'))
      .fold(0, (a, e) => a + e.value);
  int of(String name) => counts[name] ?? 0;
}

Future<EmberGame> _boot(String id) async {
  final game = EmberGame(levelId: id, seedOverride: 42);
  game.onGameResize(Vector2(800, 450));
  await game.onLoad();
  game.mount();
  await game.ready();
  game.update(0);
  return game;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    AppState.diskWrites = false;
    AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
  });

  // (level, max draw ops at spawn, max after 300 frames running right)
  const cases = [
    ('w1_l1', 140, 140),
    ('w1_l5', 150, 150),
    ('w2_l5', 150, 150),
    ('w1_boss', 100, 110),
    ('w2_bonus', 180, 180),
  ];

  for (final (id, maxSpawn, maxRun) in cases) {
    test('$id: draw ops per frame stay bounded', () async {
      final game = await _boot(id);
      final spawn = CountingCanvas();
      game.render(spawn);
      game.touchRight = true;
      for (var i = 0; i < 300; i++) {
        game.update(1 / 60);
      }
      final run = CountingCanvas();
      game.render(run);
      // ignore: avoid_print
      print(
        '[render_ops $id] spawn=${spawn.draws} run300=${run.draws} '
        'drawRect=${spawn.of('drawRect')}/${run.of('drawRect')} '
        'drawImageRect=${spawn.of('drawImageRect')}/${run.of('drawImageRect')} '
        'drawImage=${spawn.of('drawImage')}/${run.of('drawImage')}',
      );
      expect(spawn.draws, lessThanOrEqualTo(maxSpawn));
      expect(run.draws, lessThanOrEqualTo(maxRun));
      // The heart pixels are gone: no frame may spend more than a handful of
      // drawRects (boss bar, ticks, fx) — 40 per heart was the defect.
      expect(spawn.of('drawRect'), lessThan(20));
      expect(run.of('drawRect'), lessThan(20));
    });
  }
}
