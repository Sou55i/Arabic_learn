import 'package:flutter/material.dart';

import '../features/onboarding/onboarding_screen.dart';
import 'theme.dart';

class ArabicLearnApp extends StatelessWidget {
  const ArabicLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arabic Learn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // L'UI principale est en français (LTR). Les widgets affichant de
      // l'arabe gèrent leur propre Directionality.rtl localement.
      home: const OnboardingScreen(),
    );
  }
}
