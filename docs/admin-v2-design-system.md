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
   - le drawer du shell utilise `AdminV2::Ui::BackgroundGridComponent` comme repere permanent de composition.
   - l'etat vide du drawer utilise `AdminV2::DrawerEmptyStateComponent`, une surface compacte visuellement encastree dans la grille et alignee sur ses divisions.

## Palette Et Tokens

La palette est definie via variables CSS dans `admin_v2.css`.

Principes :

- fond global graphite froid, jamais noir pur ;
- surfaces zinc/bleutees ;
- bordures tres fines en blanc faible ;
- accent dynamique base sur `--g-accent-rgb` ;
- micro-couleurs reservees aux statuts, logs, focus et feedback serveur.

Theme par defaut :

- accent Lime : `--g-accent-rgb: 190, 242, 100` ;
- texte accent clair : `--g-accent-text: #efffd1` ;
- typographie globale : mono.

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

Le mode mono est le choix par defaut de l'Admin V2. Le selecteur reste dynamique et permet de repasser en sans pendant la session.

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

### Background Grid

`AdminV2::Ui::BackgroundGridComponent` rend une grille fixe en overlay absolute. Le composant n'est plus parametrique : la forme de grille est une convention du design system, exposee en CSS.

Usage :

- le parent doit etre `relative` et gerer son `overflow` ;
- le composant est `pointer-events-none` et se place en `absolute inset-0` ;
- le contenu du bloc doit rester au-dessus avec `relative z-10` ;
- la couleur par defaut utilise l'accent dynamique via `rgb(var(--g-accent-rgb))`.
- dans le drawer, la grille vit dans le shell, en dehors du frame remplace par Turbo, afin de rester visible pendant les navigations show/new/edit.

Tokens :

- `--admin-v2-drawer-width: 504px` ;
- `--admin-v2-grid-unit: 21px` ;
- `--admin-v2-layout-unit: 32px` ;
- `--admin-v2-grid-line-width: 1px` ;
- `--admin-v2-grid-opacity: 0.045`.

La largeur drawer de 504px donne exactement 24 colonnes de 21px, sans valeur decimale et sans reserve laterale. La hauteur reste fluide : la grille part du haut et la derniere ligne peut etre coupee en bas. Les nouveaux elements alignes sur la grille fine doivent utiliser des positions et dimensions en multiples de `--admin-v2-grid-unit`.

Les blocs deja calibres sur l'ancienne grille 16 colonnes peuvent rester temporairement sur `--admin-v2-layout-unit` pour eviter une regression visuelle brutale. Quand un drawer est retravaille, il peut migrer vers la grille fine de 24 colonnes.

Regle de placement texte sur la grille :

- ne pas caler directement un texte sur la grille ;
- caler une box en multiples de `--admin-v2-grid-unit`, puis aligner le texte dedans avec `flex` ;
- les titres uppercase tiennent en general sur une box de 1 cellule avec `line-height: var(--admin-v2-grid-unit)` ;
- les textes lowercase peuvent garder le meme line-height, avec un ajustement optique leger type `-translate-y-0.5` si la baseline parait trop basse ;
- eviter les borders inset et shadows pour les blocs calibres : preferer des borders classiques.

`admin-v2-grid-bg` reste disponible comme fond legacy pour certains ecrans hors drawer, mais les frames drawer ne doivent plus l'utiliser.

Composants UI actuels ou attendus :

- `ButtonComponent`
- `BadgeComponent`
- `BackgroundGridComponent`
- `DrawerEmptyStateComponent`
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

## Uploads Media Et Documents

Les uploads Admin V2 gardent le flux Active Storage direct upload vers Cloudinary.

Pattern retenu :

- pre-validation Stimulus avant `DirectUpload` pour bloquer les fichiers trop lourds ou les formats manifestement invalides ;
- validation serveur au moment d'attacher le blob au produit ;
- limites et types autorises centralises dans `AdminV2::UploadPolicy` ;
- les vues injectent les limites dans `upload_controller` via data attributes ;
- les inputs gardent un attribut `accept` coherent avec la policy ;
- les erreurs serveur renvoient un Turbo Stream de feedback, sans casser le panel ni le drawer ;
- les blobs refuses cote serveur sont purges s'ils ne sont pas deja attaches.

Limites actuelles :

- images produit : 12 MB, JPG/PNG/WEBP ;
- documentations : 25 MB, PDF/JPG/PNG/WEBP.

Le live feed doit rester explicite :

- fichier bloque cote client : taille ou format ;
- direct upload echoue : erreur reseau, storage ou Cloudinary ;
- attach serveur refuse : signed id invalide, blob absent, type non autorise ou fichier trop lourd.

Ne pas remplacer ce flux par un upload custom tant que Cloudinary et Active Storage font le travail correctement.

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

## Confirmations Destructives

Une modale de confirmation Admin V2 existe en mode opt-in pour tester le remplacement progressif du confirm natif navigateur.

Pattern actuel :

- Turbo garde le comportement natif par defaut ;
- la modale custom ne s'active que sur les formulaires avec `data-admin-v2-confirm="true"` ;
- les actions non migrees continuent d'utiliser `data-turbo-confirm` natif ou leur comportement existant ;
- le premier perimetre valide est la suppression depuis les rows de l'index Events ;
- le live feed reste alimente par les Turbo Streams serveur apres confirmation.

Ne pas generaliser cette modale aux attachments pour l'instant : les suppressions medias et documentations gardent leur comportement direct.

## Patterns Par Ressource

### Products

Produit est le modele complexe.

Pattern :

- index dans main ;
- new minimal dans drawer ;
- apres create, ouverture de l'edit V2 complet ;
- edit complexe dans `admin_v2_main` ;
- drawer pour resume/contexte ou sous-vues medias/docs/options/RALs de partie ;
- autosave par sections ;
- medias/docs avec upload state dans le header ;
- options et configuration couleur dans panels dedies.

Ne pas fusionner la logique RAL directe historique dans l'edit Product. La configuration couleur V2 passe par la logique `ProductColorPart`, `ColorPalette`, `ColorPaletteItem`.

Configuration Parts :

- cote interface, parler de `partie` produit plutot que de `part couleur` ;
- le back reste `ProductColorPart`, `ColorPalette` et `ColorPaletteItem`, mais l'UI traduit cette mecanique en vocabulaire metier ;
- le bloc principal affiche les parties du produit sous forme de grille, avec le bloc `Nouvelle partie` en colonne laterale quand la largeur le permet ;
- le clic sur une partie ouvre son editeur sous la grille ;
- les champs d'identite de la partie utilisent l'autosave au blur ;
- l'ajout de RAL reste unitaire, jamais multi-select ;
- la liste detaillee des RALs d'une partie vit dans le drawer pour alleger l'edition centrale ;
- les selects natifs sont evites dans ce flux : utiliser le custom select Admin V2 pour RAL et finition ;
- le champ RAL doit afficher une recherche locale ou live, une pastille couleur, la reference RAL et le nom ;
- la finition reste optionnelle avec une entree claire `Sans finition` ;
- la creation d'une finition est une action contextuelle du bloc d'ajout RAL, pas un bloc global de meme niveau que les parties.
- la suppression d'une partie utilise le custom confirm Admin V2 et remplace le drawer par un etat supprime si le drawer affichait cette partie.

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
- autosave `active` au clic dans un panel `Publication` ;
- produits rattaches affiches en lecture avec liens vers Product V2.

Compteur produits : compter les produits store classiques, donc `Product.where(type: nil)`, pour eviter de melanger avec `DestockProduct`.

Publication publique :

- `active: true` signifie categorie publiee sur le site public ;
- `active: false` signifie categorie en construction, visible dans l'Admin V2 mais invisible sur le site public ;
- les nouvelles categories V2 doivent naitre non publiees ;
- une categorie ne peut etre publiee que si elle possede au moins un produit store valide ;
- les produits rattaches a une categorie non publiee ne doivent pas etre accessibles sur le site public, meme par URL directe.
- une categorie ne peut etre supprimee dans l'Admin V2 que si elle ne possede aucun produit rattache.

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
