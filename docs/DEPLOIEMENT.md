# Déploiement, mise à jour, rollback et données

Procédure préparée, non exécutée sur un serveur distant. Utiliser seulement la plateforme autorisée par l'enseignant. Prérequis : Docker/Compose, domaine DNS pointant vers ce serveur, accès SSH, ports 80/443 accessibles et image publiée. Ne jamais exposer PostgreSQL (aucun mapping de port dans Compose).

## Premier déploiement

1. Publier le code dans le dépôt du groupe. Enregistrer DOCKERHUB_USERNAME et DOCKERHUB_TOKEN dans les secrets GitHub Actions ; le token doit avoir le droit de publier l'image du compte.
2. Après CI et relecture, pousser le tag `v1.0.0`. Le workflow publie `compte/campus-tasks-api:1.0.0`. Vérifier réellement son succès dans Actions et Docker Hub.
3. Sur le serveur, récupérer le dépôt à ce tag et copier `deployment/.env.example` vers `.env`. Renseigner un mot de passe PostgreSQL aléatoire, compte image, version, domaine et email ACME. Protéger ce fichier (ex. `chmod 600 .env` sous Linux).
4. Dans deployment :

```sh
docker compose --env-file .env -f compose.yaml -f compose.prod.yaml pull
docker compose --env-file .env -f compose.yaml -f compose.prod.yaml up -d
docker compose --env-file .env -f compose.yaml -f compose.prod.yaml ps
curl --fail https://api.votre-domaine/api/v1/health
```

Caddy demande et renouvelle le certificat TLS. Le domaine doit être réel, résolu vers le serveur et accessible pour ACME. Tester ensuite register/login/subjects pour vérifier aussi la DB : /health indique seulement que Java répond.

## Journaux et redémarrage

```sh
docker compose --env-file .env -f compose.yaml -f compose.prod.yaml logs --tail=100 api db proxy
docker compose --env-file .env -f compose.yaml -f compose.prod.yaml restart api db
```

Les services ont `restart: unless-stopped`. Pour prouver la persistance, créer une matière/tâche, redémarrer, se reconnecter et relever les mêmes ids. Le volume `postgres-data` conserve les données. Ne pas exécuter `down -v` sur une DB à conserver. Le changement de POSTGRES_PASSWORD dans .env ne change pas le mot de passe d'une DB déjà initialisée : le modifier aussi dans PostgreSQL selon une procédure contrôlée.

## Mise à jour

1. Sauvegarder la DB avant migration, noter image/tag et version du schéma.
2. Vérifier la nouvelle CI, les notes de livraison et la compatibilité client.
3. Changer API_VERSION dans .env (ex. 1.0.1), puis :

```sh
docker compose --env-file .env -f compose.yaml -f compose.prod.yaml pull api
docker compose --env-file .env -f compose.yaml -f compose.prod.yaml up -d --no-deps api
curl --fail https://api.votre-domaine/api/v1/health
```

Flyway applique les nouvelles migrations au démarrage. Vérifier login/CRUD et surveiller les journaux. Ne jamais remplacer V1 dans un environnement déjà migré.

## Retour à la version précédente

Si le schéma est compatible, remettre l'ancien API_VERSION et relancer les deux commandes de mise à jour. Si une migration a supprimé/transformé des données, un rollback d'image peut échouer ou corrompre les usages : prévoir une migration corrective compatible, ou restaurer la sauvegarde après validation en environnement séparé. Une restauration efface les changements survenus depuis la sauvegarde ; décider explicitement de cette perte avant de procéder.

## Sauvegarde/restauration (serveur Linux)

Le format custom pg_dump évite les problèmes d'encodage du pipe PowerShell. Utiliser pg_dump/pg_restore de la même version majeure que PostgreSQL. La sauvegarde reste temporairement dans le conteneur, puis est copiée sur l'hôte.

```sh
docker compose exec -T db sh -c 'pg_dump -U "$POSTGRES_USER" -d campustasks -Fc -f /tmp/campus.dump'
docker compose cp db:/tmp/campus.dump ./campus-YYYY-MM-DD.dump
```

Conserver une copie chiffrée hors du serveur, avec accès restreint et rotation. Tester la restauration sur une DB de test avant d'utiliser une sauvegarde en urgence.

Restauration destructive, uniquement après autorisation du groupe, maintenance et nouvelle sauvegarde :

```sh
docker compose --env-file .env -f compose.yaml -f compose.prod.yaml stop api
docker compose cp ./campus-YYYY-MM-DD.dump db:/tmp/restore.dump
docker compose exec -T db sh -c 'pg_restore -U "$POSTGRES_USER" -d campustasks --clean --if-exists --no-owner /tmp/restore.dump'
docker compose --env-file .env -f compose.yaml -f compose.prod.yaml start api
```

Vérifier la migration Flyway et les parcours après restauration. À plus grande échelle : limitation des tentatives login au proxy, monitoring externe et politique de sauvegarde automatique sont à ajouter selon la plateforme.
