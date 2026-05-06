# Codex Working Process Public V2

Derniere mise a jour : 2026-05-06

Ce document sert de contexte de travail pour les sessions Codex sur le chantier Public V2. Il adapte la logique d'isolation Admin V2 a une refonte graphique du site public, sans impacter le site public classique ni l'Admin V2.

## Contexte General

Projet : Rails 7 existant pour un site de store.

Sprint courant : Public V2, refonte graphique publique, design system responsive, theme clair/sombre.

Objectif principal : construire une zone Public V2 isolee, moderne, premium, sobre et responsive, sans casser le site public classique ni l'Admin V2.

Documents a lire au debut d'un nouveau chat Codex sur Public V2 :

1. `docs/codex-working-process-public-v2.md`
2. `docs/public-v2-design-system.md`
3. `docs/codex-working-process.md`
4. `docs/admin-v2-design-system.md`

## Decisions Actees

- URL de home Public V2 : `/public-v2/home`.
- URL du laboratoire design system : `/public-v2/design-system`.
- `/public-v2/home` utilise maintenant la direction **Atelier Graphite** comme vraie home Public V2.
- Pages Public V2 ajoutees dans la meme direction Graphite :
  - `/public-v2/categories` : index categories enrichi, chaque categorie affiche tous ses produits publies ;
  - `/public-v2/produits/:slug` : fiche produit Public V2 detaillee ;
  - `/public-v2/devis` : page devis Public V2 avec formulaire et selection produits classiques + destockage ;
  - `/public-v2/contact` : page contact Public V2 avec coordonnees, acces, showroom et CTA devis.
- Les gros titres de la direction Graphite ont ete reduits pour preparer une UI publique plus premium, plus dense et plus factorisable.
- Le laboratoire design system est centre sur le UI Kit actif **Atelier Graphite**.
- Les pages reelles Public V2 doivent afficher un selecteur de theme : clair/sombre, accents et typo. Le rendu par defaut reste clair.
- Theme par defaut : clair.
- Strategy CSS : meme logique que l'Admin V2, avec layout dedie, CSS dedie et classe racine dediee.
- Le CSS Public V2 doit toujours etre scope sous `.public-v2`.
- Le formulaire devis Public V2 doit inclure les produits classiques et les produits de destockage.
- Pas de noindex tant que le chantier n'est pas pousse en production.
- Si les routes `/public-v2/*` deviennent accessibles en production avant lancement officiel, ajouter une protection SEO temporaire dans le layout Public V2.
- Pas de modification DB pour ce chantier.
- ViewComponent autorise pour Public V2 : les composants Graphite servent maintenant aux pages reelles et au laboratoire design system.
- Codex ne lance pas de serveur Rails par defaut. Pour les steps UI/front importantes, Codex peut lancer un serveur temporaire dedie, idealement `127.0.0.1:3020`, tester desktop/mobile/theme, puis le couper systematiquement en fin de step.
- A la fin de chaque step important, verifier s'il y a une optimisation ou une factorisation pertinente a faire, cote front comme cote back.

## Etat Actuel

Structure actuelle :

- route `GET /public-v2/home` ;
- route `GET /public-v2/categories` ;
- route `GET /public-v2/produits/:slug` ;
- routes `GET /public-v2/devis` et `POST /public-v2/devis` ;
- route `GET /public-v2/contact` ;
- route `GET /public-v2/design-system` ;
- controller `PublicV2::PagesController#home` ;
- controllers `PublicV2::CategoriesController`, `PublicV2::ProductsController`, `PublicV2::QuotesController` ;
- controller `PublicV2::PagesController#design_system` et `#contact` ;
- base controller `PublicV2::BaseController` ;
- layout `app/views/layouts/public_v2.html.erb` ;
- vue `app/views/public_v2/pages/home.html.erb`, basee sur la direction Graphite retenue ;
- vues `app/views/public_v2/categories/index.html.erb`, `app/views/public_v2/products/show.html.erb`, `app/views/public_v2/quotes/new.html.erb`, `app/views/public_v2/pages/contact.html.erb` ;
- vue `app/views/public_v2/pages/design_system.html.erb` ;
- CSS `app/assets/stylesheets/public_v2.css` ;
- entree JS `app/javascript/public_v2/application.js` ;
- controllers Stimulus `theme` et `dropdown` dans `app/javascript/public_v2/controllers`; la navigation mobile reste en HTML/CSS simple.
- service `PublicV2::ThemePalette` pour centraliser les accents doux/flashy et leurs couleurs de contraste.
- service `PublicV2::ContactInfo` pour centraliser telephone, email, adresse, horaires, preuves footer et map showroom.
- composants ViewComponent `app/components/public_v2` ;
- presenters Public V2 `app/presenters/public_v2` pour preparer les donnees d'affichage sans polluer les vues.

La page `/public-v2/design-system` sert maintenant de laboratoire officiel et de banc de validation des composants. Sa coquille de presentation doit rester sobre, majoritairement Tailwind, avec une navigation laterale desktop et une navigation horizontale mobile. Les ViewComponents doivent etre rendus directement dans des cadres neutres, sans classe de demo qui modifie leur style interne.

Elle documente :

- kit actif Atelier Graphite retenu ;
- fondations : palettes clair/sombre, accents doux/flashy, typo, espacements, rayons, bordures et regles visuelles ;
- layouts : layout Rails global, hero, media + texte, CTA band, footer ;
- navigation : navbar desktop, menu mobile, dropdown, breadcrumb, segmented control, tabs et pagination ;
- contenu : cards, panels standards, spotlight panels, listes, tableaux, badges, stats, preuves et cards contact ;
- produits : blocs categories, product cards, product panels, specs, services, coloris, destockage ;
- formulaires : inputs custom, select, textarea, checkbox, radio, toggle, range, stepper, erreurs, consentement et submit ;
- feedback : alert, toast, form error, empty state, skeleton ;
- motion : hover lift, focus, progress, timeline, accordion ;
- pages : home, categories, product/show, devis et contact ;
- inventaire des composants Public V2 actifs ;
- theme clair/sombre ;
- selecteur accent doux/flashy ;
- selecteur typo ;
- data reelle quand elle aide a juger les directions.

Regle d'iteration : les requetes du laboratoire doivent rester legeres. La page charge seulement quelques categories, produits card et produits de destockage pour illustrer le UI Kit sans redevenir une page lourde.

## Architecture Composants

Les pages reelles sont migrees vers des composants Public V2 modulaires. Les requetes sont centralisees dans les controllers Public V2, les donnees derivees passent par des presenters, et les composants restent documentes dans le design-system.

Regles Rails Public V2 :

- `app/views/layouts/public_v2.html.erb` porte le shell global : tokens, navbar, event banner, contenu et footer ;
- les vues `app/views/public_v2` ne doivent pas declarer de variables locales ;
- les vues ne doivent pas preparer d'images, chemins, counts, options de select ou collections derivees ;
- les controllers chargent les records, scopes, includes et limits ;
- les presenters `PublicV2::*Page` preparent les donnees d'affichage ;
- les chemins et items derives qui composent une section specifique passent par le presenter quand ils dependent d'une ressource chargee ;
- les constantes metier transverses passent par un service Public V2 dedie, pas par chaque vue ou composant ;
- les ViewComponents structurent les sections et primitives UI, sans requetes metier.

Structure et composants crees et utilises :

- `app/views/layouts/public_v2.html.erb` : shell global Rails Public V2 avec tokens, navbar, event banner, contenu et footer ;
- `PublicV2::Layout::NavbarComponent` : navigation publique responsive avec liens essentiels, telephone, dropdown theme et tabs actives ;
- `PublicV2::Layout::FooterComponent` : footer public riche avec categories et contact ;
- `PublicV2::Content::HeroComponent` : hero editorial reutilisable ;
- `PublicV2::Content::SectionHeaderComponent` : en-tetes de section standard/home ;
- `PublicV2::Content::CtaBandComponent` : bande CTA ;
- `PublicV2::Content::InfoCardComponent` : card information/contextuelle ;
- `PublicV2::Content::PartnersComponent` : logo wall partenaires responsive avec hover accent ;
- `PublicV2::ContactInfo` : source unique des coordonnees Public V2 ;
- `PublicV2::Home::HeroSectionComponent`, `ExpertiseSectionComponent`, `CategoryGridSectionComponent`, `ProductRowsSectionComponent`, `ShowroomSectionComponent`, `QuoteShortcutSectionComponent` ;
- `PublicV2::Categories::HeroSectionComponent`, `SummarySectionComponent`, `ListSectionComponent`, `CtaSectionComponent` ;
- `PublicV2::Products::HeaderSectionComponent`, `DetailsSectionComponent`, `RelatedSectionComponent` ;
- `PublicV2::Quotes::HeroSectionComponent`, `FormSectionComponent` ;
- `PublicV2::Contact::HeroSectionComponent`, `DetailsSectionComponent`, `ShowroomSectionComponent`, `CtaSectionComponent` ;
- `PublicV2::Ui::PanelComponent`, `SpotlightPanelComponent`, `DropdownComponent`, `BadgeComponent`, `ButtonComponent`, `MediaFrameComponent`, `NotificationBannerComponent`, `EmptyStateComponent`, `BreadcrumbComponent`, `StatCardComponent` ;
- `PublicV2::Products::CategoryBlockComponent`, `ProductCardComponent`, `HeroComponent` ;
- `PublicV2::Forms::FieldComponent`, `QuoteFormComponent`.

Pages migrees avec composants :

- `/public-v2/home` ;
- `/public-v2/categories` ;
- `/public-v2/produits/:slug` ;
- `/public-v2/devis` ;
- `/public-v2/contact`.

Regles de validation :

- ne pas lancer de serveur Rails par defaut ;
- pour une etape UI/front importante, Codex peut lancer un serveur temporaire dedie, idealement `127.0.0.1:3020`, faire les captures desktop/mobile/theme utiles, puis le couper systematiquement avant de rendre la main ;
- pour un micro-ajustement CSS/UI que l'utilisateur verifie lui-meme en local, ne pas lancer de serveur Rails ni de capture Chrome ; appliquer le patch et faire seulement un check statique utile ;
- valider les GET avec `bin/rails runner` si besoin ;
- ne pas POSTer `/public-v2/devis` pendant les validations automatiques, car cela cree une demande ;
- verifier les reliquats CSS/vues/routes apres chaque gros nettoyage.

## Langue Et Style

- Repondre en francais.
- Etre direct, concret et pragmatique.
- Faire un audit avant les changements importants.
- Expliquer brievement ce qui est modifie et pourquoi.
- Garder les reponses finales courtes, sauf demande de rapport.

## Regles De Securite Projet

Par defaut, ne pas faire :

- migration ;
- reset DB ;
- modification destructive ;
- suppression de donnees ;
- installation de gem/package ;
- ajout de dependance ;
- commit ;
- push ;
- lancement de serveur si l'utilisateur dit qu'il valide lui-meme ;
- serveur Rails laisse actif en arriere-plan apres validation ;
- ajout de tests Rails dans ce sprint, sauf demande explicite ;
- refonte des modeles ;
- refonte de l'admin classique ;
- modification du site public classique ;
- modification de l'Admin V2.

Ne jamais lancer :

- `rails db:migrate` ;
- `rails db:reset` ;
- `bundle install` ;
- `npm install`, `yarn install`, `pnpm install`, `bun install` ;
- `rails db:*` ;
- commandes destructives type `rm`, `git reset --hard`, `git checkout --` sans demande explicite.

Serveur Rails : autorise uniquement pour les validations front importantes quand le process le justifie. Dans ce cas, utiliser un port dedie, documenter les routes testees et tuer le serveur avant la reponse finale.

## Fin De Step Important

Avant de cloturer une etape importante, toujours faire une revue courte :

- est-ce qu'une requete peut etre reduite, prechargee ou deplacee hors de la vue ?
- est-ce qu'un pattern front se repete assez pour meriter une future extraction ?
- est-ce qu'une factorisation maintenant rendrait le design moins flexible ?
- est-ce qu'un selecteur CSS, un controller Stimulus ou une helper methode risque de fuiter hors `.public-v2` ?
- est-ce qu'on doit documenter une decision de design system ou de process ?

Ne pas factoriser par reflexe : extraire quand le pattern est repete ou stabilise, et garder l'ERB direct pour les compositions vraiment specifiques a une page.

## Isolation Public V2

Toujours privilegier des nouveaux fichiers dans :

- `app/controllers/public_v2`
- `app/views/public_v2`
- `app/views/layouts/public_v2.html.erb`
- `app/javascript/public_v2/application.js`
- `app/javascript/public_v2/controllers`
- `app/assets/stylesheets/public_v2.css`
- `app/components/public_v2`

Composants Public V2 actifs :

- `app/components/public_v2`
- `app/components/public_v2/ui`
- `app/components/public_v2/layout`
- `app/components/public_v2/content`
- `app/components/public_v2/home`
- `app/components/public_v2/categories`
- `app/components/public_v2/products`
- `app/components/public_v2/quotes`
- `app/components/public_v2/contact`
- `app/services/public_v2`

Regles :

- ne pas reutiliser directement les vues du site public classique ;
- ne pas modifier les controllers publics classiques pour faire marcher Public V2 ;
- ne pas modifier l'Admin V2 pour faire marcher Public V2 ;
- le backend existant peut etre lu et appele, mais les controllers, vues, CSS et Stimulus Public V2 doivent rester autonomes ;
- le namespace Ruby attendu est `PublicV2` ;
- le path public attendu est `/public-v2`.

## Point CSS Important

`app/assets/stylesheets/application.css` ne doit pas utiliser `require_tree .`, afin de ne pas inclure automatiquement `public_v2.css` ou `admin_v2.css` dans le site classique.

Consequence : un nouveau fichier CSS place dans `app/assets/stylesheets` doit etre charge explicitement par son layout ou rester isole.

Regle obligatoire :

- tous les selecteurs Public V2 doivent etre prefixes ou imbriques sous `.public-v2` ;
- ne pas declarer de styles globaux non scopes sur `body`, `html`, `:root`, `a`, `button`, `input`, etc. ;
- les tokens Public V2 doivent vivre sous `.public-v2`, pas sous `:root` ;
- le layout Public V2 doit mettre `class="public-v2"` sur le body.

Tailwind :

- Tailwind est disponible dans le layout Public V2 ;
- garder les classes `pv2-*` comme API stable des composants ;
- utiliser Tailwind comme moteur par defaut pour le layout interne et le responsive (`grid`, `flex`, `gap-*`, `items-*`, `justify-*`, `w-*`, `max-w-*`, `col-span-*`, breakpoints) ;
- ne pas creer de nouvelle classe custom de layout si une utility Tailwind couvre clairement le besoin ;
- quand un layout passe a Tailwind, supprimer la propriete equivalente dans `public_v2.css` pour eviter une double source de verite ;
- eviter les couleurs Tailwind generiques dans Public V2 (`text-slate-*`, `bg-orange-*`, etc.) si elles doublonnent les tokens ;
- preferer les tokens CSS Public V2 pour couleurs, surfaces, bordures, focus et accent.

Pattern cible :

- les classes `pv2-*` portent l'API composant, le skin, les tokens, les etats et les variantes ;
- les utilities Tailwind portent les grilles, stacks, espacements, alignements et breakpoints ;
- les classes Tailwind doivent rester litterales dans les vues ou constantes Ruby scannees par Tailwind ;
- eviter les interpolations de classes Tailwind dynamiques non visibles par le build.

## Perimetre Public V2

Pages publiques ciblees :

- home ;
- category/index ;
- category/show ;
- product/show ;
- devis ;
- contact ;
- destockage ;
- notifications dynamiques sur home.

Non-objectifs :

- pas d'achat ;
- pas de panier ;
- pas de connexion client ;
- pas de configuration produit transactionnelle ;
- pas de live feed admin ;
- pas de fullpage experience ;
- pas de WebSocket ;
- pas de live reload Turbo ;
- pas de changement DB.

Exception interactive :

- le formulaire de creation de devis peut utiliser Turbo ou Stimulus si cela ameliore les erreurs, le pending state ou la confirmation.

## Design System Et Composants

Objectif : maintenir `/public-v2/design-system` comme laboratoire de composants Graphite. `/public-v2/home` est la vraie home Public V2 basee sur Atelier Graphite, et le lab documente les ViewComponents Public V2 actifs.

La page design system doit contenir :

- layout Public V2 dedie ;
- CSS Public V2 dedie ;
- JS Public V2 dedie si necessaire ;
- theme clair/sombre ;
- selecteur accent ;
- selecteur typo ;
- navigation desktop ;
- navigation mobile ;
- footer Public V2 ;
- une home V2 reelle basee sur Atelier Graphite ;
- une vue design system structuree ;
- un UI kit actif pour Atelier Graphite ;
- fondations, layouts, navigation, contenu, produits, formulaires, feedback, motion et inventaire composants ;
- notifications dynamiques dans les exemples si un event actif existe ;
- categories et produits publies pour enrichir les exemples ;
- CTA devis dans les exemples de layouts, mais pas dans la navbar globale ;
- design responsive mobile et desktop.

Regles composants :

- creer les composants modulaires dans `app/components/public_v2` ;
- brancher les composants dans `/public-v2/design-system` pour valider leur API et leur rendu ;
- utiliser les composants dans les vraies pages quand le pattern est stable ;
- les composants `section-layout` et `full-width` doivent etre `w-full min-w-0` sur leur racine ;
- les primitives `ButtonComponent`, `BadgeComponent` et `DropdownComponent` restent intrinseques par defaut ;
- les primitives `PanelComponent` restent `w-full min-w-0` et le layout externe doit venir du parent ;
- pour les donnees ordonnees comme les options produit, conserver l'ordre metier (`order`, puis dates/id en fallback) et privilegier des lectures compactes avant de multiplier les cards ;
- les composants qui en ont besoin peuvent accepter `debug: true` pour afficher leur cadre et leur nom sans modifier leur API metier ;
- la vue decide l'ordre des sections et la cellule parent, le composant decide son layout interne responsive ;
- eviter les `max-width` et marges externes sur les racines de composants bloc ; les placer sur des enfants internes si necessaire ;
- eviter les composants trop parametrables ;
- preferer des variants simples et nommes ;
- garder les variants de boutons/panels courts et explicites (`size`, `shape`, `variant`, `padding`) ;
- documenter les nouveaux composants dans le design-system.

Composants actifs :

- `PublicV2::Content::HeroComponent` ;
- `PublicV2::Content::SectionHeaderComponent` ;
- `PublicV2::Content::CtaBandComponent` ;
- `PublicV2::Content::InfoCardComponent` ;
- `PublicV2::Content::PartnersComponent` ;
- `PublicV2::Layout::NavbarComponent` ;
- `PublicV2::Layout::FooterComponent` ;
- `PublicV2::Products::ProductCardComponent` ;
- `PublicV2::Products::CategoryBlockComponent` ;
- `PublicV2::Products::HeroComponent` ;
- `PublicV2::Forms::FieldComponent` ;
- `PublicV2::Forms::QuoteFormComponent` ;
- `PublicV2::Ui::BadgeComponent` ;
- `PublicV2::Ui::ButtonComponent` ;
- `PublicV2::Ui::DropdownComponent` ;
- `PublicV2::Ui::PanelComponent` ;
- `PublicV2::Ui::SpotlightPanelComponent` ;
- `PublicV2::Ui::MediaFrameComponent` ;
- `PublicV2::Ui::NotificationBannerComponent` ;
- `PublicV2::Ui::EmptyStateComponent` ;
- `PublicV2::Ui::BreadcrumbComponent` ;
- `PublicV2::Ui::StatCardComponent`.

Pages migrees :

- home, categories/index, product/show, devis et contact utilisent ces composants ;
- les requetes sont optimisees page par page ;
- les reliquats inutiles doivent etre retires au fil des iterations ;
- le CSS non utilise doit etre nettoye apres chaque extraction.

## Routes Attendues

Routes Public V2 actuelles :

- `GET /public-v2/home` vers `PublicV2::PagesController#home`.
- `GET /public-v2/design-system` vers `PublicV2::PagesController#design_system`.
- `GET /public-v2/contact` vers `PublicV2::PagesController#contact`.
- `GET /public-v2/categories` vers `PublicV2::CategoriesController#index`.
- `GET /public-v2/produits/:slug` vers `PublicV2::ProductsController#show`.
- `GET /public-v2/devis` vers `PublicV2::QuotesController#new`.
- `POST /public-v2/devis` vers `PublicV2::QuotesController#create`.

Structure cible plus tard :

- namespace `public_v2`, path `public-v2` ;
- root interne possible vers `pages#home` ;
- route destockage V2.

Ne pas changer le `root` public classique pendant le chantier Public V2.

## Controllers Et Requetes

Les nouveaux controllers Public V2 doivent optimiser les requetes des le depart.

Principes :

- aucune requete metier directement dans les vues ;
- precharger les associations affichees ;
- filtrer les categories publiees ;
- filtrer les produits store classiques avec `type: nil` ;
- verifier que les produits rattaches a une categorie non publiee ne sont pas accessibles ;
- precharger les blobs Active Storage quand des images ou documents sont affiches ;
- eviter les `Product.all`, `Category.all`, `products.first` non scopes ;
- eviter les `count` en boucle ;
- limiter les collections affichees sur la home ;
- utiliser `Time.current` plutot que `DateTime.now`.

Requetes a corriger en Public V2 par rapport au public classique :

- home : eviter `Product.all.first` et charger uniquement les donnees utiles ;
- categories : precharger les images des produits visibles ;
- product/show : charger produit, categorie publiee, options, service, fabricants, motoristes, images, documentations et architecture couleur sans N+1 ;
- devis : preparer la collection produits dans le controller, en incluant store classique et destockage.
- le theme Graphite actif est centralise dans `PublicV2::BaseController#public_v2_graphite_theme` pour eviter de recopier les tokens controller par controller.
- les accents sont centralises dans `PublicV2::ThemePalette` : 6 doux, 6 flashy, chacun avec `hex`, `rgb`, groupe et couleur de texte de contraste.
- les scopes Public V2 communs sont centralises dans `PublicV2::BaseController` :
  - `public_categories` pour les categories publiees ;
  - `public_product_cards` pour les listes, cards, devis et design-system ;
  - `public_product_details` pour la fiche produit detaillee.

## Devis Public V2

Le formulaire devis reste la seule creation de donnees cote public.

Regles :

- pas de changement DB ;
- conserver le modele `Quote` existant ;
- inclure produits classiques et produits de destockage dans le choix produit ;
- ne pas exposer de produits rattaches a une categorie non publiee ;
- preselectionner le produit quand la page vient d'une fiche produit ;
- utiliser des inputs custom Public V2 inspires Admin V2 ;
- afficher les erreurs sans casser le layout ;
- confirmation claire apres succes.

## Theme Et Preferences

Le Public V2 doit proposer :

- mode clair ;
- mode sombre ;
- selecteur accent ;
- selecteur typo.

Regles :

- clair par defaut ;
- les tokens doivent etre propres au Public V2 ;
- ne pas reutiliser les variables `--g-*` de l'Admin V2 ;
- preferer un prefixe Public V2 type `--p-*` ;
- les preferences peuvent etre session-only au debut ;
- la persistence locale peut etre decidee plus tard.

## Verification

Checks non destructifs utiles :

- `git status --short` avant de commencer ;
- `bin/rails routes -g public-v2` apres ajout des routes ;
- `ruby -c` sur les controllers Ruby ajoutes ;
- `git diff --check` ;
- rendu manuel par l'utilisateur si le serveur n'est pas lance par Codex ;
- verification responsive mobile et desktop avant de valider une direction visuelle.

Ne pas lancer de serveur si l'utilisateur dit qu'il valide lui-meme.
Pour les micro-changements de style, privilegier un patch court et un check statique, puis laisser l'utilisateur juger le rendu dans son navigateur.

## Documentation

Mettre a jour `docs/codex-working-process-public-v2.md` quand :

- une regle de process Public V2 change ;
- une contrainte d'isolation est ajoutee ;
- une decision de route, layout, CSS ou JS est prise ;
- une exception est validee.

Mettre a jour `docs/public-v2-design-system.md` quand :

- une decision de design system est prise ;
- une palette change ;
- un composant devient reutilisable ;
- un layout de page est valide ;
- un pattern responsive ou formulaire est stabilise.
