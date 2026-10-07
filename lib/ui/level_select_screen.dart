// ui/level_select_screen.dart — the world map: per-world banners with medal
// progress, level cards with a themed thumbnail strip (forest / cave / sunny),
// gold medallions (finish / all chests / low damage) from saved results,
// wallet display, shop shortcut, and the boss node locked until w1_l1..w1_l5
// are all finished (progress_state rules).
import 'package:flutter/material.dart';

import '../audio/audio_service.dart';
import '../meta/economy.dart';
import '../meta/progress_state.dart';
import 'app_state.dart';
import 'game_screen.dart';
import 'shop_screen.dart';

const _gold = Color(0xFFE8A33D);

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  @override
  Widget build(BuildContext context) {
    final save = AppState.save;
    return Scaffold(
      backgroundColor: const Color(0xFF141420),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'DELVE',
          style: TextStyle(
            fontFamily: 'Cinzel',
            color: _gold,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront, color: _gold),
            tooltip: 'Shop',
            onPressed: () {
              AudioService.instance?.playSfx('ui_tap');
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const ShopScreen()))
                  .then((_) => setState(() {}));
            },
          ),
          WalletChip(
            wallet: Wallet(coins: save.coins, feathers: save.feathers),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg/forest_back.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.none,
            color: const Color(0xAA141420),
            colorBlendMode: BlendMode.srcATop,
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            children: [
              _worldHeader('WORLD 1 — THE PYREGROVE', world: kWorld1),
              ..._worldCards(kWorld1),
              const SizedBox(height: 16),
              _worldHeader(
                isWorld2Unlocked(save)
                    ? 'WORLD 2 — CINDER DEPTHS'
                    : 'WORLD 2 — CINDER DEPTHS  (defeat the Grove Golem)',
                world: kWorld2,
              ),
              ..._worldCards(kWorld2),
              const SizedBox(height: 16),
              _worldHeader(
                isBonusUnlocked(save)
                    ? 'BONUS — THE GROVE\'S PURSE'
                    : 'BONUS — THE GROVE\'S PURSE  (defeat the Grove Golem)',
                world: kBonusLevels,
              ),
              ..._worldCards(kBonusLevels),
            ],
          ),
        ],
      ),
    );
  }

  /// World banner: title, theme strip, and medal progress for that world.
  Widget _worldHeader(String label, {List<LevelEntry> world = const []}) {
    final save = AppState.save;
    var earned = 0;
    for (final e in world) {
      final r = save.levels[e.id];
      if (r == null) continue;
      earned +=
          (r.finished ? 1 : 0) + (r.allChests ? 1 : 0) + (r.lowDamage ? 1 : 0);
    }
    final total = world.length * 3;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 26,
            decoration: BoxDecoration(
              color: _gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              style: const TextStyle(
                fontFamily: 'Cinzel',
                color: _gold,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),
          ),
          if (total > 0) ...[
            const SizedBox(width: 8),
            _MedalCount(earned: earned, total: total),
          ],
        ],
      ),
    );
  }

  List<Widget> _worldCards(List<LevelEntry> world) {
    final save = AppState.save;
    return [
      for (var i = 0; i < world.length; i++) ...[
        Builder(
          builder: (context) {
            final entry = world[i];
            final unlocked = isLevelUnlocked(save, i, world: world);
            return _LevelCard(
              index: i + 1,
              entry: entry,
              unlocked: unlocked,
              onTap: unlocked
                  ? () {
                      AudioService.instance?.playSfx('ui_tap');
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) => GameScreen(levelId: entry.id),
                            ),
                          )
                          .then((_) => setState(() {}));
                    }
                  : null,
            );
          },
        ),
        if (i != world.length - 1) const SizedBox(height: 8),
      ],
    ];
  }
}

class _LevelCard extends StatelessWidget {
  final int index;
  final LevelEntry entry;
  final bool unlocked;
  final VoidCallback? onTap;
  const _LevelCard({
    required this.index,
    required this.entry,
    required this.unlocked,
    required this.onTap,
  });

  /// Backdrop strip per world: forest (w1), cave (w2), sunny (bonus).
  String get _thumb {
    if (entry.isBonus) return 'assets/images/bg/sunny_back.png';
    if (entry.id.startsWith('w2')) return 'assets/images/bg/cave_middle.png';
    return 'assets/images/bg/forest_middle.png';
  }

  @override
  Widget build(BuildContext context) {
    final rec = AppState.save.levels[entry.id];
    final boss = entry.isBoss;
    final medals = rec == null
        ? 0
        : (rec.finished ? 1 : 0) +
              (rec.allChests ? 1 : 0) +
              (rec.lowDamage ? 1 : 0);
    final gilded = medals == 3;
    final border = !unlocked
        ? Colors.white10
        : boss
        ? const Color(0xAAE8631A)
        : gilded
        ? const Color(0x99E8A33D)
        : Colors.white12;
    return Material(
      color: unlocked
          ? (boss ? const Color(0xEE2A1A1E) : const Color(0xEE1B1B2A))
          : const Color(0x88161622),
      borderRadius: BorderRadius.circular(12),
      elevation: unlocked ? 3 : 0,
      shadowColor: boss && unlocked ? const Color(0x66E8631A) : Colors.black54,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: boss && unlocked ? 1.5 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // Thumbnail strip with the level number over it.
              SizedBox(
                width: 84,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _thumb,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.none,
                      color: unlocked
                          ? (boss
                                ? const Color(0x55E8631A)
                                : const Color(0x33000000))
                          : const Color(0xBB0E0E16),
                      colorBlendMode: BlendMode.srcATop,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0x00000000), Color(0xCC1B1B2A)],
                        ),
                      ),
                    ),
                    Center(
                      child: unlocked
                          ? (boss
                                ? const Icon(
                                    Icons.whatshot,
                                    color: Color(0xFFFFB48A),
                                    size: 30,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  )
                                : entry.isBonus
                                ? const Icon(
                                    Icons.star,
                                    color: _gold,
                                    size: 28,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  )
                                : Text(
                                    '$index',
                                    style: const TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 30,
                                      height: 1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ))
                          : const Icon(
                              Icons.lock,
                              color: Colors.white38,
                              size: 20,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: unlocked ? Colors.white : Colors.white38,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      !unlocked
                          ? (boss
                                ? 'Finish all five levels to face the Golem'
                                : entry.isBonus
                                ? (entry.id == 'w2_bonus'
                                      ? 'Defeat the Kiln Golem to open the cellar'
                                      : 'Defeat the Grove Golem to open the hollow')
                                : 'Locked')
                          : rec == null
                          ? (boss ? 'The Golem waits' : 'Not cleared')
                          : (rec.bestTimeMs > 0
                                    ? 'Best ${_fmtMs(rec.bestTimeMs)}'
                                    : 'Cleared') +
                                (rec.hardCleared ? '  ·  Hard clear' : ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unlocked ? Colors.white54 : Colors.white30,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Three medallions: finished / all chests / low damage.
              _Medal(
                earned: rec?.finished ?? false,
                icon: Icons.flag,
                tip: 'Finished',
              ),
              _Medal(
                earned: rec?.allChests ?? false,
                icon: Icons.inventory_2,
                tip: 'All chests',
              ),
              _Medal(
                earned: rec?.lowDamage ?? false,
                icon: Icons.favorite,
                tip: 'Low damage',
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmtMs(int ms) {
    final s = ms ~/ 1000;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }
}

class _Medal extends StatelessWidget {
  final bool earned;
  final IconData icon;
  final String tip;
  const _Medal({required this.earned, required this.icon, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tip,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: earned
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF7D98A), Color(0xFFB8781E)],
                  )
                : null,
            color: earned ? null : const Color(0x22FFFFFF),
            border: Border.all(
              color: earned ? const Color(0xFFFFE9B8) : Colors.white12,
              width: 1,
            ),
            boxShadow: earned
                ? const [BoxShadow(color: Color(0x66E8A33D), blurRadius: 6)]
                : null,
          ),
          child: Icon(
            icon,
            size: 13,
            color: earned ? const Color(0xFF3A2A10) : Colors.white24,
          ),
        ),
      ),
    );
  }
}

class _MedalCount extends StatelessWidget {
  final int earned;
  final int total;
  const _MedalCount({required this.earned, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, size: 12, color: _gold),
          const SizedBox(width: 4),
          Text(
            '$earned/$total',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
