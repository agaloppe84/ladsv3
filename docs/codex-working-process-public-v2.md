# Codex Working Process Public V2

Derniere mise a jour : 2026-06-08

Ce document cadre les sessions Codex sur Public V2. Le chantier reste isole du public classique, de l'admin v1 et de l'admin v2.

## Contexte

Projet : Rails 7 pour Les Artisans du Store.

Sprint courant : preparation de la Public V2 Apple-like, testable en production sous namespace noindex avant bascule du site public.

Documents a lire au debut d'une intervention Public V2 :

1. `docs/codex-working-process-public-v2.md`
2. `docs/public-v2-design-system.md`
3. `docs/public-v2-production-migration-plan.md`
4. `docs/public-v2-interactive-blueprints.md`
5. `docs/codex-working-process.md`

## Decisions Actees

- Public V2 reste sous `/public-v2/*` tant que la bascule publique n'est pas validee.
- Ne pas toucher au site public classique, a l'admin v1 ou a l'admin v2 pendant les travaux Public V2.
- La page publique `/public-v2/design-system` est supprimee.
- La documentation design system repart sur la direction Apple-like.
- Tout Public V2 est en `noindex, nofollow, noarchive` pendant la phase de test.
- Le mode clair/sombre est conserve.
- Les composants, presenters, vues, assets et JS restent namespaces Public V2.
- Pas de modification DB pour ce chantier sauf demande explicite.
- Ne pas lancer de serveur Rails quand l'utilisateur indique qu'il verifie localement.

## Routes Public V2

Routes actives :

- `GET /public-v2/home`
- `GET /public-v2/categories`
- `GET /public-v2/produits/:slug`
- `GET /public-v2/produits/:slug/selecteur-toile`
- `GET /public-v2/devis`
- `POST /public-v2/devis`
- `GET /public-v2/contact`

Il ne doit plus y avoir de route `/public-v2/design-system`.

## Architecture

Structure attendue :

- controllers sous `app/controllers/public_v2` ;
- vues sous `app/views/public_v2` ;
- composants sous `app/components/public_v2` ;
- presenters sous `app/presenters/public_v2` ;
- CSS dedie `app/assets/stylesheets/public_v2.css` ;
- entree JS dediee `app/javascript/public_v2/application.js`.

Regles Rails :

- les controllers chargent records, scopes, includes et limits ;
- les presenters preparent les donnees d'affichage ;
- les vues assemblent des composants ;
- les ViewComponents ne font pas de requetes metier ;
- les helpers et chemins Public V2 restent explicites ;
- le CSS reste scope sous `.public-v2`.

## Design

Direction : Apple-like.

Principes :

- interface calme, premium, lisible ;
- medias utiles et visibles ;
- composants sobres, peu de decoration gratuite ;
- textes courts, metier, orientes devis ;
- cartes et controls stables sur mobile ;
- dark mode coherent avec le light mode ;
- pas de retour des anciens blocs Warm System ou labs.

## SEO

Pendant le test de production :

- meta `robots` en noindex ;
- meta `googlebot` en noindex ;
- header `X-Robots-Tag` en noindex.

Chaque vue Public V2 doit garder :

- `title` ;
- `description` ;
- `keywords` quand utile.

Le retrait du noindex se fait uniquement lors de la bascule publique, avec le plan `docs/public-v2-production-migration-plan.md`.

## Validation

Regles :

- ne pas lancer de serveur Rails si l'utilisateur teste lui-meme ;
- utiliser `bin/rails routes -g public-v2` pour verifier les routes ;
- utiliser `ruby -c` pour les fichiers Ruby touches ;
- utiliser `git diff --check` avant de cloturer ;
- ne pas POSTer `/public-v2/devis` en validation automatique sans demande.

Checklist de fin d'etape :

- routes Public V2 coherentes ;
- aucun retour de `/public-v2/design-system` ;
- vieux blocs demandes supprimes du rendu et des reliquats principaux ;
- CSS legacy cible nettoye ;
- docs alignees avec le code.

## Securite Projet

Par defaut, ne pas faire :

- migration ;
- reset DB ;
- installation de gem/package ;
- commit ;
- push ;
- serveur Rails laisse actif ;
- modification du public classique ;
- modification de l'admin v1 ;
- modification de l'admin v2.
