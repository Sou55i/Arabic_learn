import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../data/models/content_models.dart';
import 'answer_contract.dart';

/// Exercice à choix unique : QCM, écoute-et-choisis, traduis-et-choisis.
class ChoiceExercise extends StatefulWidget {
  const ChoiceExercise({
    super.key,
    required this.exercise,
    required this.locked,
    required this.onAnswer,
  });

  final Exercise exercise;
  final bool locked;
  final AnswerCallback onAnswer;

  @override
  State<ChoiceExercise> createState() => _ChoiceExerciseState();
}

class _ChoiceExerciseState extends State<ChoiceExercise> {
  String? _selected;

  void _select(String option) {
    if (widget.locked) return;
    setState(() => _selected = option);
    widget.onAnswer(
      (ready: true, correct: option == widget.exercise.answer),
    );
  }

  /// Heuristique simple : une option courte est probablement une lettre/mot
  /// arabe → on l'affiche en grand et en RTL.
  bool _looksArabic(String s) =>
      s.runes.any((r) => r >= 0x0600 && r <= 0x06FF);

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ex.type == ExerciseType.listenChoose) _AudioButton(audio: ex.audio),
        Text(
          ex.promptFr,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: ex.options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final option = ex.options[i];
              return _OptionTile(
                label: option,
                arabic: _looksArabic(option),
                state: _stateFor(option),
                onTap: () => _select(option),
              );
            },
          ),
        ),
      ],
    );
  }

  _OptionState _stateFor(String option) {
    if (!widget.locked) {
      return _selected == option ? _OptionState.selected : _OptionState.idle;
    }
    if (option == widget.exercise.answer) return _OptionState.correct;
    if (option == _selected) return _OptionState.wrong;
    return _OptionState.idle;
  }
}

enum _OptionState { idle, selected, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.arabic,
    required this.state,
    required this.onTap,
  });

  final String label;
  final bool arabic;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (Color border, Color fill) = switch (state) {
      _OptionState.idle => (const Color(0xFFE0E0E0), Colors.white),
      _OptionState.selected => (AppTheme.primary, const Color(0xFFEFFCE0)),
      _OptionState.correct => (AppTheme.primary, const Color(0xFFD7FFB8)),
      _OptionState.wrong => (AppTheme.heart, const Color(0xFFFFDFE0)),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: border, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: arabic
            ? Text(
                label,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppTheme.arabic(size: 30),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

/// Bouton de lecture audio. En Phase 0 il n'y a pas encore de fichiers son,
/// donc il informe simplement l'utilisateur (l'audio arrive en Phase 1).
class _AudioButton extends StatelessWidget {
  const _AudioButton({this.audio});

  final String? audio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 56),
            padding: const EdgeInsets.symmetric(horizontal: 22),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🔊 Audio à venir (Phase 1).')),
            );
          },
          icon: const Icon(Icons.volume_up_rounded, size: 28),
          label: const Text('Écouter'),
        ),
      ),
    );
  }
}
