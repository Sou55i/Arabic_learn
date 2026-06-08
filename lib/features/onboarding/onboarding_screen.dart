import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../home/home_screen.dart';

/// Écran d'accueil / onboarding.
///
/// On y assume honnêtement la promesse de l'app : un complément accessible
/// pour débuter, qui ne remplace pas un vrai cours avec un professeur.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Text(
                  'مَرحَبًا',
                  textDirection: TextDirection.rtl,
                  style: AppTheme.arabic(size: 56, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Apprends l\'arabe littéraire',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'Lecture, vocabulaire et grammaire, pas à pas.\n'
                'Quelques minutes par jour suffisent pour progresser.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppTheme.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cette application aide à débuter et à pratiquer '
                        'régulièrement. Elle ne remplace pas un vrai cours '
                        'avec un professeur.',
                        style: TextStyle(fontSize: 13.5, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Text('Commencer'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
