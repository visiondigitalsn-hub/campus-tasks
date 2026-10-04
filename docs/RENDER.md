# Livraison Docker Hub et Render

Les deux livrables à transmettre sont l’image Docker versionnée publiée sur Docker Hub et l’URL HTTPS réellement attribuée au backend par Render. Une image locale et une adresse Wi-Fi ne constituent pas ces livrables.

## Déploiement initial

Le fichier `render.yaml` définit un service web Docker et PostgreSQL dans la même région. Il reconstruit `backend/Dockerfile` depuis GitHub. Les identifiants de la base sont injectés par Render, sans les enregistrer dans le dépôt. L’accès externe à la base est désactivé. Spring Boot utilise le port `PORT` fourni par Render.

Dans Render, connecter GitHub puis créer un Blueprint depuis le dépôt `visiondigitalsn-hub/campus-tasks`. Choisir `render.yaml`, vérifier les deux offres gratuites et lancer la création. Si une base gratuite existe déjà, adapter la configuration à cette base au lieu d’en créer une seconde.

Le déploiement est prêt uniquement après un état Live et un test réussi du chemin `/api/v1/health`, puis une inscription et un appel authentifié sur PostgreSQL distant. Relever l’URL attribuée par Render ; ne pas supposer qu’un nom de service garantit une URL précise.

## Image publiée

Le dépôt Docker Hub et le compte doivent être confirmés. Le workflow `.github/workflows/image.yaml` publie une image sur un tag `v1.0.0` lorsque les secrets GitHub `DOCKERHUB_USERNAME` et `DOCKERHUB_TOKEN` sont configurés. Ne jamais mettre le token dans le code ni dans une conversation.

Pour déployer exactement l’image publiée, utiliser un service Render avec le runtime image et la référence Docker Hub versionnée, puis conserver les mêmes variables de base, le port et le contrôle de santé. Conserver également son digest pour identifier la livraison.

## Vérifications à remettre

- Lien Docker Hub, tag et digest de l’image publiée.
- URL HTTPS du backend et réponse du contrôle de santé.
- Preuve d’inscription, connexion, séparation entre deux comptes et déconnexion.
- Persistance après redémarrage du service API, sans supprimer PostgreSQL.
- APK reconstruit avec `API_BASE_URL=https://URL-RENDER/api/v1`, puis testé depuis le téléphone.

## Limites de l’offre gratuite

La base PostgreSQL gratuite expire après 30 jours ; le service web gratuit peut se mettre en veille. Conserver une sauvegarde avant expiration et ouvrir le backend avant une démonstration. Une instance payante exige un choix et une autorisation explicites.

Sources : https://render.com/docs/blueprint-spec et https://render.com/docs/free.
