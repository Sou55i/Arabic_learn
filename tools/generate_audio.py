#!/usr/bin/env python3
"""Génère les fichiers audio arabes à partir des manifestes du projet.

Parcourt tous les `assets/audio/*/manifest.json` et produit, dans chaque
dossier, un `.mp3` par entrée. Utilise `edge-tts` (Microsoft Edge TTS,
gratuit, voix arabes natives de bonne qualité).

Prérequis :
    pip install -r tools/requirements.txt

Utilisation :
    python tools/generate_audio.py             # génère ce qui manque
    python tools/generate_audio.py --force      # régénère tout
    python tools/generate_audio.py --only words # un seul dossier (letters|words)
    python tools/generate_audio.py --list-voices

Chaque manifeste définit sa propre voix via le champ "voice", p. ex. :
    ar-SA-HamedNeural   (homme, Arabie saoudite)
    ar-EG-SalmaNeural   (femme, Égypte)
    ar-SA-ZariyahNeural (femme, Arabie saoudite)
"""

import argparse
import asyncio
import json
import sys
from pathlib import Path

AUDIO_ROOT = Path(__file__).resolve().parent.parent / "assets" / "audio"


def find_manifests(only: str | None) -> list[Path]:
    manifests = sorted(AUDIO_ROOT.glob("*/manifest.json"))
    if only:
        manifests = [m for m in manifests if m.parent.name == only]
    return manifests


async def synthesize(text: str, voice: str, out_path: Path) -> None:
    import edge_tts

    communicate = edge_tts.Communicate(text, voice)
    await communicate.save(str(out_path))


async def list_voices() -> None:
    import edge_tts

    voices = await edge_tts.list_voices()
    arabic = [v for v in voices if v["Locale"].startswith("ar")]
    for v in sorted(arabic, key=lambda v: v["ShortName"]):
        print(f"  {v['ShortName']:24} {v['Gender']:8} {v['Locale']}")


async def process(manifest_path: Path, force: bool) -> tuple[int, int]:
    with manifest_path.open(encoding="utf-8") as f:
        manifest = json.load(f)
    voice = manifest.get("voice", "ar-SA-HamedNeural")
    entries: dict = manifest["entries"]
    out_dir = manifest_path.parent

    generated, skipped = 0, 0
    print(f"\n[{out_dir.name}] voix : {voice}")
    for slug, text in entries.items():
        out_path = out_dir / f"{slug}.mp3"
        if out_path.exists() and not force:
            skipped += 1
            continue
        print(f"  → {slug}.mp3  ({text})")
        await synthesize(text, voice, out_path)
        generated += 1
    return generated, skipped


async def main() -> int:
    parser = argparse.ArgumentParser(description="Génère l'audio arabe du projet.")
    parser.add_argument("--force", action="store_true", help="régénère même si le fichier existe")
    parser.add_argument("--only", help="ne traiter qu'un dossier (ex : letters, words)")
    parser.add_argument("--list-voices", action="store_true", help="liste les voix arabes et quitte")
    args = parser.parse_args()

    try:
        import edge_tts  # noqa: F401
    except ImportError:
        print("Erreur : 'edge-tts' n'est pas installé.\n  pip install -r tools/requirements.txt", file=sys.stderr)
        return 1

    if args.list_voices:
        await list_voices()
        return 0

    manifests = find_manifests(args.only)
    if not manifests:
        print("Aucun manifeste trouvé sous assets/audio/*/manifest.json", file=sys.stderr)
        return 1

    total_gen, total_skip = 0, 0
    for m in manifests:
        g, s = await process(m, args.force)
        total_gen += g
        total_skip += s

    print(f"\nTerminé : {total_gen} générés, {total_skip} ignorés (déjà présents).")
    return 0


if __name__ == "__main__":
    raise SystemExit(asyncio.run(main()))
