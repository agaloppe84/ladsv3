# Public V2 - Plan De Mise En Production Et Migration

Derniere mise a jour : 2026-06-08

Objectif : mettre Public V2 en production pour test reel sans indexation, puis basculer le site public classique vers Public V2 avec un referencement propre.

## Phase 1 - Mise En Production Test Noindex

Deployer le namespace `/public-v2/*` avec :

- meta `robots` : `noindex, nofollow, noarchive` ;
- meta `googlebot` : `noindex, nofollow, noarchive` ;
- header `X-Robots-Tag` : `noindex, nofollow, noarchive` ;
- aucune route publique v1 remplacee.

But : tester la V2 en production sans exposition Google.

Pages a tester :

- `/public-v2/home`
- `/public-v2/categories`
- `/public-v2/produits/:slug`
- `/public-v2/produits/:slug/selecteur-toile`
- `/public-v2/devis`
- `/public-v2/contact`

Parcours a tester :

- navigation desktop/mobile ;
- light/dark mode ;
- ouverture fiche produit depuis categories ;
- lien fiche produit vers selecteur de toile V2 ;
- retour selecteur vers fiche produit ;
- demande de devis avec produit preselectionne ;
- demande de devis sans produit ;
- affichage Event home ;
- affichage partenaires home ;
- absence de blocs anciens design.

## Phase 2 - Pre-bascule SEO

Avant de remplacer le public classique :

- verifier tous les `title` et `description` ;
- retirer les libelles temporaires `Public V2` des titres publics finaux si besoin ;
- definir les canonicals des futures routes publiques ;
- preparer le sitemap des routes finales ;
- verifier `robots.txt` ;
- verifier les images principales et textes alternatifs importants ;
- controler les pages produit sans image ou sans description ;
- controler les erreurs 404 et produits non publies.

Les URLs publiques finales doivent rester propres :

- `/`
- `/categories`
- `/produits/:slug`
- `/devis`
- `/contact`

## Phase 3 - Bascule V1 Vers V2

Quand la V2 est validee :

1. router les URLs publiques finales vers les controllers/vues Public V2 ou equivalent hors namespace ;
2. conserver les anciens chemins publics quand ils sont deja bons pour le SEO ;
3. ajouter des redirections 301 seulement pour les URLs qui changent vraiment ;
4. retirer le noindex des pages publiques finales ;
5. mettre a jour sitemap et robots ;
6. verifier Search Console apres deploiement.

Checks immediats apres bascule :

- home en 200 ;
- categories en 200 ;
- plusieurs fiches produits en 200 ;
- devis GET en 200 ;
- devis POST valide ;
- contact en 200 ;
- aucun noindex sur les routes publiques finales ;
- pas de canonical pointant vers `/public-v2/*`.

## Phase 4 - Surveillance

Sur les premiers jours :

- surveiller logs 404/500 ;
- verifier les devis recus ;
- controler l'indexation Search Console ;
- verifier les pages produit les plus importantes ;
- comparer les anciens chemins et les nouveaux chemins ;
- garder un oeil sur performance mobile.

## Retour Arriere

Si la bascule echoue :

- remettre les routes publiques sur la v1 ;
- remettre Public V2 sous `/public-v2/*` noindex ;
- conserver les corrections non destructives ;
- corriger puis relancer la checklist avant nouvelle bascule.
