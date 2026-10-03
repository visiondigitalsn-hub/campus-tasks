# APK de livraison signé

Un APK debug local a été construit pour l'émulateur Android ; aucun APK de livraison connecté au backend distant n'est déclaré produit. La signature de livraison utilise exclusivement une clé privée locale ; le build release refuse l'absence de key.properties. Le debug utilise la clé debug habituelle et autorise HTTP vers l'émulateur ; la livraison requiert HTTPS.

## Préparer la signature (une fois)

Dans un emplacement sécurisé hors du dépôt, exécuter le keytool du JDK :

```powershell
keytool -genkeypair -v -keystore C:/secure/campustasks-release.jks -alias campustasks -keyalg RSA -keysize 2048 -validity 10000
```

Choisir personnellement le mot de passe dans le terminal interactif. Conserver clé et mots de passe dans un stockage sécurisé sauvegardé. Ne jamais transmettre les secrets dans le chat, commit ou captures. Créer `mobile/android/key.properties` à partir de `.example`, avec storeFile absolu utilisant `/`. Ces fichiers sont ignorés par Git.

## Compiler et vérifier

```powershell
Set-Location mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=API_BASE_URL=https://api.votre-domaine/api/v1 --build-name=1.0.0 --build-number=1
```

Résultat attendu : `mobile/build/app/outputs/flutter-apk/app-release.apk`. Copier sous `campus-tasks-1.0.0.apk`. Vérifier la signature avec `apksigner verify --print-certs` (SDK Android) et noter le SHA-256 du fichier (`Get-FileHash`). Installer : `adb install chemin.apk`. Tester compte, matière, tâche, reconnexion et backend distant.

Pour une mise à jour, garder applicationId et la même clé, augmenter versionCode (`+2`, `--build-number=2`), puis `adb install -r nouvel.apk`. Ne pas désinstaller avant ce test : cela ne prouverait pas la mise à jour d'une installation existante. Vérifier conservation de session/données et nouveau numéro de version. Si la clé est perdue, une mise à jour compatible n'est plus possible avec une autre clé.

## GitHub Release

Après tests réels : créer une Release associée au tag v1.0.0, joindre l'APK signé, le SHA-256 et les notes `docs/RELEASE_NOTES.md`. Indiquer URL du backend, nouveautés, limitations et notice Android (autoriser l'installation de cette source, télécharger, installer). Ne pas joindre key.properties ou le keystore. Pour les versions ultérieures, garder les mêmes identifiants/signature et un numéro de build croissant.

Depuis la racine, le script PowerShell `scripts/build_release.ps1 -ApiBaseUrl https://api.votre-domaine/api/v1 -Version 1.0.0 -BuildNumber 1` regroupe les contrôles, la compilation et le calcul SHA-256. Il vérifie HTTPS et la présence de la configuration de signature.
