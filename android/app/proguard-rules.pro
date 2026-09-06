# R8 keep rules for Pyregrove release builds (alpha.21, Play quality Feb-2027
# DEX requirement — docs/PLAY-QUALITY-2027.md). Trimmed from Emberdelve's
# battle-tested rules (issue #94 there) to the plugins Pyregrove actually
# ships: flame (pure Dart), path_provider, audioplayers, firebase_core,
# firebase_analytics, shared_preferences.

# Generic: keep enums used via valueOf reflection.
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Firebase ships consumer rules with its AARs; just silence warnings from
# optional transitive references.
-dontwarn com.google.firebase.**

# Play Core deferred-components stubs referenced by the Flutter engine.
-dontwarn com.google.android.play.core.**
