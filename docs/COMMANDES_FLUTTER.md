# Mémo des commandes Flutter — Arabic Learn

Toutes les commandes utiles pour développer, lancer et publier l'app.
À lancer depuis la racine du projet.

---

## 1. Première installation (une seule fois)

```bash
# Générer les dossiers de plateforme (android/, ios/, web/, linux/...)
# Ne touche pas à lib/, pubspec.yaml ni assets/.
flutter create .

# Installer les dépendances du projet
flutter pub get

# Vérifier que l'environnement est complet (SDK, Android, etc.)
flutter doctor
```

---

## 2. Lancer l'app

```bash
# Aperçu rapide dans le navigateur (le plus simple)
flutter run -d chrome

# Sur Linux desktop (peut nécessiter des paquets gstreamer pour l'audio)
flutter run -d linux

# Sur un appareil/émulateur Android (la cible finale)
flutter run

# Lister les appareils disponibles
flutter devices

# Choisir explicitement un appareil
flutter run -d <device_id>
```

### Raccourcis pendant que l'app tourne
- `r`  → hot reload (recharge le code instantanément)
- `R`  → hot restart (redémarre l'app)
- `q`  → quitter
- `p`  → afficher la grille de debug
- `o`  → basculer Android / iOS pour le rendu

---

## 3. Émulateur Android

```bash
# Lister les émulateurs installés
flutter emulators

# Démarrer un émulateur
flutter emulators --launch <emulator_id>

# Créer un émulateur : passe par Android Studio > Device Manager
```

---

## 4. Audio des lettres

```bash
# Installer l'outil de génération (une fois)
pip install -r tools/requirements.txt

# Générer tous les fichiers MP3 manquants
python tools/generate_audio.py

# Tout régénérer (ex : après changement de voix)
python tools/generate_audio.py --force

# Voir les voix arabes disponibles
python tools/generate_audio.py --list-voices
```

---

## 5. Tests & qualité du code

```bash
# Lancer les tests unitaires
flutter test

# Lancer un seul fichier de test
flutter test test/content_models_test.dart

# Analyser le code (lint, erreurs statiques)
flutter analyze

# Formater automatiquement le code Dart
dart format .
```

---

## 6. Dépendances

```bash
# Installer / mettre à jour selon pubspec.yaml
flutter pub get

# Voir les paquets qui ont des versions plus récentes
flutter pub outdated

# Mettre à jour dans les limites autorisées par pubspec.yaml
flutter pub upgrade

# Ajouter un paquet
flutter pub add <nom_du_paquet>
```

---

## 7. Nettoyage (en cas de problème de build)

```bash
# Supprimer les artefacts de build et le cache
flutter clean

# Puis réinstaller
flutter pub get
```

---

## 8. Compiler pour la publication

```bash
# APK Android (test/installation directe)
flutter build apk --release

# App Bundle Android (format requis par le Google Play Store)
flutter build appbundle --release

# Version web
flutter build web --release

# Le résultat se trouve dans build/app/outputs/ (Android)
# ou build/web/ (web).
```

---

## 9. Mises à jour de Flutter

```bash
# Mettre à jour Flutter lui-même
flutter upgrade

# Voir la version installée
flutter --version
```

---

## Ordre recommandé pour démarrer

```bash
flutter create .          # 1. générer les plateformes
flutter pub get           # 2. dépendances
flutter run -d chrome     # 3. aperçu rapide
```
