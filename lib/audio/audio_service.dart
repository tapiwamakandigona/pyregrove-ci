// lib/audio/audio_service.dart — music loops + SFX one-shots (audioplayers).
//
// Music: one looping track per screen family (title/map/combat/boss_combat)
// with a short crossfade on change; victory/defeat play as non-looping stings.
// A quiet ember-ambience bed runs under the title and rest screens.
//
// SFX: one-shot ids (see [sfxPaths]) played through a small player pool.
// The platformer maps them per event in EmberGame._handlePlayerEvents /
// _handleSessionEvents (jump/land/swing combo/chest/feather/secret/...).
//
// Everything is best-effort: every platform call is caught so audio can never
// crash gameplay, and nothing here is constructed in widget tests.
import 'dart:math' as math;
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'music_mix.dart';
import 'round_robin.dart';
import 'settings.dart';

class AudioService {
  /// Set by main(); null in tests (all call sites are null-safe).
  static AudioService? instance;

  static const Map<String, String> musicPaths = {
    'title_menu': 'audio/music/title_menu.ogg',
    'map': 'audio/music/map.ogg',
    'combat': 'audio/music/combat.ogg',
    // World 2 got its own bed in the 2026-07-25 audio pass: before that every
    // one of the twelve levels played 'combat' and boss_combat.ogg shipped
    // unreferenced.
    'cave_combat': 'audio/music/cave_combat.ogg',
    'boss_combat': 'audio/music/boss_combat.ogg',
    'victory': 'audio/music/victory.ogg',
    'defeat': 'audio/music/defeat.ogg',
  };

  /// SFX ids that repeat often enough to fatigue; each play gets a small
  /// random playback-rate wobble so no two hits/coins sound identical
  /// (indie-standard 'pitch variance'; research-2026-09.md). Kept off
  /// one-shot UI/jingle sounds where a stable pitch reads as intentional.
  static const Set<String> variedSfx = {
    'coin',
    'enemy_hit',
    'player_hit',
    'land',
    'step1',
    'step2',
    'swing1',
    'swing2',
    'swing3',
    'block',
  };

  /// Playback rate for this play of [id]: 1.0 for stable ids, otherwise a
  /// uniform wobble in [0.94, 1.06]. Pure — unit-tested; [unit] is a random
  /// draw in [0,1).
  static double sfxRateFor(String id, double unit) =>
      variedSfx.contains(id) ? 0.94 + unit * 0.12 : 1.0;

  // B5 (FEEL-POLISH): rising coin chain. Coins collected in quick
  // succession climb ~a semitone per pickup (x1.059 each, capped at +8),
  // turning a coin run into a little arpeggio; a 1.5s gap resets the
  // chain. Composable with the wobble: the chain sets the base, the
  // wobble keeps repeats organic. Pure helper — unit-tested.
  static const double _chainWindow = 1.5; // s between coins to keep chain
  static const int _chainCap = 8; // semitone steps above base
  int _coinChain = 0;
  double _lastCoinAt = -10;

  /// Chain multiplier for the [n]th coin of a chain (0-based), pure:
  /// 2^(n/12) capped at [_chainCap] steps.
  static double coinChainRate(int n) {
    final steps = n > _chainCap ? _chainCap : n;
    return math.pow(2.0, steps / 12.0).toDouble();
  }

  /// Advance the chain clock for a coin picked up at [now] (seconds, any
  /// monotonic clock) and return this pickup's chain multiplier.
  double coinChainAdvance(double now) {
    if (now - _lastCoinAt > _chainWindow) _coinChain = 0;
    final rate = coinChainRate(_coinChain);
    _coinChain++;
    _lastCoinAt = now;
    return rate;
  }

  static const Map<String, String> sfxPaths = {
    // -- movement / combat (platformer v2 pass, tool/build_platformer_sfx.py)
    'jump': 'audio/sfx/jump.ogg',
    'double_jump': 'audio/sfx/double_jump.ogg',
    'land': 'audio/sfx/land.ogg',
    'step1': 'audio/sfx/step1.ogg',
    'step2': 'audio/sfx/step2.ogg',
    'swing1': 'audio/sfx/swing1.ogg',
    'swing2': 'audio/sfx/swing2.ogg',
    'swing3': 'audio/sfx/swing3.ogg',
    // -- loot / discovery
    'chest_open': 'audio/sfx/chest_open.ogg',
    'feather': 'audio/sfx/feather.ogg',
    'secret': 'audio/sfx/secret.ogg',
    'medal': 'audio/sfx/medal.ogg',
    // -- shared
    'player_hit': 'audio/sfx/player_hit.ogg',
    'enemy_hit': 'audio/sfx/enemy_hit.ogg',
    'enemy_hit_b': 'audio/sfx/enemy_hit_b.ogg',
    'enemy_hit_c': 'audio/sfx/enemy_hit_c.ogg',
    'block': 'audio/sfx/block.ogg',
    'enemy_death': 'audio/sfx/enemy_death.ogg',
    'boss_death': 'audio/sfx/boss_death.ogg',
    'victory': 'audio/sfx/victory.ogg',
    'defeat': 'audio/sfx/defeat.ogg',
    'coin': 'audio/sfx/coin.ogg',
    'coin_b': 'audio/sfx/coin_b.ogg',
    'coin_c': 'audio/sfx/coin_c.ogg',
    'heal': 'audio/sfx/heal.ogg',
    'ui_tap': 'audio/sfx/ui_tap.ogg',
    'ui_back': 'audio/sfx/ui_back.ogg',
    'unlock': 'audio/sfx/unlock.ogg',
    'ember_gain': 'audio/sfx/ember_gain.ogg',
    'whoosh': 'audio/sfx/whoosh.ogg',
    'ember_ambience_loop': 'audio/sfx/ember_ambience_loop.ogg',
    'danger_loop': 'audio/sfx/danger_loop.ogg',
    'boss_layer': 'audio/sfx/boss_layer.ogg',
  };

  AudioSettings settings;
  AudioService(this.settings);

  /// One-time platform audio session setup — call from main() before any
  /// player is created. Android's default AudioContext makes EVERY player
  /// request exclusive audio focus (AUDIOFOCUS_GAIN) on play(), so each SFX
  /// one-shot (ui_tap on the settings gear, the difficulty selector, every
  /// EmberButton...) delivered a permanent AUDIOFOCUS_LOSS to the music
  /// player, which audioplayers answers with a pause() that is never
  /// resumed — "tapping settings kills the music". mixWithOthers drops all
  /// in-app focus fighting (Android: AUDIOFOCUS_NONE, iOS: playback +
  /// mixWithOthers); backgrounding is handled by the app-lifecycle observer
  /// (pauseAll/resumeAll), not by audio focus.
  static Future<void> initPlatformAudio() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
        ).build(),
      );
    } catch (_) {}
  }

  static const _ambienceLevel = 0.35; // relative to music volume

  AudioPlayer? _music;
  String? _musicKey;

  // Live music gain (music_mix.dart): fade-in after a switch + duck on heavy
  // moments. One 50 ms timer runs only while the gain is moving.
  double _musicSince = kMusicFadeInTime; // seconds since the track started
  bool _musicFading = false; // stings start at full volume
  double _duck = 0; // 1 = just ducked, decays to 0 over kDuckTime
  Timer? _gainTimer;
  double _dangerVol = 0.5; // last pushed danger level (relative)
  AudioPlayer? _bossLayer;
  AudioPlayer? _ambience;
  AudioPlayer? _danger;

  // SFX voices: per-id players prepared ONCE, then replayed with a cheap
  // native stop+resume. See [playSfx] for why this is load-bearing for
  // frame pacing (the previous design caused gameplay stutter).
  final math.Random _pitchRng = math.Random();
  final Map<String, int> _lastVariant = {};
  final Map<String, List<AudioPlayer>> _sfx = {};
  final Map<String, int> _sfxNext = {};
  static const _sfxVoicesPerId = 2;

  // -- Music ----------------------------------------------------------------

  Future<void> playMusic(String key, {bool loop = true}) async {
    final path = musicPaths[key];
    if (path == null) return;
    // Dedupe looping tracks: navigating title -> shop/settings -> title must
    // not restart the theme mid-phrase. Stings (victory/defeat) always play.
    if (loop && key == _musicKey && _music != null) return;
    _musicKey = key;
    final old = _music;
    _music = null;
    if (old != null) _fadeOutAndDispose(old);
    AudioPlayer? p;
    try {
      p = AudioPlayer();
      _music = p;
      await p.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
      // C1: loops ramp in over kMusicFadeInTime to mirror the fade-out;
      // stings (victory/defeat) hit at full volume on purpose.
      _musicFading = loop;
      _musicSince = loop ? 0 : kMusicFadeInTime;
      _duck = 0;
      await p.play(AssetSource(path), volume: settings.effectiveMusic * _gain);
      if (loop) _startGainTimer();
    } catch (_) {
      // A failed start must not poison the dedupe key: playMusic would keep
      // early-returning on `key == _musicKey` and the whole screen family
      // (title/map/combat) would stay silent. Reset so the next call retries
      // — but only if a newer playMusic hasn't already taken over.
      if (_music == p) {
        _music = null;
        _musicKey = null;
      }
      try {
        await p?.dispose();
      } catch (_) {}
    }
  }

  double get _gain =>
      musicGain(sinceStart: _musicFading ? _musicSince : null, duck: _duck);

  /// C3: dip the music for a beat (player hit, boss phase, boss death) and
  /// ease back over [kDuckTime]. Never call for coins/swings — pumping.
  void duckMusic() {
    if (_music == null) return;
    _duck = 1;
    _startGainTimer();
  }

  void _startGainTimer() {
    if (_gainTimer != null) return;
    const step = Duration(milliseconds: 50);
    _gainTimer = Timer.periodic(step, (t) {
      const dt = 0.05;
      _musicSince += dt;
      _duck = (_duck - dt / kDuckTime).clamp(0.0, 1.0);
      final settled = _duck == 0 && _musicSince >= kMusicFadeInTime;
      if (settled) {
        _musicFading = false;
        t.cancel();
        _gainTimer = null;
      }
      try {
        _music?.setVolume(settings.effectiveMusic * _gain);
      } catch (_) {}
    });
  }

  void _fadeOutAndDispose(AudioPlayer p) {
    var v = settings.effectiveMusic;
    // One timer per faded player: rapid consecutive music switches each get
    // their own fade, so an earlier fading player can never be orphaned
    // mid-fade (which would leave it looping at partial volume).
    Timer.periodic(const Duration(milliseconds: 50), (t) async {
      v -= 0.12;
      if (v <= 0) {
        t.cancel();
        try {
          await p.stop();
          await p.dispose();
        } catch (_) {}
      } else {
        try {
          await p.setVolume(v.clamp(0.0, 1.0));
        } catch (_) {}
      }
    });
  }

  /// Quiet ember-crackle bed under title/rest.
  void setAmbience(bool on) {
    if (on) {
      if (_ambience != null) return;
      AudioPlayer? p;
      try {
        p = AudioPlayer();
        _ambience = p;
        p.setReleaseMode(ReleaseMode.loop);
        p.play(
          AssetSource(sfxPaths['ember_ambience_loop']!),
          volume: settings.effectiveMusic * _ambienceLevel,
        );
      } catch (_) {
        // Same retry rule as playMusic: a failed start must not occupy the
        // slot, or ambience stays silent until the next off/on phase swing.
        if (_ambience == p) _ambience = null;
      }
    } else {
      final p = _ambience;
      _ambience = null;
      if (p != null) {
        try {
          p.stop();
          p.dispose();
        } catch (_) {}
      }
    }
  }

  /// Low-HP danger bed (v0.4, flagged "before 1.0" since v0.2): a quiet
  /// heartbeat loop under the combat music while the player is in lethal
  /// range. Same lifecycle rules as the ambience bed: a failed start must
  /// not occupy the slot, and off always stops+disposes.
  ///
  /// C6: [level] (relative to music volume, see [dangerLevel]) scales the
  /// bed with peril; changes while on are pushed straight to the player.
  void setDanger(bool on, {double level = 0.5}) {
    if (on) {
      if (_danger != null) {
        if ((level - _dangerVol).abs() > 0.01) {
          _dangerVol = level;
          try {
            _danger!.setVolume(settings.effectiveMusic * level);
          } catch (_) {}
        }
        return;
      }
      AudioPlayer? p;
      try {
        p = AudioPlayer();
        _danger = p;
        _dangerVol = level;
        p.setReleaseMode(ReleaseMode.loop);
        p.play(
          AssetSource(sfxPaths['danger_loop']!),
          volume: settings.effectiveMusic * level,
        );
      } catch (_) {
        if (_danger == p) _danger = null;
      }
    } else {
      final p = _danger;
      _danger = null;
      if (p != null) {
        try {
          p.stop();
          p.dispose();
        } catch (_) {}
      }
    }
  }

  // -- SFX --------------------------------------------------------------------

  /// One-shot SFX with prepared, low-latency voices (movement-stutter fix,
  /// owner-reported 2026-07-25).
  ///
  /// The previous implementation round-robined 6 shared players and called
  /// `p.play(AssetSource(path))` on EVERY shot — audioplayers re-sets the
  /// source each time, which on Android is a full MediaPlayer release +
  /// setDataSource + prepare on the platform thread. Footsteps fire every
  /// 0.26 s while running, so the game hitched rhythmically exactly during
  /// movement.
  ///
  /// Now each sfx id lazily gets [_sfxVoicesPerId] players in
  /// [PlayerMode.lowLatency] (Android: SoundPool) with the source set ONCE
  /// — SoundPool keeps the decoded sample loaded and shares the soundId
  /// between voices of the same asset. Each shot is then stop() + resume(),
  /// a cheap native replay with zero re-preparation (verified against
  /// audioplayers 6.6.0 / audioplayers_android 5.2.1 internals). Two voices
  /// per id let rapid repeats (coin bursts, combo swings) overlap instead
  /// of cutting each other off.
  Future<void> playSfx(String id, {double volume = 1.0}) async {
    // Round-robin: [id] stays the logical sound (rate wobble, coin chain);
    // [path] is the concrete variant, never the same one twice in a row.
    final vi = pickVariantIndex(
      id,
      _lastVariant[id] ?? -1,
      _pitchRng.nextDouble(),
    );
    _lastVariant[id] = vi;
    final vid = variantId(id, vi);
    final path = sfxPaths[vid];
    if (path == null) return;
    final v = settings.effectiveSfx * volume;
    if (v <= 0) return;
    try {
      final voices = await _ensureVoice(vid, path);
      final n = (_sfxNext[vid] ?? -1) + 1;
      _sfxNext[vid] = n;
      final p = voices[n % voices.length];
      await p.stop();
      await p.setVolume(v.clamp(0.0, 1.0));
      var rate = sfxRateFor(id, _pitchRng.nextDouble());
      if (id == 'coin') {
        rate *= coinChainAdvance(DateTime.now().microsecondsSinceEpoch / 1e6);
      }
      if (rate != 1.0) await p.setPlaybackRate(rate);
      await p.resume();
    } catch (_) {}
  }

  /// Lazily grows the voice list for one concrete sfx asset by one player
  /// (up to [_sfxVoicesPerId]) with the source set once — see [playSfx].
  Future<List<AudioPlayer>> _ensureVoice(String vid, String path) async {
    final voices = _sfx[vid] ??= [];
    if (voices.length < _sfxVoicesPerId) {
      final p = AudioPlayer();
      // Order matters: mode must be set before the source is attached. The
      // voice joins the list only once it is fully set up, so a failed
      // setup (no platform, bad asset) never leaves a dead voice in a slot.
      try {
        await p.setPlayerMode(PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setSource(AssetSource(path));
      } catch (_) {
        p.dispose().ignore();
        rethrow;
      }
      voices.add(p);
    }
    return voices;
  }

  /// Voices currently allocated for a concrete sfx asset id (0 = cold).
  int sfxVoiceCount(String vid) => _sfx[vid]?.length ?? 0;

  /// Pre-create the voices for the one-shots gameplay fires first
  /// (alpha.23 #36). Without this the FIRST jump / step / swing / coin / hit
  /// of a session each pay a native player creation plus a SoundPool sample
  /// load inside the shot — the first sound of every kind is late, and the
  /// allocation lands mid-gameplay on the platform thread. Called from the
  /// title screen after the first frame (main.dart), never on the cold-start
  /// path; fail-open per asset. Returns the number of voices created.
  Future<int> warmSfx({Iterable<String>? ids}) async {
    var created = 0;
    for (final vid in sfxWarmVariantIds(ids ?? kSfxWarmIds)) {
      final path = sfxPaths[vid];
      if (path == null) continue;
      try {
        final before = sfxVoiceCount(vid);
        final voices = await _ensureVoice(vid, path);
        // Two voices per id (see playSfx); create the second too so the
        // first rapid repeat (coin burst, combo) is warm as well.
        if (voices.length < _sfxVoicesPerId) await _ensureVoice(vid, path);
        created += sfxVoiceCount(vid) - before;
      } catch (_) {
        // fail-open: the shot path creates the voice lazily as before
      }
    }
    return created;
  }

  /// Boss intensity layer (C5, vertical layering at minimum viable scale):
  /// 'Wrath Rising' — a tempo-free ember-wind/taiko texture looped over
  /// boss_combat once the boss is in phase 2 or 3. Same lifecycle rules as
  /// the danger bed: a failed start frees the slot; off stops+disposes.
  static const double kBossLayerLevel = 0.6; // relative to music volume

  bool get bossLayerOn => _bossLayer != null;

  void setBossLayer(bool on) {
    if (on) {
      if (_bossLayer != null) return;
      AudioPlayer? p;
      try {
        p = AudioPlayer();
        _bossLayer = p;
        p.setReleaseMode(ReleaseMode.loop);
        p.play(
          AssetSource(sfxPaths['boss_layer']!),
          volume: settings.effectiveMusic * kBossLayerLevel,
        );
      } catch (_) {
        if (_bossLayer == p) _bossLayer = null;
      }
    } else {
      final p = _bossLayer;
      _bossLayer = null;
      if (p != null) {
        try {
          p.stop();
          p.dispose();
        } catch (_) {}
      }
    }
  }

  // -- App lifecycle (v0.3.1 F3) ----------------------------------------------

  /// Pause everything when the app leaves the foreground (Home/lock/call) —
  /// Android keeps audioplayers running otherwise, which is a Play-review
  /// killer. Best-effort like everything else here.
  void pauseAll() {
    try {
      _music?.pause();
      _ambience?.pause();
      _danger?.pause();
      _bossLayer?.pause();
      for (final voices in _sfx.values) {
        for (final p in voices) {
          p.stop();
        }
      }
    } catch (_) {}
  }

  /// Resume the music + ambience beds on return to the foreground.
  void resumeAll() {
    try {
      _music?.resume();
      _ambience?.resume();
      _danger?.resume();
      _bossLayer?.resume();
    } catch (_) {}
  }

  // -- Settings ---------------------------------------------------------------

  /// Push current settings onto live players (sliders move audio instantly).
  void applySettings() {
    try {
      _music?.setVolume(settings.effectiveMusic * _gain);
      _ambience?.setVolume(settings.effectiveMusic * _ambienceLevel);
      _danger?.setVolume(settings.effectiveMusic * _dangerVol);
      _bossLayer?.setVolume(settings.effectiveMusic * kBossLayerLevel);
    } catch (_) {}
  }
}
