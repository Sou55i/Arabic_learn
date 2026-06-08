import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/models/content_models.dart';
import 'widgets/articulation_exercise.dart';
import 'widgets/build_exercise.dart';
import 'widgets/choice_exercise.dart';
import 'widgets/intro_exercise.dart';
import 'widgets/match_exercise.dart';

/// Lecteur de leçon : enchaîne les exercices, donne le feedback,
/// puis affiche un écran de fin. Renvoie `true` si la leçon est terminée.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _index = 0;
  bool _checked = false;

  /// La réponse courante est-elle complète (prête à valider) ?
  bool _ready = false;

  /// La réponse courante est-elle correcte ? (calculée par le widget enfant)
  bool _correctPending = false;

  Exercise get _current => widget.lesson.exercises[_index];
  bool get _isLast => _index >= widget.lesson.exercises.length - 1;
  bool get _isIntro => _current.type.isInformational;

  void _onAnswer(({bool ready, bool correct}) result) {
    if (_checked) return;
    setState(() {
      _ready = result.ready;
      _correctPending = result.correct;
    });
  }

  void _check() => setState(() => _checked = true);

  void _next() {
    if (_isLast) {
      _showCompletion();
      return;
    }
    setState(() {
      _index++;
      _checked = false;
      _ready = false;
      _correctPending = false;
    });
  }

  void _showCompletion() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CompletionDialog(xp: widget.lesson.xp),
    ).then((_) {
      if (mounted) Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.lesson.exercises.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (_index + 1) / total,
            minHeight: 10,
            backgroundColor: AppTheme.surface,
            color: AppTheme.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildExercise(),
              ),
            ),
            _Footer(
              checked: _checked,
              isCorrect: _correctPending,
              isIntro: _isIntro,
              primary: _primaryButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton() {
    if (_isIntro) {
      return FilledButton(onPressed: _next, child: const Text('Continuer'));
    }
    if (_checked) {
      return FilledButton(
        onPressed: _next,
        child: Text(_isLast ? 'Terminer' : 'Continuer'),
      );
    }
    return FilledButton(
      onPressed: _ready ? _check : null,
      child: const Text('Vérifier'),
    );
  }

  Widget _buildExercise() {
    // La clé force la reconstruction de l'état interne à chaque exercice.
    final key = ValueKey(_index);
    return switch (_current.type) {
      ExerciseType.intro => IntroExercise(key: key, exercise: _current),
      ExerciseType.articulation =>
        ArticulationExercise(key: key, exercise: _current),
      ExerciseType.mcq ||
      ExerciseType.listenChoose ||
      ExerciseType.translateChoose =>
        ChoiceExercise(
          key: key,
          exercise: _current,
          locked: _checked,
          onAnswer: _onAnswer,
        ),
      ExerciseType.match => MatchExercise(
          key: key,
          exercise: _current,
          locked: _checked,
          onAnswer: _onAnswer,
        ),
      ExerciseType.build => BuildExercise(
          key: key,
          exercise: _current,
          locked: _checked,
          onAnswer: _onAnswer,
        ),
      ExerciseType.unknown => const Center(
          child: Text('Type d\'exercice non supporté.'),
        ),
    };
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.checked,
    required this.isCorrect,
    required this.isIntro,
    required this.primary,
  });

  final bool checked;
  final bool isCorrect;
  final bool isIntro;
  final Widget primary;

  @override
  Widget build(BuildContext context) {
    final Color? bg = !checked || isIntro
        ? null
        : isCorrect
            ? const Color(0xFFD7FFB8)
            : const Color(0xFFFFDFE0);

    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (checked && !isIntro)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? AppTheme.primaryDark : AppTheme.heart,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCorrect ? 'Bien joué !' : 'Pas tout à fait.',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isCorrect ? AppTheme.primaryDark : AppTheme.heart,
                    ),
                  ),
                ],
              ),
            ),
          primary,
        ],
      ),
    );
  }
}

class _CompletionDialog extends StatelessWidget {
  const _CompletionDialog({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            const Text(
              'Leçon terminée !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '+$xp XP',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continuer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
