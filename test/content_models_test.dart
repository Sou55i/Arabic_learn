import 'dart:convert';

import 'package:arabic_learn/data/models/content_models.dart';
import 'package:arabic_learn/data/models/user_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Module.fromContentFile', () {
    test('parse un module avec ses leçons et exercices', () {
      final raw = json.decode('''
      {
        "module": {"id": "m1", "title_fr": "Alphabet", "title_ar": "الحروف", "level": 0},
        "lessons": [
          {
            "id": "l1", "title_fr": "Lettres", "xp": 10,
            "exercises": [
              {"type": "intro_letter", "letter": "ب", "prompt_fr": "Voici bâ’"},
              {"type": "mcq", "prompt_fr": "Quelle lettre ?", "options": ["ب","ت"], "answer": "ت"},
              {"type": "build", "prompt_fr": "Assemble", "tokens": ["a","b"], "answer": ["a","b"]}
            ]
          }
        ]
      }
      ''') as Map<String, dynamic>;

      final module = Module.fromContentFile(raw);

      expect(module.id, 'm1');
      expect(module.level, 0);
      expect(module.lessons, hasLength(1));

      final lesson = module.lessons.first;
      expect(lesson.exercises, hasLength(3));
      expect(lesson.exercises[0].type, ExerciseType.intro);
      expect(lesson.exercises[0].letter, 'ب');
      expect(lesson.exercises[1].type, ExerciseType.mcq);
      expect(lesson.exercises[1].answer, 'ت');
      expect(lesson.exercises[2].type, ExerciseType.build);
      expect(lesson.exercises[2].answerTokens, ['a', 'b']);
    });
  });

  group('UserProgress', () {
    test('compléter une leçon ajoute l\'XP une seule fois', () {
      var p = const UserProgress();
      p = p.completeLesson('l1', 10);
      expect(p.xpTotal, 10);
      expect(p.isLessonDone('l1'), isTrue);

      // Recompléter ne double pas l'XP.
      p = p.completeLesson('l1', 10);
      expect(p.xpTotal, 10);
    });

    test('perdre un cœur ne descend pas sous zéro', () {
      var p = const UserProgress(hearts: 1);
      p = p.copyWith(hearts: p.hearts - 1);
      expect(p.hearts, 0);
    });
  });
}
