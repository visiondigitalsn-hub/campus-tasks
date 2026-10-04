# Livrables Docker Hub et backend Render

Livraison vérifiée le 4 octobre 2026.

## Liens à transmettre au professeur

- Image Docker Hub : https://hub.docker.com/r/dvisn/campus-tasks-api/tags
- Référence versionnée : `docker.io/dvisn/campus-tasks-api:1.0.0`
- Backend HTTPS : https://campus-tasks-api-4k21.onrender.com
- Contrôle de santé public : https://campus-tasks-api-4k21.onrender.com/api/v1/health
- Code source et configuration : https://github.com/visiondigitalsn-hub/campus-tasks

L’URL racine n’est pas une page web : les routes de l’API commencent par `/api/v1`. Utiliser le contrôle de santé pour vérifier le serveur dans un navigateur.

## Image livrée

L’image est publique, compatible Linux amd64 et exécutée par l’utilisateur non root `campus`. Le JAR a été construit et vérifié par Maven avant la construction avec `backend/Dockerfile.local`. Le Dockerfile principal permet également de reconstruire depuis les sources en plusieurs étapes.

Digest publié sur Docker Hub : `sha256:88bd5d34ba38b714f6ca04e92805dc1c16016315e3b8a6f80b45ce4a69c78df1`.

Digest de l’image amd64 exécutée par Render : `sha256:9202b8fcedf4f3539798d9309d77382be34b89bf181f6bedd0728274070ecad3`. Le premier digest désigne l’index publié et le second son image de plateforme.

## Déploiement et vérifications

Render affiche le service en état Live, sur l’offre Free à Frankfurt. Il utilise l’image Docker Hub 1.0.0 et PostgreSQL 17.11. Le Blueprint est `render.yaml`. La base n’autorise aucune connexion externe ; l’API utilise le réseau interne et reçoit ses identifiants via Render.

Les vérifications HTTP HTTPS suivantes ont réussi : contrôle de santé UP, inscription de deux comptes de test, connexion, création d’une matière et d’une tâche, lecture de la matière associée, tableau de bord, absence des tâches du premier compte dans le second, refus 404 d’une suppression par le second compte, révocation du jeton avec réponse 401 après déconnexion, et récupération des données après reconnexion. Les tâches et matières de test ont ensuite été supprimées. Les deux comptes techniques restent en base avec leurs sessions révoquées.

Le script reproductible est `scripts/smoke_remote.py`. Il crée des comptes techniques ; l’exécuter explicitement uniquement pour une vérification autorisée.

La récupération après reconnexion a été testée. La persistance après un redémarrage du service et l’utilisation complète du nouvel APK sur un téléphone n’ont pas encore été vérifiées.

Preuve visuelle : `docs/preuves/render-live.jpg`.

## APK de test connecté à Render

Le fichier local `mobile/build/app/outputs/flutter-apk/campus-tasks-render.apk` est compilé avec `API_BASE_URL=https://campus-tasks-api-4k21.onrender.com/api/v1`. C’est un APK debug, pas encore un APK de release signé par le groupe ni un fichier publié dans une GitHub Release.

## Durée de l’offre gratuite

Le service peut se mettre en veille et prendre du temps à répondre au premier appel. La base gratuite expire le 3 novembre 2026 à 16 h 13 UTC, également heure de Dakar. Prévoir une sauvegarde et une solution de conservation avant cette date. Aucun abonnement payant n’a été créé.

Message à envoyer : « Bonjour Monsieur, voici l’image Docker versionnée de CampusTasks : https://hub.docker.com/r/dvisn/campus-tasks-api/tags (tag 1.0.0). Le backend est déployé en HTTPS sur Render : https://campus-tasks-api-4k21.onrender.com. Pour vérifier son fonctionnement : https://campus-tasks-api-4k21.onrender.com/api/v1/health. Le code et la configuration sont disponibles sur https://github.com/visiondigitalsn-hub/campus-tasks. »
