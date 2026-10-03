# Versionnement et organisation du groupe

Livraison visée : tag Git `v1.0.0`, pom `1.0.0`, fichier VERSION `1.0.0`, Flutter `1.0.0+1`, Docker `compte/campus-tasks-api:1.0.0`. Le contrat HTTP reste `/api/v1` pour des corrections/ajouts compatibles. Une rupture du contrat demande une migration client et éventuellement `/api/v2`.

Le dépôt local et les publications ne doivent pas être confondus. Les tags et releases seront créés après validation. Pour une prochaine version, modifier VERSION, pom, pubspec, version /health et notes de release ; le Dockerfile prend le JAR Maven courant. Incrémenter toujours le build Android.

Travail à trois : un membre conduit l'API, un le mobile, un le déploiement/docs. Chaque membre relit un autre et doit pouvoir expliquer les trois couches. Les responsabilités seront attribuées aux vrais membres, sans inventer de noms ou de contributions.

Branches : main stable, feature/authentication, feature/tasks, feature/mobile, feature/deployment. Développer sur branche, faire une PR, attendre CI, demander relecture d'un autre membre, puis intégrer. Exemple commit : `feat: isoler les tâches par étudiant`. Ne pas reconstruire artificiellement un historique collaboratif après coup.

Avant tag : tests verts, données privées vérifiées, .env/clé absents de Git, version cohérente, documentation à jour. Pousser le tag déclenche publication d'image, pas le déploiement ni la Release APK (manuels documentés).
