# Livraison 1.0.0 — notes préparatoires

Statut : candidat local, non publié. Remplacer cette mention après vérifications et publication effectives.

Fonctionnalités : inscription/connexion/déconnexion, matières, tâches, filtres matière/statut et tri échéance, compteurs/prochaines échéances/retards, stockage sécurisé de session et isolation des données.

Environnement : API Java 21/Spring Boot 4.0, PostgreSQL 17, Flutter 3.41.9. Image attendue `compte/campus-tasks-api:1.0.0`, mobile 1.0.0+1, contrat /api/v1.

Limites : pas de notifications, mode hors ligne, récupération de mot de passe ou collaboration. Suppression de matière refusée si elle contient des tâches. Jeton valable 24 h par défaut. Les listes ne sont pas paginées. Une déconnexion sans réseau efface la session locale ; le jeton distant expire normalement s'il n'a pas pu être révoqué.

À renseigner avant publication : URL HTTPS réelle, lien image, APK signé, SHA-256, résultats appareil et mise à jour, noms des membres, notes de migration.
