import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/content_models.dart';
import '../../../shared/widgets/speaker_button.dart';
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
                SpeakerButton(audio: exercise.audio!),
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
