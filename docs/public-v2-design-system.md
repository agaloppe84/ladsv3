# Public V2 Design System

Derniere mise a jour : 2026-05-06

Ce document decrit le design system du Public V2. Il sert de reference pour construire une refonte graphique publique isolee, responsive et coherente, inspiree de l'Admin V2 sans copier son interface admin.

## Vision

Nom de direction : **Graphite Public Atelier**.

Public V2 doit donner une impression premium, sobre, technique et contemporaine, adaptee a un site public de consultation de produits : stores, volets roulants, portes de garage, moustiquaires, pergolas et protections solaires.

Objectifs :

- site full responsive ;
- experience publique lisible et rassurante ;
- navigation simple vers accueil, produits, devis et contact ;
- consultation produit claire, riche et technique ;
- design premium inspire de l'Admin V2 ;
- theme clair/sombre ;
- accent dynamique ;
- typo dynamique ;
- composants modulaires quand le design sera stabilise ;
- performance soignee.

Non-objectifs :

- ne pas copier le shell Admin V2 ;
- ne pas faire une experience fullpage ;
- ne pas faire un dashboard ;
- ne pas ajouter achat, panier, connexion ou configuration transactionnelle ;
- ne pas imposer WebSocket ou Action Cable ;
- ne pas modifier la base de donnees.

## Differences Avec Admin V2

Admin V2 :

- desktop first ;
- fullpage ;
- sidebar gauche ;
- drawer droit ;
- scroll interne ;
- mono par defaut ;
- dark mode graphite par defaut ;
- interface dense de gestion.

Public V2 :

- mobile first et desktop solide ;
- scroll naturel du body ;
- navbar publique ;
- footer riche ;
- pas de drawer permanent ;
- sans par defaut ;
- light mode par defaut ;
- dark mode disponible ;
- interface de consultation et conversion.

On reprend :

- isolation par namespace ;
- tokens CSS ;
- accent dynamique ;
- typo dynamique ;
- inputs custom ;
- sobriete graphite ;
- rigueur des composants.

On adapte :

- densite plus respirante ;
- textes plus pedagogiques ;
- images produits et showroom plus presentes ;
- CTA plus visibles ;
- responsive prioritaire ;
- layout editorial et commercial plutot qu'outil admin.

## Isolation

Convention cible :

- namespace Ruby : `PublicV2`
- routes : `/public-v2`
- layout : `app/views/layouts/public_v2.html.erb`
- vues : `app/views/public_v2`
- controllers : `app/controllers/public_v2`
- presenters : `app/presenters/public_v2`
- services : `app/services/public_v2`
- Stimulus controllers : `app/javascript/public_v2/controllers`
- entree JS : `app/javascript/public_v2/application.js`
- CSS dedie : `app/assets/stylesheets/public_v2.css`
- classe racine : `.public-v2`

Regle importante : creer de nouveaux fichiers Public V2 plutot que modifier ou reutiliser les vues du site public classique.

## Etat Actuel

Etat actuel :

- URL home : `/public-v2/home` ;
- URL laboratoire : `/public-v2/design-system` ;
- layout dedie avec classe racine `.public-v2` ;
- CSS dedie entierement scope sous `.public-v2` ;
- entree JS dediee ;
- shell global porte par le layout Rails Public V2 ;
- presenters Public V2 pour preparer les donnees derivees hors des vues ;
- service `PublicV2::ContactInfo` pour centraliser coordonnees, liens contact, horaires, preuves footer et map showroom ;
- controller Stimulus `theme` pour mode clair/sombre, accent et typo ;
- controller Stimulus `dropdown` pour les menus deroulants custom Public V2 ;
- home Public V2 reelle basee sur Atelier Graphite et reconstruite avec composants ;
- bloc partenaires integre a la home avec logo wall responsive et hover accent ;
- pages reelles categories, product/show, devis et contact reconstruites avec les composants Public V2 ;
- vue `design_system` enrichie avec le UI Kit actif et l'inventaire des composants.

Design system lab :

- la home ne porte plus le laboratoire ; elle utilise la direction Atelier Graphite ;
- le laboratoire est maintenant centre sur le kit actif **Atelier Graphite** ;
- le laboratoire separe la presentation UX/UI de la page et le contenu des composants : la coquille est sobre, en utilities Tailwind, avec nav laterale desktop et nav horizontale mobile ;
- les composants sont rendus directement dans des cadres neutres, sans surcouche `pv2-kit-*` susceptible de deformer paddings, badges ou alignements ;
- le laboratoire documente les composants vraiment utilises avant extraction future ;
- le laboratoire est trie par type : fondations, layouts, navigation, contenu, produits, formulaires, feedback, motion, pages et inventaire ViewComponent ;
- les exemples utilisent une collection limitee de categories et produits reels quand cela aide a documenter un composant.

UI kit actif Atelier Graphite :

- fond clair froid, surfaces blanches, texte graphite, accent lime par defaut ;
- mode sombre disponible avec les memes tokens Public V2 ;
- accents dynamiques etendus : 6 couleurs douces et 6 couleurs flashy, chacune avec couleur de texte de contraste ;
- titres reduits pour une lecture plus premium et moins hero marketing ;
- rails accent, bordures fines, angles courts, ombres rares ;
- navbar sticky avec liens essentiels, telephone, etat actif et selecteur theme compact en dropdown icon-only ;
- footer sombre avec coordonnees, contact et categories ;
- cards categorie, cards produit, panels product/show, cards contact, logo wall partenaires, CTA band ;
- breadcrumb, dropdown custom, facts, badges services, swatches coloris, galerie, empty state ;
- liste options produit en rail compact : index carres, ligne verticale masquee derriere les index, liaisons horizontales courtes et texte mono uppercase en couleur accent ;
- panels expressifs `SpotlightPanelComponent` en variantes soft et flashy pour les messages forts ;
- formulaires custom : labels mono, inputs, select, textarea, erreur, consentement, submit ;
- interactions : hover leger, focus ring accent, transitions courtes.

Les routes reelles actuellement disponibles couvrent `/public-v2/home`, `/public-v2/categories`, `/public-v2/produits/:slug`, `/public-v2/devis`, `/public-v2/contact` et `/public-v2/design-system`.

Note : la page `/public-v2/design-system` charge une collection limitee pour rester utile sans devenir une page lourde : categories `limit(8)`, produits cards `limit(8)` et destockage `limit(2)`.

## Layout Global

Le layout Public V2 doit etre un shell public, pas un shell admin.

Zones attendues :

1. **Header / Navbar**
   - sticky ou semi-sticky ;
   - logo visible ;
   - liens : Accueil, Produits, Devis, Contact ;
   - tabs actives desktop et mobile ;
   - acces telephone possible ;
   - selecteur theme discret ;
   - navigation mobile dediee.

2. **Main**
   - scroll naturel ;
   - sections pleine largeur avec contenu contraint ;
   - alternance de surfaces calmes, medias et blocs techniques ;
   - largeur max coherente desktop ;
   - mobile en colonne simple.

3. **Footer**
   - coordonnees ;
   - horaires ;
   - adresse ;
   - liens principaux ;
   - rappel devis/contact ;
   - partenaires ou certifications si pertinent.

## Navigation UX

Desktop :

- navbar horizontale claire ;
- Accueil, Produits, Devis et Contact visibles ;
- produits accessibles en un clic ;
- Devis accessible comme lien de navigation, sans bouton CTA redondant dans la navbar ;
- theme controls compacts.

Mobile :

- bouton menu icon-only ;
- panneau mobile plein largeur ou bottom sheet leger ;
- liens grands et lisibles ;
- etat actif visible sur le lien courant ;
- telephone accessible dans le menu ;
- aucun hover-only indispensable ;
- pas de texte qui deborde dans les boutons.

## Palette Et Tokens

Les tokens doivent vivre sous `.public-v2`.

Prefixe recommande :

- `--p-bg`
- `--p-bg-soft`
- `--p-surface`
- `--p-surface-raised`
- `--p-surface-inset`
- `--p-border`
- `--p-border-strong`
- `--p-text`
- `--p-muted`
- `--p-subtle`
- `--p-faint`
- `--p-accent-rgb`
- `--p-accent`
- `--p-accent-soft`
- `--p-accent-border`
- `--p-accent-hover`
- `--p-accent-text`
- `--pv2-accent`
- `--pv2-accent-rgb`
- `--pv2-accent-text`
- `--p-success`
- `--p-warning`
- `--p-danger`

Principes :

- clair par defaut ;
- sombre disponible ;
- pas de noir pur ;
- pas de blanc agressif sur de grandes surfaces ;
- surfaces legerement teintees ;
- accent modifiable via une seule source `--p-accent-rgb` ;
- pas de violet hardcode ;
- statuts et feedback limites a quelques couleurs utiles.

Direction light :

- fond general clair legerement froid ;
- surfaces blanc casse ou zinc tres clair ;
- texte graphite ;
- bordures fines ;
- accent technique mais chaleureux.

Direction dark :

- fond graphite froid proche Admin V2, mais moins dense ;
- surfaces lisibles ;
- images et CTA gardent du relief ;
- contrastes confortables.

Accents supportes :

- Lime technique ;
- Teal showroom ;
- Amber chaleureux ;
- Cyan precision ;
- Slate premium ;
- Coral conversion.

## Typographie

Modes attendus :

- Sans : defaut Public V2 ;
- Mono : mode technique, inspire Admin V2.

Regles :

- ne pas forcer des polices localement sans raison ;
- le mode global doit pouvoir changer toute l'interface ;
- les titres publics doivent rester lisibles et commerciaux ;
- eviter les grands titres hero trop dominants : la direction retenue privilegie des H1 autour de 2rem desktop et des H2 autour de 1.1rem sur les pages reelles ;
- utiliser la mono surtout pour details techniques, references, dimensions, labels courts ;
- pas de texte hero trop grand dans des cards compactes ;
- pas de letter-spacing negatif.

## Architecture Rails Et Composants

Le layout Rails Public V2 porte le shell global : tokens de theme, navbar, event banner, contenu et footer.

Les controllers chargent les records avec scopes, includes et limits. Les presenters `PublicV2::*Page` preparent les donnees d'affichage : images principales, chemins, options de formulaire, sections de categories, palettes, services et produits associes.

Les vues `app/views/public_v2` ne declarent pas de variables locales. Elles assemblent le contenu a partir de presenters et de ViewComponents.

Les ViewComponents Public V2 structurent les sections et primitives UI, et restent documentes dans `/public-v2/design-system`.

Les informations fixes de contact vivent dans `PublicV2::ContactInfo`. Le footer, la page devis et la page contact ne doivent pas redefinir telephone, email, adresse, horaires ou URL de map chacun de leur cote.

Pattern CSS/Tailwind actif :

- `pv2-*` reste l'API stable des composants et porte l'identite visuelle : tokens, surfaces, couleurs, bordures, focus, hover, dark mode, theme accent, pseudo-elements et motion ;
- Tailwind porte le layout interne : `grid`, `flex`, `gap-*`, `items-*`, `justify-*`, `w-*`, `max-w-*`, `col-span-*` et breakpoints responsive ;
- une propriete de layout migree vers Tailwind ne doit plus etre redefinie dans `public_v2.css` ;
- les utilities doivent rester litterales dans les templates ou dans les classes Ruby scannees par Tailwind ;
- ne pas utiliser de couleurs Tailwind generiques pour remplacer les tokens Public V2.
- la page design-system utilise Tailwind pour sa propre mise en page et ne doit pas recreer une couche CSS de laboratoire ; si un composant apparait casse dans le lab, corriger le composant ou son API plutot qu'ajouter une surcouche demo.

Contrat de largeur :

- les composants `section-layout` et `full-width` occupent toujours toute la cellule donnee par leur parent avec `w-full min-w-0` ;
- les vues structurent l'ordre des sections et les wrappers de page, mais ne doivent pas porter les layouts internes complexes ;
- les composants de section portent leur propre layout responsive interne ;
- les cards, panels, medias, forms et etats remplissent leur cellule parent ;
- les primitives `ButtonComponent`, `BadgeComponent` et `DropdownComponent` restent intrinseques par defaut, avec `classes:` pour les cas full-width ;
- aucune racine de composant bloc ne doit porter une largeur de page, un `max-width` global ou une marge externe. Les contraintes de lecture vivent sur des enfants internes.

Namespaces actifs :

- `app/components/public_v2/ui`
- `app/components/public_v2/layout`
- `app/components/public_v2/content`
- `app/components/public_v2/home`
- `app/components/public_v2/categories`
- `app/components/public_v2/products`
- `app/components/public_v2/quotes`
- `app/components/public_v2/contact`
- `app/components/public_v2/forms`
- `app/services/public_v2`

Composants crees :

- `PublicV2::Layout::NavbarComponent` : logo, liens essentiels, tabs actives, telephone, menu mobile et dropdown theme ;
- `PublicV2::Layout::FooterComponent` : coordonnees, horaires et liens contact ;
- `app/views/layouts/public_v2.html.erb` : shell global Rails Public V2 avec tokens, navbar, event banner, contenu et footer ;
- `PublicV2::Content::HeroComponent` : hero public compact, panneau preuve et actions ;
- `PublicV2::Content::SectionHeaderComponent` : entete de section standard ;
- `PublicV2::Content::CtaBandComponent` : bandeau CTA avec actions ;
- `PublicV2::Content::InfoCardComponent` : card contact, preuve ou contexte ;
- `PublicV2::Content::PartnersComponent` : logo wall partenaires responsive avec hover accent ;
- `PublicV2::ContactInfo` : source unique des coordonnees, liens, horaires, preuves et map showroom ;
- `PublicV2::Home::HeroSectionComponent` : hero home reel avec copy, actions, proofline, media et produit mis en avant ;
- `PublicV2::Home::ExpertiseSectionComponent` : section besoins metier ;
- `PublicV2::Home::CategoryGridSectionComponent` : grille familles produits home ;
- `PublicV2::Home::ProductRowsSectionComponent` : selection catalogue home ;
- `PublicV2::Home::ShowroomSectionComponent` : bloc showroom home ;
- `PublicV2::Home::QuoteShortcutSectionComponent` : raccourci devis home ;
- `PublicV2::Categories::SummarySectionComponent` : synthese catalogue ;
- `PublicV2::Categories::HeroSectionComponent` : hero categories/index ;
- `PublicV2::Categories::ListSectionComponent` : liste categories + produits ;
- `PublicV2::Categories::CtaSectionComponent` : CTA categories/index ;
- `PublicV2::Products::ProductCardComponent` : card produit catalogue ;
- `PublicV2::Products::CategoryBlockComponent` : bloc categorie avec media, tags et produits futurs ;
- `PublicV2::Products::HeroComponent` : hero fiche produit avec preuves, actions et media ;
- `PublicV2::Products::HeaderSectionComponent` : breadcrumb + hero fiche produit ;
- `PublicV2::Products::DetailsSectionComponent` : contenu detaille product/show ;
- `PublicV2::Products::RelatedSectionComponent` : produits proches product/show ;
- `PublicV2::Quotes::HeroSectionComponent` : hero devis ;
- `PublicV2::Quotes::FormSectionComponent` : layout devis avec formulaire, produit selectionne, etapes et contact ;
- `PublicV2::Contact::HeroSectionComponent` : hero contact ;
- `PublicV2::Contact::DetailsSectionComponent` : coordonnees et carte ;
- `PublicV2::Contact::ShowroomSectionComponent` : bloc showroom pedagogique ;
- `PublicV2::Contact::CtaSectionComponent` : CTA contact ;
- `PublicV2::Forms::FieldComponent` : label, input, select, textarea, hint et erreur ;
- `PublicV2::Forms::QuoteFormComponent` : formulaire devis complet avec selection produit ;
- `PublicV2::Ui::BadgeComponent` : badge neutral, accent, success, warning, destock, danger ;
- `PublicV2::Ui::ButtonComponent` : bouton/lien primary, secondary, ghost, inverse, danger ;
- `PublicV2::Ui::DropdownComponent` : trigger et panneau slotte, gere par Stimulus `dropdown` ;
- `PublicV2::Ui::PanelComponent` : surface generique avec header, body et slot actions ;
- `PublicV2::Ui::SpotlightPanelComponent` : panneau expressif soft ou flashy pour messages premium ;
- `PublicV2::Ui::MediaFrameComponent` : cadre media avec image Cloudinary ou fallback asset ;
- `PublicV2::Ui::NotificationBannerComponent` : notification event, info ou toast ;
- `PublicV2::Ui::EmptyStateComponent` : etat vide avec action optionnelle ;
- `PublicV2::Ui::BreadcrumbComponent` : fil d'Ariane public ;
- `PublicV2::Ui::StatCardComponent` : card chiffre cle.

Composants a evaluer ensuite :

- `PublicV2::Layout::ThemeSettingsComponent` ;
- `PublicV2::Products::ProductPanelComponent` ;
- `PublicV2::Products::ProductGalleryComponent`.

Regle d'abstraction :

- garder l'ERB direct pour les compositions tres specifiques a une page ;
- extraire quand le pattern est repete ou stabilise ;
- eviter les composants trop parametrables ;
- preferer des variants simples et nommes.

## Forms

Les formulaires Public V2 doivent reprendre l'esprit custom input Admin V2, avec une finition publique.

Regles :

- labels visibles ;
- champs confortables mobile ;
- focus accent ;
- erreurs claires ;
- pending state visible ;
- textarea stable ;
- select produit custom si le select natif devient trop lourd ;
- largeur et hauteur stables ;
- pas de submit global complexe, sauf formulaire devis complet.

Formulaire devis :

- produit preselectionne si contexte produit ;
- produits classiques et destockage inclus ;
- message d'aide discret ;
- confirmation claire ;
- erreurs conservees dans le layout ;
- ne pas exposer de donnees sensibles dans des logs ou evenements client.

## Home V2

La home ne sert plus de laboratoire. Elle utilise maintenant la direction **Atelier Graphite** comme vraie home Public V2.

Objectif actuel :

- garder un point d'entree propre sur `/public-v2/home` ;
- presenter rapidement categories, produits, showroom, partenaires, preuves et devis ;
- laisser le laboratoire vivre dans une page dediee ;
- s'appuyer sur les composants Public V2 stabilises ;
- continuer a optimiser les requetes et les patterns apres chaque iteration.

## Design System Lab

La page `/public-v2/design-system` sert maintenant de laboratoire UI Kit officiel pour Atelier Graphite. Elle doit rester suffisamment complete pour preparer les futurs ViewComponents, avec un contenu propre et centre sur les composants actifs.

Sections attendues :

- fondations : palettes clair/sombre, accents doux/flashy, typographie, espacements, rayons, bordures, regles de densite ;
- layouts : layout Rails global, hero, media + texte, logo wall partenaires, CTA band, footer ;
- navigation : navbar desktop, menu mobile, dropdown, breadcrumb, segmented control, tabs, pagination ;
- contenu : cards, panneaux standards, spotlight panels, listes, tableaux, badges, stats, preuves, cards contact, partenaires ;
- produits : blocs categories, cards produits, panels detail, specs, services, coloris, destockage ;
- formulaires : inputs custom, select, textarea, checkbox, radio, toggle, range, stepper, erreurs, consentement, submit ;
- feedback : notification, toast, form error, empty state, skeleton ;
- motion : hover lift, focus ring, progress, timeline, accordion ;
- pages : liens et apercus vers home, categories, product/show, devis et contact ;
- inventaire ViewComponent : composants cibles, responsabilites et niveau de maturite.

La future home devra pouvoir contenir plus de contexte que le site classique actuel, sans devenir une landing page bavarde. Le visiteur devra comprendre vite :

- ce que vend l'entreprise ;
- ou elle intervient ;
- pourquoi elle est credible ;
- comment demander un devis.

## Category Index

Objectif :

- donner une vue claire des familles produits ;
- aider a choisir sans jargon excessif ;
- montrer une image pertinente par categorie ;
- afficher description courte, nombre de produits si utile, CTA vers categorie.
- en Public V2, `/public-v2/categories` affiche aussi tous les produits de chaque categorie pour eviter l'index vide du site public classique.

## Product Show

Objectif :

- conserver la richesse de la fiche produit actuelle ;
- la rendre plus lisible avec une hero claire, galerie, options, coloris, services, marques et documents ;
- garder un CTA devis visible avec produit preselectionne ;
- utiliser les vraies donnees produit sans toucher a la DB.

Route actuelle : `/public-v2/produits/:slug`.

## Devis

Objectif :

- remplacer la page vide par une vraie page de conversion ;
- formulaire complet : nom, email, telephone, ville, adresse, produit, message ;
- selection produits classiques et produits de destockage ;
- contexte rassurant : retour 48h, contact direct, etapes du devis.

Routes actuelles : `GET /public-v2/devis`, `POST /public-v2/devis`.

## Contact

Objectif :

- remplacer la page classique tres simple par une vraie page Public V2 ;
- afficher coordonnees, horaires, email, telephone et adresse dans des cards Graphite ;
- integrer la carte d'acces au showroom ;
- rappeler l'utilite metier du showroom avant devis ;
- proposer un CTA devis sans transformer la page en landing page.

Route actuelle : `GET /public-v2/contact`.

Layout probable :

- grille responsive ;
- cards sobres ;
- image stable en ratio ;
- texte court ;
- hover desktop discret ;
- mobile tres lisible.

## Category Show

Objectif :

- expliquer la categorie ;
- afficher les produits de maniere comparative ;
- ajouter contexte technique si la page classique est trop vide ;
- guider vers devis ou fiche produit.

Layout probable :

- intro categorie ;
- grille produits ;
- bloc aide au choix ;
- CTA devis ;
- liens categories associees si pertinent.

## Product Show

Page la plus fournie.

Objectif :

- valoriser image et nom produit ;
- expliquer usages ;
- afficher options, services, motorisations, fabricants, documentation, coloris ;
- rendre la technique consultable sans noyer le visiteur ;
- CTA devis visible plusieurs fois.

Layout probable :

- hero produit avec galerie ;
- resume technique ;
- panneaux modulaires ;
- coloris par parties ;
- documentation ;
- marques / motorisation ;
- galerie ;
- CTA final.

Performance :

- precharger toutes les associations affichees ;
- eviter les requetes dans les composants ;
- eviter la preparation de donnees dans les vues ;
- limiter les grosses listes de RAL en premiere vue ;
- utiliser modal ou disclosure si la liste est longue.

Tailwind :

- Tailwind est charge dans le layout Public V2 ;
- les classes `pv2-*` restent l'API stable des composants ;
- Tailwind sert maintenant de reference pour les layouts internes et le responsive (`grid`, `flex`, `gap-*`, `items-*`, `justify-*`, `w-*`, `max-w-*`, `col-span-*`, breakpoints) ;
- les anciennes classes custom purement utilitaires doivent etre supprimees quand elles sont remplacees par Tailwind ;
- le design-system doit montrer le pattern `pv2-* + utilities Tailwind` pour preparer les futurs ViewComponents ;
- les couleurs, surfaces, bordures, focus et accents doivent rester pilotes par les tokens CSS Public V2.

Primitives recentes :

- `PublicV2::Ui::PanelComponent` accepte maintenant des variantes de surface (`default`, `accent`, `soft`, `rail`, `elevated`, `outline`, `inset`, `flashy`) et des paddings (`sm`, `md`, `lg`) ;
- `PublicV2::Ui::ButtonComponent` accepte `size`, `shape`, `variant` et `full_width` pour eviter les boutons trop ronds ou trop massifs par defaut ;
- les composants compatibles peuvent recevoir `debug: true` pour afficher leur limite spatiale et le nom du composant, utile pendant les arbitrages de layout ;
- la fiche produit Public V2 utilise temporairement `debug: true` pour visualiser les limites de ses composants ;
- `PublicV2::Products::OptionListComponent` explore cinq lectures plus compactes des options ordonnees : `rail`, `chips`, `focus`, `blueprint`, `accordion` ;
- la variante `rail` retenue sur product/show affiche une lecture technique compacte : cube d'index legerement arrondi, rail vertical accent, petit trait horizontal vers le texte, texte mono uppercase couleur accent et densite verticale reduite ;
- `focus` et `accordion` utilisent `public_v2/controllers/option_list_controller.js`.

## Destockage

Objectif :

- afficher les produits de destockage avec prix et dimensions ;
- clarifier le perimetre geographique ;
- permettre une demande de devis rapide ;
- ne pas melanger avec les produits standards sauf dans le formulaire devis.

Layout probable :

- grille responsive ;
- prix ancien/nouveau ;
- badge destockage ;
- CTA devis ;
- details techniques courts.

## Notifications

Les notifications dynamiques de home viennent des `Event` actifs.

Regles :

- pas de WebSocket ;
- pas de polling ;
- simple rendu serveur au chargement ;
- visible mais non intrusif ;
- compatible theme clair/sombre ;
- mobile compact.

## Motion

Motion autorisee :

- transitions hover ;
- reveal discret ;
- menu mobile ;
- theme switch ;
- carousel image si utile.

Motion a eviter :

- animation permanente inutile ;
- layout shift ;
- effets qui masquent le contenu ;
- dependance a hover sur mobile.

Respecter `prefers-reduced-motion` quand les animations deviennent significatives.

## Images Et Medias

Le site public doit utiliser de vrais visuels :

- produits ;
- showroom ;
- magasin ;
- logos partenaires ;
- realisations.

Regles :

- ratios stables ;
- placeholders propres ;
- pas de crop trop sombre ou trop flou ;
- lazy-load sauf image hero prioritaire ;
- precharger les blobs necessaires cote controller.

## Accessibilite Minimum

A maintenir :

- focus visible ;
- boutons icon-only avec label accessible ;
- contrastes suffisants en light et dark ;
- champs avec labels ;
- zones tactiles assez grandes ;
- textes sans debordement ;
- navigation clavier correcte ;
- aria-expanded sur menus et selectors ;
- pas de contenu essentiel hover-only.

## Performance

Points a surveiller :

- N+1 Active Storage sur categories et produits ;
- listes de produits trop larges ;
- RALs trop nombreux sur product/show ;
- `Product.all` dans devis ;
- `products.first` dans les vues ;
- events actifs charges avec `Time.current` ;
- pas de WebSocket ou polling ;
- pas de dependance externe ajoutee.

Regle : les controllers Public V2 preparent les donnees. Les vues affichent.

## Maintenance

Mettre a jour ce document quand :

- un layout de page est valide ;
- une palette est retenue ;
- un accent par defaut change ;
- un composant devient reusable ;
- un pattern responsive est fixe ;
- le comportement du theme change ;
- une regle formulaire est ajoutee ;
- une decision de performance est prise.
