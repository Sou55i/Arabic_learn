import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_progress.dart';
import '../data/repositories/content_repository.dart';

/// Dépôt de contenu (chargement des JSON).
final contentRepositoryProvider =
    Provider<ContentRepository>((ref) => const ContentRepository());

/// Chargement asynchrone du cours et de ses modules.
final courseProvider = FutureProvider<LoadedCourse>((ref) {
  return ref.watch(contentRepositoryProvider).loadCourse();
});

/// État de progression de l'utilisateur (en mémoire en Phase 0).
final userProgressProvider =
    NotifierProvider<UserProgressNotifier, UserProgress>(
  UserProgressNotifier.new,
);

class UserProgressNotifier extends Notifier<UserProgress> {
  @override
  UserProgress build() => const UserProgress();

  /// Marque une leçon comme terminée et attribue l'XP.
  void completeLesson(String lessonId, int xp) {
    state = state.completeLesson(lessonId, xp);
  }

  /// Retire un cœur (erreur). Ne descend pas sous zéro.
  void loseHeart() {
    if (state.hearts <= 0) return;
    state = state.copyWith(hearts: state.hearts - 1);
  }

  /// Recharge les cœurs au maximum (ex : nouveau jour, ou pub regardée).
  void refillHearts() {
    state = state.copyWith(hearts: UserProgress.maxHearts);
  }
}
