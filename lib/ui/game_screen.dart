// ui/game_screen.dart — GameWidget route hosting EmberGame with Flutter
// overlays for pause / results / fail. Meta stays plain Flutter (spec seam).
import 'dart:async' show Timer;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../audio/audio_service.dart';
import '../game/ember_game.dart';
import '../game/session.dart';
import '../meta/progress_state.dart';
import 'app_state.dart';
import '../telemetry/telemetry_service.dart';

/// What the system back gesture should do given the current overlay state.
/// Pure so the routing truth table is unit-testable without pumping a
/// GameWidget (M2c escape hatch: GameWidget frame loops are flaky headless).
enum BackIntent { pauseMenu, resume, leave }

BackIntent resolveBackIntent({
  required bool loaded,
  required bool endOverlayShown,
  required bool pauseShown,
}) {
  if (!loaded || endOverlayShown) return BackIntent.leave;
  if (pauseShown) return BackIntent.resume;
  return BackIntent.pauseMenu;
}

class GameScreen extends StatefulWidget {
  final String levelId;
  final int? seed; // Daily Delve passes the deterministic daily seed
  final bool daily;
  const GameScreen({
    super.key,
    required this.levelId,
    this.seed,
    this.daily = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final EmberGame _game;
  bool _endLogged = false;

  @override
  void initState() {
    super.initState();
    _game = EmberGame(
      levelId: widget.levelId,
      seedOverride: widget.seed,
      daily: widget.daily,
    );
    TelemetryService.instance.logEvent('level_started', {
      'level_id': widget.levelId,
      'daily': widget.daily ? 1 : 0,
    });
  }

  /// Log the level outcome exactly once per GameScreen (overlay builders may
  /// rebuild; dispose covers mid-level quits). Schema: telemetry-events.md.
  void _logEndOnce(String outcome) {
    if (_endLogged) return;
    _endLogged = true;
    final r = _game.session.results;
    TelemetryService.instance.logEvent('level_ended', {
      'level_id': widget.levelId,
      'daily': widget.daily ? 1 : 0,
      'outcome': outcome,
      if (r != null && outcome == 'won') ...{
        'time_s': r.timeMs ~/ 1000,
        'coins': r.coinsEarned,
        'medals':
            (r.finished ? 1 : 0) +
            (r.allChests ? 1 : 0) +
            (r.lowDamage ? 1 : 0),
      },
    });
  }

  @override
  void dispose() {
    _logEndOnce('quit'); // no-op if a won/failed outcome was already logged
    AudioService.instance?.playMusic('title_menu');
    super.dispose();
  }

  void _replay() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          levelId: widget.levelId,
          seed: widget.seed,
          daily: widget.daily,
        ),
      ),
    );
  }

  void _leave() => Navigator.of(context).pop();

  /// Next campaign level, if the results screen should offer one. Daily runs
  /// never chain (they are a remix, not campaign progress).
  String? get _nextId => (widget.daily || !AppState.isReady)
      ? null
      : nextLevelId(AppState.save, widget.levelId);

  void _next(String id) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => GameScreen(levelId: id)),
    );
  }

  /// System back (gesture or button) during gameplay. With edge-swipe
  /// navigation the back gesture starts one slip away from the movement
  /// buttons — before this handler existed a stray swipe popped the route
  /// and dumped a live run straight back to the menu. Back now closes the
  /// topmost thing instead: playing → pause menu, paused → resume,
  /// results/fail → leave (those runs are already over).
  void _onBackGesture() {
    switch (resolveBackIntent(
      loaded: _game.sessionReady,
      endOverlayShown:
          _game.overlays.isActive(EmberGame.overlayResults) ||
          _game.overlays.isActive(EmberGame.overlayFail),
      pauseShown: _game.overlays.isActive(EmberGame.overlayPause),
    )) {
      case BackIntent.leave:
        _leave();
      case BackIntent.resume:
        _game.resumeGame();
      case BackIntent.pauseMenu:
        _game.pauseGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safe-area pass (2026-07-25): the game canvas stays edge-to-edge (no
    // letterboxing the world), but the touch HUD inside EmberGame is inset
    // so no control sits under a display cutout or the gesture/3-button nav
    // bar. viewPadding (not padding) so hidden-but-reappearing system bars
    // in immersive modes are still respected.
    final mq = MediaQuery.of(context);
    _game.setSafeArea(
      EdgeInsets.fromLTRB(
        mq.viewPadding.left,
        mq.viewPadding.top,
        mq.viewPadding.right,
        mq.viewPadding.bottom,
      ),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBackGesture();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GameWidget<EmberGame>(
          game: _game,
          overlayBuilderMap: {
            EmberGame.overlayPause: (context, game) => PauseOverlay(
              onResume: game.resumeGame,
              onRestart: _replay,
              onLeave: _leave,
            ),
            EmberGame.overlayResults: (context, game) {
              _logEndOnce('won');
              final next = _nextId;
              return ResultsOverlay(
                results: game.session.results!,
                unlocks: game.unlockNotice,
                onReplay: _replay,
                onContinue: _leave,
                onNext: next == null ? null : () => _next(next),
              );
            },
            EmberGame.overlayFail: (context, game) {
              _logEndOnce('failed');
              return FailOverlay(onRetry: _replay, onLeave: _leave);
            },
          },
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final List<Widget> children;
  const _Panel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xF0141420),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3A52)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onLeave;

  /// alpha.23: restart the level from the pause menu (every comparable has
  /// it; before this the only way to restart a bad run was Leave → card).
  /// Optional so old call sites / the harness keep working.
  final VoidCallback? onRestart;
  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onLeave,
    this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      children: [
        const Text(
          'PAUSED',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 24,
            letterSpacing: 4,
            color: Color(0xFFE8A33D),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF3E8948),
          ),
          onPressed: onResume,
          child: const Text('Resume'),
        ),
        const SizedBox(height: 8),
        if (onRestart != null)
          TextButton(onPressed: onRestart, child: const Text('Restart level')),
        TextButton(onPressed: onLeave, child: const Text('Leave level')),
      ],
    );
  }
}

class FailOverlay extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onLeave;
  const FailOverlay({super.key, required this.onRetry, required this.onLeave});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      children: [
        const Text(
          'FALLEN...',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 24,
            letterSpacing: 4,
            color: Color(0xFFD53C3C),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF3E8948),
          ),
          onPressed: onRetry,
          child: const Text('Try again'),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onLeave, child: const Text('Leave')),
      ],
    );
  }
}

/// Public so the web test harness (main_webtest.dart) can mount the real
/// end-of-level screens for visual QA instead of placeholder banners.
class ResultsOverlay extends StatefulWidget {
  final LevelResults results;
  final VoidCallback onReplay;
  final VoidCallback onContinue;

  /// When non-null a "Next level" primary button is shown and Continue
  /// demotes to a text button ("Levels"). Null = last level / daily / locked.
  final VoidCallback? onNext;

  /// Labels of what this clear opened (alpha.23) — shown as UNLOCKED lines
  /// after the medals reveal, so a boss kill that opens a world or a bonus
  /// level says so instead of leaving the player to find it in the list.
  final List<String> unlocks;
  const ResultsOverlay({
    super.key,
    required this.results,
    required this.onReplay,
    required this.onContinue,
    this.onNext,
    this.unlocks = const [],
  });

  @override
  State<ResultsOverlay> createState() => ResultsOverlayState();
}

class ResultsOverlayState extends State<ResultsOverlay> {
  // Medals reveal one by one (0.35s stagger); each earned one pops with a
  // little scale bounce + the medal chime.
  int _revealed = 0;
  Timer? _timer;

  LevelResults get results => widget.results;

  @override
  void initState() {
    super.initState();
    final earned = [results.finished, results.allChests, results.lowDamage];
    _timer = Timer.periodic(const Duration(milliseconds: 350), (t) {
      if (!mounted) return;
      setState(() => _revealed++);
      if (_revealed <= 3 && earned[_revealed - 1]) {
        AudioService.instance?.playSfx('medal', volume: 0.8);
      }
      if (_revealed >= 3) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _time {
    final s = results.timeMs ~/ 1000;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Widget _medal(int index, String label, bool earned) {
    final shown = _revealed > index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedScale(
          scale: shown ? 1.0 : 1.6,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                earned ? Icons.emoji_events : Icons.emoji_events_outlined,
                size: 18,
                color: earned ? const Color(0xFFE8A33D) : Colors.white24,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: earned ? Colors.white : Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      children: [
        const Text(
          'LEVEL CLEAR!',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 22,
            letterSpacing: 3,
            color: Color(0xFFE8A33D),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Time $_time  ·  par ${results.parSeconds ~/ 60}:'
          '${(results.parSeconds % 60).toString().padLeft(2, '0')}'
          '\nCoins +${results.coinsEarned}'
          '   Chests ${results.chestsOpened}/${results.chestTotal}'
          '   Hits ${results.hitsTaken}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 12),
        _medal(0, 'Finished', results.finished),
        _medal(1, 'All chests', results.allChests),
        _medal(2, 'Low damage', results.lowDamage),
        if (widget.unlocks.isNotEmpty) ...[
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: _revealed >= 3 ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final u in widget.unlocks)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_open,
                        size: 16,
                        color: Color(0xFF8FBF3F),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'UNLOCKED  $u',
                        style: const TextStyle(
                          fontSize: 12,
                          letterSpacing: 1,
                          color: Color(0xFF8FBF3F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
        if (results.perfectBonus > 0) ...[
          const SizedBox(height: 8),
          Text(
            'PERFECT!  +${results.perfectBonus} coins',
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 14,
              letterSpacing: 2,
              color: Color(0xFFE8A33D),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(onPressed: widget.onReplay, child: const Text('Replay')),
            const SizedBox(width: 12),
            if (widget.onNext != null) ...[
              TextButton(
                onPressed: widget.onContinue,
                child: const Text('Levels'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3E8948),
                ),
                onPressed: widget.onNext,
                child: const Text('Next level'),
              ),
            ] else
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3E8948),
                ),
                onPressed: widget.onContinue,
                child: const Text('Continue'),
              ),
          ],
        ),
      ],
    );
  }
}
