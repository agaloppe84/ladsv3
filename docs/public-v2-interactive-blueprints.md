# Public V2 - Plans produits interactifs

Ce document decrit le systeme de plans interactifs utilise sur les fiches produits Public V2.
Il sert de reference de travail pour les prochaines sessions Codex/ChatGPT sur ce chantier.

## Perimetre

- Public V2 uniquement.
- Ne jamais impacter public v1.
- Ne jamais impacter admin v2.
- Ne pas lancer de serveur local sauf demande explicite.
- Pas de tests Rails, composants ou unitaires tant que le systeme visuel n'est pas stabilise.
- Verifications acceptees : lecture du code, `rg`, `ruby -c`, blueprint validator, Rails runner de rendu, `git diff --check`.

## Objectif courant

Le systeme passe progressivement du dessin technique filaire a un rendu "objet plein".

Objectifs :

- ne plus utiliser de rendu filaire comme rendu principal final ;
- creer des objets parametriques reutilisables pour rails, coffres, toiles, barres, controles, moteurs, supports et accessoires ;
- garder des palettes clair/sombre coherentes ;
- poser les blueprints sur une grille commune ;
- generer les callouts avec des regles, pas avec des decisions ponctuelles dans chaque template.

## Architecture

Fichiers centraux :

- `app/components/public_v2/products/exploded_view_experiment_component.rb`
- `app/components/public_v2/products/exploded_view/base_drawing_component.rb`
- `app/components/public_v2/products/exploded_view/generic_drawing_component.rb`
- `app/components/public_v2/products/exploded_view/blueprints/base.rb`
- `app/components/public_v2/products/exploded_view/layout_primitives.rb`
- `app/components/public_v2/products/exploded_view/solid_profiles.rb`
- `app/components/public_v2/products/exploded_view/fabrics.rb`
- `app/components/public_v2/products/exploded_view/callouts.rb`
- `app/components/public_v2/products/exploded_view/blueprints/blueprint_validator.rb`
- `config/public_v2/blueprints/schema/v1.json`
- `app/components/public_v2/products/exploded_view/blueprint_specs/spec.rb`
- `app/components/public_v2/products/exploded_view/blueprint_specs/loader.rb`
- `app/components/public_v2/products/exploded_view/blueprint_specs/element_registry.rb`
- `app/components/public_v2/products/exploded_view/blueprint_specs/preset_registry.rb`
- `app/components/public_v2/products/exploded_view/blueprint_specs/preset_slot_layout.rb`
- `app/components/public_v2/products/exploded_view/blueprint_specs/assembler.rb`
- `app/components/public_v2/products/exploded_view/blueprint_specs/assembled_blueprint.rb`
- `app/components/public_v2/products/exploded_view/blueprint_specs/data_layout_builder.rb`
- `app/components/public_v2/products/exploded_view/blueprint_specs/validator.rb`

Les fichiers blueprint portent les donnees produit, le layout et les callouts.
Les drawing components doivent rester fins et rendre les objets produits par le systeme blueprint/layout.

## Architecture JSON cible

Le chantier migre progressivement vers un systeme data-driven.

Objectif final :

- aucun fichier Ruby specifique a un nom de produit ;
- aucun template SVG specifique a un produit ;
- un fichier JSON par blueprint ;
- un renderer generique qui assemble les objets parametriques existants ;
- affichage du composant sur `product/show` uniquement si une spec JSON existe pour le `product.slug`.

Architecture finale attendue :

- `product/show` demande uniquement un blueprint JSON par slug produit ;
- `DataBlueprint` lit la spec et expose les donnees front ;
- `Assembler` normalise les elements, groupes et callouts ;
- `DataLayoutBuilder` transforme la data en primitives de layout ;
- les presets de layout reduisent les positions explicites au strict necessaire ;
- les presets de callouts fournissent les routes standards par slot de layout ;
- `GenericDrawingComponent` rend tous les produits avec les familles generiques ;
- les fichiers Ruby produits et templates produits sont supprimes ;
- les helpers filaires et classes CSS legacy sont retires ou limites au debug ;
- les nouveaux produits enrichissent la librairie d'elements au lieu de creer un dessin one-shot.

Emplacement cible des specs :

```text
config/public_v2/blueprints/
  schema/v1.json
  stores-exterieurs/store-vertical-zippe.json
  stores-interieurs/store-duette.json
  stores-interieurs/store-venitien.json
  stores-interieurs/store-rouleau-duo.json
  moustiquaires/moustiquaire-plissee.json
  moustiquaires/moustiquaire-enroulable-verticale.json
```

Categories catalogue autorisees :

- `moustiquaires`
- `pergolas`
- `portes-de-garage`
- `stores-exterieurs`
- `stores-interieurs`
- `volets-battants`
- `volets-roulants`

Contrat d'une spec JSON :

- `schema_version` : version du contrat, actuellement `1` ;
- `product` : slug, categorie, aliases, fabricant et famille ;
- `sources` : page officielle, PDF technique, fiche de pose, datasheet ;
- `technical_data` : dimensions, references, contraintes documentees ;
- `presets` : famille de layout et famille de callouts ;
- `render_options` : grille visuelle, animation callout, accent ;
- `canvas` : grille globale et snap ;
- `parts` : legende et ordre d'affichage ;
- `metrics` : cartes de synthese ;
- `elements` : objets semantiques a generer, avec un `slot` de layout quand un
  preset est declare ;
- `groups` : groupes attaches ou groupes de layout ;
- `callouts` : marqueurs, routes et eventuel override de slot ;
- `validation` : regles specifiques au blueprint.

Regle importante :

Le JSON decrit les objets, il ne dessine pas les objets.
Il ne doit pas contenir de SVG brut, de `d`, de `raw_svg`, de `outline_path`,
de `detail_path`, de `surface_path` ou de `profile_path`.
Les formes doivent etre generees par les familles parametriques Ruby.

Validation JSON :

- `PublicV2::Products::ExplodedView::BlueprintSpecs::Validator.validate_all!`
  valide le schema et les specs JSON ;
- `PublicV2::Products::ExplodedView::Blueprints::BlueprintValidator.validate_specs!`
  expose le meme controle depuis le validator historique.
- `PublicV2::Products::ExplodedView::Blueprints::BlueprintValidator.validate_spec_layouts!`
  valide que les specs dotees d'un builder data-driven produisent un layout exploitable.

Assemblage JSON :

- `BlueprintSpecs::ElementRegistry` declare les couples `type:variant` supportes ;
- `BlueprintSpecs::PresetRegistry` declare les presets de layout/callouts supportes ;
- `BlueprintSpecs::Assembler` transforme une spec JSON en objets normalises ;
- `ElementDefinition` porte `id`, `part_id`, `type`, `variant`, `slot`, `box`,
  `options`, `attached_features` et `renderer_family` ;
- `GroupDefinition` porte les groupes de layout ;
- `CalloutDefinition` convertit les marqueurs en `Point` et herite du `slot`
  de l'element lie quand le callout ne declare pas son propre slot ;
- `AssembledBlueprint` expose les index `element(id)`, `group(id)`,
  `callout(part_id)` et la liste des familles de rendu necessaires.
- `BlueprintSpecs::PresetSlotLayout` expose les elements par slot, les boxes
  explicites de slot et les gaps entre slots pour amorcer le moteur de layout
  parametrique.
- `BlueprintSpecs::DataLayoutBuilder` transforme la spec assemblee en layout Ruby.
  Au stade actuel, `store-vertical-zippe`, `moustiquaire-enroulable-verticale`,
  `moustiquaire-plissee`, `store-duette`, `store-venitien` et
  `store-rouleau-duo` sont supportes.
- `GenericDrawingComponent` sait rendre les layouts data-driven supportes
  en mode objet plein. Il est utilise par `product/show` via `blueprint_source: :json`.

Presets JSON declares au stade actuel :

- `store-vertical-zippe` -> layout `vertical-product-layout`, callouts `vertical-product-callouts` ;
- `moustiquaire-enroulable-verticale` -> layout `vertical-product-layout`, callouts `vertical-product-callouts` ;
- `moustiquaire-plissee` -> layout `horizontal-product-layout`, callouts `horizontal-product-callouts` ;
- `store-duette` -> layout `vertical-product-layout`, callouts `vertical-product-callouts` ;
- `store-venitien` -> layout `vertical-product-layout`, callouts `vertical-product-callouts` ;
- `store-rouleau-duo` -> layout `vertical-product-layout`, callouts `vertical-product-callouts`.

Important :

Au stade actuel, les deux presets structurants `vertical-product-layout` et
`horizontal-product-layout` sont declares et valides. Les positions explicites des
elements restent la source de verite du rendu, mais les callouts peuvent deja
heriter d'options par defaut depuis `vertical-product-callouts` ou
`horizontal-product-callouts` quand ils n'ont ni `placement`, ni route/longueur
explicite. `moustiquaire-enroulable-verticale` est le premier blueprint dont le
builder consomme les slots de `vertical-product-layout` via `PresetSlotLayout`,
sans modifier le rendu valide.

Couples JSON supportes au stade actuel :

- `bar:bottom-charge` -> `solid_bar_profile`
- `bar:roll-tube` -> `solid_bar_profile`
- `bar:threshold` -> `solid_bar_profile`
- `bar:vertical-handle` -> `solid_bar_profile`
- `bar:zipped-load` -> `solid_bar_profile`
- `closure:magnetic-receivers` -> `solid_accessory_profile`
- `closure:plissee-lock` -> `solid_accessory_profile`
- `closure:rail-bavettes` -> `solid_accessory_profile`
- `control:bead-chain` -> `solid_control_profile`
- `control:cord-pair` -> `solid_control_profile`
- `control:venetian-wand` -> `solid_control_profile`
- `fabric:bordered-grid-solid` -> `fabric_pattern`
- `fabric:duo-bands-solid` -> `fabric_pattern`
- `fabric:honeycomb-solid` -> `fabric_pattern`
- `fabric:pleated-solid` -> `fabric_pattern`
- `fabric:zipped-solid` -> `fabric_pattern`
- `housing:front-coffre` -> `solid_housing_profile`
- `housing:kiss-50-cassette` -> `solid_housing_profile`
- `motor:tubular` -> `solid_motor_profile`
- `rail:duette-head` -> `solid_bar_profile`
- `rail:double-coulisse-pair` -> `solid_profile`
- `rail:horizontal-guide` -> `solid_profile`
- `rail:profile-pair` -> `solid_profile`
- `rail:zipped-coulisse-pair` -> `solid_profile`
- `slat:venetian-pack` -> `slat_pattern`
- `support:mount-pair` -> `solid_support_profile`

Prochaine migration technique :

1. Faire consommer progressivement `presets.layout` par `DataLayoutBuilder`.
2. Remplacer les positions recurrentes par des slots de layout reutilisables.
3. Faire consommer progressivement `presets.callouts` pour proposer les routes
   standards par slot.
4. Garder les overrides JSON pour les collisions et cas produit particuliers.
5. Supprimer les branches Ruby qui dispatchent uniquement par nom de produit quand
   un preset peut generer le meme rendu.
6. Supprimer les classes Ruby et templates produits legacy quand ils ne sont plus
   appeles par le chemin JSON.

Etat actuel :

- les 6 blueprints POC existants disposent maintenant d'une spec JSON ;
- les 6 specs declarent un preset de layout et un preset de callouts ;
- `moustiquaire-enroulable-verticale` utilise deja ses slots pour construire le
  caisson, la toile, les coulisses, la barre, la fermeture et les bavettes ;
- les anciens fichiers Ruby et templates produits restent temporairement en place
  comme dette legacy explicite ;
- la prochaine phase systeme consiste a faire porter le placement par les presets,
  pas a creer de nouveaux chemins specifiques produit.

Important :

Les specs JSON servent de contrat data pour preparer la bascule complete vers un
renderer generique. Le composant public charge maintenant le chemin data-driven
avec `blueprint_source: :json`.
Les blueprints Ruby historiques restent disponibles uniquement comme source legacy explicite
pendant la migration.

Mode de chargement controle :

- `ExplodedViewExperimentComponent` accepte `blueprint_source: :legacy` ou `:json` ;
- `product/show` utilise explicitement `blueprint_source: :json` ;
- `blueprint_source: :json` force le chargement via `DataBlueprint.find_for_product` ;
- en mode `:json`, aucune fallback vers `StoreVerticalZippe` n'est appliquee ;
- si aucune spec JSON ne correspond au `product.slug`, le composant ne rend rien ;
- un blueprint injecte explicitement reste prioritaire pour les smokes isoles.

Objectif du prochain basculement :

1. extraire une premiere generation de boxes par slot dans `PresetSlotLayout` ;
2. reduire les `box` JSON explicites sur `moustiquaire-enroulable-verticale` ;
3. etendre le meme mode de consommation a un deuxieme blueprint vertical ;
4. remplacer les constantes de placement recurrentes par des slots de preset ;
5. supprimer progressivement les fichiers Ruby et templates specifiques produits
   devenus inutiles ;
6. nettoyer les helpers filaires, SVG code en dur et classes CSS legacy qui ne sont
   plus utilises par la voie JSON.

## Options de rendu

Les blueprints peuvent exposer des options de rendu.

Cles recommandees :

- `show_layout_grid` : booleen ;
- `callout_animation_profile` : `:draw` ou `:none`.

Cas d'usage :

- tester un blueprint sans grille visuelle ;
- comparer callouts animes et callouts instantanes ;
- isoler les essais visuels par produit.

Comportement par defaut :

- grille masquee sauf override blueprint ;
- animation des callouts desactivee sauf override blueprint.

## Regles de grille

La grille visuelle est aussi la reference de layout.

Standard actuel :

- maille mineure : `120` ;
- grosse ligne toutes les `4` mailles ;
- grosse maille : `480` ;
- marge canvas : `60` ;
- unite de snap : `10`.

Regles :

- La largeur et la hauteur du frame de grille doivent etre des nombres entiers de mailles.
- Les objets principaux doivent etre snappes.
- Les grands objets horizontaux doivent commencer et finir sur de grosses lignes quand c'est possible.
- Les dimensions d'elements reutilisables doivent privilegier des largeurs compatibles avec la grosse maille.
- Les grilles internes de toiles doivent utiliser des subdivisions entieres.
- Les formes pleines fermees doivent masquer la grille de fond a l'interieur de leur silhouette.

## Grammaire de layout globale

Chaque blueprint doit tendre vers une structure produit previsible.

Slots recommandes :

- `top_supports` : supports de pose au-dessus du profil principal ;
- `top_housing` / `headrail` : coffre, caisson ou rail haut, centre ;
- `fabric_cluster` : toile dans la zone centrale ;
- `side_guides` : coulisses, profils lateraux ou profils muraux ;
- `bottom_bar` : barre de charge, seuil, rail bas ou barre poignee ;
- `controls` : chainette, cordon, tige, moteur ou details de commande ;
- `attached_features` : details physiquement attaches a un autre element.

Regles d'espacement :

- Les elements attaches comptent comme un seul groupe pour les espacements.
- Les elements eclates utilisent les gaps nommes de `LayoutStandards`.
- Les objets symetriques doivent etre generes depuis une seule source de verite.
- Ne pas regler separement gauche/droite sauf asymetrie reelle du produit.

## Presets de layout et callouts

Le systeme evolue vers des presets reutilisables.
L'objectif est d'eviter de recalculer manuellement les positions pour chaque produit.

Familles de presets posees :

- `vertical-product-layout` : toile/lames/plis au centre, coffre/caisson/rail au-dessus,
  supports optionnels au-dessus, coulisses optionnelles en miroir, barre basse sous la
  toile et accessoires/commandes a droite du groupe central ;
- `horizontal-product-layout` : toile/plis au centre, rail ou guide haut au-dessus,
  supports optionnels, profils lateraux optionnels en miroir, barre de tirage verticale
  attachee a droite quand elle existe ;
- les anciens presets plus specifiques restent dans le registre uniquement comme
  compatibilite de migration et ne doivent plus etre choisis pour un nouveau blueprint.

Chaque preset doit definir :

- les slots disponibles ;
- les gaps nommes par defaut ;
- les regles d'attachement entre elements ;
- les contraintes de snap sur grosse grille ;
- les positions de callouts recommandees par slot ;
- les overrides autorises pour les cas particuliers.

Regles de slots :

- le `slot` se declare au niveau de l'element, pas dans `options` ;
- les noms de slots sont valides par le `layout` preset choisi ;
- les slots requis du preset doivent etre couverts par les elements JSON ;
- un callout herite du slot de son element via `part_id` ;
- un callout peut declarer son propre `slot` si le marqueur vise un groupe ou un
  detail attache different de l'element principal ;
- si un callout conserve un `placement`, une `route` ou une longueur explicite, cet
  override reste prioritaire sur le preset.

Regle de progression :

- pendant la migration JSON, les positions explicites restent acceptees ;
- apres migration complete, extraire les constantes recurrentes dans des presets ;
- un nouveau blueprint doit d'abord choisir un preset global, puis ne declarer que
  les variations produit necessaires.

## Regles de callouts

Un callout est compose de :

- marqueur numerote ;
- ligne droite ou coudee ;
- petit point terminal ;
- texte.

Regles :

- Preferer les placements existants de `CalloutPlacement`.
- Utiliser `route: :auto` ou `label_side: :auto` quand la position du marqueur doit decider la direction.
- Utiliser `animation_profile: :none` seulement pour une comparaison blueprint ou une variante sans mouvement.
- Garder une taille coherente entre les ronds du plan et les ronds de la legende.
- Eviter toute collision entre texte, callout et produit.
- Le callout doit pointer vers l'objet visuel reel, pas vers une boite decorative.

### Presets de callouts cibles

Les callouts doivent etre lies aux presets de layout.

Direction cible :

- chaque slot global expose une position de marqueur recommandee ;
- chaque slot expose une route recommandee : droite, gauche, haut, bas, auto,
  ligne droite ou ligne coudee ;
- sur `vertical-product-callouts`, les slots principaux `top-housing`, `top-rail`,
  `headrail`, `fabric`, `bottom-bar` et `bottom-rail` utilisent par defaut une ligne
  droite vers la droite ;
- sur `horizontal-product-callouts`, les slots principaux `top-guide`, `top-rail`,
  `headrail` et `fabric` utilisent par defaut une ligne droite vers la droite ;
- les groupes attaches peuvent recevoir un callout sur le groupe plutot que sur
  une seule piece ;
- les elements tres proches doivent partager des regles de collision communes ;
- les overrides JSON restent possibles, mais doivent rester rares et lisibles.

Quand un nouveau callout est ajoute :

- utiliser un preset existant si possible ;
- si le placement revient sur plusieurs blueprints, creer un preset ;
- si le placement est specifique a un produit, le laisser en override JSON.

## Rendu objet plein

La direction finale est le rendu objet plein.

Regle de chantier :

- ne plus introduire de nouveau rendu filaire principal ;
- si un element est encore filaire, le convertir avec une famille parametrique ;
- si aucune famille existante ne convient, creer une nouvelle variante generique ;
- ne pas mettre de SVG code en dur dans un template pour corriger un produit ;
- les templates specifiques produits sont temporaires et doivent disparaitre.

Familles reutilisables actuelles :

- `SolidProfile` : rails/profils lineaires avec bandes de tons et points ;
- `SolidHousingProfile` : coffres, caissons et cassettes ;
- `SolidBarProfile` : barres horizontales pleines avec corps, detail central, poignee, points, extensions et onglets attaches optionnels ;
- `SolidSupportProfile` : supports de pose rectangulaires avec details et points ;
- `SolidControlProfile` : chainettes, cordons, tiges et points de commande en segments pleins ;
- `SolidMotorProfile` : moteurs tubulaires avec tube, embout, tete moteur et trous ;
- `SolidAccessoryProfile` : petits accessoires pleins, recepteurs, verrous et details attaches ;
- `SlatPattern` : packs de lames repetitives avec tons pleins et profondeur legere ;
- `FabricPattern` : surfaces de toile et patterns techniques.

Familles a enrichir ensuite :

- variantes `SolidAccessoryProfile` pour languettes, guides, verrous et details attaches plus specifiques.

Eviter `outline`, `profile`, `detail` et `hairline` comme rendu principal final.
Ces classes peuvent rester temporairement pour debug ou micro-details tres subtils.

## Inventaire dette filaire

Cet inventaire sert de backlog pour supprimer progressivement tout rendu principal filaire.
Une entree est consideree comme migree quand le template rend un objet plein parametrique
et que la geometrie n'est plus decrite par un `outline_path`, `detail_path`, `surface_path`
ou une classe `outline` / `profile` / `detail` / `hairline`.

### Priorites de migration restantes

1. **Accessoires restants** : languettes et details attaches.
2. **Fallbacks legacy** : retirer les anciens chemins apres migration complete.

### Par blueprint

#### Store vertical zippe

Elements deja en objet plein :

- coffre extrude via `SolidHousingProfile` ;
- motorisation via `SolidMotorProfile` ;
- supports de pose via `SolidSupportProfile` ;
- coulisses laterales via `SolidProfile` vertical parametrique ;
- toile zippee via `FabricPattern` ;
- barre de charge via `SolidBarProfile` avec `embouts` ;
- zip textile et bordures de toile en rendu plein.

Dette restante :

- fallback filaire de `barre-charge` encore present dans le template et dans `BarElement`,
  a supprimer quand tous les usages de barre zippee seront pleins.

Cible :

- suppression du fallback `zipped_load_bar` filaire.

#### Moustiquaire plissee

Elements deja en objet plein :

- guide superieur via `SolidProfile` ;
- profils muraux via `SolidProfile` ;
- toile plissee via `FabricPattern` ;
- barre poignee via `SolidBarProfile` ;
- seuil extra-plat via `SolidBarProfile` ;
- verrouillage via `SolidAccessoryProfile`.

Dette restante :

- aucune dette filaire prioritaire sur les elements principaux.

Cible :

- enrichir `SolidAccessoryProfile` si de nouveaux verrous ou recepteurs doivent etre representes.

#### Moustiquaire enroulable verticale

Elements deja en objet plein :

- caisson KISS 50 via `SolidHousingProfile` ;
- double coulisse via `SolidProfile` ;
- toile bordee via `FabricPattern` ;
- barre de charge via `SolidBarProfile` ;
- fermeture magnetique via `SolidAccessoryProfile` ;
- bavettes via `SolidAccessoryProfile`, avec geometrie attachee aux coulisses.

Dette restante :

- aucune dette filaire prioritaire sur les elements principaux.

Cible :

- conserver l'attachement physique des bavettes aux coulisses via `RailAttachedFeature`.

#### Store venitien

Elements deja en objet plein :

- boitier haut via `SolidProfile` ;
- lames orientables via `SlatPattern` ;
- barre finale via `SolidBarProfile` ;
- supports de pose via `SolidSupportProfile` ;
- commande via `SolidControlProfile` ;
- cordons/echelles via `SolidControlProfile`.

Dette restante :

- aucune dette filaire prioritaire sur les elements principaux.

Cible :

- enrichir `SlatPattern` si de nouvelles variantes de lames doivent etre representees.

#### Store Duette

Elements deja en objet plein :

- rail superieur via `SolidBarProfile` ;
- supports de pose via `SolidSupportProfile` ;
- toile Duette via `FabricPattern` ;
- rail intermediaire via `SolidBarProfile` ;
- rail bas via `SolidBarProfile` ;
- cordons de guidage via `SolidControlProfile`.

Dette restante :

- aucune dette filaire prioritaire sur les elements principaux.

#### Store rouleau duo

Elements deja en objet plein :

- rail superieur via `SolidProfile` ;
- supports de pose via `SolidSupportProfile` ;
- tube d'enroulement en rectangles pleins ;
- toile duo via `FabricPattern` ;
- barre de charge via `SolidBarProfile` ;
- commande/chainette via `SolidControlProfile`.

Dette restante :

- aucune dette filaire prioritaire sur les elements principaux.

### Dette transversale modele et helpers

Classes/methodes a conserver temporairement, puis a retirer quand les migrations sont terminees :

- `BaseDrawingComponent#surface_path` ;
- classes CSS principales `pv2-product-exploded__outline`,
  `pv2-product-exploded__profile`, `pv2-product-exploded__detail`,
  `pv2-product-exploded__hairline` ;
- `RailElement#outline_path`, `RailElement#inner_path`, `RailElement#profile_path` ;
- `BarElement#outline_path` et les branches `detail_path` legacy ;
- `MotorElement#tube_path`, `MotorElement#head_path`, `MotorElement#detail_path`.

Ces APIs ne doivent plus etre utilisees pour de nouveaux objets.
Elles servent uniquement de transition pendant la migration des blueprints existants.

### Prochain ordre conseille

1. Supprimer les fallbacks legacy devenus inutiles.
2. Continuer la migration des micro-details directs vers des familles pleines dediees.
3. Enrichir les variantes `SolidAccessoryProfile` si un nouveau blueprint introduit un detail attache recurrent.

## Lumiere, degradés et ombres

Le systeme doit definir une seule logique de lumiere globale.

Direction recommandee :

- lumiere en haut a gauche ;
- highlights sur faces hautes/gauches ;
- ombres sur faces basses/droites ;
- gradients tres subtils ;
- pas d'ombres lourdes ;
- pas de glow decoratif.

Direction technique :

- centraliser les tokens de palette dans le CSS du composant ;
- generer les gradients SVG dans `BaseDrawingComponent` ;
- garder des tons semantiques : `light`, `mid`, `dark`, puis plus tard `highlight`, `shade`, `shadow` ;
- utiliser `color-mix()` pour deriver les variantes clair/sombre ;
- utiliser les ombres avec parcimonie, plutot sur des groupes que sur des petits elements repetes.

## Process de recherche produit

Pour chaque nouveau produit :

1. Identifier le produit exact dans le catalogue production.
2. Confirmer fabricant et famille produit.
3. Chercher d'abord sur les sites officiels fabricant.
4. Chercher PDF techniques, notices de pose, fiches dimensions et schemas.
5. Extraire les dimensions documentees et les indices de geometrie.
6. Decider si les objets parametriques existants suffisent.
7. Creer de nouvelles variantes reutilisables quand la geometrie est vraiment differente.
8. Construire un blueprint POC.
9. Valider visuellement en mode clair et sombre.
10. Reinjecter les decouvertes reutilisables dans la librairie d'elements.

## Checklist blueprint

Avant de considerer un blueprint stable :

- slug/nom produit alignes avec le catalogue production ;
- source technique nommee ;
- elements principaux snappes sur la grille ;
- grandes largeurs alignees sur les grosses lignes quand possible ;
- elements miroirs generes symetriquement ;
- groupes attaches declares ;
- callouts bases sur presets ou overrides documentes ;
- aucune animation de scale indesirable sur les elements ;
- options grille/callout intentionnelles ;
- dette filaire restante listee ;
- rendu Rails runner OK ;
- `BlueprintValidator.validate_all!` OK.

## Directives agent

Pour tout agent Codex/ChatGPT travaillant sur ce chantier :

- Lire le code actuel avant de proposer ou modifier.
- Rester dans Public V2.
- Ne pas toucher public v1 ou admin v2.
- Ne pas lancer de serveur sauf demande explicite.
- Ne pas lancer de tests Rails/composants/unitaires tant que l'utilisateur ne les remet pas dans le scope.
- Garder les changements cibles.
- Preferer des objets parametriques reutilisables au SVG one-shot.
- Preserver le mode clair/sombre.
- Preserver les changements utilisateur non lies.
- Utiliser `rg` pour les recherches.
- Utiliser `apply_patch` pour les edits manuels.
- A la fin de chaque step implemente, resumer le prochain step logique.
- Si aucun next step n'est evident, faire un audit avant de coder.
