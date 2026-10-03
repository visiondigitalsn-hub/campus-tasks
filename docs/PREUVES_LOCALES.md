# Résultats locaux — 3 octobre 2026

Ce relevé concerne les commandes exécutées sur le poste du projet. Il ne constitue pas une preuve de publication, de fonctionnement Docker, de connexion distante ou d'installation sur téléphone.

## Backend

Commande : `mvn -B verify` dans backend. Résultat Maven réellement obtenu :

```text
Tests run: 3, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS
```

Les tests HTTP/Security/JPA s'exécutent sur H2 mode PostgreSQL. Ils couvrent l'isolation entre comptes, le CRUD et les règles de suppression, les retards, la validation, la révocation, la reconnexion, les filtres/tri et le nom/identifiant des matières dans les réponses de tâches. Les traces Surefire sont présentes sous backend/target/surefire-reports ; leurs sorties ne sont pas publiées automatiquement dans Git.

JAR exécutable construit : `backend/target/campus-tasks-api-1.0.0.jar`.
SHA-256 : `5b94ac0ae5edffa22efec0e4a95ce4bded2188ed26782e5e1c940a000702fc98`.

## Flutter

`flutter analyze` : `No issues found!`.
`flutter test` : `+5: All tests passed!`.

Un test d'écran et quatre tests du client API/session : stockage/restauration, Bearer et 401, logout en panne serveur, messages UTF-8 et réponse 204. Les appels sont simulés dans les tests mobiles ; aucun téléphone distant n'a été utilisé.

## Android

Commande : `flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1`.
Résultat réel : `BUILD SUCCESSFUL`, puis `Built build/app/outputs/flutter-apk/app-debug.apk`, code de sortie 0.

APK de test : `mobile/build/app/outputs/flutter-apk/app-debug.apk`.
Taille : 152987593 octets.
SHA-256 : `d59a82c3043c96feb8fa0fc7bb7e3dde4307cfa91e381376beeeb98d1c29eab8`.

`apksigner verify --print-certs` a validé la signature debug Android (CN=Android Debug). L'empreinte SHA-256 du certificat est `6c1822af0a4dcd1a9915fcf9525dcdff56bf1b758bda80c86e899770d47bae0c`. `aapt dump badging` confirme le package `sn.campustasks.campus_tasks`, versionName 1.0.0, versionCode 1, SDK minimum 24, SDK cible 36, le nom CampusTasks et la permission INTERNET. L'URL vise le PC depuis un émulateur ; l'API doit être démarrée sur ce PC. Une clé de livraison, l'URL HTTPS réelle et les essais sur appareil restent nécessaires pour la Release.

## Documents et configuration

Rapport PDF : 10 pages, vérifiées par extraction et rendu visuel, sans débordement observé. Le source LaTeX est conservé ; le compilateur intégré a retourné un problème d'environnement (`Unable to find standard directories for platform`). Le PDF a été généré avec ReportLab et ses pages relues.

Les six fichiers YAML (Compose, workflows et pubspec), les manifestes XML et le script PowerShell de livraison ont passé leurs contrôles syntaxiques. `scripts/check_versions.py` confirme la version commune 1.0.0.

## À vérifier séparément

PostgreSQL réel, Docker et persistance après redémarrage ; exécution GitHub Actions ; publication d'image et déploiement HTTPS ; APK de livraison signé ; installation et mise à jour sur téléphone ; sauvegarde/restauration en environnement isolé. Les procédures figurent dans docs/DEPLOIEMENT.md, docs/APK.md et docs/VERIFICATIONS.md.
