# Admin V2 Design System

Derniere mise a jour : 2026-05-04

Ce document decrit le design system experimental construit pour l'Admin V2 du store. Il sert de reference pour garder une interface coherente quand on ajoute un nouveau modele, un nouveau composant ou un nouveau flux Hotwire.

## Vision

Nom de direction : **Graphite Store Console**.

L'Admin V2 est une zone experimentale isolee, pensee pour tester une nouvelle interface admin premium, dense et reactive, sans casser l'admin classique ni le site public.

Objectifs principaux :

- interface desktop first, non orientee mobile ;
- experience fullpage, sans scroll global du body ;
- sidebar gauche fixe, main central dynamique, context drawer droit permanent ;
- CRUD fluide via Turbo, Stimulus et ViewComponent ;
- autosave cible plutot que submit global quand le modele s'y prete ;
- dark mode graphite calme, lisible et technique ;
- design system modulaire, facile a modifier globalement.

Non-objectifs :

- ne pas refaire tout le backend ;
- ne pas remplacer l'admin classique ;
- ne pas refondre les modeles existants ;
- ne pas imposer Action Cable ou une persistance de logs ;
- ne pas ajouter de charts marketing ou de dashboard statistiques inutiles.

## Isolation

L'Admin V2 doit rester separe du reste de l'application.

Convention actuelle :

- namespace Ruby : `AdminV2`
- routes : `/admin-v2`
- layout : `app/views/layouts/admin_v2.html.erb`
- composants : `app/components/admin_v2`
- vues : `app/views/admin_v2`
- controllers : `app/controllers/admin_v2`
- Stimulus controllers : `app/javascript/admin_v2/controllers`
- CSS dedie : `app/assets/stylesheets/admin_v2.css`

Regle importante : creer de nouveaux fichiers Admin V2 plutot que modifier ou reutiliser les vues de l'admin classique. Le backend existant peut etre lu et appele, mais la surface UI/Hotwire V2 doit rester autonome.

## Layout

Le shell Admin V2 est organise en trois zones :

1. **Sidebar gauche**
   - navigation store ;
   - theme couleur dynamique ;
   - mode typographique ;
   - liens vers Produits, Categories, Events, RALs, Devis ;
   - item actif en texte accent non attenue, sans fond lourd.

2. **Main central**
   - frame principal : `admin_v2_main` ;
   - index, edit complexe ou workspace principal ;
   - scroll interne uniquement ;
   - header sticky ;
   - search live quand utile ;
   - tables ou row-cards selon le modele.

3. **Context drawer droit**
   - frame : `admin_v2_drawer` ;
   - contexte permanent ;
   - live feed session en haut ;
   - show, new, preview, CRUD associe ou resume ;
   - scroll interne uniquement ;
   - fond grille autorise dans le drawer, mais pas derriere les logs.

## Palette Et Tokens

La palette est definie via variables CSS dans `admin_v2.css`.

Principes :

- fond global graphite froid, jamais noir pur ;
- surfaces zinc/bleutees ;
- bordures tres fines en blanc faible ;
- accent dynamique base sur `--g-accent-rgb` ;
- micro-couleurs reservees aux statuts, logs, focus et feedback serveur.

Tokens importants :

- `--g-bg`
- `--g-bg-soft`
- `--g-surface`
- `--g-surface-raised`
- `--g-surface-hover`
- `--g-surface-inset`
- `--g-border`
- `--g-border-strong`
- `--g-text`
- `--g-muted`
- `--g-subtle`
- `--g-faint`
- `--g-accent-rgb`
- `--g-accent`
- `--g-accent-soft`
- `--g-accent-border`
- `--g-accent-hover`
- `--g-accent-text`

La couleur primaire doit rester modifiable via une seule source : `--g-accent-rgb`. Les composants doivent utiliser les tokens, pas des couleurs violettes hardcodees.

## Typographie

Le mode typographique est dynamique :

- mode sans : interface standard ;
- mode mono : toute l'interface passe en mono.

Les composants ne doivent pas forcer une police locale inutilement. Les exceptions doivent etre intentionnelles, par exemple timestamps ou IDs, mais le mode global doit pouvoir tout changer.

Usage recommande :

- titres de panels : uppercase, tracking large, couleur accent ;
- sous-titres de panels : meme logique typographique, plus petit et plus discret ;
- IDs, timestamps, routes serveur : mono naturel ;
- textes de formulaire : lisibles, pas trop petits.

## Composants ViewComponent

Les composants generiques vivent dans :

```text
app/components/admin_v2/ui
```

Composants UI actuels ou attendus :

- `ButtonComponent`
- `BadgeComponent`
- `PanelComponent`
- `ActionStateComponent`
- `DateTimePickerComponent`
- loaders SVG reutilisables
- futurs inputs ou controls partages si duplication reelle.

Les composants metier vivent par ressource :

```text
app/components/admin_v2/products
app/components/admin_v2/events
app/components/admin_v2/quotes
app/components/admin_v2/categories
```

Regle d'abstraction :

- garder un composant specifique tant qu'il porte du metier ;
- extraire en `ui` seulement quand au moins deux ressources ont le meme besoin ;
- eviter les composants trop parametrables qui deviennent plus durs a lire que le HTML ;
- preferer des variants simples et nommes plutot qu'une grande liste de classes injectees partout.

## Panels

Le pattern standard d'un bloc est :

- `PanelComponent`
- titre accent ;
- sous-titre discret ;
- action area a droite du header ;
- contenu dense, clair, scroll local si necessaire.

Les actions de panel peuvent contenir :

- bouton icon-only ;
- upload state ;
- `ActionStateComponent` ;
- badge count ;
- lien vers drawer.

Les panels doivent etre autonomes. Si une action sauvegarde uniquement le panel, elle ne doit pas re-render brutalement toute la page.

## Feedback Et Autosave

Patterns existants :

- `autosave-field` : submit au blur si la valeur a change ;
- `inline-form` : submit local, classe pending pendant la requete ;
- `toggle-association` : submit au clic/change pour radio ou checkbox ;
- `action-state` : etat visuel `saving`, `saved`, `error` dans le header du bloc.

Regle UX :

- pas de submit global sauf cas exceptionnel ;
- chaque action sauvegarde sa section ;
- le feedback doit etre visible mais compact ;
- les erreurs doivent re-render le panel concerne, pas toute l'interface ;
- les succes peuvent remplacer une row, un header de drawer, un badge ou un compteur.

## Turbo Frames Et Streams

Frames stables :

- `admin_v2_main`
- `admin_v2_drawer`
- `admin_v2_products_results`
- `admin_v2_events_results`
- `admin_v2_quotes_results`
- `admin_v2_categories_results`

Patterns de reponse :

- navigation sidebar : replace `admin_v2_main` + store nav active ;
- recherche live : replace seulement le results frame ;
- show : charge dans `admin_v2_drawer` ;
- create simple : replace index/main + replace drawer show + replace nav + live feed ;
- autosave : replace row + header drawer ou panel concerne + live feed.

Attention : les routes appelees par Turbo Stream doivent toujours rendre des targets presents sur la page courante. Si le target peut etre absent, le stream doit rester sans effet destructeur.

## Pagination

Les index Admin V2 utilisent une pagination maison, sans gem externe.

Pieces principales :

- `AdminV2::Pagination` pour calculer `page`, `per_page`, `offset`, `total_count` et les records limites ;
- `AdminV2::Ui::PaginationComponent` pour le rendu des controles ;
- params standards : `query`, filtres eventuels, `page` ;
- les liens de pagination ciblent le turbo-frame results de la ressource.

Regles :

- le search-live remplace uniquement le frame results ;
- une nouvelle recherche repart naturellement en page 1 car le formulaire n'envoie pas `page` ;
- les liens de pagination conservent `query` et les filtres actifs ;
- ne pas paginer dans le composant row : la pagination se fait dans le controller, avant le rendu ;
- garder `per_page` fixe au debut pour eviter une UI trop bavarde.

## Live Feed

Le live feed reste **session-only**, mais peut maintenant s'appuyer sur une session Admin V2 persistante et legere :

- session courante : `AdminV2Session` ;
- evenements courts : `AdminV2SessionEvent` ;
- pas de modele global `ActivityLog` ;
- pas d'Action Cable obligatoire ;
- logs scopes sur l'Admin V2 et le user connecte ;
- compteurs denormalises sur la session pour garder le footer leger.
- retention par session : garder environ les 1000 derniers events utiles et supprimer les anciens au fil de l'eau ;
- contexte courant : area + ressource ouverte quand il y en a une.

Il sert a donner une sensation vivante :

- frame loaded ;
- submit success/error ;
- autosave ;
- upload ;
- reorder ;
- create/update/delete V2.

Le format debug affiche volontairement des informations compactes :

- source : `client`, `form`, `turbo`, `server`, `system` ;
- type : `session`, `frame`, `submit`, `response`, `create`, `autosave`, `upload`, etc. ;
- meta : methode HTTP, status code, ressource concernee si disponible.

Ne pas y mettre de donnees sensibles inutilement. Preferer `Product#id`, `Quote#id`, `Category#id` a des emails, telephones ou contenus prives.

Le feed visible peut encore recevoir des evenements client via Stimulus pour garder une sensation instantanee, mais les evenements serveur importants doivent passer par le tracker Admin V2 afin d'alimenter le rapport de session.

## Session Storage

La maintenance des sessions Admin V2 est une action manuelle dans l'interface, pas une tache automatique.

Pattern retenu :

- bloc accordeon `Session storage` dans la section `Configuration` de la sidebar ;
- affichage compact des sessions, events, sessions gardees et sessions purgeables ;
- purge volontaire via confirmation Turbo ;
- scope strict sur le user connecte ;
- conservation des 4 dernieres sessions, avec protection de la session courante ;
- suppression des sessions plus anciennes et de leurs events via `dependent: :destroy` ;
- retour Turbo : mise a jour du bloc storage, du rapport user et ajout d'un event dans le live feed.

Ne pas afficher d'IP, user-agent ou details sensibles dans ce bloc. Ces informations peuvent exister en base pour debug, mais l'UI de sidebar doit rester sobre.

## Patterns Par Ressource

### Products

Produit est le modele complexe.

Pattern :

- index dans main ;
- new minimal dans drawer ;
- apres create, ouverture de l'edit V2 complet ;
- edit complexe dans `admin_v2_main` ;
- drawer pour resume/contexte ou sous-vues medias/docs/options ;
- autosave par sections ;
- medias/docs avec upload state dans le header ;
- options et configuration couleur dans panels dedies.

Ne pas fusionner la logique RAL directe historique dans l'edit Product. La configuration couleur V2 passe par la logique `ProductColorPart`, `ColorPalette`, `ColorPaletteItem`.

### Events

Modele simple.

Pattern :

- index ;
- new dans drawer ;
- create termine dans le drawer avec show ;
- edit dans le drawer, pas de workspace central dedie ;
- date picker custom Admin V2 ;
- autosave pour details et schedule ;
- succes autosave : row index, header drawer, preview et statut calcule mis a jour par Turbo Streams.

### Quotes / Devis

Modele issu du formulaire public.

Pattern :

- pas de create V2 ;
- pas d'edit complet ;
- index + show drawer ;
- toggle `processed` dans le drawer avec autosave ;
- pas de delete dans V2 pour l'instant.

### Categories

Modele simple.

Pattern :

- index + search live ;
- new minimal dans drawer ;
- create met a jour index + sidebar + drawer show ;
- autosave `name` et `description` au blur ;
- autosave `color` au clic dans une palette controlee ;
- produits rattaches affiches en lecture avec liens vers Product V2.

Compteur produits : compter les produits store classiques, donc `Product.where(type: nil)`, pour eviter de melanger avec `DestockProduct`.

## Index Et Row Cards

Le style retenu pour les index store est une row-card dense :

- pas de table HTML classique par defaut ;
- ligne arrondie avec gradient accent tres subtil a gauche ;
- titre principal fort ;
- sous-ligne `Resource#id · contexte` ;
- chips a droite ;
- actions icon-only ;
- hover accent discret ;
- pas de photo a gauche pour l'index Products retenu.

Ce pattern sert de base pour Products, Events, Devis et Categories.

## Forms

Regles :

- labels petits et lisibles ;
- inputs graphite ;
- focus accent ;
- textarea non resize si le layout doit rester stable ;
- radio/checkbox transformes en badges cliquables quand l'usage est selectionnel ;
- boutons de creation dans le header d'index ou de panel si l'action est contextuelle.

New simple :

- formulaire dans drawer ;
- peu de champs ;
- apres create, afficher le show drawer ;
- pas de redirection vers edit sauf modele complexe comme Product.

## Accessibilite Minimum

A maintenir :

- focus visible via `admin-v2-focus` ;
- boutons icon-only avec `sr-only` et `title` ;
- contrastes suffisants ;
- champs avec labels ;
- zones cliquables pas trop petites ;
- pas de texte qui deborde hors conteneur ;
- widths stables pour elements de header afin d'eviter les shifts.

## Performance

Points a surveiller :

- index Products peut charger beaucoup d'Active Storage ;
- toujours precharger ce qui est affiche dans les rows ;
- search live doit remplacer uniquement le results frame ;
- eviter de compter via associations dans une boucle ;
- pour Categories, preferer un count agrege des produits store ;
- ne pas ajouter de polling ou WebSocket tant que ce n'est pas necessaire.

## Maintenance

Ce document doit etre mis a jour quand :

- un nouveau modele entre dans Admin V2 ;
- un nouveau composant UI devient reutilisable ;
- un pattern Hotwire est change ;
- une contrainte UX est ajoutee ou retiree ;
- le comportement create/edit/show d'une ressource change ;
- la palette, la typographie ou le layout evolue.

Avant un gros changement, relire ce document et verifier que le changement respecte l'isolation Admin V2.
