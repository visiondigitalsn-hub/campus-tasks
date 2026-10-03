# Vérifications et preuves

Date de travail : 3 octobre 2026. Le statut ci-dessous distingue les tests exécutés des procédures à réaliser. Ne pas ajouter de coche sans preuve.

| Vérification | État / preuve |
|---|---|
| Compilation backend | Réussie localement ; JAR exécutable construit par mvn package |
| Tests HTTP + JPA + Security | 3 tests réussis, 0 échec, Maven ; H2 mode PostgreSQL |
| Hash du mot de passe | Assertion automatique : différent du mot de passe en clair |
| Accès croisé tâches/matières | Tests mutation/suppression/association/filtre refusés en 404 |
| CRUD, suppression matière non vide | Tests 201/200/204 et refus 409 |
| Retard, tâche terminée | Test compteurs et exclusion des tâches DONE |
| Validation, routes privées, logout | Tests 400/401 et jeton supprimé |
| Reconnexion et tri/filtres | Test données retrouvées après nouveau login |
| Flutter analyse/tests | Analyse sans problème ; 5 tests réussis (écran + client API/session) |
| Rapport | PDF de 10 pages généré et relu visuellement ; compilation du source LaTeX indisponible dans l’éditeur intégré |
| APK debug local | Compilation en cours ; ne constitue pas une livraison signée |
| Configuration CI | YAML/XML validés ; CI prévue avec PostgreSQL 17, exécution distante non effectuée |
| Docker/PostgreSQL réel et redémarrage | À réaliser : Docker absent sur ce poste |
| Publication GitHub/Docker Hub et HTTPS | À réaliser : comptes/serveur/domaine nécessaires |
| APK signé sur Android distant | À réaliser : clé, URL HTTPS et appareil nécessaires |
| Mise à jour APK même signature | À réaliser sur une installation existante |

## Protocole manuel à conserver

Créer le dossier preuves de la livraison. Pour chaque scénario noter date, commit/tag, environnement, étapes, attendu, observé et capture ou log sans secrets.

1. Compte A : inscrire, créer matière et tâche, noter ids ; déconnecter, reconnecter, retrouver ids et contenu.
2. Compte B : liste vide, mutation et suppression des ids A refusées ; association d'une tâche B à une matière A refusée.
3. Envoyer titre vide, date/enum invalide, email incorrect ; relever le message compréhensible et 400.
4. PostgreSQL/Compose : créer données, `restart api db`, attendre disponibilité, reconnecter et retrouver ids. Tester aussi recréation du conteneur sans supprimer le volume.
5. Installer APK signé connecté à HTTPS ; créer depuis téléphone, vérifier réponse DB puis reconnecter.
6. Installer seconde version avec même clé et versionCode augmenté via `adb install -r`. Vérifier lancement, conservation et version ; conserver empreinte du certificat.
7. Tester sauvegarde/restauration dans un environnement isolé et vérifier les données restaurées.

Conserver les rapports Surefire `backend/target/surefire-reports` dans les artefacts de preuve de la livraison, sans les confondre avec un test de serveur distant.
