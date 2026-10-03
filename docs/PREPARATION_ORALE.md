# Préparer la présentation de CampusTasks

Ces attentes viennent du sujet du projet. Les questions ci-dessous sont probables, pas une liste connue des questions du professeur.

## Ce que tu dois montrer

Une application qui fonctionne et dont tu comprends le parcours complet : Flutter envoie une requête HTTP à Spring Boot ; le backend authentifie l’étudiant, applique les règles métier et lit ou écrit dans PostgreSQL ; une réponse JSON revient au téléphone.

Présente les fonctions demandées : inscription, connexion, déconnexion, matières, tâches, modification, suppression, filtre par statut et matière, tri par échéance, tableau de bord et séparation des données entre deux comptes. Puis explique Docker, les tests, Git/CI et la livraison Android. Le sujet demande aussi le déploiement HTTPS, l’image Docker publiée/versionnée, l’APK signé, les preuves et le rapport de 8 à 12 pages.

## Démonstration rapide, dans cet ordre

1. Connecte le téléphone au Wi-Fi du PC. Vérifie que `http://192.168.1.146:8080/api/v1/health` répond. Le PC et Docker doivent rester allumés.
2. Ajoute une matière « Programmation Java » avec une courte description.
3. Crée « Préparer la soutenance », priorité haute, échéance aujourd’hui, statut en cours.
4. Crée « Réviser les collections », échéance hier, statut à faire. Montre le retard sur l’accueil.
5. Change cette tâche en terminée : le compteur des retards diminue.
6. Montre les filtres et le tri. Modifie puis supprime une tâche de test.
7. Déconnecte-toi puis reconnecte-toi : les données restent en base. Un second compte doit voir ses propres données.
8. Sur le PC, montre `docker ps`, les fichiers Docker, un test et les commits. Explique les limites actuelles avec précision.

## Introduction à dire en 30 secondes

« CampusTasks aide un étudiant à organiser ses matières et ses tâches avec des dates limites, des priorités et un suivi d’avancement. Le mobile est développé avec Flutter. Il communique avec une API Spring Boot, qui protège les données de chaque étudiant et les stocke dans PostgreSQL. Docker permet de lancer l’API et la base de façon reproductible. Je vais vous montrer le parcours utilisateur, puis expliquer l’architecture et les vérifications. »

## Questions probables et réponses à comprendre

| Question | Réponse courte et précise |
|---|---|
| Pourquoi Flutter ? | Il permet de construire l’interface mobile avec Dart et des widgets. Les appels réseau sont séparés dans `api.dart`. |
| Quelle différence entre frontend et backend ? | Le frontend affiche et recueille les saisies ; le backend vérifie les droits, les données et les règles avant d’accéder à la base. |
| Pourquoi contrôleur, service et repository ? | Le contrôleur reçoit HTTP, le service porte les règles métier et le repository accède aux données avec Spring Data JPA. |
| Une entité et un DTO, c’est quoi ? | L’entité représente une table et ses relations ; le DTO décrit les champs acceptés ou renvoyés par l’API, sans exposer toute la base. |
| Quelles relations en base ? | Un étudiant possède plusieurs matières et tâches ; plusieurs tâches peuvent appartenir à une matière. Les clés étrangères garantissent ces liens. |
| Comment protégez-vous les mots de passe ? | Le backend stocke un hachage BCrypt. Il compare le mot de passe saisi au hachage sans stocker le mot de passe en clair. |
| Votre jeton est-il un JWT ? | Non. C’est un jeton aléatoire opaque ; son hachage et son expiration sont stockés en base. Le client transmet le jeton avec `Authorization: Bearer`. |
| Que fait la déconnexion ? | Elle révoque le jeton côté serveur et efface la session locale. Une ancienne session révoquée ne permet plus les appels protégés. |
| Comment empêchez-vous de consulter les tâches d’un autre compte ? | Le serveur tire l’identité du jeton et cherche les objets avec leur identifiant et leur propriétaire. Le mobile ne choisit pas le propriétaire. |
| Pourquoi une matière ne se supprime pas si elle contient des tâches ? | Pour éviter de supprimer un lien utilisé. L’API renvoie 409 ; il faut d’abord supprimer ou déplacer les tâches. |
| Quelle différence entre 400, 401, 404 et 409 ? | 400 : saisie invalide ; 401 : session absente ou invalide ; 404 : élément absent ou inaccessible ; 409 : conflit avec une règle métier. |
| Comment trouvez-vous les retards ? | Une tâche non terminée dont la date limite est passée est en retard. La référence de date du backend est UTC. |
| Docker, image et conteneur ? | Une image contient ce qu’il faut pour exécuter un programme ; un conteneur est une instance en cours d’exécution. Compose relie l’API et PostgreSQL. |
| Pourquoi un volume PostgreSQL ? | Il conserve les données lorsque le conteneur est remplacé. Un volume ne remplace pas une sauvegarde. |
| Pourquoi un Dockerfile multi-stage ? | Maven compile dans une première étape ; l’image finale contient seulement le runtime Java et le JAR, exécutés avec un utilisateur non root. |
| Comment vérifiez-vous le projet ? | Tests backend : authentification, isolation entre comptes et règles métier. Tests Flutter : formulaire et client HTTP/session. Analyse statique Flutter. Tests réels d’inscription et déconnexion sur Docker/PostgreSQL. |
| À quoi servent Git et la CI ? | Git conserve les versions du code. La CI prépare les builds et vérifie automatiquement les changements ; un workflow présent n’est pas la preuve qu’il a déjà tourné sur GitHub. |
| Pourquoi HTTPS en production ? | Il chiffre les échanges, dont les identifiants et jetons. Le test actuel sur le Wi-Fi est en HTTP ; il reste à mettre en place la livraison distante HTTPS. |
| Pourquoi conserver la clé de signature Android ? | Android exige une signature compatible pour installer une mise à jour de l’application. L’APK actuel utilise une signature de debug. |
| Pourquoi l’ancien APK ne répondait pas ? | Il ciblait `10.0.2.2`, adresse spéciale de l’émulateur. Le téléphone physique doit utiliser l’adresse Wi-Fi du PC ou une URL HTTPS publique. |

## État réel à annoncer

Le code, les tests locaux, le JAR, l’APK debug et Docker avec PostgreSQL ont été exécutés localement. L’API a répondu à un test de santé, à une inscription, à une lecture authentifiée et à une déconnexion. Le nouveau design conserve les mêmes fonctions. Le test complet du nouvel APK sur téléphone doit être effectué par toi.

Le nouvel APK de démonstration est `mobile/build/app/outputs/flutter-apk/campus-tasks-demo.apk`. Il cible `http://192.168.1.146:8080/api/v1`. L’analyse Flutter ne signale aucun problème, les cinq tests passent et la compilation Android a réussi. SHA256 : `a25e018b41c4b981b3a48475ff161fd9cfb5d42e3b6a5cb038d446200d723454`.

La publication GitHub, la publication Docker Hub, le serveur HTTPS et l’APK de release signé ne sont pas encore vérifiés. Ne présente pas le démarrage sur le PC comme un déploiement public. Explique ce qui reste à faire et montre les fichiers préparés. Pour les contributions du groupe, indique uniquement le travail réellement réalisé par chaque membre.

Si une question te bloque, dis ce que tu sais et montre le fichier concerné. Par exemple : « Je sais que cette vérification est faite côté serveur ; je vais vous montrer la méthode du service. » Tu dois pouvoir expliquer un chemin complet de création d’une tâche et le contrôle de son propriétaire.
