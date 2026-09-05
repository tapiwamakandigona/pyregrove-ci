// game/mimic_disguise.dart — what a Bramble Mimic hides as, per environment.
//
// World 1 mimics wear the bush prop, because bushes are everywhere in the
// grove. Caves have no bushes, so a cave mimic wears the shroom cluster
// instead (the cave decor players have already walked past). The revealed
// form is the same thornling strip, tinted so veterans can tell it from a
// plain thornling: leaf-green in the grove, spore-violet in the caves.
// Pure Dart so the mapping is unit-testable without a canvas.

import 'dart:ui' show Color;

/// Prop image (under assets/images/) a hidden mimic is drawn with.
String mimicDisguiseAsset(String environment) =>
    environment == 'cave' ? 'props/shrooms.png' : 'props/bush.png';

/// Modulate tint for the revealed thornling strip.
Color mimicRevealTint(String environment) => environment == 'cave'
    ? const Color(0xFFC9A6E6) // spore-violet
    : const Color(0xFFB8D97A); // leaf-green
