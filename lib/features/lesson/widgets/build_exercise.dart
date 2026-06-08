import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../data/models/content_models.dart';
import 'answer_contract.dart';

/// Exercice de reconstruction : assembler une phrase en tapant les jetons
/// (mots) dans le bon ordre. Les jetons arabes se lisent de droite à gauche.
class BuildExercise extends StatefulWidget {
  const BuildExercise({
    super.key,
    required this.exercise,
    required this.locked,
    required this.onAnswer,
  });

  final Exercise exercise;
  final bool locked;
  final AnswerCallback onAnswer;

  @override
  State<BuildExercise> createState() => _BuildExerciseState();
}

class _BuildExerciseState extends State<BuildExercise> {
  late final List<String> _bank;
  final List<String> _answer = [];

  @override
  void initState() {
    super.initState();
    _bank = [...widget.exercise.tokens]..shuffle();
  }

  void _add(String token) {
    if (widget.locked) return;
    setState(() {
      _bank.remove(token);
      _answer.add(token);
    });
    _report();
  }

  void _remove(int index) {
    if (widget.locked) return;
    setState(() {
      _bank.add(_answer.removeAt(index));
    });
    _report();
  }

  void _report() {
    final ready = _answer.isNotEmpty;
    final correct = listEquals(_answer, widget.exercise.answerTokens);
    widget.onAnswer((ready: ready, correct: correct));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.exercise.promptFr,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        // Zone de réponse (les mots arabes s'enchaînent en RTL).
        Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _answer.length; i++)
                  _Token(label: _answer[i], onTap: () => _remove(i)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Banque de jetons disponibles.
        Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final token in _bank)
                _Token(label: token, onTap: () => _add(token)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Token extends StatelessWidget {
  const _Token({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textDirection: TextDirection.rtl,
          style: AppTheme.arabic(size: 24),
        ),
      ),
    );
  }
}
