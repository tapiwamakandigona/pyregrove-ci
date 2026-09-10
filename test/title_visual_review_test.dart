import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/core/save.dart';
import 'package:pyregrove/ui/app_state.dart';
import 'package:pyregrove/ui/title_screen.dart';

void main() {
  late Directory temp;
  setUpAll(() async {
    for (final pair in [
      ('Cinzel', 'assets/fonts/Cinzel-Variable.ttf'),
      ('Inter', 'assets/fonts/Inter-Regular.ttf'),
    ]) {
      await (FontLoader(pair.$1)
            ..addFont(Future.value(ByteData.sublistView(File(pair.$2).readAsBytesSync()))))
          .load();
    }
  });
  setUp(() {
    temp = Directory.systemTemp.createTempSync('title_visual_');
    AppState.init(store: SaveStore(baseDirOverride: temp), save: SaveData());
    AppState.diskWrites = false;
  });
  tearDown(() {
    AppState.diskWrites = true;
    temp.deleteSync(recursive: true);
  });

  Future<void> pumpTitle(WidgetTester tester, Size size, double scale, GlobalKey key) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF141420),
            textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Inter'),
          ),
          home: MediaQuery(
            data: MediaQueryData(size: size, textScaler: TextScaler.linear(scale)),
            child: const TitleScreen(),
          ),
        ),
      ),
    );
    // Real asset I/O must flush outside FakeAsync.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    await tester.pump(const Duration(milliseconds: 100));
  }

  for (final size in [
    const Size(320, 568),
    const Size(568, 320),
    const Size(915, 412),
    const Size(1280, 720),
  ]) {
    testWidgets('title plate $size', (tester) async {
      final key = GlobalKey();
      await pumpTitle(tester, size, size.width <= 568 ? 1.3 : 1, key);
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 1.5));
      final bytes = await tester.runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));
      final name = 'title_${size.width.toInt()}x${size.height.toInt()}';
      File('build/visual-review/$name.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!.buffer.asUint8List());
      if (Platform.environment['GITHUB_HEAD_REF'] == 'feat/visual-polish-20260905') {
        final encoded = base64Encode(bytes.buffer.asUint8List());
        for (var start = 0; start < encoded.length; start += 512) {
          final end = (start + 512).clamp(0, encoded.length);
          // ignore: avoid_print
          print('VISUAL_PNG:$name:$start:${encoded.substring(start, end)}');
        }
      }
      image!.dispose();
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets('unscaled usable title actions at $size', (tester) async {
      await pumpTitle(tester, size, 1.3, GlobalKey());
      final play = find.widgetWithText(FilledButton, 'PLAY');
      await tester.ensureVisible(play);
      await tester.pump();
      final box = tester.renderObject<RenderBox>(play);
      final visualHeight = (box.localToGlobal(Offset(0, box.size.height)) - box.localToGlobal(Offset.zero)).distance;
      expect(visualHeight, greaterThanOrEqualTo(48), reason: 'scale-to-fit must not shrink touch targets');
      expect(
        find.ancestor(of: find.text('PLAY'), matching: find.byType(FittedBox)),
        findsNothing,
        reason: 'only decorative wordmark may scale, never menu actions',
      );
      for (final label in ['SHOP', 'SETTINGS', 'CREDITS']) {
        await tester.ensureVisible(find.text(label));
        await tester.pump();
        expect(tester.getRect(find.text(label)).overlaps(Offset.zero & size), isTrue);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
