import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../data/models/content_models.dart';
import 'answer_contract.dart';

/// Exercice d'association : relier chaque élément de gauche (lettre arabe)
/// à son correspondant de droite (translittération).
class MatchExercise extends StatefulWidget {
  const MatchExercise({
    super.key,
    required this.exercise,
    required this.locked,
    required this.onAnswer,
  });

  final Exercise exercise;
  final bool locked;
  final AnswerCallback onAnswer;

  @override
  State<MatchExercise> createState() => _MatchExerciseState();
}

class _MatchExerciseState extends State<MatchExercise> {
  late final List<String> _lefts;
  late final List<String> _rights;

  /// Bonne réponse : left -> right attendu.
  late final Map<String, String> _solution;

  String? _selectedLeft;

  /// Associations faites par l'utilisateur : left -> right choisi.
  final Map<String, String> _matches = {};

  @override
  void initState() {
    super.initState();
    final pairs = widget.exercise.pairs;
    _solution = {for (final p in pairs) p.left: p.right};
    _lefts = pairs.map((p) => p.left).toList();
    _rights = pairs.map((p) => p.right).toList()..shuffle();
  }

  void _tapLeft(String left) {
    if (widget.locked || _matches.containsKey(left)) return;
    setState(() => _selectedLeft = (_selectedLeft == left) ? null : left);
  }

  void _tapRight(String right) {
    if (widget.locked || _selectedLeft == null) return;
    if (_matches.containsValue(right)) return;
    setState(() {
      _matches[_selectedLeft!] = right;
      _selectedLeft = null;
    });
    final ready = _matches.length == _lefts.length;
    final correct = _matches.entries.every((e) => _solution[e.key] == e.value);
    widget.onAnswer((ready: ready, correct: ready && correct));
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
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _column(_lefts, isLeft: true)),
              const SizedBox(width: 16),
              Expanded(child: _column(_rights, isLeft: false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _column(List<String> items, {required bool isLeft}) {
    return Column(
      children: [
        for (final item in items) ...[
          _MatchChip(
            label: item,
            arabic: isLeft,
            state: _chipState(item, isLeft: isLeft),
            onTap: () => isLeft ? _tapLeft(item) : _tapRight(item),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  _ChipState _chipState(String item, {required bool isLeft}) {
    final bool matched = isLeft
        ? _matches.containsKey(item)
        : _matches.containsValue(item);

    if (widget.locked && matched) {
      // Le "left" associé à cet item (directement si gauche, sinon en
      // remontant l'association qui pointe vers ce "right").
      final String left = isLeft
          ? item
          : _matches.entries.firstWhere((e) => e.value == item).key;
      final correct = _solution[left] == _matches[left];
      return correct ? _ChipState.correct : _ChipState.wrong;
    }
    if (matched) return _ChipState.matched;
    if (isLeft && _selectedLeft == item) return _ChipState.selected;
    return _ChipState.idle;
  }
}

enum _ChipState { idle, selected, matched, correct, wrong }

class _MatchChip extends StatelessWidget {
  const _MatchChip({
    required this.label,
    required this.arabic,
    required this.state,
    required this.onTap,
  });

  final String label;
  final bool arabic;
  final _ChipState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (Color border, Color fill, Color text) = switch (state) {
      _ChipState.idle => (const Color(0xFFE0E0E0), Colors.white, Colors.black87),
      _ChipState.selected => (AppTheme.primary, const Color(0xFFEFFCE0), Colors.black87),
      _ChipState.matched => (const Color(0xFFE0E0E0), AppTheme.surface, Colors.black38),
      _ChipState.correct => (AppTheme.primary, const Color(0xFFD7FFB8), Colors.black87),
      _ChipState.wrong => (AppTheme.heart, const Color(0xFFFFDFE0), Colors.black87),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: border, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: arabic
            ? Text(label,
                textDirection: TextDirection.rtl,
                style: AppTheme.arabic(size: 28, color: text))
            : Text(label,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: text)),
      ),
    );
  }
}
