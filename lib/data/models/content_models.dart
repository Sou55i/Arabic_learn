/// Modèles de données du contenu pédagogique.
///
/// Le contenu est piloté par des fichiers JSON (`assets/content/*.json`),
/// ce qui permet d'ajouter des leçons sans toucher au code.
library;

/// Un cours complet (ex : arabe littéraire).
class Course {
  const Course({
    required this.id,
    required this.titleFr,
    required this.titleAr,
    required this.languageCode,
  });

  final String id;
  final String titleFr;
  final String titleAr;
  final String languageCode;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        titleFr: json['title_fr'] as String,
        titleAr: json['title_ar'] as String,
        languageCode: json['language_code'] as String? ?? 'ar',
      );
}

/// Un module = un regroupement thématique de leçons.
class Module {
  const Module({
    required this.id,
    required this.titleFr,
    required this.titleAr,
    required this.level,
    required this.lessons,
  });

  final String id;
  final String titleFr;
  final String titleAr;
  final int level;
  final List<Lesson> lessons;

  /// Construit un module à partir d'un fichier de contenu complet
  /// (qui contient la clé `module` et la liste `lessons`).
  factory Module.fromContentFile(Map<String, dynamic> json) {
    final moduleJson = json['module'] as Map<String, dynamic>;
    final lessonsJson = (json['lessons'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return Module(
      id: moduleJson['id'] as String,
      titleFr: moduleJson['title_fr'] as String,
      titleAr: moduleJson['title_ar'] as String? ?? '',
      level: moduleJson['level'] as int? ?? 0,
      lessons: lessonsJson.map(Lesson.fromJson).toList(),
    );
  }
}

/// Une leçon = une micro-unité d'apprentissage avec ses exercices.
class Lesson {
  const Lesson({
    required this.id,
    required this.titleFr,
    required this.xp,
    required this.exercises,
    this.conceptFr,
  });

  final String id;
  final String titleFr;
  final int xp;
  final String? conceptFr;
  final List<Exercise> exercises;

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        titleFr: json['title_fr'] as String,
        xp: json['xp'] as int? ?? 10,
        conceptFr: json['concept_fr'] as String?,
        exercises: (json['exercises'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(Exercise.fromJson)
            .toList(),
      );
}

/// Type d'exercice supporté par le moteur.
enum ExerciseType {
  intro, // présentation d'une notion / lettre (pas de réponse)
  mcq, // choix multiple textuel
  listenChoose, // écoute un audio puis choisis
  translateChoose, // traduis en choisissant
  match, // associe des paires
  build, // reconstruis une phrase à partir de jetons
  unknown;

  static ExerciseType fromString(String raw) {
    switch (raw) {
      case 'intro_letter':
      case 'intro_rule':
        return ExerciseType.intro;
      case 'mcq':
        return ExerciseType.mcq;
      case 'listen_choose':
        return ExerciseType.listenChoose;
      case 'translate_choose':
        return ExerciseType.translateChoose;
      case 'match':
        return ExerciseType.match;
      case 'build':
        return ExerciseType.build;
      default:
        return ExerciseType.unknown;
    }
  }
}

/// Un exercice individuel.
class Exercise {
  const Exercise({
    required this.type,
    required this.promptFr,
    this.options = const [],
    this.answer,
    this.audio,
    this.letter,
    this.pairs = const [],
    this.tokens = const [],
    this.answerTokens = const [],
  });

  final ExerciseType type;
  final String promptFr;
  final List<String> options;
  final String? answer;
  final String? audio;
  final String? letter;
  final List<({String left, String right})> pairs;
  final List<String> tokens;
  final List<String> answerTokens;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final answerRaw = json['answer'];
    return Exercise(
      type: ExerciseType.fromString(json['type'] as String? ?? ''),
      promptFr: json['prompt_fr'] as String? ?? '',
      options:
          (json['options'] as List<dynamic>? ?? const []).cast<String>(),
      answer: answerRaw is String ? answerRaw : null,
      audio: json['audio'] as String?,
      letter: json['letter'] as String?,
      pairs: (json['pairs'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map((p) => (left: p['left'] as String, right: p['right'] as String))
          .toList(),
      tokens: (json['tokens'] as List<dynamic>? ?? const []).cast<String>(),
      answerTokens:
          answerRaw is List ? answerRaw.cast<String>() : const <String>[],
    );
  }
}
