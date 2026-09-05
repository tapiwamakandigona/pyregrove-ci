// "More from Tsoro Studios" — one quiet cross-promotion row (owner directive
// 2026-09-05b). Settings only, at the bottom. No badge, no modal, no telemetry
// event: the Play install-referrer already measures the tap.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// This game's id, used as the utm_source / install referrer on Android.
const kThisGame = 'pyregrove';

/// Fliptide's Play listing is still in closed testing (2026-09-05): send
/// everyone to the itch.io page until it is public.
const kFliptideOnPlay = false;

class MoreGame {
  const MoreGame({
    required this.name,
    required this.hook,
    required this.packageId,
    this.webUrl,
    this.preferWeb = false,
  });
  final String name;
  final String hook;
  final String packageId;

  /// Where web builds (and the https fallback) go. Defaults to the Play listing.
  final String? webUrl;

  /// True while the Play listing is not public: skip market:// and use [webUrl].
  final bool preferWeb;

  Uri get playUri =>
      Uri.parse('https://play.google.com/store/apps/details?id=$packageId');
  Uri get marketUri => Uri.parse(
      'market://details?id=$packageId&referrer=utm_source%3D$kThisGame');
  Uri get httpsUri => webUrl != null ? Uri.parse(webUrl!) : playUri;
}

const kEmberdelve = MoreGame(
  name: 'Emberdelve',
  hook: 'Dice roguelite. No ads, offline.',
  packageId: 'com.tsorostudios.emberdelve',
);

const kFliptide = MoreGame(
  name: 'Fliptide',
  hook: 'One tap flips gravity. Same course for everyone today.',
  packageId: 'com.tsorostudios.fliptide',
  webUrl: 'https://tsorostudios.itch.io/fliptide',
  preferWeb: !kFliptideOnPlay,
);

/// The entries shown in this game, in order.
const List<MoreGame> kMoreGames = [kEmberdelve, kFliptide];

typedef UriLauncher = Future<bool> Function(Uri uri, {LaunchMode mode});

/// Android: try the Play app (market://) first, then https. Everywhere else,
/// or while the listing is not public: the https URL in an external browser.
Future<bool> openMoreGame(
  MoreGame g, {
  UriLauncher? launcher,
  TargetPlatform? platform,
  bool? isWeb,
}) async {
  final launch = launcher ?? launchUrl;
  final web = isWeb ?? kIsWeb;
  final tp = platform ?? defaultTargetPlatform;
  if (!web && tp == TargetPlatform.android && !g.preferWeb) {
    try {
      if (await launch(g.marketUri, mode: LaunchMode.externalApplication)) {
        return true;
      }
    } catch (_) {
      // No Play app on this device — fall through to https.
    }
  }
  try {
    return await launch(g.httpsUri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// Settings section: header in the existing amber micro style + one ListTile
/// per game, matching the tiles above it.
class MoreFromTsoro extends StatelessWidget {
  const MoreFromTsoro({super.key, this.games = kMoreGames, this.onOpen});
  final List<MoreGame> games;

  /// Test seam; defaults to [openMoreGame].
  final Future<bool> Function(MoreGame g)? onOpen;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) return const SizedBox.shrink();
    return Column(
      key: const Key('more-from-tsoro'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 4),
          child: Text(
            'MORE FROM TSORO STUDIOS',
            style: TextStyle(
              color: Color(0xFFE8A33D),
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        for (final g in games)
          ListTile(
            key: Key('more-${g.packageId}'),
            leading: const Icon(Icons.sports_esports, color: Colors.white70),
            title: Text(g.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              g.hook,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            trailing: const Icon(Icons.open_in_new, color: Colors.white38, size: 18),
            onTap: () => (onOpen ?? openMoreGame)(g),
          ),
      ],
    );
  }
}
