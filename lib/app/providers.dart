import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio_player_service.dart';
import '../data/models/user_progress.dart';
import '../data/repositories/content_repository.dart';

/// Dépôt de contenu (chargement des JSON).
final contentRepositoryProvider =
    Provider<ContentRepository>((ref) => const ContentRepository());

/// Service audio partagé (libéré automatiquement à la fin de vie du provider).
final audioPlayerProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

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
