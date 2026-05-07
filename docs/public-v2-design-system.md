# Public V2 - Design System Warm System

Derniere mise a jour : 2026-05-07

Ce document decrit le design system actif pour les pages publiques V2.
La direction validee est **Warm System V9** : une interface claire/sombre, premium, moderne, orientee devis, avec une base visuelle stable et facilement factorisable en ViewComponents.

## Perimetre

Le design system concerne uniquement `Public V2`.

Pages reelles concernees :

- `/public-v2/home`
- `/public-v2/categories`
- `/public-v2/produits/:slug`
- `/public-v2/devis`
- `/public-v2/contact`
- `/public-v2/design-system`

Hors perimetre :

- public classique ;
- admin-v2 ;
- anciennes pages de test ;
- laboratoires temporaires ;
- themes avec selection dynamique de couleur ou de police.

La page `/public-v2/design-system` est une reference UI Kit. Elle ne sert pas a tester des layouts de pages reelles. Les tests futurs doivent etre isoles dans des pages dediees et temporaires, avec un nom explicite contenant `test`.

## Direction Warm System

Objectifs visuels :

- ambiance premium, artisanale, moderne et chaude ;
- photo presente mais jamais dominante par defaut ;
- accents francs mais controles ;
- contenus courts, utiles et orientes devis ;
- hierarchie claire entre information, preuve, conseil et action ;
- pages lisibles sur desktop comme sur mobile.

Principes de construction :

- composer les pages avec des sections reutilisables ;
- composer les sections avec des micro composants ;
- garder les primitives UI petites, previsibles et factorisables ;
- eviter les variations cosmetiques non documentees ;
- separer strictement pages reelles, UI Kit et pages de test.

## Fondations

### Modes

Le systeme ne garde que deux modes :

- clair ;
- sombre.

Il n'y a plus de selection dynamique d'accent, de palette ou de police dans les vues publiques.

Le changement clair/sombre est porte par le layout Public V2 et par le `NavbarComponent`.

### Accent

Accent principal :

- `#ff3d12`

Son role :

- attirer l'oeil sur les actions devis ;
- signaler une information courte ;
- soutenir les badges, rails, CTA et preuves ;
- rester rare pour preserver le niveau premium.

Utilisation recommandee :

- 5 a 12% de la surface visible ;
- plus fort sur les CTA et signaux courts ;
- attenue sur les fonds, rails et tags secondaires.

### Typographie

Le systeme utilise une police unique pour simplifier la maintenance.

Regles :

- meme famille typographique sur toute l'interface ;
- variation par graisse, taille et couleur ;
- pas de textes hero trop grands dans les surfaces compactes ;
- pas de textes longs dans les blocs accentues ;
- titres courts, actionnables, avec une intention claire.

### Surfaces

Les surfaces principales sont portees par les variables `pv2-home-*`.

Familles utiles :

- background global ;
- surface calme ;
- surface elevee ;
- surface accent attenue ;
- border ;
- muted text ;
- accent ;
- accent strong ;
- accent soft.

Les surfaces doivent aider a lire la page. Elles ne doivent pas devenir un decor lourd.

### Rayons, bordures et densite

Regles :

- radius modere ;
- pas de boutons trop ronds ;
- pas de boutons trop gros ;
- bordures fines et utiles ;
- ombres discretes ;
- densite moyenne par defaut ;
- mobile : empilement propre, pas de blocs tres hauts.

## Primitives UI

### ButtonComponent

Usage :

- action principale ;
- action secondaire ;
- action fantome ;
- action danger si besoin metier.

Parametres attendus :

- `label:`
- `href:`
- `variant:`
- `size:`
- `shape:`
- `classes:`

Variantes actives :

- `primary`
- `secondary`
- `ghost`
- `danger`

Tailles :

- `small`
- `medium`
- `large`

Formes :

- `soft`
- `sharp`
- `pill`

Regle :

- privilegier `soft` ou `sharp` pour Public V2 ;
- reserver `pill` aux usages tres specifiques.

### PanelComponent

Usage :

- surface de contenu ;
- bloc metier ;
- bloc conseil ;
- bloc preuve ;
- encart technique.

Variantes actives :

- `default`
- `accent`
- `soft`
- `rail`
- `elevated`
- `outline`
- `inset`
- `flashy`

Regles :

- `flashy` reste compact ;
- `outline` sert aux blocs calmes ou techniques ;
- `soft` sert aux transitions ou contenus secondaires ;
- `rail` sert a signaler sans saturer ;
- `inset` sert aux details ou metadonnees.

### BadgeComponent

Usage :

- statut ;
- categorie ;
- preuve courte ;
- famille produit ;
- contexte chantier.

Variantes :

- `default`
- `accent`
- `soft`
- `outline`
- `success`
- `warning`
- `danger`

Tailles :

- `small`
- `medium`

### StatCardComponent

Usage :

- preuve chiffree ;
- temps de reponse ;
- surface showroom ;
- experience ;
- certification.

Variantes :

- `default`
- `accent`
- `soft`
- `outline`
- `inset`

Regles :

- une stat doit rester lisible en 2 secondes ;
- eviter les phrases longues ;
- utiliser une valeur forte et un label court.

### MediaFrame

Usage :

- photo chantier ;
- showroom ;
- produit ;
- detail technique ;
- mosaique media.

Ratios recommandes :

- `hero`
- `wide`
- `square`
- `category`
- `portrait`

Regles :

- la photo soutient le layout ;
- ne pas l'utiliser comme plein ecran par defaut ;
- garder une hauteur controlee ;
- toujours fournir `alt`.

## Composants De Layout

### NavbarComponent

Role :

- navigation publique ;
- signal de marque ;
- acces contact ;
- controle clair/sombre.

Regles :

- pas de selection de palette ;
- pas de selection de police ;
- CTA visible mais mesure ;
- mobile simple et stable.

### FooterComponent

Role :

- contact ;
- reassurance ;
- navigation secondaire ;
- ancrage local.

Regles :

- reutilisable en page reelle et dans la reference UI Kit ;
- `id:` configurable pour eviter les doublons quand le footer est rendu dans une demo.

### BreadcrumbComponent

Role :

- orientation ;
- retour categorie ;
- contexte produit.

Usage prioritaire :

- categories ;
- product/show ;
- devis si parcours etendu.

### DropdownComponent

Role :

- navigation secondaire ;
- tri ;
- filtres ;
- choix d'options.

Regle :

- rester lisible sans JavaScript critique.

## Composants De Section

### HeroComponent

Role :

- premiere intention de page ;
- promesse courte ;
- action devis ;
- support photo ou preuve.

Regles :

- pas de hero trop haut par defaut ;
- texte court ;
- CTA devis clair ;
- photo presente mais maitrisee.

### SectionShellComponent

Role :

- standardiser les sections ;
- gerer kicker, titre, texte et actions ;
- garder une structure de page coherente.

Variantes :

- `default`
- `muted`
- `accent`
- `split`

### CtaBandComponent

Role :

- relance devis ;
- fin de section ;
- transition vers contact.

Regles :

- court ;
- action claire ;
- preuve ou contexte utile.

### InfoCardComponent

Role :

- bloc conseil ;
- bloc technique ;
- engagement ;
- information metier.

## Composants Metier

### ActionDockComponent

Role :

- action devis compacte ;
- contact rapide ;
- rappel de preuve.

Usage :

- home ;
- product/show ;
- devis ;
- footer contextuel.

### QuoteIntakeComponent

Role :

- mini parcours devis ;
- cadrage rapide ;
- reduction de friction.

Regles :

- 3 a 4 etapes maximum ;
- intitules courts ;
- action claire.

### ProofRailComponent

Role :

- preuves rapides ;
- experience ;
- certification ;
- showroom ;
- delai.

Items attendus :

- `value`
- `label`
- `text`

### StepRailComponent

Role :

- expliquer un processus ;
- cadrer le parcours client ;
- rassurer sur les etapes.

### TrustClusterComponent

Role :

- regrouper plusieurs signaux de confiance ;
- soutenir les pages devis et produit.

### ProductFamilyGridComponent

Role :

- presenter les familles produit ;
- orienter vers categories ;
- composer une entree catalogue premium.

### ComparisonStripComponent

Role :

- comparer des usages ;
- aider au choix ;
- synthese technique accessible.

## Composants Produit

### CategoryBlockComponent

Role :

- afficher une categorie ;
- relier produits et besoin client ;
- enrichir la page categories.

### ProductCardComponent

Role :

- carte produit ;
- acces fiche produit ;
- contexte court.

### OptionListComponent

Role :

- details techniques ;
- options ;
- finitions ;
- aide au choix.

Les concepts d'affichage doivent rester factorisables avant d'etre integres dans les pages reelles.

## Formulaires

### QuoteFormComponent

Role :

- demande de devis ;
- contact qualifie ;
- collecte courte.

Regles :

- labels explicites ;
- champs utiles seulement ;
- messages d'aide courts ;
- parcours mobile confortable.

### FieldComponent

Role :

- champ de formulaire standard ;
- textarea ;
- select ;
- erreurs ;
- aide.

## Feedback Et Etats

### NotificationBannerComponent

Role :

- information ;
- succes ;
- alerte ;
- erreur.

### EmptyStateComponent

Role :

- etat vide ;
- resultat absent ;
- redirection vers action.

### FaqAccordionComponent

Role :

- questions courtes ;
- informations de reassurance ;
- details produit ou devis.

### MediaMosaicComponent

Role :

- ambiance showroom ;
- preuves visuelles ;
- details produit.

## Debug Components

Le mode debug doit rester disponible sur toutes les pages Public V2.

Objectif :

- visualiser les limites des composants ;
- verifier les layouts ;
- faciliter la factorisation ;
- inspecter rapidement les sections et micro composants.

Regle d'usage :

- activation en une ligne de code quand on travaille sur une page ;
- pas de logique dupliquee par composant ;
- le comportement est porte par `PublicV2::Debuggable`.

Les composants doivent accepter `debug:` quand ils sont structurants ou utiles a inspecter.

## Page Design System

La page `/public-v2/design-system` doit contenir :

- fondations visuelles ;
- primitives UI ;
- navigation ;
- sections ;
- composants metier ;
- composants produit ;
- formulaires ;
- feedback ;
- inventaire ViewComponents.

Elle ne doit pas contenir :

- tests de layouts complets ;
- versions temporaires de home ;
- prototypes de page ;
- anciennes experimentations ;
- selection dynamique de theme, couleur ou typo.

Cette page est la boite de briques propre du Public V2.

## Regles Pour Les Futures Pages

Pour construire une page reelle :

1. synthetiser les donnees metier de la page ;
2. choisir une structure de page ;
3. composer avec des sections reutilisables ;
4. utiliser les micro composants du UI Kit ;
5. verifier mobile et desktop ;
6. activer le debug pendant la construction ;
7. retirer les artifices de test avant validation.

Pour tester une idee :

1. creer une page dediee temporaire avec `test` dans le nom ;
2. ne pas polluer `design-system` ;
3. ne pas modifier une page reelle tant que la direction n'est pas validee ;
4. supprimer la page de test apres integration ou abandon.

## Validation Technique

Avant de considerer le design system stable :

- verifier que les routes Public V2 reelles rendent en 200 ;
- verifier que `/public-v2/design-system` rend en 200 ;
- chercher les traces d'anciens labs ou anciennes directions ;
- verifier que le debug fonctionne ;
- verifier que la doc est alignee avec le code ;
- garder public classique et admin-v2 intacts.

Recherches utiles :

```sh
rg -n "ANCIEN_NOM_DE_LAB|ANCIENNE_DIRECTION|ANCIEN_HELPER_THEME" app config docs
```

```sh
git diff --check
```

## Etat Actuel

Le design system actif est maintenant Warm System V9.

La page `/public-v2/design-system` est la reference UI Kit propre.

Les pages reelles Public V2 doivent progressivement etre reconstruites avec :

- composants de layout ;
- composants de section ;
- micro composants ;
- mode clair/sombre uniquement ;
- debug factorise ;
- wording premium, metier et oriente devis.
