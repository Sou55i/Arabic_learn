import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

/// Bouton circulaire de lecture audio, réutilisable.
///
/// Joue l'asset `audio` ; si le fichier n'est pas encore généré
/// (voir `tools/generate_audio.py`), affiche un message de repli.
class SpeakerButton extends ConsumerWidget {
  const SpeakerButton({super.key, required this.audio, this.size = 30});

  final String audio;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton.filled(
      iconSize: size,
      onPressed: () async {
        final played = await ref.read(audioPlayerProvider).play(audio);
        if (!played && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '🔊 Audio non disponible (lance tools/generate_audio.py).'),
            ),
          );
        }
      },
      icon: const Icon(Icons.volume_up_rounded),
    );
  }
}
