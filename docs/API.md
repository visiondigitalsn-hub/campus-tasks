# Contrat API v1

Base : `https://votre-domaine/api/v1`. Réponses JSON, header `Content-Type: application/json`. Sauf register/login/health, envoyer `Authorization: Bearer <token>`. Ne pas envoyer un ownerId : le serveur le déduit du jeton.

| Méthode | Route | Réponse |
|---|---|---|
| GET | /health | 200, état et version (vivacité, pas un test DB) |
| POST | /auth/register | 201, session |
| POST | /auth/login | 200, session |
| POST | /auth/logout | 204, jeton révoqué |
| GET | /subjects | 200, tableau de matières |
| POST | /subjects | 201, matière créée |
| PUT | /subjects/{id} | 200, matière modifiée |
| DELETE | /subjects/{id} | 204 ou 409 si tâches associées |
| GET | /tasks?subjectId=1&status=TODO&sort=asc | 200, tableau filtré et trié |
| POST | /tasks | 201, tâche créée |
| PUT | /tasks/{id} | 200, tâche modifiée |
| DELETE | /tasks/{id} | 204 |
| GET | /dashboard | 200, indicateurs |

Filtres facultatifs combinables. `sort` vaut `asc` ou `desc` (date limite, puis id). `status` : TODO, IN_PROGRESS, DONE. `priority` : LOW, MEDIUM, HIGH.

## Requêtes

Inscription :
```json
{"name":"Awa","email":"awa@example.com","password":"MotDePasse123!"}
```
Connexion : même email et password, sans name. Session : token opaque aléatoire, expiresAt ISO UTC, name. Durée par défaut 24 heures. Le serveur stocke seulement le hash SHA-256 du jeton ; le mot de passe est haché BCrypt. À la déconnexion le jeton est supprimé côté serveur et du stockage sécurisé Flutter.

Matière :
```json
{"name":"Programmation Java","description":"Cours du semestre"}
```
Tâche :
```json
{"title":"Projet REST","description":"Préparer les DTO","subjectId":1,"dueDate":"2026-10-30","priority":"HIGH","status":"TODO"}
```
Retour matière : id, name, description. Retour tâche : id, title, description, subjectId, subjectName, dueDate, priority, status, createdAt. createdAt est généré côté serveur et conservé en modification.

Dashboard : todo, inProgress, done, overdue (compteurs), upcoming (au plus cinq tâches non terminées à échéance >= aujourd'hui), late (toutes les tâches non terminées dont la date est dépassée).

## Erreurs et validation

400 : saisie/enum/date/tri invalide. 401 : connexion requise ou mauvais identifiants. 404 : objet absent ou appartenant à un autre étudiant. 409 : email utilisé, matière non vide ou conflit d'intégrité. Erreur : `{"message":"Explication"}`. Aucun hash ou propriétaire n'apparaît dans les DTO.

Nom étudiant/matière 100 caractères, titre 150, email 254, descriptions matière 2000/tâche 4000, mot de passe 8 à 72 caractères et maximum 72 octets UTF-8 (limite BCrypt). Une date passée est autorisée : elle apparaît dans les retards. Les descriptions sont obligatoires dans le JSON mais peuvent être vides.

## Collection exécutable

Le fichier `api.http` fournit les requêtes à exécuter avec un client REST. Remplacer le jeton et les ids avec les réponses effectives.
