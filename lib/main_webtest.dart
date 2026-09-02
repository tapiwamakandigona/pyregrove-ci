// main_webtest.dart — web-only test harness entrypoint.
//
// The production save/settings layer (lib/core/save.dart, lib/audio/settings.dart)
// uses dart:io + path_provider, which throw at runtime on the web, so the normal
// main() can never boot in a browser. This entrypoint exists purely so automated
// browser tests (Playwright/CI) can exercise the real gameplay code:
//   * in-memory save (AppState.diskWrites = false, no file IO ever runs)
//   * a real AudioService with in-memory AudioSettings (matches shipping
//     main.dart, which always sets the instance before runApp - without it
//     the Settings screen hid the sliders + haptics/screen-shake toggles
//     behind its 'Audio unavailable' fallback and they were never QA-able).
//     playSfx/playMusic are internally try/catch'd, so headless is safe.
//   * boots straight into a level (default w1_l1, or ?level=w1_l3 in the URL)
//     with a fixed seed for deterministic runs
//   * publishes live telemetry to JS every 50ms so tests can assert on real
//     simulation state instead of pixels:
//       window.__pyregrove = { loaded, x, y, hp, coins }
//
// Build:  flutter build web --release -t lib/main_webtest.dart
// Serve:  any static file server over build/web
// NOT part of the Android app; nothing in lib/main.dart imports this file.
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'core/save.dart';
import 'game/ember_game.dart';
import 'meta/catalog.dart' show kWeapons;
import 'meta/daily.dart' show dailyKey;
import 'audio/audio_service.dart';
import 'audio/settings.dart';
import 'ui/game_screen.dart' show ResultsOverlay, FailOverlay, PauseOverlay;
import 'ui/app_state.dart';
import 'ui/credits_screen.dart';
import 'ui/level_select_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/shop_screen.dart';
import 'ui/title_screen.dart';

/// Game-level event instrumentation: counts events that reach the component
/// tree at all, so tests can tell "recognizer not attached" apart from
/// "routing to HUD children broken".
int _rawPointerDowns = 0;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // In-memory save: store is never read from or written to (diskWrites=false).
  AppState.diskWrites = false;
  AppState.init(store: SaveStore(), save: SaveData(tutorialSeen: true));
  AudioService.instance = AudioService(AudioSettings());

  final params = Uri.base.queryParameters;

  // alpha.16 (overflow sweep release): ?screen=title|select|shop|settings|
  // credits boots the REAL meta screen instead of gameplay, so release
  // look-passes can screenshot meta UI in a browser. ?coins=N / ?allclear=1
  // fake a loaded save (widest wallet / every medal row). Harness-only.
  final metaScreen = params['screen'];
  if (metaScreen != null) {
    final coins = int.tryParse(params['coins'] ?? '') ?? 0;
    AppState.save.coins = coins;
    // ?dailybest=MS fakes a daily best run recorded today, so the title
    // screen's 'best M:SS' subtitle state is screenshot-able.
    final dailyBest = int.tryParse(params['dailybest'] ?? '') ?? 0;
    if (dailyBest > 0) {
      AppState.save
        ..dailyBestDate = dailyKey(DateTime.now())
        ..dailyBestTimeMs = dailyBest;
    }
    if (params['allclear'] == '1') {
      for (final w in ['w1', 'w2']) {
        for (final l in ['l1', 'l2', 'l3', 'l4', 'l5', 'boss']) {
          AppState.save.recordFor('${w}_$l')
            ..finished = true
            ..allChests = true
            ..lowDamage = true;
        }
      }
    }
    final screen = switch (metaScreen) {
      'select' => const LevelSelectScreen() as Widget,
      'shop' => const ShopScreen(),
      'settings' => const SettingsScreen(),
      'credits' => const CreditsScreen(),
      _ => const TitleScreen(),
    };
    // Minimal loaded-marker so drivers can wait for first frame.
    Timer.periodic(const Duration(milliseconds: 50), (_) {
      final obj = JSObject();
      obj.setProperty('loaded'.toJS, true.toJS);
      obj.setProperty('screen'.toJS, metaScreen.toJS);
      globalContext.setProperty('__pyregrove'.toJS, obj);
    });
    runApp(
      MaterialApp(
        title: 'Pyregrove (web test harness)',
        debugShowCheckedModeBanner: false,
        home: screen,
      ),
    );
    return;
  }

  final levelId = params['level'] ?? 'w1_l1';
  final seed = int.tryParse(params['seed'] ?? '') ?? 42;
  // AKP-4a evidence: ?weapon=<catalog id> boots with that weapon owned +
  // equipped (harness-only; the in-memory save never persists).
  final weapon = params['weapon'];
  if (weapon != null && kWeapons.any((w) => w.id == weapon)) {
    AppState.save.ownedWeapons.add(weapon);
    AppState.save.equippedWeapon = weapon;
  }
  // AKP-4c evidence: ?apples=N pre-fills the pouch (harness-only) so the
  // held-throw arc preview can be exercised without hunting pickups.
  final apples = int.tryParse(params['apples'] ?? '') ?? 0;
  var applesApplied = false;
  // Boss-presentation evidence: ?bosshp=N clamps the boss to N hp once it
  // spawns (harness-only) so phase/death visuals can be captured without a
  // full scripted duel — the w2 arena is too roamy for the dumb capture bot.
  final bossHp = int.tryParse(params['bosshp'] ?? '') ?? -1;
  var bossHpApplied = false;
  // Scene-QA evidence: ?spawn=col,row teleports the player onto that tile once
  // the session is up (harness-only) so look-passes can screenshot any spot in
  // a level without a scripted bot surviving the whole walk to it.
  final spawnParam = params['spawn'];
  var spawnApplied = false;
  // Scene-QA evidence: ?peace=1 clears all enemies once the session is up
  // (harness-only) so sign/prop screenshots aren't ruined by knockback from
  // whatever patrols the spot being captured.
  final peace = params['peace'] == '1';
  var peaceApplied = false;

  final game = EmberGame(levelId: levelId, seedOverride: seed);

  // Telemetry bridge: browser tests poll window.__pyregrove.
  Timer.periodic(const Duration(milliseconds: 50), (_) {
    final obj = JSObject();
    var loaded = false;
    try {
      final pBoss = game.session.boss;
      if (!bossHpApplied && bossHp >= 0 && pBoss != null) {
        pBoss.hp = bossHp.clamp(0, pBoss.hp);
        bossHpApplied = true;
      }
      if (!spawnApplied && spawnParam != null) {
        final parts = spawnParam.split(',');
        final tx = int.tryParse(parts[0]);
        final ty = parts.length > 1 ? int.tryParse(parts[1]) : null;
        if (tx != null && ty != null) {
          final b = game.session.player.body;
          b.x = tx * 16.0 + (16.0 - b.w) / 2;
          b.y = (ty + 1) * 16.0 - b.h;
          b.vx = 0;
          b.vy = 0;
          game.session.respawnX = b.x;
          game.session.respawnY = b.y;
        }
        spawnApplied = true;
      }
      if (!peaceApplied && peace && game.session.enemies.isNotEmpty) {
        game.session.enemies.clear();
        peaceApplied = true;
      }
      if (!applesApplied && apples > 0) {
        game.session.applesHeld = apples;
        applesApplied = true;
      }
      final body = game.session.player.body;
      obj.setProperty('x'.toJS, body.centerX.toJS);
      obj.setProperty('y'.toJS, body.centerY.toJS);
      obj.setProperty('hearts'.toJS, game.session.player.hearts.toJS);
      obj.setProperty('coins'.toJS, game.session.coinsCollected.toJS);
      obj.setProperty('touchLeft'.toJS, game.touchLeft.toJS);
      obj.setProperty('touchRight'.toJS, game.touchRight.toJS);
      obj.setProperty('paused'.toJS, game.paused.toJS);
      // Run/outcome state: lets a driver verify a FULL level clear instead of
      // just movement (the alpha.3 harness could only watch x/y).
      final s = game.session;
      obj.setProperty('level'.toJS, game.levelId.toJS);
      obj.setProperty('levelName'.toJS, s.level.name.toJS);
      obj.setProperty('time'.toJS, s.time.toJS);
      obj.setProperty('completed'.toJS, s.completed.toJS);
      obj.setProperty('failed'.toJS, s.failed.toJS);
      obj.setProperty('over'.toJS, s.over.toJS);
      obj.setProperty('apples'.toJS, s.applesHeld.toJS);
      obj.setProperty('feathers'.toJS, s.feathersCollected.toJS);
      obj.setProperty('kills'.toJS, s.kills.toJS);
      obj.setProperty('bossHp'.toJS, (s.boss?.hp ?? -1).toJS);
      obj.setProperty('bossPhase'.toJS, (s.boss?.phase ?? 0).toJS);
      obj.setProperty('hitsTaken'.toJS, s.hitsTaken.toJS);
      obj.setProperty('secrets'.toJS, s.secretsFound.toJS);
      obj.setProperty(
        'chestsOpened'.toJS,
        s.chests.where((c) => c.opened).length.toJS,
      );
      obj.setProperty('chestTotal'.toJS, s.chests.length.toJS);
      obj.setProperty(
        'enemiesAlive'.toJS,
        s.enemies.where((e) => e.alive).length.toJS,
      );
      obj.setProperty('exitX'.toJS, s.exitX.toJS);
      obj.setProperty('exitY'.toJS, s.exitY.toJS);
      obj.setProperty('levelW'.toJS, (s.level.width * 16).toJS);
      obj.setProperty('levelH'.toJS, (s.level.height * 16).toJS);
      // Frame-time stats (1s windows) for throttled low-end profiling.
      obj.setProperty('fps'.toJS, game.frameStats.fps.toJS);
      obj.setProperty('frameAvgMs'.toJS, game.frameStats.avgMs.toJS);
      obj.setProperty('frameWorstMs'.toJS, game.frameStats.worstMs.toJS);
      loaded = true;
    } catch (_) {
      // session not initialised yet (game still loading)
    }
    obj.setProperty('loaded'.toJS, loaded.toJS);
    obj.setProperty('rawPointerDowns'.toJS, _rawPointerDowns.toJS);
    globalContext.setProperty('__pyregrove'.toJS, obj);
  });

  runApp(
    MaterialApp(
      title: 'Pyregrove (web test harness)',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (PointerDownEvent e) => _rawPointerDowns++,
          child: GameWidget(
            game: game,
            // Harness bug (found in the alpha.3 playtest): the game adds
            // 'results'/'fail'/'pause' overlays at level end. With no
            // overlayBuilderMap the widget threw "Null check operator used on a
            // null value" and the canvas went grey, so no automated run could
            // ever verify a level CLEAR. Minimal stand-ins keep the harness alive
            // (the real overlays live in ui/game_screen.dart).
            // All three in-game overlays mount the REAL widgets (public in
            // ui/game_screen.dart) with harness-appropriate callbacks, so
            // automated visual QA critiques what players actually see.
            overlayBuilderMap: {
              EmberGame.overlayResults: (_, EmberGame g) => ResultsOverlay(
                    results: g.session.results!,
                    onReplay: () {},
                    onContinue: () {},
                  ),
              EmberGame.overlayFail: (_, EmberGame g) => FailOverlay(
                    onRetry: () {},
                    onLeave: () {},
                  ),
              EmberGame.overlayPause: (_, EmberGame g) => PauseOverlay(
                    onResume: g.resumeGame,
                    onLeave: () {},
                  ),
            },
          ),
        ),
      ),
    ),
  );
}
