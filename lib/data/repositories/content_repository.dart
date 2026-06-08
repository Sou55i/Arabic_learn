import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/content_models.dart';

/// Charge le contenu pédagogique depuis les fichiers JSON embarqués
/// (`assets/content/`).
///
/// Le fichier `index.json` décrit le cours et liste les fichiers de contenu
/// à charger. Chaque fichier de contenu fournit un module et ses leçons.
class ContentRepository {
  const ContentRepository();

  static const String _indexPath = 'assets/content/index.json';

  /// Charge le cours et tous ses modules, triés par niveau.
  Future<LoadedCourse> loadCourse() async {
    final indexRaw = await rootBundle.loadString(_indexPath);
    final indexJson = json.decode(indexRaw) as Map<String, dynamic>;

    final course =
        Course.fromJson(indexJson['course'] as Map<String, dynamic>);

    final files = (indexJson['content_files'] as List<dynamic>).cast<String>();
    final modules = <Module>[];
    for (final path in files) {
      final raw = await rootBundle.loadString(path);
      final fileJson = json.decode(raw) as Map<String, dynamic>;
      modules.add(Module.fromContentFile(fileJson));
    }

    modules.sort((a, b) => a.level.compareTo(b.level));
    return LoadedCourse(course: course, modules: modules);
  }
}

/// Résultat du chargement : le cours + ses modules.
class LoadedCourse {
  const LoadedCourse({required this.course, required this.modules});

  final Course course;
  final List<Module> modules;
}
