#!/usr/bin/env python3
"""'Wrath Rising' — boss intensity layer (AUDIO-POLISH-BACKLOG C5).

A texture loop played OVER boss_combat.ogg from boss phase 2 on. It is
deliberately tempo- and chord-agnostic: the runtime cannot beat-align a
second player with the music, so the layer has no beat grid and no pitched
chord tones — ember-wind tremolo noise in the phone-speaker band, taiko
rolls (free rolls, not on-beat hits) and a faint tonic (D) rumble. Built
from the same synthesis kit as the score (tool/build_original_music.py),
so it is original like the rest of the music. Seamless via crossfade.

Output: assets/audio/sfx/boss_layer.ogg (a background bed like danger_loop,
so it lives in sfxPaths / the sfx mix report with group 'background').
"""
import importlib.util
import json
import subprocess
import tempfile
from pathlib import Path

import numpy as np

REPO = Path(__file__).resolve().parent.parent
OUT = REPO / "assets" / "audio" / "sfx" / "boss_layer.ogg"
MIX_REPORT = REPO / "tool" / "audio_mix.json"
TARGET_PHONE_RMS = -30.5  # dB; under the -26 beds, like danger_loop (-32)


def _load(name):
    spec = importlib.util.spec_from_file_location(name, Path(__file__).with_name(f"{name}.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def compose(m, seconds=6.4):
    SR = m.SR
    n = int(seconds * SR)
    t = np.arange(n) / SR
    rng = np.random.default_rng(20260902)
    out = np.zeros((n, 2))

    # 1. Ember wind: band-passed noise, 9.5 Hz tremolo (matches the score's
    #    tremolo strings), slow 2-cycle swell so it breathes.
    wind = m.hp1(m.lp1(rng.standard_normal(n), 5200), 1400).ravel()
    trem = 0.62 + 0.38 * np.sin(2 * np.pi * 9.5 * t)
    swell = 0.75 + 0.25 * np.sin(2 * np.pi * t / seconds * 2 - np.pi / 2)
    wind = wind * trem * swell
    out += m.stereo(wind * 0.9, np.roll(wind, 311) * 0.9) * 0.16

    # 2. Taiko rolls: two rolls per loop, 7 hits accelerating slightly,
    #    velocities rising then falling. Not on a beat grid on purpose.
    for start in (0.35, 3.55):
        pos = start
        for i in range(7):
            vel = [0.35, 0.5, 0.65, 0.8, 0.65, 0.5, 0.35][i]
            hit = m.d2_taiko(int(0.5 * SR), vel)
            s = int(pos * SR)
            e = min(n, s + len(hit))
            out[s:e] += hit[: e - s] * 0.10
            pos += 0.105 - i * 0.004

    # 3. Tonic rumble: D3 (146.8 Hz) with a hair of drift, soft.
    f = 146.83 * (1 + 0.002 * np.sin(2 * np.pi * 0.17 * t))
    rumble = np.sin(2 * np.pi * np.cumsum(f) / SR) * (0.8 + 0.2 * np.sin(2 * np.pi * 0.4 * t))
    out += m.stereo(rumble, rumble) * 0.006

    # Seamless loop: crossfade the last 0.6 s into the first 0.6 s.
    xf = int(0.6 * SR)
    ramp = np.linspace(0, 1, xf)[:, None]
    head = out[:xf].copy()
    tail = out[n - xf:].copy()
    out[:xf] = head * ramp + tail * (1 - ramp)
    return out[: n - xf]


def phone_rms_db(path):
    p = subprocess.run(["ffmpeg", "-v", "info", "-i", str(path), "-af",
                        "highpass=f=500,volumedetect", "-f", "null", "-"],
                       capture_output=True, text=True)
    for line in p.stderr.splitlines():
        if "mean_volume:" in line:
            return float(line.split("mean_volume:")[1].split("dB")[0])
    return -99.0


def main():
    m = _load("build_original_music")
    bav3 = _load("build_audio_v3")
    x = compose(m)
    with tempfile.TemporaryDirectory() as td:
        wav = Path(td) / "boss_layer.wav"
        m.write_wav(wav, x)
        gain = TARGET_PHONE_RMS - phone_rms_db(wav)
        subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", str(wav), "-af",
                        f"volume={gain:.2f}dB,alimiter=limit=0.7:level=false",
                        "-ac", "1", "-ar", str(m.SR), "-c:a", "libvorbis", "-q:a", "4",
                        str(OUT)], check=True)
    mix = json.loads(MIX_REPORT.read_text())
    entry = {
        "above500": round(bav3.energy_above_500(OUT), 3),
        "group": "background",
        "peak": round(bav3.peak_db(OUT), 1),
        "phoneRms": round(phone_rms_db(OUT), 1),
        "seconds": round(len(x) / m.SR, 2),
        "source": "original synthesis, tool/build_boss_layer.py",
    }
    mix["sfx"]["boss_layer"] = entry
    MIX_REPORT.write_text(json.dumps(mix, indent=1, sort_keys=True) + "\n")
    print("boss_layer.ogg", OUT.stat().st_size, "bytes", entry)


if __name__ == "__main__":
    main()
