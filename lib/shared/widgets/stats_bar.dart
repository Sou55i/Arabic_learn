import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Barre supérieure affichant streak, XP et cœurs (style "jeu").
class StatsBar extends StatelessWidget {
  const StatsBar({
    super.key,
    required this.xp,
    required this.streak,
    required this.hearts,
  });

  final int xp;
  final int streak;
  final int hearts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Stat(icon: Icons.local_fire_department, color: Colors.orange, value: '$streak'),
          _Stat(icon: Icons.star_rounded, color: AppTheme.accent, value: '$xp'),
          _Stat(icon: Icons.favorite, color: AppTheme.heart, value: '$hearts'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.color, required this.value});

  final IconData icon;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ],
    );
  }
}
