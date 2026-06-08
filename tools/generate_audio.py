#!/usr/bin/env python3
"""Génère les fichiers audio des lettres arabes à partir du manifeste.

Utilise `edge-tts` (Microsoft Edge TTS, gratuit, voix arabes natives de bonne
qualité). Lit `assets/audio/letters/manifest.json` et produit un `.mp3` par
entrée dans le même dossier.

Prérequis :
    pip install edge-tts

Utilisation :
    python tools/generate_audio.py            # génère ce qui manque
    python tools/generate_audio.py --force    # régénère tout
    python tools/generate_audio.py --list-voices   # voix arabes disponibles

Pour changer de voix, modifie le champ "voice" dans le manifeste, p. ex. :
    ar-SA-HamedNeural   (homme, Arabie saoudite)
    ar-EG-SalmaNeural   (femme, Égypte)
    ar-SA-ZariyahNeural (femme, Arabie saoudite)
"""

import argparse
import asyncio
import json
import sys
from pathlib import Path

LETTERS_DIR = Path(__file__).resolve().parent.parent / "assets" / "audio" / "letters"
MANIFEST = LETTERS_DIR / "manifest.json"


def load_manifest() -> dict:
    with MANIFEST.open(encoding="utf-8") as f:
        return json.load(f)


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


async def main() -> int:
    parser = argparse.ArgumentParser(description="Génère l'audio des lettres arabes.")
    parser.add_argument("--force", action="store_true", help="régénère même si le fichier existe")
    parser.add_argument("--list-voices", action="store_true", help="liste les voix arabes et quitte")
    args = parser.parse_args()

    try:
        import edge_tts  # noqa: F401
    except ImportError:
        print("Erreur : 'edge-tts' n'est pas installé.\n  pip install edge-tts", file=sys.stderr)
        return 1

    if args.list_voices:
        await list_voices()
        return 0

    manifest = load_manifest()
    voice = manifest.get("voice", "ar-SA-HamedNeural")
    entries: dict = manifest["entries"]

    generated, skipped = 0, 0
    for slug, text in entries.items():
        out_path = LETTERS_DIR / f"{slug}.mp3"
        if out_path.exists() and not args.force:
            skipped += 1
            continue
        print(f"  → {slug}.mp3  ({text})")
        await synthesize(text, voice, out_path)
        generated += 1

    print(f"\nTerminé : {generated} générés, {skipped} ignorés (déjà présents).")
    print(f"Voix utilisée : {voice}")
    return 0


if __name__ == "__main__":
    raise SystemExit(asyncio.run(main()))
