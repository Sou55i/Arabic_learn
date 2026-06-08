/// Progression de l'utilisateur (XP, streak, leçons terminées, cœurs).
///
/// En Phase 0, cet état vit uniquement en mémoire. La persistance locale
/// (Isar/Drift) et la synchronisation cloud arriveront en Phase 2.
class UserProgress {
  const UserProgress({
    this.xpTotal = 0,
    this.streak = 0,
    this.hearts = 5,
    this.completedLessonIds = const {},
  });

  static const int maxHearts = 5;

  final int xpTotal;
  final int streak;
  final int hearts;
  final Set<String> completedLessonIds;

  bool isLessonDone(String lessonId) => completedLessonIds.contains(lessonId);

  UserProgress completeLesson(String lessonId, int xp) {
    if (isLessonDone(lessonId)) return this;
    return copyWith(
      xpTotal: xpTotal + xp,
      completedLessonIds: {...completedLessonIds, lessonId},
    );
  }

  UserProgress copyWith({
    int? xpTotal,
    int? streak,
    int? hearts,
    Set<String>? completedLessonIds,
  }) {
    return UserProgress(
      xpTotal: xpTotal ?? this.xpTotal,
      streak: streak ?? this.streak,
      hearts: hearts ?? this.hearts,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
    );
  }
}
