import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../data/models/content_models.dart';
import 'articulation_diagram.dart';

/// Tutoriel de prononciation : montre le schéma de l'appareil phonatoire avec
/// le point d'articulation de la lettre mis en surbrillance, plus une
/// explication et un bouton d'écoute. Aucune réponse attendue.
class ArticulationExercise extends ConsumerWidget {
  const ArticulationExercise({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (exercise.letter != null)
                Text(
                  exercise.letter!,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.arabic(size: 64, color: AppTheme.primary),
                ),
              if (exercise.audio != null) ...[
                const SizedBox(width: 16),
                _SpeakerButton(audio: exercise.audio!),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ArticulationDiagram(
            pointX: exercise.pointX,
            pointY: exercise.pointY,
            zoneLabel: exercise.zoneFr,
          ),
          const SizedBox(height: 16),
          Text(
            exercise.promptFr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _SpeakerButton extends ConsumerWidget {
  const _SpeakerButton({required this.audio});

  final String audio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton.filled(
      iconSize: 30,
      onPressed: () async {
        final played = await ref.read(audioPlayerProvider).play(audio);
        if (!played && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('🔊 Audio non disponible (lance tools/generate_audio.py).'),
            ),
          );
        }
      },
      icon: const Icon(Icons.volume_up_rounded),
    );
  }
}
