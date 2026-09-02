#!/usr/bin/env python3
"""Round-robin variants for the two most-fired one-shots (AUDIO-POLISH C4).

Derives coin_b/coin_c and enemy_hit_b/enemy_hit_c from the shipped
coin.ogg / enemy_hit.ogg (same CC0 sources as tool/build_audio_v3.py, so
CREDITS.md is unchanged). Each variant differs in timbre, not just pitch:
EQ tilt + small rate change + envelope, because pitch wobble alone cannot
hide a single repeating sample. Output: ogg q5 mono 44.1k, normalized.
"""
import subprocess
import tempfile

import numpy as np
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SFX = REPO / "assets" / "audio" / "sfx"

VARIANTS = {
    # id: (source, filter chain)
    "coin_b": ("coin.ogg", "asetrate=44100*1.045,aresample=44100,highpass=f=900,treble=g=3"),
    "coin_c": ("coin.ogg", "asetrate=44100*0.965,aresample=44100,lowpass=f=6000,afade=t=out:st=0.10:d=0.08"),
    "enemy_hit_b": ("enemy_hit.ogg", "asetrate=44100*0.93,aresample=44100,bass=g=4:f=200,lowpass=f=5000"),
    "enemy_hit_c": ("enemy_hit.ogg", "asetrate=44100*1.07,aresample=44100,highpass=f=350,treble=g=2,afade=t=out:st=0.12:d=0.06"),
}


def peak(path: Path, chain: str = "anull") -> float:
    """Sample peak of [path] after [chain], decoded to mono float32."""
    raw = subprocess.run(
        ["ffmpeg", "-v", "error", "-i", str(path), "-af", chain, "-f", "f32le",
         "-ac", "1", "-ar", "44100", "-"],
        check=True, capture_output=True).stdout
    return float(np.abs(np.frombuffer(raw, dtype=np.float32)).max())


def _bav3():
    import importlib.util
    spec = importlib.util.spec_from_file_location("bav3", Path(__file__).with_name("build_audio_v3.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def update_mix_report(ids):
    """Add the variants to tool/audio_mix.json using build_audio_v3's meters
    (audio_mix_test requires an entry per sfx id)."""
    import json
    bav3 = _bav3()
    mix = json.loads(bav3.MIX_REPORT.read_text())
    for out, (src, _) in ids.items():
        path = SFX / f"{out}.ogg"
        base = mix["sfx"][src[:-4]]
        mix["sfx"][out] = {
            "above500": round(bav3.energy_above_500(path), 3),
            "group": base["group"],
            "peak": round(bav3.peak_db(path), 1),
            "phoneRms": round(bav3.phone_rms_db(path), 1),
            "seconds": round(bav3.duration_s(path), 2) if hasattr(bav3, "duration_s") else base["seconds"],
            "source": base["source"] + " (variant via tool/build_sfx_variants.py)",
        }
    bav3.MIX_REPORT.write_text(json.dumps(mix, indent=1, sort_keys=True) + "\n")
    print("updated", bav3.MIX_REPORT)


def main():
    for out, (src, chain) in VARIANTS.items():
        # Match the source's phone-band RMS (the mix report's loudness
        # meter) so the variant sits at the same level, then cap the peak
        # at -1 dBFS. loudnorm is unreliable on 0.1 s clips.
        bav3 = _bav3()
        with tempfile.TemporaryDirectory() as td:
            stage = Path(td) / "stage.wav"
            subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(SFX / src),
                            "-af", chain, "-ac", "1", "-ar", "44100", str(stage)], check=True)
            gain_db = bav3.phone_rms_db(SFX / src) - bav3.phone_rms_db(stage)
            gain_db = min(gain_db, -1.0 - bav3.peak_db(stage))
        gain = 10 ** (gain_db / 20)
        cmd = [
            "ffmpeg", "-y", "-loglevel", "error", "-i", str(SFX / src),
            "-af", f"{chain},volume={gain:.4f}",
            "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "5",
            str(SFX / f"{out}.ogg"),
        ]
        subprocess.run(cmd, check=True)
        print(out, (SFX / f"{out}.ogg").stat().st_size, "bytes",
              f"peak={peak(SFX / f'{out}.ogg'):.2f}")
    update_mix_report(VARIANTS)


if __name__ == "__main__":
    main()
