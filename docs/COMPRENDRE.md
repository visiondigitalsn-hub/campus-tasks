# Comprendre CampusTasks pas à pas

Tu peux avancer sans avoir suivi tous les cours. Lis et exécute une petite partie à la fois. Ce guide décrit le code produit ; il ne prétend pas reproduire les cours qui seront transmis plus tard.

1. **Le besoin** : un étudiant a des matières, chaque matière contient des tâches. L'étudiant voit uniquement ses propres données. Rejouer inscription → matière → tâche → dashboard.
2. **Le modèle** : ouvrir `model/Student.java`, `Subject.java`, `Task.java`. `@Entity` signifie que JPA stocke cette classe en table. `@ManyToOne` représente une FK : plusieurs tâches peuvent avoir la même matière.
3. **Les repositories** : `findByIdAndOwnerId` est interprété par Spring Data en recherche SQL. La double condition empêche l'accès à l'objet d'un autre compte. `findByOwnerIdOrderByDueDateAscIdAsc` trie les tâches dans la DB.
4. **Les DTO** : ouvrir `dto/Dto.java`. Une requête TaskInput porte les données saisies ; TaskView porte la réponse. On n'envoie pas le mot de passe haché ni les relations JPA au mobile.
5. **Le service** : `PlannerService.saveTask` cherche la matière de l'étudiant, copie les champs et enregistre. `@Transactional` regroupe les opérations de DB. La création fixe createdAt ; une modification le conserve.
6. **Le contrôleur** : les annotations `@GetMapping`, `@PostMapping` associent URL et méthode Java. `@Valid` vérifie les contraintes DTO avant de lancer le service. Authentication contient l'id extrait du jeton.
7. **La sécurité** : le mot de passe est BCrypt. Login produit un jeton aléatoire. TokenFilter lit Bearer, vérifie le hash en base et la date d'expiration. Logout supprime ce jeton. Une application mobile n'est jamais une autorité pour ownerId.
8. **Flutter** : `api.dart` envoie HTTP et traduit les erreurs. SessionGate restaure le jeton. AuthScreen gère le formulaire. HomeScreen charge les trois listes et affiche compteurs/filtres. EditorScreen réutilise le même formulaire pour création et modification. setState demande à Flutter de reconstruire l'écran après une réponse.
9. **Docker** : l'étape Maven compile le JAR ; l'étape runtime ne garde que Java et ce JAR. Compose relie API et DB. Le volume conserve PostgreSQL après remplacement d'un conteneur. Caddy fournit HTTPS en production.
10. **Git et livraison** : un commit est un état du code ; une branche isole une fonctionnalité ; une PR demande relecture ; un tag identifie une livraison. API v1 est un contrat, 1.0.0 une version du produit, +1 un numéro de build Android.

## Exercices pour vérifier que tu comprends

- Pourquoi un id envoyé par le mobile ne suffit-il pas pour vérifier un droit d'accès ? Montre la condition ownerId.
- Change une tâche ancienne en DONE et constate que overdue diminue.
- Supprime une matière contenant une tâche : explique le 409, puis supprime la tâche et recommence.
- Observe une réponse API et retrouve son record DTO.
- Déconnecte un compte et réutilise son ancien jeton : il doit recevoir 401.
- Explique ce qui disparaît lors d'un changement de conteneur et ce qui reste dans le volume.

À la réception des cours : noter les conventions demandées (noms, packages, version Spring, gestion d'état Flutter), comparer au code puis adapter sans supprimer les contrôles de sécurité ni les tests.
