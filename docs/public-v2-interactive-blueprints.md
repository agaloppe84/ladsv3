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
- `app/components/public_v2/products/exploded_view/blueprints/base.rb`
- `app/components/public_v2/products/exploded_view/layout_primitives.rb`
- `app/components/public_v2/products/exploded_view/solid_profiles.rb`
- `app/components/public_v2/products/exploded_view/fabrics.rb`
- `app/components/public_v2/products/exploded_view/callouts.rb`
- `app/components/public_v2/products/exploded_view/blueprints/blueprint_validator.rb`

Les fichiers blueprint portent les donnees produit, le layout et les callouts.
Les drawing components doivent rester fins et rendre les objets produits par le systeme blueprint/layout.

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

- grille visible sauf override blueprint ;
- animation des callouts active sauf override blueprint.

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

## Rendu objet plein

La direction finale est le rendu objet plein.

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

1. **Accessoires restants** : verrouillage plissee, languettes et details attaches.
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
- verrouillage rendu en formes pleines/echos.

Dette restante :

- aucune dette filaire prioritaire sur les elements principaux.

Cible :

- rattacher le verrouillage a une famille `SolidAccessoryProfile` si on le reutilise.

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
- `MotorElement#tube_path`, `MotorElement#head_path`, `MotorElement#detail_path` ;
- `ControlElement#cord_path` ;
- `ClosureElement#receiver_path`.

Ces APIs ne doivent plus etre utilisees pour de nouveaux objets.
Elles servent uniquement de transition pendant la migration des blueprints existants.

### Prochain ordre conseille

1. Migrer le verrouillage plissee vers `SolidAccessoryProfile` si on veut supprimer ses chemins directs.
2. Supprimer les fallbacks legacy devenus inutiles.
3. Continuer la migration des micro-details directs vers des familles pleines dediees.

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
