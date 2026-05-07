# Codex Working Process Public V2

Derniere mise a jour : 2026-05-07

Ce document sert de contexte de travail pour les sessions Codex sur le chantier Public V2. Il encadre la refonte graphique du site public dans une zone isolee, sans impacter le site public classique ni l'Admin V2.

## Contexte

Projet : Rails 7 existant pour un site de stores, volets, fermetures, pergolas, moustiquaires et solutions de protection solaire.

Sprint courant : stabilisation de Public V2 apres validation de la direction **Warm System V9**.

Objectif principal : reconstruire Public V2 avec un design system clair, factorisable, premium, moderne, oriente devis, responsive, et limite au mode clair/sombre.

Documents a lire au debut d'un nouveau chat Codex sur Public V2 :

1. `docs/codex-working-process-public-v2.md`
2. `docs/public-v2-design-system.md`
3. `docs/codex-working-process.md`
4. `docs/admin-v2-design-system.md`

## Decisions Actees

- Public V2 reste isole sous `/public-v2/*`.
- Les routes reelles Public V2 sont :
  - `/public-v2/home`
  - `/public-v2/categories`
  - `/public-v2/produits/:slug`
  - `/public-v2/devis`
  - `/public-v2/contact`
  - `/public-v2/design-system`
- Les anciennes vues de test et de lab Public V2 ont ete supprimees de la base applicative.
- Le design valide est **Warm System V9**.
- Le Public V2 final doit garder uniquement le mode clair/sombre.
- Supprimer la logique de selection dynamique de couleur, d'accent et de police dans les prochaines etapes de refonte.
- Le design-system doit redevenir une reference propre du UI Kit et des composants, pas un espace de prototypes de pages.
- Les tests de layouts et explorations temporaires ne doivent pas rester dans le code applicatif final. Si une exploration est necessaire, elle doit etre isolee, nommee explicitement, puis supprimee apres validation.
- Le mode debug des composants est conserve sur toutes les pages Public V2 pendant la reconstruction.
- Le debug doit pouvoir s'activer globalement depuis le shell Public V2, sans repasser `debug: true` dans chaque vue.
- Pas de modification DB pour ce chantier.
- Ne jamais toucher au site public classique ni a l'Admin V2 dans ce sprint.

## Direction Warm System V9

La direction validee sert de reference visuelle pour la suite :

- ambiance : premium, design, moderne, structuree, chaleureuse, orientee devis ;
- typographie cible : police moderne et sobre proche de `Plus Jakarta Sans`, `DM Sans`, `Avenir Next`, Inter ;
- accent principal : chaud et visible, autour de `#ff3d12` ;
- accent attenue : surfaces claires chaudes type `#fff0e8`, bordures type `#ffc3ad` ;
- fonds clairs : nuances naturelles tres claires, par exemple `#fbf7ef`, `#fffdf7`, `#f2e8da` ;
- texte clair : base sombre chaude proche de `#1a1815`, texte secondaire proche de `#625f58` ;
- dark mode : chaud, lisible, premium, sans devenir trop noir ;
- formes : angles courts a moyens, pas de boutons trop ronds ou trop gros ;
- photos : presentes mais non dominantes, utiles au contexte metier ;
- contenus : textes courts, actionnables, metier, devis, conseil, technique, engagement.

## Etat Actuel

Structure actuelle :

- controller `PublicV2::BaseController` ;
- controller `PublicV2::PagesController` pour `home`, `contact`, `design_system` ;
- controllers `PublicV2::CategoriesController`, `PublicV2::ProductsController`, `PublicV2::QuotesController` ;
- layout `app/views/layouts/public_v2.html.erb` ;
- vues reelles dans `app/views/public_v2` ;
- composants dans `app/components/public_v2` ;
- presenters dans `app/presenters/public_v2` ;
- CSS dedie `app/assets/stylesheets/public_v2.css` ;
- entree JS `app/javascript/public_v2/application.js`.

Routes Public V2 actives :

- `GET /public-v2/home`
- `GET /public-v2/categories`
- `GET /public-v2/produits/:slug`
- `GET /public-v2/devis`
- `POST /public-v2/devis`
- `GET /public-v2/contact`
- `GET /public-v2/design-system`

Le formulaire devis Public V2 doit continuer a inclure les produits classiques et les produits de destockage.

## Architecture Cible

Les pages Public V2 doivent etre reconstruites avec deux niveaux de composants :

- composants de section : structure, rythme, composition responsive, placement des medias, pression devis ;
- composants micro/UI Kit : boutons, badges, panels, cards, medias, rails de preuve, stats, champs de formulaire, elements de navigation.

Regles Rails Public V2 :

- les controllers chargent les records, scopes, includes et limits ;
- les presenters `PublicV2::*Page` preparent les donnees d'affichage ;
- les vues assemblent des composants, sans requetes ni preparation metier ;
- les ViewComponents ne font pas de requetes metier ;
- les constantes transverses passent par un service Public V2 dedie ;
- les chemins et images derives passent par presenter ou helper selon le niveau de responsabilite ;
- le CSS Public V2 reste scope sous `.public-v2`.

## Debug Components

Le debug de layout est un outil officiel pendant la reconstruction Public V2.

Regles :

- `PublicV2::BaseController#load_public_v2_shell_context` porte l'activation globale via `@public_v2_debug`.
- `public_v2_debug?` est expose comme helper.
- `PublicV2::Debuggable` lit ce helper et ajoute les classes/data attributes de debug.
- Les vues reelles ne doivent pas repasser `debug: true` a chaque composant.
- Pour couper le debug partout, changer uniquement la ligne d'activation globale dans `PublicV2::BaseController`.
- Un composant compatible debug doit utiliser `debug_class`, `debug_data` ou `with_debug_data`.
- Le rendu debug doit rester purement visuel, sans modifier la logique metier.

## Design System

La page `/public-v2/design-system` doit devenir la reference propre du nouveau systeme :

- fondations visuelles Warm System V9 ;
- light/dark uniquement ;
- UI Kit complet ;
- composants de navigation, footer, sections, formulaires, cards, panels, medias, feedback et composants metier ;
- exemples avec donnees reelles quand cela aide a juger ;
- pas de prototypes de pages ;
- pas d'ancienne bibliotheque de layouts ;
- pas de switch d'accent ou de police dynamique.

La documentation detaillee du design system doit etre mise a jour pendant l'etape dediee, apres stabilisation des composants.

## Pages A Reconstruire

Les vues Public V2 a reconstruire avec le systeme valide :

- home : premium, devis, photo forte mais non dominante, parcours clair ;
- categories/index : comparer les familles, orienter vers produit ou devis ;
- product/show : page la plus riche, informations metier, techniques, options, preuves, CTA devis ;
- devis : formulaire clair, rassurant, rapide, oriente retour commercial ;
- contact : showroom, acces, contact direct, conseil.

## Regles D'Iteration

- Faire un audit avant les changements importants.
- Nommer clairement le step en cours.
- Ne pas melanger exploration temporaire, design-system et vues reelles.
- Une direction validee peut etre integree dans les vraies vues.
- Apres integration, supprimer les artefacts temporaires.
- Garder les textes courts mais enrichis en contexte metier.
- Chercher la densite juste : pas vide, pas compact au point de perdre le premium.
- Mobile obligatoire : ordre logique, sections pas trop hautes, pas de texte qui deborde.

## Validation

Regles de validation :

- ne pas lancer de serveur Rails par defaut ;
- pour une etape UI/front importante, Codex peut lancer un serveur temporaire dedie, idealement `127.0.0.1:3020`, faire les captures utiles, puis le couper avant de rendre la main ;
- pour les steps que l'utilisateur teste lui-meme en local, ne pas lancer de serveur Rails ;
- valider les GET avec `bin/rails runner` quand utile ;
- ne pas POSTer `/public-v2/devis` pendant les validations automatiques ;
- verifier les reliquats CSS/vues/routes apres chaque gros nettoyage ;
- verifier `git diff --check` avant de cloturer un step important.

## Securite Projet

Par defaut, ne pas faire :

- migration ;
- reset DB ;
- modification destructive de donnees ;
- installation de gem/package ;
- ajout de dependance ;
- commit ;
- push ;
- lancement de serveur si l'utilisateur dit qu'il valide lui-meme ;
- serveur Rails laisse actif en arriere-plan ;
- refonte des modeles ;
- refonte du site public classique ;
- refonte de l'admin classique ;
- refonte de l'Admin V2.

Ne jamais lancer :

- `rails db:migrate`
- `rails db:reset`
- `bundle install`
- `npm install`, `yarn install`, `pnpm install`, `bun install`
- `rails db:*`
- commandes destructives type `rm`, `git reset --hard`, `git checkout --` sans demande explicite.

## Fin De Step Important

Avant de cloturer une etape importante, faire une revue courte :

- est-ce qu'une requete peut etre reduite, prechargee ou deplacee hors de la vue ?
- est-ce qu'un pattern front se repete assez pour meriter une extraction ?
- est-ce qu'une factorisation maintenant rendrait le design moins flexible ?
- est-ce qu'un selecteur CSS, Stimulus ou helper risque de fuiter hors `.public-v2` ?
- est-ce qu'on doit documenter une decision de design system ou de process ?

Ne pas factoriser par reflexe : extraire quand le pattern est repete ou stabilise, garder l'ERB direct pour les compositions specifiques encore mouvantes.

## Isolation Public V2

Toujours privilegier les fichiers dans :

- `app/controllers/public_v2`
- `app/views/public_v2`
- `app/views/layouts/public_v2.html.erb`
- `app/javascript/public_v2/application.js`
- `app/javascript/public_v2/controllers`
- `app/assets/stylesheets/public_v2.css`
- `app/components/public_v2`
- `app/presenters/public_v2`

Interdits dans ce sprint sans demande explicite :

- `app/controllers/admin*`
- `app/views/admin*`
- `app/components/admin*`
- vues/controllers du public classique
- modeles et migrations
