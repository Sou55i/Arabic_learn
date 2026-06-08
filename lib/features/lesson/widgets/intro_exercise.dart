import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../data/models/content_models.dart';
import '../../../shared/widgets/speaker_button.dart';

/// Exercice de présentation : on montre une notion, une lettre ou un mot,
/// sans rien à répondre. Si un audio est fourni, un bouton « écouter »
/// apparaît sous le terme.
class IntroExercise extends StatelessWidget {
  const IntroExercise({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final term = exercise.letter ?? exercise.word;
    // Une lettre seule s'affiche très grand ; un mot, un peu moins.
    final double size = exercise.letter != null ? 96 : 64;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (term != null) ...[
            Text(
              term,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabic(size: size, color: AppTheme.primary),
            ),
            if (exercise.audio != null) ...[
              const SizedBox(height: 12),
              SpeakerButton(audio: exercise.audio!),
            ],
            const SizedBox(height: 24),
          ] else
            const Icon(Icons.menu_book_rounded,
                size: 64, color: AppTheme.primary),
          const SizedBox(height: 8),
          Text(
            exercise.promptFr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, height: 1.5),
          ),
        ],
      ),
    );
  }
}
