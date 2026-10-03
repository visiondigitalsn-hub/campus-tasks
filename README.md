# CampusTasks — projet examen L3

Application de gestion des matières et des tâches étudiantes. Version commune prévue : **1.0.0** (mobile **1.0.0+1**, contrat **/api/v1**).

Le code est réalisé à partir du cahier des charges. Les cours du professeur ne sont pas encore disponibles : les conventions pourront être adaptées après leur réception. Aucune publication distante ou preuve sur téléphone n'est déclarée réalisée.

## Structure et fonctionnement

- `backend/` : Java 21, Spring Boot 4.0, Web MVC, Security, JPA, DTO, migrations Flyway.
- `mobile/` : Flutter/Dart, écrans comptes, dashboard, matières et tâches, stockage sécurisé du jeton.
- `deployment/` : Compose PostgreSQL + API, développement local ou production HTTPS via Caddy.
- `docs/` : API, modèle de données, guide pédagogique, déploiement, signature APK et vérifications.
- `.github/workflows/` : contrôles PR et publication Docker sur tag.

Flux : Flutter → JSON HTTP/HTTPS → contrôleur → service → repository JPA → PostgreSQL.

Chaque requête utilise l'identifiant de l'étudiant tiré du jeton authentifié. Une matière contenant des tâches ne peut pas être supprimée (409). Une tâche terminée n'est jamais comptée en retard. La date limite est une date civile ; les indicateurs utilisent UTC, identique à Dakar.

## Prérequis

Java JDK 21 ou compatible, Maven 3.9+, Flutter 3.41.9 / Dart 3.11+, SDK Android et Docker avec Compose v2. L'image de production utilise Java 21. Ne pas confondre Docker installé et moteur Docker démarré.

## Démarrer localement avec Docker (PowerShell)

Depuis la racine :

```powershell
Copy-Item deployment/.env.example deployment/.env
# Modifier deployment/.env : mot de passe aléatoire, API_IMAGE=campustasks-api
Set-Location deployment
docker compose --env-file .env -f compose.yaml -f compose.dev.yaml up -d --build
Invoke-RestMethod http://localhost:8080/api/v1/health
```

La DB n'a aucun port publié. L'API de développement est disponible sur le PC à `localhost:8080`. Pour un vrai téléphone, utiliser le serveur HTTPS déployé ; l'adresse 10.0.2.2 désigne le PC uniquement depuis l'émulateur Android.

```powershell
Set-Location ../mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

Pour démarrer Java directement contre une PostgreSQL déjà disponible : définir DB_PASSWORD, DB_USER et DB_URL, puis `mvn spring-boot:run` dans `backend`.

## Vérifier

```powershell
Set-Location backend
mvn verify
Set-Location ../mobile
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Les tests backend locaux utilisent H2 en mode PostgreSQL et les vraies couches HTTP/Security/JPA. La CI est configurée pour les exécuter contre PostgreSQL 17 ; son exécution distante reste à effectuer. Ils ne remplacent pas les vérifications PostgreSQL, Docker et appareil physique. Voir [état des vérifications](docs/VERIFICATIONS.md).

## Livrer

Suivre [déploiement](docs/DEPLOIEMENT.md), [APK signé](docs/APK.md), [versions et travail du groupe](docs/VERSIONS.md). La publication nécessite le dépôt GitHub, les identifiants Docker Hub et un serveur/domaine autorisés par l'enseignant. Garder les secrets hors du dépôt.

## Pour comprendre et présenter

Commencer par [guide pédagogique](docs/COMPRENDRE.md), puis [API](docs/API.md) et [schéma](docs/ARCHITECTURE.md). Le [rapport PDF de 10 pages](output/pdf/CampusTasks-rapport.pdf) (source : [rapport.tex](docs/rapport.tex)) est une version de travail à compléter avec les membres du groupe, captures et résultats réels. Le [scénario de soutenance](docs/DEMO.md) dure 15 minutes.

## Livrables locaux vérifiés

Le JAR exécutable est dans `backend/target/campus-tasks-api-1.0.0.jar`. L'APK de **test pour émulateur** est dans `mobile/build/app/outputs/flutter-apk/app-debug.apk` ; il utilise `http://10.0.2.2:8080/api/v1` et nécessite un backend lancé sur le PC. Il ne remplace pas l'APK de livraison HTTPS signé avec la clé du groupe. Les binaires de compilation sont ignorés par Git et peuvent être reconstruits.

Voir `docs/PREUVES_LOCALES.md` pour les résultats et empreintes des fichiers construits. Les étapes distantes et les essais sur téléphone demeurent distincts.
