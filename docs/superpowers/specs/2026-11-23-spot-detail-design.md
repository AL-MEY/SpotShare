# Fiche Spot (« Detail View ») + notes et commentaires — design

Date : 2026-11-23 · Branche : `feat/spot-detail`, partie de `feat/user-profile` (non mergée, elle apporte `firestore.rules`, `firebase.json`, `users/{uid}` et `SubmitController`). À rebaser sur `main` quand `feat/user-profile` y sera mergée.

## 1. Intention

Livrer la §2.3 des consignes (fiche détaillée d'un spot) et la partie « noter / commenter » de la §2.5, toutes deux à la charge de Mathis. Le projet est noté : la fiche est citée nommément dans la grille (tests de widgets « Fiche lieu »), et la démo se fait en direct sur un appareil physique. Tout doit pouvoir être expliqué et modifié en soutenance.

Aucune entité `Spot` n'existe encore dans le dépôt : **ce travail fixe le modèle `Spot` pour toute l'équipe** (flux, carte, formulaire de création le réutiliseront).

## 2. Objectifs, non-objectifs, anti-objectifs

**Objectifs**
- Fiche : titre, description, catégorie, adresse exacte, note moyenne, tags, auteur du spot.
- Galerie : carrousel swipeable de **photos et vidéos courtes**, plein écran avec zoom (photos) ou lecture (vidéos).
- Avis : note moyenne + nombre de notes, liste des commentaires en temps réel.
- Noter un spot (1 à 5 étoiles, modifiable) et commenter (ajout, suppression de ses propres commentaires).
- Transition `Hero` depuis une liste vers la fiche ; layout adapté tablette ; FR/EN ; clair/sombre.
- Moyenne et compteurs calculés côté serveur par Cloud Functions ; règles Firestore strictes.
- Données de démo sur le projet dev.

**Non-objectifs** (hors de ce travail)
- Créer / éditer un spot (§2.4), ajouter / retirer un favori et partage (§2.5, pas pris), flux immersif et carte (§2.2). Seuls le champ `favoriteCount` et la Function qui le tient à jour sont livrés ici.
- Requêtes par proximité (la carte) : seul le champ `geohash` et son calcul sont livrés ici.
- Base locale (Drift, Isar…) et écriture hors ligne (§2.6) : la fiche s'appuie sur le cache natif de Firestore.
- Modifier un commentaire, répondre en fil, liker un commentaire, retirer sa note.
- Répartition des notes (histogramme 5★/4★…).
- Ouvrir l'adresse dans une app de cartographie (demanderait `url_launcher`, relève de la carte).
- Nettoyer les sous-collections quand un spot est supprimé.

**Anti-objectifs** (ce qui ferait échouer le travail même s'il « marche »)
- Toute la page reconstruite quand on touche une étoile ou qu'un commentaire arrive.
- Un client capable d'écrire `averageRating` / `ratingCount` / `commentCount`, ou de noter à la place d'un autre.
- Un loader infini hors ligne sur un spot jamais chargé.
- Un `build()` > 80 lignes, un texte en dur, une couleur ou marge en dur.
- Un modèle `Spot` taillé pour la seule fiche, inutilisable par le flux ou la carte.

## 3. Contraintes

Celles de `CLAUDE.md` et `docs/` s'appliquent, en particulier : Clean Architecture feature-first (le domaine est du Dart pur), Riverpod sans codegen (providers écrits à la main), `Failure` levées et converties via `failureFrom`, `showErrorBottomSheet` depuis un `ref.listen`, `context.appTheme` pour tout style, slang pour les textes, un widget par fichier, go_router uniquement (`context.push(AppRoutes.xxx)`), tests sans vrai Firebase (mocktail / fakes), doc mise à jour dans le même changement.

Projets Firebase en forfait **Blaze** (vérifié pour dev ; à confirmer pour prod avant déploiement).

## 4. Approches envisagées

| | Approche | Compromis | Décision |
|---|---|---|---|
| A | **Firestore en direct** : la datasource écoute les documents en temps réel ; le cache offline natif de Firestore et `CachedNetworkImage` couvrent la consultation hors ligne d'un spot déjà vu. Le repository cache la source, une base locale pourra s'y brancher plus tard sans toucher la fiche. | Aucun nouveau package, simple à expliquer. Le choix du moteur local reste ouvert pour l'équipe. | **Retenue** |
| B | Base locale (Drift) dès maintenant, Firestore la remplit en arrière-plan. | Offline réglé pour de bon, mais gros chantier (schéma, codegen, sync), tranche à la place de l'équipe et déborde sur la §2.6. | Écartée |
| — | Faux repository en mémoire. | Rien de réel à montrer en démo. | Écartée d'emblée |

Pour les avis, deux modèles ont été comparés : un avis unique (note + texte, un par personne) ou **notes et commentaires séparés**. Mathis a choisi **séparés** : plus fidèle aux « commentaires interactifs » de la §2.5 et à la notation directe depuis le flux (§2.2).

Pour les médias, « photos seules » (plus simple, le formulaire §2.4 ne parle que de photos) a été écarté au profit de **photos et vidéos** (le flux §2.2 met en avant des « vidéos courtes ») : le modèle porte une liste de médias typés dès maintenant pour éviter une migration plus tard. `geohash` et `favoriteCount` sont ajoutés dès maintenant à la demande de Mathis.

## 5. Modèle de données (Firestore)

```
spots/{spotId}
  title          string     3–80 caractères
  description    string     0–2000, texte brut multi-paragraphes (pas de Markdown)
  category       string     cafe | viewpoint | streetArt | restaurant | park | other
  address        string     adresse lisible, 1–200
  location       geopoint   requis (carte)
  media          map[]      1–10, ordonnés ; le premier sert de couverture (Hero)
    type           string     photo | video
    url            string     image ou fichier vidéo (mp4)
    thumbnailUrl   string?    requis si video : image affichée avant lecture
    durationMs     int?       requis si video ; « courte » = ≤ 60 s
  tags           string[]   0–10, chacun 1–24, minuscules sans '#'
  authorId       string     uid du créateur
  createdAt      timestamp
  geohash        string     ┐
  averageRating  number     │ écrits UNIQUEMENT par les Cloud Functions
  ratingCount    int        │ (compteurs à 0 à la création)
  commentCount   int        │
  favoriteCount  int        ┘

spots/{spotId}/ratings/{uid}       value int 1–5, updatedAt timestamp
spots/{spotId}/comments/{autoId}   authorId string, text string 1–500 (trimé), createdAt timestamp
spots/{spotId}/favorites/{uid}     createdAt timestamp   (écrit par le propriétaire des favoris)
users/{uid}                        existant (feat/user-profile) : displayName, avatarUrl…
```

- L'id du document de note est l'uid : « une note par personne » est garanti par construction. Même principe pour les favoris.
- Nom et avatar d'un auteur (de commentaire ou du spot) sont lus dans `users/{uid}`, pas recopiés : ils restent à jour quand le profil change.
- `geohash` (précision 9, format standard) est calculé par le serveur à partir de `location` : ni le formulaire ni la carte n'ont à le calculer à l'écriture, et il ne peut pas être incohérent. La carte s'en servira pour ses requêtes par zone.
- Emplacement des favoris (`spots/{spotId}/favorites/{uid}`) : c'est mon choix, pour que `favoriteCount` se calcule comme les autres compteurs. La liste « mes favoris » du tableau de bord passe par une requête `collectionGroup('favorites')` sur l'uid. Les règles d'écriture des favoris sont laissées à leur propriétaire.

### Règles Firestore (ajoutées à `firestore.rules`)

- `spots/{spotId}` : lecture pour tout utilisateur connecté. **Écriture : rien dans ce travail** (relève du formulaire §2.4). Contrat noté pour son auteur dans la doc : à la création, les compteurs valent 0 et `geohash` est absent ; une écriture client ne peut jamais modifier `geohash` ni les compteurs.
- `ratings/{uid}` : lecture pour tout connecté ; `create`/`update` si `uid == request.auth.uid`, clés exactes `value`/`updatedAt`, `value` entier 1–5, `updatedAt == request.time`, et l'auteur du spot ne peut pas noter son propre spot (`get(spot).data.authorId != request.auth.uid`). Pas de `delete`.
- `comments/{commentId}` : lecture pour tout connecté ; `create` si `authorId == request.auth.uid`, clés exactes, `text` 1–500 et non vide une fois trimé, `createdAt == request.time` ; `delete` si `resource.data.authorId == request.auth.uid` ; pas d'`update`.

### Cloud Functions (`functions/`, TypeScript, 2e génération)

- `onRatingWritten` (`spots/{spotId}/ratings/{uid}`, création/modification) : requête d'agrégation `count()` + `average('value')` sur la sous-collection, puis écrit `ratingCount` et `averageRating` sur le spot.
- `onCommentCreated` / `onCommentDeleted` : `count()` sur `comments`, puis écrit `commentCount`.
- `onFavoriteCreated` / `onFavoriteDeleted` : `count()` sur `favorites`, puis écrit `favoriteCount`.
- `onSpotWritten` : quand `location` est créé ou modifié, calcule `geohash` (`geofire-common`, bibliothèque officielle Firebase) et l'écrit. Si `location` n'a pas changé, il n'écrit rien, ce qui évite que la function se redéclenche en boucle sur sa propre écriture.
- Le recalcul complet (plutôt qu'un incrément) est idempotent : un trigger rejoué par Firebase ne fausse pas les compteurs.
- Le spot peut avoir été supprimé entre-temps : la function ne fait rien dans ce cas.
- Région : celle de la base Firestore (à lire dans la console avant de déployer).
- Déploiement : `scripts/deploy-rules.sh` étendu (ou script voisin) pour `--only functions`. **Cette branche ne déploie que sur dev.** Le déploiement prod (règles + Functions, après vérification du forfait Blaze) est une étape de livraison, documentée dans `backend-firebase.md`.

### Données de démo

Script Node `functions/scripts/seed.ts` (`firebase-admin`), **projet dev uniquement** (refuse tout autre id de projet). Il crée environ 6 spots couvrant toutes les catégories (adresses réelles, Paris par défaut), 3 profils `users/` fictifs, des notes et des commentaires de ces profils. Les photos sont des URLs Lorem Picsum fixes (`https://picsum.photos/id/<n>/1600/1200`), pour ne pas versionner d'images. Au moins deux spots contiennent une vidéo courte (mp4 libre de droits, URL stable, ≤ 60 s, au choix de l'implémentation) avec sa vignette. Aucun favori n'est créé : `favoriteCount` vaut 0. Identifiants admin via `gcloud auth application-default login` : rien dans git. Le script est rejouable (ids de documents fixes). Il écrit aussi lui-même `geohash` et les compteurs, avec les mêmes valeurs que les Functions : les données restent cohérentes même si celles-ci ne sont pas encore déployées.

## 6. Côté app

### Domaine (`features/spot/domain/`)

- Entités : `Spot` (champs ci-dessus, `location` en value object `GeoPosition(latitude, longitude)` Dart pur, `category` en enum `SpotCategory`, `media` en `List<SpotMedia>`). `SpotMedia` est une sealed class : `SpotPhoto(url)` et `SpotVideo(url, thumbnailUrl, duration)`. Le `switch` exhaustif force chaque écran à traiter les deux cas. `Spot.coverImageUrl` renvoie l'url de la photo ou la vignette de la vidéo. Autres entités : `SpotComment` (`id`, `authorId`, `text`, `createdAt`), `SpotAuthor` (`id`, `displayName`, `avatarUrl?`). Value object `Rating` (entier 1–5, constructeur qui refuse le reste). Limites de longueur en constantes statiques, comme `UserProfile`.
- Repositories : `SpotRepository` (`watchSpot(id)`, `watchRecentSpots(limit)`), `RatingRepository` (`watchMyRating(spotId, uid)`, `rate(spotId, uid, Rating)`), `CommentRepository` (`watchComments(spotId, limit)`, `addComment(spotId, authorId, text)`, `deleteComment(spotId, commentId)`), `SpotAuthorRepository` (`watchAuthor(uid)`).
- Use cases : `RateSpot`, `AddComment` (trime le texte puis délègue, comme `SaveProfile`), `DeleteComment`. Les lectures passent directement par les interfaces de repository, comme pour le profil.

**Pourquoi notes et commentaires restent dans `spot` et pas dans une feature `social`** : la fiche affiche les commentaires et les étoiles. Or `architecture.md` interdit à une feature d'importer les widgets d'une autre. Une feature `social` obligerait la fiche à enfreindre cette règle. Pour que le flux (§2.2) puisse noter sans dupliquer :
- `features/spot/presentation/providers/spot_providers.dart` expose les providers d'infrastructure (`ratingRepositoryProvider`, `rateSpotProvider`, `commentRepositoryProvider`, `addCommentProvider`…), que le flux peut lire ;
- le widget d'étoiles est générique et sans Riverpod (`RatingStars` : valeur, `onChanged`, taille), dans `core/widgets/`. `MyRatingStars` (fiche) l'enveloppe avec le provider.

### Data (`features/spot/data/`)

DTO + mapper par entité ; une datasource distante par repository (ou une seule `SpotRemoteDataSource` si plus lisible : au choix de l'implémentation) ; repositories `Firebase…Repository` qui convertissent en `Failure`.

- Spot jamais chargé + hors ligne : le cache renvoie « inexistant » → le repository lève `NetworkFailure` (pas de loader infini). Spot inexistant en ligne → `NotFoundFailure`.
- Un média mal formé (type inconnu, vidéo sans vignette) est ignoré par le mapper plutôt que de faire planter toute la fiche.
- `SpotAuthor` lit `users/{uid}` par sa propre datasource : la feature `spot` n'importe rien de `profile/data` ni `profile/presentation`. Profil absent → auteur « inconnu » localisé.

### Écritures et réseau

Noter et commenter **attendent la confirmation du serveur**. Hors ligne, l'étoile et le champ de commentaire sont désactivés avec une mention « hors ligne » (un `connectivityProvider` dans `core/network/`, basé sur `connectivity_plus` déjà présent). L'écriture hors ligne avec synchronisation différée relève de la §2.6.

### Présentation (`features/spot/presentation/`)

**Routes** : `AppRoutes.spotDetail(id)` → `/spots/:spotId` ; route enfant `media` (`/spots/:spotId/media?index=n`) pour le plein écran. `NotFoundPage` si l'id est vide.

**Providers** (tous `autoDispose`, `family` par id)
- `spotProvider(spotId)` : `StreamProvider<Spot>`.
- `myRatingProvider(spotId)` : `AsyncNotifier<Rating?>` **optimiste** : la nouvelle valeur s'affiche aussitôt, puis revient en arrière en cas d'erreur (bottom sheet via `ref.listen`).
- `commentsProvider(spotId)` : flux des N derniers commentaires (N = 20, +20 à chaque « voir plus »), triés du plus récent au plus ancien.
- `spotAuthorProvider(uid)` : un provider par auteur, donc un auteur commun à plusieurs commentaires n'est lu qu'une fois.
- `commentComposerControllerProvider(spotId)` et `deleteCommentControllerProvider` : `SubmitController` (`core/providers/`).

**Rebuilds** : la page ne `watch` que l'état global (chargement / erreur / spot). La note moyenne, ma note, la liste et chaque auteur ont leur propre `ConsumerWidget` (`.select` sur `spotProvider` pour la note moyenne et les compteurs).

**Layout**
- Breakpoints centralisés dans `core/layout/breakpoints.dart` (compact < 600, medium < 840, expanded ≥ 840) : ils n'existent pas encore.
- Compact / medium : `CustomScrollView`, galerie dans un `SliverAppBar` extensible (la couverture porte le `Hero` `spot-image-$id`), puis infos, avis, commentaires.
- Expanded : deux colonnes, galerie fixe à gauche, infos et avis défilants à droite.

```
┌──────────────────────────┐
│ ‹   [ photo 1/5  •••• ]  │  ← swipe, tap = plein écran
├──────────────────────────┤
│ Café Lomi        ☕ Café  │
│ ★ 4,3 (27 notes)          │
│ 📍 3 rue Marcadet, Paris ⧉│  ← copier l'adresse
│ Proposé par Léa           │
│ Description… voir plus    │
│ #torréfaction #brunch     │
├──────────────────────────┤
│ Votre note  ☆☆☆☆☆         │
│ Commentaires (12)         │
│ [ Écrire un commentaire ]▶│
│ (avatar) Tom · il y a 2 h │
│ Super flat white…   🗑    │  ← seulement les miens
│ Voir plus                 │
└──────────────────────────┘
```

**Widgets** (un par fichier, `const` partout) : `SpotDetailPage`, `SpotDetailLayout` (choix compact/expanded), `SpotGallery` (`PageView.builder` + indicateur ; une vidéo y apparaît en vignette avec icône lecture et durée, sans lecture automatique), `SpotMediaViewerPage` (plein écran, `PageView`, `Hero` par média), `ZoomablePhoto` (`InteractiveViewer`), `SpotVideoPlayer` (`video_player` : lecture au tap, pause en quittant la page ou en changeant de média, barre de progression, son coupé/activé ; contrôleur créé et libéré dans un `StatefulWidget`, ce qui est un état visuel local toléré par les règles), `SpotHeader`, `SpotCategoryChip`, `SpotRatingSummary`, `SpotAddressRow` (copie via `Clipboard`), `SpotAuthorLabel`, `SpotDescription` (repliée au-delà de ~5 lignes), `SpotTags`, `MyRatingStars`, `CommentComposer`, `CommentList`, `CommentTile`, `AuthorAvatar`, `SpotDetailSkeleton`, `SpotLoadError`, `SpotListTile` (liste temporaire).
- `AnimatedSwitcher` pour chargement → données et pour le changement d'étoiles ; arrivée animée d'un nouveau commentaire.
- Images : `CachedNetworkImage` avec `memCacheWidth` selon la largeur affichée, placeholder, et image d'erreur.
- Vidéos : lues en streaming, sans cache disque. Hors ligne, la vignette (en cache) reste visible et la lecture affiche un état d'erreur localisé.
- Accessibilité : `Semantics` sur les étoiles (« Noter 4 sur 5 »), `tooltip` sur les boutons icônes, cibles ≥ 48 dp.
- Couleur `accent` réservée aux étoiles de note moyenne et à l'état sélectionné, selon `ui-guidelines.md`. Les boutons d'action utilisent `action`.

**Point d'entrée temporaire** : `HomePage` affiche `watchRecentSpots(20)` sous forme de `SpotListTile` (vignette `Hero` + titre + note). Ce sera remplacé par le flux (§2.2) ; à signaler en commentaire et dans la PR.

**Textes** : clés slang sous `spot.*` (FR et EN), libellés de catégories, dates relatives localisées (`intl`).

## 7. Tests

Selon `docs/testing.md` :
- DTO / mappers (aller-retour Firestore ↔ entité, catégorie inconnue → `other`, photo / vidéo / média mal formé ignoré).
- Datasources avec `fake_cloud_firestore`.
- Repositories : conversion en `Failure`, spot absent → `NotFoundFailure`, cache vide hors ligne → `NetworkFailure`.
- Use cases : `RateSpot`, `AddComment` (trim), `DeleteComment`.
- `Rating` : refuse 0 et 6.
- Providers : `myRatingProvider` optimiste avec retour arrière en cas d'erreur ; pagination de `commentsProvider`.
- Widgets : `SpotDetailPage` en loading / data / error ; une vidéo affichée en vignette dans la galerie ; layout tablette (≥ 840) ; tap sur une étoile ; validation du `CommentComposer` ; bouton supprimer visible seulement sur mes commentaires ; désactivation hors ligne.
- Routeur : `/spots/:id` affiche la fiche.
- Functions : test du calcul d'agrégat si l'émulateur est disponible ; sinon, procédure de vérification manuelle documentée.

Fakes partagés dans `test/helpers/` (`FakeSpotRepository`, etc.).

## 8. Packages et docs

- Ajouts dans l'app : `video_player` (package officiel de l'équipe Flutter, seul moyen de lire une vidéo sans réécrire un lecteur natif ; à justifier dans le README) et `fake_cloud_firestore` (dev, déjà autorisé par `testing.md`). Côté `functions/` : `firebase-functions`, `firebase-admin`, `geofire-common`, `typescript`.
- Docs mises à jour dans le même changement : `architecture.md` (section Spot, breakpoints, réseau), `backend-firebase.md` (modèle de données, règles, Functions, seed, déploiement, contrat pour le formulaire §2.4), `testing.md` (nouveaux fakes), `README.md` (packages, Functions, procédure de seed), `CLAUDE.md` (commandes Functions/seed si ajoutées).

## 9. Commits

Mathis l'a demandé pour faciliter la review : des commits **petits et séparés**, chacun cohérent, qui compile et passe les tests (Conventional Commits, scope `spot`, `core`, `functions`…). Une couche ou une préoccupation par commit : par exemple domaine, puis data, puis règles, puis chaque Function, puis chaque widget ou section de la fiche, puis la doc qui va avec. Imposé :
- **`geohash`** (champ, mapping, Function, seed, doc) dans des commits à lui ;
- **`favoriteCount`** (champ, mapping, Function, doc) dans des commits à lui ;
- l'ajout de `video_player` dans un commit `build` séparé, avant le lecteur.

## 10. Laissé à l'implémentation

Découpage exact des datasources, noms des clés slang, durées d'animation, nombre de lignes de la description repliée, contenu précis du seed (dont le choix des vidéos), format des dates relatives, ordre exact des commits dans le respect du §9.
