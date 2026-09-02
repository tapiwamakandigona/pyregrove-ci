// lib/audio/settings.dart — user audio settings, persisted with the same
// best-effort JSON-file pattern as MetaStore (lib/meta/meta.dart).
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioSettings {
  double musicVolume;
  double sfxVolume;
  bool musicMuted;
  bool sfxMuted;
  bool haptics; // v0.3.1 F12: vibration on key beats (roll/assign/hit/death)
  bool screenShake; // accessibility: camera kick on hits/boss beats

  /// Touch-control size multiplier (alpha.23): 0.85 small / 1.0 normal /
  /// 1.2 large. Comparables (Dead Cells mobile) let players resize the pad;
  /// applied to the in-game HUD at level start. Clamped on load.
  double controlScale;
  static const controlScaleMin = 0.85;
  static const controlScaleMax = 1.2;

  /// Mirror the touch layout (alpha.23): move-pad bottom-right, action
  /// diamond bottom-left — the left-handed layout. Pause and the readout
  /// stay where they are. Applied at level start, like [controlScale].
  bool mirrorControls;

  /// Lift the touch clusters off the bottom edge (alpha.23), in view px:
  /// 0 flush / 14 raised / 28 high. Tall phones put the bottom row under
  /// the thumb's crease; Dead Cells mobile solves it with free placement,
  /// this is the one-axis version. Pause and the readout stay put. Applied
  /// at level start; clamped on load and again against the readout row.
  double controlLift;
  static const controlLiftMin = 0.0;
  static const controlLiftMax = 28.0;
  AudioSettings({
    this.musicVolume = 0.7,
    this.sfxVolume = 0.9,
    this.musicMuted = false,
    this.sfxMuted = false,
    this.haptics = true,
    this.screenShake = true,
    this.controlScale = 1.0,
    this.mirrorControls = false,
    this.controlLift = 0.0,
  });

  double get effectiveMusic => musicMuted ? 0.0 : musicVolume;
  double get effectiveSfx => sfxMuted ? 0.0 : sfxVolume;

  Map<String, Object?> toJson() => {
    'musicVolume': musicVolume,
    'sfxVolume': sfxVolume,
    'musicMuted': musicMuted,
    'sfxMuted': sfxMuted,
    'haptics': haptics,
    'screenShake': screenShake,
    'controlScale': controlScale,
    'mirrorControls': mirrorControls,
    'controlLift': controlLift,
  };

  // Volumes clamped on load: an out-of-range value in a hand-edited or
  // corrupt settings file would otherwise crash the Settings sliders
  // (Slider asserts value ∈ [min, max]).
  factory AudioSettings.fromJson(Map<String, dynamic> j) => AudioSettings(
    musicVolume: ((j['musicVolume'] as num?)?.toDouble() ?? 0.7).clamp(
      0.0,
      1.0,
    ),
    sfxVolume: ((j['sfxVolume'] as num?)?.toDouble() ?? 0.9).clamp(0.0, 1.0),
    musicMuted: j['musicMuted'] as bool? ?? false,
    sfxMuted: j['sfxMuted'] as bool? ?? false,
    haptics: j['haptics'] as bool? ?? true,
    screenShake: j['screenShake'] as bool? ?? true,
    controlScale: ((j['controlScale'] as num?)?.toDouble() ?? 1.0).clamp(
      controlScaleMin,
      controlScaleMax,
    ),
    mirrorControls: j['mirrorControls'] as bool? ?? false,
    controlLift: ((j['controlLift'] as num?)?.toDouble() ?? 0.0).clamp(
      controlLiftMin,
      controlLiftMax,
    ),
  );
}

/// Control-height presets (Flush/Raised/High) in view px.
const kControlLiftPresets = [0.0, 14.0, 28.0];

/// Snap a stored lift to the nearest preset, same reason as
/// [nearestControlScale].
double nearestControlLift(double v) {
  var best = kControlLiftPresets.first;
  for (final p in kControlLiftPresets) {
    if ((p - v).abs() < (best - v).abs()) best = p;
  }
  return best;
}

/// How far the clusters may actually rise: the requested lift, but never so
/// far that the tallest cluster button ([headroom] px below the top safe pad
/// before lifting) would leave the view. Never negative.
double clampedControlLift(double requested, double headroom) {
  if (headroom <= 0) return 0;
  return requested.clamp(0, headroom).toDouble();
}

/// Snap a stored scale to the nearest Settings preset (Small/Normal/Large)
/// so a hand-edited or legacy value still selects one segment.
double nearestControlScale(double v) {
  const presets = [0.85, 1.0, 1.2];
  var best = presets.first;
  for (final p in presets) {
    if ((p - v).abs() < (best - v).abs()) best = p;
  }
  return best;
}

class SettingsStore {
  static const _fileName = 'pyregrove_settings.json';

  static Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<AudioSettings> load() async {
    try {
      final f = await _file();
      if (!await f.exists()) return AudioSettings();
      return AudioSettings.fromJson(
        jsonDecode(await f.readAsString()) as Map<String, dynamic>,
      );
    } catch (_) {
      return AudioSettings();
    }
  }

  /// Same durability contract as MetaStore.save / the run autosave: the JSON
  /// snapshot is captured synchronously, writes are chained on a queue (a
  /// slider release + a mute tap fire back-to-back saves that must not
  /// interleave bytes in one file), and each write goes to a temp file that
  /// is renamed into place so a crash mid-write can never leave truncated
  /// JSON (which would silently reset the player's audio settings on load).
  static Future<void> _writeQueue = Future.value();
  static Future<void> save(AudioSettings s) {
    final snap = jsonEncode(s.toJson());
    _writeQueue = _writeQueue.then((_) async {
      try {
        final f = await _file();
        final tmp = File('${f.path}.tmp');
        await tmp.writeAsString(snap, flush: true);
        await tmp.rename(f.path);
      } catch (_) {
        /* best-effort; never crash the game on save failure */
      }
    });
    return _writeQueue;
  }
}
