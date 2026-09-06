// asset_warmup.dart — decode the sprites every level needs while the player
// is still on the title screen, so the first level entry of a session does
// not pay the cold-cache decode (alpha.23 #35, first ten minutes).
//
// Measured before (desktop VM, test/first_frame_complete_test.dart):
// EmberGame.onLoad for w1_l1 with a cold Flame.images cache 143–153 ms,
// warm 6–18 ms. Since #34 holds the loading state until every level
// component has decoded, the cold cost is the black gap between PLAY and the
// first frame — on a 2 GB phone several times the VM number.
//
// What is warmed: everything a level can draw for BOTH worlds (backdrops,
// tilesets, props, items, fx, HUD, every enemy strip) plus the player body
// and ONLY the equipped skin/weapon overlay — not the shop icons, not the
// other skins/weapons, not the legacy bladed base sheets. Decoded size of the
// starter set: 64 files, 3.35 MiB RGBA (measured from the PNG headers; all
// 179 bundled PNGs together are 6.34 MiB, docs/PLAY-QUALITY-2027.md row 3).
// Flame's cache never evicts, so a W1 level would have pinned most of this
// anyway; the W2-only part (cave backdrops, cave tileset, five enemy strips)
// is the extra a fresh save carries early.
import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';

import '../core/save.dart';

/// Player sheet names (body and every skin/weapon dir share them).
const List<String> kPlayerSheetNames = [
  'attack1',
  'attack2',
  'attack3',
  'fall',
  'hit',
  'idle',
  'jump',
  'roll',
  'run',
];

/// Level sprites shared by every run, independent of the save.
const List<String> kWarmupSharedImages = [
  // Backdrops (ParallaxBackground, both environments).
  'bg/forest_back.png',
  'bg/forest_middle.png',
  'bg/forest_front.png',
  'bg/forest_lights.png',
  'bg/cave_back.png',
  'bg/cave_middle.png',
  'bg/cave_front.png',
  'bg/cave_lights.png',
  // Tiles + props (TileLayer, DecorLayer, Items).
  'tiles/tileset.png',
  'tiles/tileset_cave.png',
  'props/block_big.png',
  'props/bush.png',
  'props/campfire_lit.png',
  'props/campfire_out.png',
  'props/door.png',
  'props/door_open.png',
  'props/platform.png',
  'props/rock.png',
  'props/shrooms.png',
  'props/sign.png',
  'props/spikes.png',
  'props/tree.png',
  // Items + HUD.
  'items/apple.png',
  'items/chest.png',
  'items/coin.png',
  'items/feather.png',
  'hud/btn_down.png',
  'hud/btn_left.png',
  'hud/btn_right.png',
  'hud/btn_round.png',
  'hud/icon_dash.png',
  'hud/icon_jump.png',
  'hud/icon_pause.png',
  'hud/icon_spell.png',
  'hud/icon_sword.png',
  // FX + every enemy strip (W1 and W2).
  'fx/enemy_death.png',
  'fx/fire.png',
  'enemies/thornling.png',
  'enemies/ashbat.png',
  'enemies/hopper_idle.png',
  'enemies/hopper_jump.png',
  'enemies/soot_creeper.png',
  'enemies/cinder_diver.png',
  'enemies/pyre_wisp.png',
  'enemies/slag_hound.png',
  'enemies/slag_hound_charge.png',
];

/// The full warm-up list for a save: shared set + player body + the equipped
/// skin (when not the starter 'red' body) + the equipped weapon overlay.
List<String> warmupImagesFor({
  required String skinId,
  required String weaponId,
}) {
  return [
    ...kWarmupSharedImages,
    for (final n in kPlayerSheetNames) 'player/body/$n.png',
    if (skinId != 'red')
      for (final n in kPlayerSheetNames) 'player/skins/$skinId/$n.png',
    for (final n in kPlayerSheetNames) 'player/weapons/$weaponId/$n.png',
  ];
}

/// Decode the warm-up set into [images] (default: the global cache EmberGame
/// uses). Fail-open: paths that are not in the asset manifest are skipped up
/// front (a missing skin/weapon sheet is exactly the case PlayerComponent
/// already tolerates at runtime, and Flame's cache would otherwise surface
/// the miss as an unhandled async error), and a decode error on a listed
/// asset is swallowed rather than aborting the rest. Returns the number of
/// images that decoded.
Future<int> warmUpLevelSprites(SaveData save, {Images? images}) async {
  final cache = images ?? Flame.images;
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final bundled = manifest.listAssets().toSet();
  final paths = warmupImagesFor(
    skinId: save.equippedSkin,
    weaponId: save.equippedWeapon,
  ).where((p) => bundled.contains('$kImagePrefix$p'));
  var ok = 0;
  await Future.wait(
    paths.map((p) async {
      try {
        await cache.load(p);
        ok++;
      } catch (_) {
        // fail-open: see doc comment
      }
    }),
  );
  return ok;
}

/// Flame's default image prefix (Images() with no argument).
const String kImagePrefix = 'assets/images/';
