# Workflow Git et livrables

L'historique Git compte dans la note : il doit être propre, atomique, et équilibré entre les 3 membres.

## Branches

- `main` est protégée : on n'y pousse jamais directement.
- Une branche par fonctionnalité ou correctif : `feat/<sujet>`, `fix/<sujet>`, `chore/<sujet>`, `docs/<sujet>`, `test/<sujet>`.
- Merge dans `main` uniquement via Pull Request relue et approuvée par un autre membre, CI au vert.

## Commits (Conventional Commits)

Format : `<type>(<scope>): <description>` en anglais, impératif, minuscule, sans point final.

- Types : `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`, `ci`, `perf`, `build`.
- Scope = la feature ou la zone : `auth`, `feed`, `spot`, `spot-editor`, `social`, `offline`, `map`, `core`, `l10n`, `theme`.
- Exemples : `feat(feed): add vertical immersive feed`, `fix(auth): persist session after app restart`, `test(spot): cover favorite toggle use case`.
- Un commit = un changement cohérent qui compile et passe les tests.
- L'auteur du commit est le membre de l'équipe : ne jamais ajouter d'agent IA en co-auteur.

## Pull Requests

- Titre au format Conventional Commits.
- Remplir le template (`.github/pull_request_template.md`) : contexte, changements, captures si UI, checklist.
- Petites PR ciblées, faciles à relire.

## Livrables (avant le 01/01/2027)

Le `README.md` final doit contenir :

- Présentation du projet et captures d'écran en mode clair **et** sombre.
- Diagramme d'architecture et modèle de données (diagramme de classes / entités).
- Tableau de répartition des tâches par membre.
- Procédure d'installation et de build pas à pas.
- Gestion des variables d'environnement (ex. clés d'API cartographiques).
- Choix techniques clés et packages tiers retenus, avec justification.

Mettre à jour la section concernée du README dans la PR qui introduit un package, une variable d'env ou un choix d'architecture.
