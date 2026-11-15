## Projet Flutter

Voici les sujets et consignes pour le projet de fin de module Flutter programmation multiplateforme.

## Les consignes

Veuillez lire attentivement les consignes suivantes avant de démarrer votre projet :

- Constitution des équipes : Vous devez former des groupes de 3 personnes maximum. Des équipes de 2 personnes sont autorisées uniquement si le nombre d'étudiants de la classe l'impose.

- Choix du sujet : Deux sujets distincts vous sont proposés dans la suite de ce document. Vous devez choisir un seul sujet à réaliser en équipe.

- Répartition du travail : La charge de travail doit être répartie de manière équitable entre l'ensemble des membres du groupe. Chaque étudiant sera évalué sur sa contribution personnelle ainsi que sur le livrable global.

- L’usage de l’AI : L’usage de l’IA est autorisé et recommandé. Tout code doit pouvoir être expliqué et modifié lors de la soutenance.

- Livraison du projet : Le projet devra être mis à disposition pour évaluation au moins 2 semaines avant la date de soutenance dans un dépôt git avec toutes ses dépendances.

- Soutenance : La soutenance a une durée de 15 minutes et se déroulera selon le planning suivant :

- 3 min de démonstration sur un device physique

- 12 min de questions/réponses

## Les livrables attendus au plus tard le 01/01/2027

Les projets doivent être fournis avec les éléments suivants à la date d'échéance :

- Dépôt Git public ou accessible :

- Historique de commits propre, atomique et structuré selon les normes Conventional Commits.

- Recommandation : Utilisation de branches de fonctionnalités (feature branches) et de Pull Requests révisées entre pairs.


- Fichier README.md professionnel :

- Présentation du projet, captures d'écran (modes clair et sombre), diagramme d'architecture et modèle de données (diagramme de classes / entités).

- Tableau synthétique de répartition des tâches réalisées par chaque membre de l’équipe.

- Procédure d'installation et de build étape par étape.

- Gestion des variables d'environnement (ex. : clés d'API cartographiques).

- Documentation des choix techniques clés et des packages tiers retenus.

- Démonstration lors de la soutenance :

- Démonstration fonctionnelle en direct (Live Demo) sur terminal physique.

- Passage en revue du code source et modification de fonctionnalités durant la soutenance.

## Les deux sujets au choix

- Le Sujet 1 (« SpotShare ») est davantage orienté vers une architecture logicielle d'entreprise et des services cloud (Clean Architecture, gestion d'état réactive, persistance locale, mode hors-ligne et intégration complète de Firebase).

- Le Sujet 2 (« Game ») est davantage axé sur la performance bas niveau et l'optimisation temps réel (gestion de la boucle de jeu, fluidité graphique à 60/120 FPS, mathématiques de collision et gestion de la mémoire pour éviter les saccades).


## Sujet 1 : Application sociale « SpotShare »

## 1. Contexte & objectifs du projet

Contexte : Conception et développement d'une application sociale mobile et multiplateforme axée sur le référencement, la découverte et le partage communautaire de points d'intérêt ou « spots » (cafés de spécialité, points de vue panoramiques, œuvres de street art, restaurants insolites, parcs urbains).

Objectif pédagogique : Démontrer une maîtrise avancée de l'écosystème Flutter et des fonctionnalités modernes du langage Dart 3 à travers la livraison d'une application à l'architecture robuste, réactive, performante, résiliente aux pannes réseau et intégralement testée.

## 2. Périmètre fonctionnel (User Stories & fonctionnalités clés)

L'application s'articule autour de 6 axes fonctionnels devant être répartis équitablement au sein de l'équipe :

## 2.1. Authentification & Gestion du Profil

- Création de compte & Connexion : Identification sécurisée via e-mail/mot de passe ou fournisseurs tierces (OAuth).

- Gestion du profil : Consultation et édition du profil utilisateur (avatar, bio, préférences).

- Tableau de bord individuel : Historique des spots créés par l'utilisateur et liste d'accès rapide aux spots mis en favoris.

## 2.2. Flux Immersif & Découverte Visuelle

- Feed vertical immersif : Flux principal de contenu défilant plein écran (inspiré d'Instagram/TikTok) mettant à l'honneur les photos et vidéos courtes des spots.

- Interactions directes sur le flux : Prise en charge de la notation, des commentaires et des favoris directement depuis les cartes d'affichage du flux principal.

- Exploration cartographique secondaire : Vue carte optionnelle accessible en mode secondaire pour visualiser la localisation des spots à proximité et filtrer par proximité géolocalisée.

## 2.3. Fiche Lieu / Spot (« Detail View »)

- Informations détaillées : Titre, description riche, catégorie, adresse exacte, note moyenne et tags associés.


- Galerie média : Carrousel interactif d'images haute résolution supportant le swipe et l'agrandissement plein écran.

- Avis & Interactions : Consultation des notes et avis déposés par la communauté.

## 2.4. Création & Édition de Spot

- Formulaire dynamique : Saisie contrôlée avec validation en temps réel des champs requis.

- Sélection & Annotation Média : Prise de photo directe via l'appareil ou sélection depuis la galerie avec prévisualisation et possibilité d'annoter les photos en dessinant directement dessus.

- Localisation du spot : Attribution automatique du lieu par géolocalisation GPS ou recherche textuelle d'adresse lors de la création.

## 2.5. Interactions Sociales & Partage

- Engagements : Ajout/Retrait de spots dans les favoris (« Likes ») et rédaction de commentaires interactifs.

- Partage externe : Génération de Deep Links ou appel au Share Sheet natif du système pour partager un spot vers d'autres applications.

## 2.6. Mode Offline & Persistance Locale

- Cache de consultation : Consultation hors-ligne des spots pré-chargés et des images associées.

- Base de données locale : Stratégie de synchronisation permettant une navigation continue en l'absence de réseau mobile.

- Capture hors-ligne & synchronisation différée : Prise de photo d'un spot en mode offline avec stockage local temporaire et synchronisation automatique dès le rétablissement de la connexion réseau.

## 3. Exigences techniques & spécificités Flutter & Dart

## 3.1. Découpage de l'arbre de widgets & UI déclarative

- Modularité stricte : Décomposition obligatoire des composants UI. Tout bloc de code de méthode build() dépassant 80 lignes doit être refactorisé en widgets isolés (StatelessWidget).

- Immutabilité & optimisation : Usage systématique des constructeurs const sur l'ensemble de l'arbre statique pour minimiser les allocations mémoire.


- Choix des composants : Utilisation préférentielle de StatelessWidget, combinée à une gestion d’état robuste.

## 3.2. Gestion d'état & architecture réactive

- Architecture en couches (Clean Architecture / Layered) :

- a. Presentation Layer : Widgets, Controllers/Notifiers, UI Logic.

- b. Domain Layer : Entities, Value Objects, Use Cases / Interactors.

- c. Data Layer : DTOs, Mappers, Data Sources (Remote API / Local Database).

- d. Repository Pattern : Abstraction totale des sources de données vis-à-vis du domaine.

- Gestion d'état robuste : Utilisation obligatoire de Riverpod ou BLoC / Cubit.

- Rebuilds chirurgicaux : Interdiction d'utiliser des setState globaux ou de reconstruire une page entière pour une modification d'état locale (ex. : basculement d'un bouton favori).

- États asynchrones explicites : Modélisation systématique via AsyncValue ou des Sealed Classes couvrant obligatoirement les cas : Initial, Loading, Data, Error.

## 3.4. Performance graphique & expérience sensorielle

- Fluidité d'affichage : Maintien d'un taux d'affichage constant de 60/120 fps. Zéro jank toléré lors du défilement des listes ou des manipulations de carte.

- Animations fluides : Mise en œuvre d'animations Hero lors des transitions entre les éléments de liste/carte et la fiche détaillée. Et, par exemple, utilisation d'AnimatedSwitcher pour les transitions d'état.

- Gestion mémoire des médias : Utilisation de CachedNetworkImage pour le chargement, le dimensionnement optimisé et la mise en cache des images distantes.

## 3.5. Responsive design, localisation & conformité écosystème

- Adaptabilité multi-écrans : Layout adaptatif fonctionnel sur téléphones de toutes tailles et tablettes/grands écrans via LayoutBuilder, OrientationBuilder ou MediaQuery.


- Conformité Material 3 & accessibilité : Respect strict des zones sécurisées (SafeArea), thématisation complète supportant explicitement le mode Clair et le mode Sombre.

- Localisation de l’application : Les interfaces de l’application doivent supporter deux langues FR et EN. La langue choisie par l’utilisateur doit être persisté.

- Application multiplateforme : L’application doit impérativement fonctionner sur smartphone Android et iOS.

## 4. Architecture & services Backend (Firebase)

## 4.1. Authentification & gestion des utilisateurs

- Firebase Authentication : Gestion sécurisée des sessions utilisateur (email/mot de passe et OAuth) avec persistance des jetons d'accès (JWT).

## 4.2. Base de données Cloud & synchronisation

- Cloud Firestore : Base de données NoSQL orientée documents pour la gestion en temps réel des spots, commentaires et données de profil.

- Règles de sécurité : Restriction des accès en lecture/écriture en fonction du rôle et de l'état d'authentification de l'utilisateur.

## 4.3. Fonctions serverless & sécurisation des secrets

- Cloud Functions : Déploiement de fonctions serverless pour exécuter la logique métier critique du côté serveur.

- Masquage des clés d'API : Encapsulation des requêtes sensibles (notamment la clé d'API cartographique) dans des Cloud Functions pour éviter de les exposer directement dans le code client Flutter.

## 5. Grille d'évaluation détaillée & barème de notation

Le projet sera évalué sur une échelle de 100 points (convertie sur 20 points pour la note finale) selon la répartition explicite suivante :


| Domaine d'évaluation | Critères d'exigence & Attendus | Barème |
| --- | --- | --- |
| 1. Architecture & Gestion d'État | • Respect de la séparation en couches | 10 pts |
|   | (Presentation, Domain, Data, Repositories).• |   |
|   | Implémentation correcte de Riverpod ou |   |
|   | BLoC avec découpage fin des |   |
|   | responsabilités.• Rebuilds isolés au |   |
|   | composant strict sans re-rendu superflu de la |   |
|   | page.• Gestion explicite et propre des états |   |
|   | asynchrones (Loading, Data, Error). |   |
| 2. UI, Arbre de Widgets & | • Modularité de l'arbre UI (absence de | 8 pts |
| Ergonomie | widgets monolithiques > 80 lignes).• Usage |   |
|   | rigoureux du mot-clé const sur l'ensemble |   |
|   | du projet.• Responsive Design éprouvé |   |
|   | (mobiles et tablettes).• Intégration complète |   |
|   | d'un thème Material 3 (Modes Clair et |   |
|   | Sombre).• Localisation (support des deux |   |
|   | langues FR et EN avec persistance).• Fluidité |   |
|   | des animations (transitions Hero, |   |
|   | micro-interactions). |   |
| 3. Services Backend & Base de | • Authentification Firebase sécurisée avec | 8 pts |
| Données | gestion des sessions.• Utilisation adéquate |   |
|   | de Cloud Firestore et définition de règles de |   |
|   | sécurité strictes.• Déploiement de Cloud |   |
|   | Functions pour la logique serveur critique et |   |
|   | le masquage des clés d'API. |   |
| 4. Périmètre Fonctionnel & | • Fonctionnalités de carte, géolocalisation et | 8 pts |
| Intégration | clustering fluides et opérationnelles.• |   |
|   | Formulaire de création complet avec capture |   |
|   | photo et validation des données.• |   |
|   | Persistance hors-ligne des spots.• |   |
|   | Interactions sociales fonctionnelles (favoris, |   |
|   | commentaires, partage). |   |
| 5. Tests, Robustesse & Outillage | • Tests unitaires couvrant les Repositories, | 6 pts |
|   | Use Cases et Providers/Blocs.• Tests de |   |
|   | widgets sur les composants critiques (ex: |   |
|   | Carte, Fiche lieu, Formulaires). |   |
| 6. Soutenance & Travail | • Historique Git clair, équilibré entre les 3 | 60 pts |
| d'Équipe | membres (Conventional Commits).• |   |
|   | Démonstration live fluide sur émulateur ou |   |
