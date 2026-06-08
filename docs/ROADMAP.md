# Arabic Learn — Plan de projet

> Application mobile type Duolingo pour apprendre **l'arabe littéraire (fusha)**.
> Stack : **Flutter** (Android d'abord, iOS ensuite). Objectif : application **monétisable**.

---

## 1. Vision & positionnement

**Le problème marché :** Duolingo ne propose PAS l'arabe comme langue *cible* pour les
francophones et anglophones. Les apps existantes (Memrise, Mondly, Busuu) le traitent
en surface. Il y a donc un vrai créneau pour une app **dédiée, sérieuse et bien pensée**
sur l'arabe.

**Notre angle :**
- Se concentrer sur **un seul produit excellent** plutôt que 30 langues moyennes.
- Très bien gérer les spécificités de l'arabe que les concurrents bâclent :
  - écriture **droite-à-gauche (RTL)**,
  - lettres qui **changent de forme** selon la position (isolée / initiale / médiane / finale),
  - **voyelles courtes (harakat)** : fatha, kasra, damma, sukun, shadda, tanwin,
  - prononciation des lettres « difficiles » (ع ح خ ق ض ظ ط) avec audio natif.
- Pédagogie progressive : **lire l'alphabet → mots → phrases simples → grammaire de base**.

**Public cible initial :**
- Francophones/anglophones débutants (grand public).
- Personnes voulant lire le Coran / textes classiques (segment fort et engagé).
- Diaspora arabe de 2e/3e génération voulant (re)apprendre.

---

## 2. Périmètre du MVP (V1)

Garder le MVP **petit mais fini**. Objectif : une boucle d'apprentissage complète sur
un seul domaine bien fait.

**Module 1 — L'alphabet arabe** (le meilleur point de départ) :
1. Reconnaissance des 28 lettres (forme isolée).
2. Le son de chaque lettre (audio).
3. Les 4 formes selon la position dans le mot.
4. Les voyelles courtes (harakat).
5. Lecture de premiers mots simples.

**Mécaniques de jeu indispensables (le « feel » Duolingo) :**
- Parcours de leçons (skill tree / chemin linéaire).
- Types d'exercices : QCM, association image/son ↔ lettre, écoute → choix,
  reconstruction de mot, écriture/traçage de lettre (plus tard).
- **XP** (points d'expérience) par leçon.
- **Streak** (jours consécutifs) + objectif quotidien.
- **Cœurs / vies** (limite d'erreurs → levier de monétisation).
- Barre de progression + écran de fin de leçon célébratoire.
- Notifications de rappel quotidien.

**Hors périmètre V1 (à garder pour plus tard) :**
- Reconnaissance vocale (parler), classements/ligues, mode hors-ligne complet,
  contenu social, dialectes, iOS.

---

## 3. Architecture technique

### Stack
- **Frontend :** Flutter (Dart). UI animée, excellent support RTL via `Directionality`.
- **State management :** Riverpod (recommandé) ou Bloc.
- **Stockage local :** Isar ou Drift (SQLite) — progression et contenu en cache.
- **Backend (V1 minimal) :** le contenu des leçons peut être embarqué en JSON local
  au début (pas besoin de serveur pour lancer). Backend ajouté quand on a des comptes.
- **Backend (V2) :** Firebase (Auth + Firestore + Storage pour l'audio) ou Supabase.
  Firebase est le plus rapide pour démarrer et gère bien l'analytics + notifications.
- **Audio :** fichiers MP3 par lettre/mot, voix native (à enregistrer ou licencier).

### Structure de projet (proposée)
```
lib/
  main.dart
  app/                 # config, thème, routing
  core/                # utils, constantes, helpers RTL
  data/
    models/            # Lesson, Exercise, Letter, UserProgress
    repositories/      # accès contenu + progression
    sources/           # JSON local, plus tard API
  features/
    onboarding/
    home/              # le parcours / skill tree
    lesson/            # moteur d'exercices
    profile/           # XP, streak, stats
    paywall/           # écran abonnement
  shared/widgets/      # boutons, cartes leçon, barre progression
assets/
  content/             # JSON des leçons
  audio/               # sons des lettres/mots
  images/
```

### Modèle de données (cœur du système)
```
Course   { id, langue, titre, modules[] }
Module   { id, titre, lessons[] }
Lesson   { id, titre, type, exercises[], xp }
Exercise { id, type(qcm|listen|match|build), prompt, options[],
           answer, audioRef, imageRef }
Letter   { char, nom, translit, son, formes{iso,ini,med,fin}, audioRef }

UserProgress { userId, lessonsDone[], xpTotal, streak, lastActive, hearts }
```

Le contenu (Course/Module/Lesson/Exercise) est **piloté par des données** (JSON),
pas codé en dur. Ça permet d'ajouter des leçons sans toucher au code.

---

## 4. Spécificités arabe à gérer dès le départ

- **RTL global :** envelopper l'UI arabe dans `Directionality(textDirection: rtl)`.
  Attention au mélange français (LTR) / arabe (RTL) dans un même écran.
- **Police :** utiliser une police arabe lisible et pédagogique
  (ex : *Amiri*, *Noto Naskh Arabic*, *Lateef*). Taille généreuse pour débutants.
- **Harakat :** pouvoir afficher les mots **avec et sans** voyelles courtes
  (les débutants ont besoin des harakat, les avancés non).
- **Formes des lettres :** stocker les 4 formes ; le rendu se fait automatiquement
  par le moteur de texte, mais pour l'enseignement on montre chaque forme isolément.
- **Audio natif obligatoire :** certaines lettres n'ont pas d'équivalent FR/EN.

---

## 5. Modèle de monétisation

Modèle recommandé : **Freemium + Abonnement** (c'est le modèle de Duolingo et le plus
rentable sur l'éducation).

| Niveau | Contenu | Prix indicatif |
|---|---|---|
| **Gratuit** | Accès aux 1ers modules, pubs, cœurs limités | 0 € |
| **Premium (abo)** | Tout le contenu, sans pub, cœurs illimités, mode hors-ligne | 4,99–9,99 €/mois ou ~40 €/an |
| **À vie** (option) | Achat unique | ~80–120 € |

**Leviers complémentaires :**
- **Pubs** (AdMob) pour les utilisateurs gratuits — entre les leçons, ou « regarder
  une pub pour récupérer un cœur ».
- **Cœurs / vies** : frustration légère → conversion vers premium.
- **Essai gratuit** de 7 jours pour l'abonnement.

**Outils :** [RevenueCat](https://www.revenuecat.com) pour gérer les abonnements
(simplifie énormément les achats in-app Google Play / App Store). AdMob pour les pubs.

> ⚠️ **Réalité business :** la monétisation arrive APRÈS le volume d'utilisateurs.
> Compter ~1 à 5 % de conversion gratuit→payant. Le nerf de la guerre = acquisition
> + rétention (d'où l'importance du streak et des notifications).

---

## 6. Roadmap par phases

### Phase 0 — Fondations (semaine 1)
- [ ] Initialiser le projet Flutter + structure de dossiers.
- [ ] Thème, navigation, support RTL, polices arabes.
- [ ] Modèles de données + chargement de contenu JSON local.

### Phase 1 — MVP jouable (semaines 2–4)
- [ ] Écran « parcours » (chemin de leçons).
- [ ] Moteur d'exercices (QCM, écoute, association).
- [ ] Module 1 complet : l'alphabet (28 lettres + harakat).
- [ ] XP, streak, cœurs, écran de fin de leçon.
- [ ] Audio des lettres.

### Phase 2 — Comptes & persistance (semaines 5–6)
- [ ] Auth (Firebase) + synchronisation de la progression.
- [ ] Profil, statistiques, objectif quotidien.
- [ ] Notifications de rappel.

### Phase 3 — Monétisation (semaines 7–8)
- [ ] Intégration RevenueCat (abonnement) + paywall.
- [ ] AdMob pour les gratuits.
- [ ] Verrouillage du contenu premium.

### Phase 4 — Contenu & lancement (semaines 9+)
- [ ] Modules 2+ (vocabulaire thématique, phrases, grammaire de base).
- [ ] Polish UI/UX, animations, sons de récompense.
- [ ] Tests, build release, publication Google Play.
- [ ] iOS (même code Flutter).

---

## 7. Coûts & prérequis (vue d'ensemble)

| Poste | Coût |
|---|---|
| Compte développeur Google Play | 25 $ (unique) |
| Compte développeur Apple (si iOS) | 99 $/an |
| Firebase / Supabase | Gratuit au début, payant à l'échelle |
| RevenueCat | Gratuit jusqu'à un certain CA |
| Enregistrement audio (voix native) | variable (ou s'enregistrer soi-même) |
| **Le plus précieux : le temps de création de contenu** | élevé |

---

## 8. Risques & comment les gérer

| Risque | Mitigation |
|---|---|
| Contenu pédagogique faible | Faire valider le curriculum par un arabophone/prof. |
| Rétention faible | Soigner streak, notifications, leçons courtes (<5 min). |
| Peu de conversions payantes | Bien doser le « gratuit » : assez pour accrocher, pas trop. |
| Concurrence qui se réveille | Avancer vite sur le MVP, viser la qualité arabe. |
| RTL/affichage cassé | Le tester dès la Phase 0, pas à la fin. |

---

## 9. Prochaine étape

Une fois ce plan validé, on attaque la **Phase 0** : initialiser le projet Flutter
avec la structure ci-dessus, le thème, le support RTL et un premier écran de parcours.
