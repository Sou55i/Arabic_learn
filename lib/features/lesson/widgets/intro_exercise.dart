import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../data/models/content_models.dart';

/// Exercice de présentation : on montre une notion ou une lettre,
/// sans rien à répondre.
class IntroExercise extends StatelessWidget {
  const IntroExercise({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (exercise.letter != null) ...[
            Text(
              exercise.letter!,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabic(size: 96, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
          ] else
            const Icon(Icons.menu_book_rounded,
                size: 64, color: AppTheme.primary),
          const SizedBox(height: 16),
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
