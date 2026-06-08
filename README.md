# Arabic Learn

Application mobile (type Duolingo) pour apprendre **l'arabe littéraire (fusha)** :
lecture de l'alphabet, vocabulaire et grammaire, par petites leçons ludiques.

> Cette application aide à débuter et à pratiquer régulièrement.
> Elle ne remplace pas un vrai cours avec un professeur.

## Stack

- **Flutter** (Dart) — Android d'abord, iOS ensuite.
- **Riverpod** pour la gestion d'état.
- Contenu pédagogique **piloté par des données** (`assets/content/*.json`).

## Documentation

- [`docs/ROADMAP.md`](docs/ROADMAP.md) — plan de projet, architecture, monétisation.
- [`docs/CURRICULUM.md`](docs/CURRICULUM.md) — programme pédagogique (alphabet → grammaire).

## Démarrer (Phase 0)

Ce dépôt contient le code applicatif (`lib/`), le contenu (`assets/`) et les
tests. Les dossiers de plateforme (Android/iOS) se génèrent en une commande.

Prérequis : [installer Flutter](https://docs.flutter.dev/get-started/install).

```bash
# 1. Générer les dossiers de plateforme (android/, ios/, etc.)
#    sans écraser lib/ ni pubspec.yaml :
flutter create .

# 2. Installer les dépendances
flutter pub get

# 3. Lancer sur un émulateur ou un appareil Android branché
flutter run

# 4. (optionnel) Lancer les tests
flutter test
```

## État d'avancement

- [x] **Phase 0** — Fondations : structure, thème, support RTL, modèles de
      données, chargement du contenu JSON, écran de parcours, moteur
      d'exercices (QCM, écoute, association, reconstruction), XP/streak/cœurs.
- [ ] **Phase 1** — Contenu complet de l'alphabet + audio.
- [ ] **Phase 2** — Comptes, persistance locale, synchronisation, notifications.
- [ ] **Phase 3** — Monétisation (abonnement + pubs).
- [ ] **Phase 4** — Modules de grammaire/vocabulaire, polish, publication.

## Structure

```
lib/
  app/         # thème, providers (Riverpod), widget racine
  core/        # (à venir) utilitaires
  data/
    models/        # Module, Lesson, Exercise, UserProgress
    repositories/  # chargement du contenu JSON
  features/
    onboarding/    # écran d'accueil
    home/          # le parcours de leçons
    lesson/        # moteur d'exercices
  shared/widgets/  # composants réutilisables
assets/content/    # leçons au format JSON (le contenu pédagogique)
```
