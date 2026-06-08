import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/models/content_models.dart';
import '../../shared/widgets/stats_bar.dart';
import '../lesson/lesson_screen.dart';

/// Écran principal : le parcours de leçons, organisé par modules/niveaux.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseProvider);
    final progress = ref.watch(userProgressProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            StatsBar(
              xp: progress.xpTotal,
              streak: progress.streak,
              hearts: progress.hearts,
            ),
            const Divider(height: 1),
            Expanded(
              child: courseAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Erreur de chargement du contenu : $e'),
                  ),
                ),
                data: (course) => _Path(modules: course.modules),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Path extends ConsumerWidget {
  const _Path({required this.modules});

  final List<Module> modules;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        for (final module in modules) ...[
          _ModuleHeader(module: module),
          for (var i = 0; i < module.lessons.length; i++)
            _LessonNode(
              lesson: module.lessons[i],
              done: progress.isLessonDone(module.lessons[i].id),
              // Une leçon est déverrouillée si c'est la 1re ou si la
              // précédente est terminée (progression linéaire).
              unlocked: i == 0 ||
                  progress.isLessonDone(module.lessons[i - 1].id),
              alignRight: i.isOdd,
            ),
        ],
        const SizedBox(height: 32),
        const _ComingSoon(),
      ],
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.module});

  final Module module;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Niveau ${module.level}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  module.titleFr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          if (module.titleAr.isNotEmpty)
            Text(
              module.titleAr,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabic(size: 22, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

/// Un "noeud" cliquable du parcours.
class _LessonNode extends ConsumerWidget {
  const _LessonNode({
    required this.lesson,
    required this.done,
    required this.unlocked,
    required this.alignRight,
  });

  final Lesson lesson;
  final bool done;
  final bool unlocked;
  final bool alignRight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color color = done
        ? AppTheme.accent
        : unlocked
            ? AppTheme.primary
            : AppTheme.locked;
    final IconData icon = done
        ? Icons.check_rounded
        : unlocked
            ? Icons.play_arrow_rounded
            : Icons.lock_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          children: [
            Material(
              color: color,
              shape: const CircleBorder(),
              elevation: unlocked ? 4 : 0,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: unlocked
                    ? () => _openLesson(context, ref)
                    : () => _showLocked(context),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Icon(icon, color: Colors.white, size: 34),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 140,
              child: Text(
                lesson.titleFr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: unlocked ? Colors.black87 : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLesson(BuildContext context, WidgetRef ref) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson)),
    );
    if (completed == true) {
      ref.read(userProgressProvider.notifier).completeLesson(lesson.id, lesson.xp);
    }
  }

  void _showLocked(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Termine la leçon précédente pour débloquer.')),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          'D\'autres leçons arrivent bientôt… 🌱',
          style: TextStyle(color: Colors.black45),
        ),
      ),
    );
  }
}
