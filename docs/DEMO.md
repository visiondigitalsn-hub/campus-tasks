# Démonstration de 15 minutes

Préparer avant : backend déployé, deux comptes, téléphone avec APK signé, connexion Internet, données simples et une tâche passée. Ne pas afficher mot de passe, jeton ou clés dans la projection.

| Durée | Démonstration et explication |
|---|---|
| 0–2 min | Problème étudiant, objectifs et architecture Flutter → API → PostgreSQL |
| 2–4 min | Créer un compte, ouvrir l'application, ajouter une matière |
| 4–7 min | Créer deux tâches, modifier statut/priorité/date, filtrer et trier |
| 7–9 min | Dashboard : compteurs, prochaines échéances et retard ; terminer le retard |
| 9–11 min | Déconnexion/reconnexion, retrouver les données ; montrer test d'isolation avec second compte |
| 11–13 min | Docker multi-stage, DB privée, volume, CI et tag/image versionnée, HTTPS |
| 13–15 min | APK signé/mise à jour, tests/preuves, limites et contributions des trois membres |

Répartir le temps entre les trois membres sans spécialisation exclusive. Prévoir une vidéo ou captures datées en secours, en les présentant comme captures et non comme un direct. Ne pas annoncer une publication ou un test qui n'a pas eu lieu.

Questions possibles : différence entité/DTO ; raison du ownerId serveur ; intérêt du hachage BCrypt ; rôle du volume ; différence version produit/version API/build Android ; risque d'un rollback après migration ; pourquoi conserver la clé de signature ; traitement du 409 matière non vide.
