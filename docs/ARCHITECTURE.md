# Architecture et schéma relationnel

```mermaid
flowchart LR
  Mobile[Flutter / stockage sécurisé] -->|Bearer + JSON HTTPS| Proxy[Caddy TLS]
  Proxy --> API[Contrôleurs Spring]
  API --> Services[AuthService / PlannerService]
  Services --> Repositories[Spring Data JPA]
  Repositories --> DB[(PostgreSQL privée)]
```

```mermaid
erDiagram
  STUDENTS ||--o{ SUBJECTS : possede
  STUDENTS ||--o{ TASKS : possede
  STUDENTS ||--o{ AUTH_TOKENS : ouvre
  SUBJECTS ||--o{ TASKS : contient
  STUDENTS {
    bigint id PK
    varchar name
    varchar email UK
    varchar password_hash
  }
  SUBJECTS {
    bigint id PK
    bigint owner_id FK
    varchar name
    varchar description
  }
  TASKS {
    bigint id PK
    bigint owner_id FK
    bigint subject_id FK
    varchar title
    varchar description
    date due_date
    varchar priority
    varchar status
    timestamptz created_at
  }
  AUTH_TOKENS {
    bigint id PK
    bigint owner_id FK
    varchar token_hash UK
    timestamptz expires_at
  }
```

Le SQL réel est `backend/src/main/resources/db/migration/V1__initial.sql`. Flyway l'applique une fois et Hibernate valide la correspondance ; pas de modification automatique du schéma en production. Les migrations futures sont ajoutées sous V2, V3… sans modifier V1 déjà déployée.

La propriété d'une tâche et de sa matière est vérifiée dans le service à chaque création/modification. Les lectures et mutations recherchent simultanément id et owner_id. Même si l'application affiche seulement les éléments de l'étudiant, le serveur reste responsable de l'isolation. Les FK empêchent la suppression d'une matière encore utilisée, y compris en cas de concurrence.

Les DTO définissent le contrat client ; les entités JPA ne sont jamais sérialisées. Le jeton aléatoire de 256 bits évite une clé de signature JWT et permet une révocation immédiate. Les sessions expirées sont refusées ; une purge périodique des jetons expirés pourra être ajoutée pour une utilisation longue durée. Le périmètre L3 ne comprend pas récupération de mot de passe, pagination, notifications ou synchronisation hors ligne.
