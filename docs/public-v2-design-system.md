# Public V2 - Design System Apple-like

Derniere mise a jour : 2026-06-08

Ce document est la reference design system du chantier Public V2. Il remplace l'ancienne base Warm System et repart de zero autour de la direction **Apple-like**.

Il n'y a plus de page publique `/public-v2/design-system`. Le design system vit dans cette documentation, les composants Public V2 et le CSS namespace `public_v2.css`.

## Perimetre

Public V2 reste isole sous `/public-v2/*` pendant la phase de test.

Routes applicatives Public V2 :

- `/public-v2/home`
- `/public-v2/categories`
- `/public-v2/produits/:slug`
- `/public-v2/produits/:slug/selecteur-toile`
- `/public-v2/devis`
- `/public-v2/contact`

Hors perimetre :

- public classique v1 ;
- admin v1 ;
- admin v2 ;
- anciennes pages de laboratoire ;
- anciennes explorations de design system.

## Direction Apple-like

Objectif : une interface claire, premium, calme, orientee produit et devis, avec une lecture immediate sur mobile et desktop.

Principes visuels :

- fonds sobres, beaucoup d'air, sections peu bruitees ;
- typographie sans-serif nette, tailles genereuses uniquement pour les vrais titres de page ;
- cartes produit visuelles, avec image utile et action lisible ;
- boutons noirs/blancs ou accentues avec retenue ;
- mode clair/sombre conserve ;
- accents colores limites a l'orientation, jamais a une palette mono-teinte ;
- textes courts, metier, utiles pour cadrer un projet ;
- pas de blocs marketing explicatifs qui decrivent l'interface.

## Composants

Les pages reelles composent des ViewComponents dedies Public V2 :

- `PublicV2::Layout::*` pour le shell, navbar et footer ;
- `PublicV2::Home::*` pour la home, l'Event et les sections metier ;
- `PublicV2::Categories::*` pour le catalogue ;
- `PublicV2::Products::*` pour la fiche produit et le selecteur de toile ;
- `PublicV2::Quotes::*` pour le devis ;
- `PublicV2::Contact::*` pour le showroom et l'acces ;
- `PublicV2::Ui::*` pour les primitives reutilisables.

Regles :

- garder les composants et styles dans le namespace Public V2 ;
- ne pas appeler de composants public v1 ou admin dans Public V2 ;
- ne pas mettre de requetes metier dans les vues ;
- charger les donnees dans les controllers/presenters ;
- conserver `PublicV2::Debuggable` sur les composants structurants.

## SEO Et Noindex

Pendant la mise en production de test, tout le namespace Public V2 doit rester non indexable :

- meta `robots` : `noindex, nofollow, noarchive` ;
- meta `googlebot` : `noindex, nofollow, noarchive` ;
- header `X-Robots-Tag` : `noindex, nofollow, noarchive`.

Chaque vue Public V2 doit quand meme porter les bases SEO :

- `title` ;
- `description` ;
- `keywords` quand utile ;
- wording propre, exploitable lors de la future bascule publique.

Au moment de la bascule v1 -> v2, retirer le noindex Public V2 seulement quand les routes publiques finales, le sitemap, les canonicals et les controles de devis sont valides.

## Pages Actuelles

Home :

- hero Apple-like ;
- notification Event dediee home ;
- familles produits ;
- showroom ;
- partenaires dans le nouveau style ;
- plus de raccourci devis ancien design.

Categories :

- hero catalogue ;
- navigation par familles ;
- sections produits Apple-like ;
- plus de CTA ancien design `Un produit a cadrer ?` ;
- CSS legacy categories retire des styles actifs.

Product/show :

- fiche produit V2 ;
- lien selecteur de toile vers la route Public V2 ;
- composants produits dedies V2.

Selecteur de toile :

- page Public V2 dediee ;
- iframe Dickson Designer ;
- actions retour produit et devis ;
- breadcrumb V2.

Devis :

- formulaire V2 ;
- produits classiques et destockage conserves.

Contact :

- showroom, acces, contact et preparation de visite.

## Validation

Ne pas lancer de serveur Rails si l'utilisateur indique qu'il teste lui-meme.

Checks statiques utiles :

```sh
bin/rails routes -g public-v2
git diff --check
ruby -c app/controllers/public_v2/base_controller.rb
```

Pour une validation visuelle, verifier au minimum :

- desktop et mobile ;
- light et dark mode ;
- home, categories, product/show, selecteur de toile, devis, contact ;
- absence de retour des anciens blocs de design.
