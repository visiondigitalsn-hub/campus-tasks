# Test sur un téléphone Android

L’APK pour émulateur utilise `10.0.2.2`, adresse inaccessible depuis un téléphone physique. Pour un test local, le téléphone et le PC doivent utiliser le même réseau Wi-Fi.

Adresse Wi-Fi observée sur ce PC : `192.168.1.146`. Elle peut changer après une reconnexion.

Le 3 octobre 2026, Docker Desktop 29.8.1 a démarré PostgreSQL 17.11 et l’API 1.0.0. Le endpoint de santé a répondu `UP`. Une inscription de test, une lecture authentifiée des matières et une déconnexion ont réussi sur PostgreSQL. L’accès depuis le téléphone reste à vérifier, ainsi que l’autorisation du pare-feu Windows.

L’APK debug compilé pour cette adresse a pour SHA256 : `e5a1114dd3ebc4e4e8e08a81dcbee544ecbb08224d1c0d6f01ff6782ac6ba4ed`.

Depuis la racine du projet, avec Docker Desktop démarré et `deployment/.env` configuré :

```powershell
$env:LAN_IP = '192.168.1.146'
docker compose --env-file deployment/.env -f deployment/compose.yaml -f deployment/compose.phone.yaml up -d --build
```

La base PostgreSQL reste privée. Le port 8080 de l’API est lié à l’adresse Wi-Fi du PC. Si Windows bloque l’accès, autoriser ce port uniquement pour le réseau privé et le sous-réseau local.

Pour accélérer le démarrage local avec un JAR déjà compilé, on peut construire `docker build -f backend/Dockerfile.local -t campustasks-api:1.0.0 backend`, puis utiliser `up -d --no-build` avec la configuration téléphone. Le Dockerfile principal reconstruit le JAR depuis les sources pour la publication.

Ouvrir sur le téléphone `http://192.168.1.146:8080/api/v1/health` pour vérifier la connexion, puis installer l’APK de test compilé avec cette adresse :

```powershell
cd mobile
flutter build apk --debug --dart-define=API_BASE_URL=http://192.168.1.146:8080/api/v1
```

Cette connexion HTTP est destinée aux essais locaux avec des comptes de test. Pour utiliser l’application hors du Wi-Fi du PC, il faut déployer l’API sur un serveur HTTPS puis compiler un APK avec son URL publique.
