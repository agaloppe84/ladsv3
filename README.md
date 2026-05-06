# Les Artisans du Store - LADSv3

Application Rails du site **Les Artisans du Store**.

Le projet couvre le site public, la gestion admin, la refonte Admin V2 et le chantier Public V2. Il sert a presenter les familles de produits, les fiches techniques, les produits de destockage, les evenements et les demandes de devis.

## Stack

- Ruby `3.2.2`
- Rails `7.0`
- PostgreSQL
- Hotwire : Turbo + Stimulus
- Importmap
- Tailwind CSS via `tailwindcss-rails`
- ViewComponent
- Devise
- Active Storage avec Cloudinary
- Simple Form

## Zones Applicatives

Le repo contient plusieurs surfaces qui doivent rester separees :

- **Site public classique** : routes racine, `/categories`, `/produits/:slug`, `/devis`, `/contact`, `/destock`.
- **Admin classique** : namespace `/admin`.
- **Admin V2** : namespace `/admin-v2`, interface de gestion plus moderne.
- **Public V2** : namespace `/public-v2`, refonte graphique publique isolee.

Routes Public V2 utiles :

- `/public-v2/home`
- `/public-v2/categories`
- `/public-v2/produits/:slug`
- `/public-v2/devis`
- `/public-v2/contact`
- `/public-v2/design-system`

## Architecture

Structure principale :

- `app/controllers` : controllers publics classiques, admin, admin-v2 et public-v2.
- `app/views` : vues Rails par namespace.
- `app/components` : ViewComponents, dont les composants modulaires Admin V2 et Public V2.
- `app/assets/stylesheets` : CSS dedies, notamment `admin_v2.css` et `public_v2.css`.
- `app/javascript` : entrees JS et controllers Stimulus.
- `app/presenters` : preparation des donnees d'affichage, surtout Public V2.
- `app/services` : logique applicative transverse.
- `docs` : documents de process et design system.

Principes importants :

- ne pas casser le site public classique en travaillant sur Public V2 ;
- ne pas casser Admin V2 en travaillant sur Public V2 ;
- garder les CSS namespaces et scopes ;
- eviter les requetes metier dans les vues ;
- preparer les donnees dans les controllers/presenters ;
- utiliser les composants stabilises pour les sections et primitives UI.

## Installation Locale

Prerequis :

- Ruby `3.2.2`
- PostgreSQL
- Bundler
- credentials Rails disponibles pour les services externes si necessaire

Installation :

```bash
bin/setup
```

Cette commande installe les gems, prepare la base et nettoie les fichiers temporaires.

Si besoin, les etapes peuvent etre lancees manuellement :

```bash
bundle install
bin/rails db:prepare
```

Attention : `bin/rails db:seed` contient des suppressions de donnees de demonstration. Ne l'utiliser que sur une base locale que vous pouvez reinitialiser.

## Lancer Le Projet

Serveur Rails seul :

```bash
bin/rails server
```

Mode developpement avec Rails + Tailwind watch :

```bash
bin/dev
```

Build CSS ponctuel :

```bash
bin/rails tailwindcss:build
```

## Tests Et Checks Utiles

Tests Rails :

```bash
bin/rails test
```

Routes Public V2 :

```bash
bin/rails routes -g public-v2
```

Checks rapides avant commit :

```bash
git status --short
git diff --check
bin/rails tailwindcss:build
```

Pour les changements UI importants, verifier le rendu desktop et mobile. Pour les micro-ajustements CSS, un check statique peut suffire si le rendu est verifie manuellement.

## Configuration

La production utilise PostgreSQL via `DATABASE_URL`.

Variables et secrets importants :

- `DATABASE_URL` pour PostgreSQL en production ;
- `RAILS_MASTER_KEY` ou `config/master.key` pour les credentials Rails ;
- credentials Cloudinary pour Active Storage ;
- credentials SMTP si l'envoi d'emails est actif ;
- `REDIS_URL` si Action Cable/Redis est utilise en production.

Ne jamais committer de secrets, `.env` personnel, cle master ou credentials non chiffres.

## Documentation Projet

Documents de reference :

- `docs/codex-working-process.md` : process general Codex.
- `docs/admin-v2-design-system.md` : references Admin V2.
- `docs/codex-working-process-public-v2.md` : process Public V2.
- `docs/public-v2-design-system.md` : design system Public V2.

Pour travailler sur Public V2, lire en priorite :

1. `docs/codex-working-process-public-v2.md`
2. `docs/public-v2-design-system.md`

## Public V2

Public V2 est une refonte graphique isolee du site public.

Objectifs :

- proposer une experience publique plus moderne, premium et responsive ;
- conserver le site public classique intact pendant le chantier ;
- utiliser un layout Rails dedie ;
- garder un CSS dedie scope sous `.public-v2` ;
- utiliser ViewComponent pour les sections et primitives stabilisees ;
- garder le theme clair/sombre, les accents et la typo pilotables depuis la navbar.

Le laboratoire `/public-v2/design-system` sert a documenter et tester les composants actifs.

## Contribution

Avant d'ouvrir une PR ou de pousser un changement important :

- verifier le scope du diff ;
- garder les changements namespaces quand ils concernent Public V2 ou Admin V2 ;
- eviter les refactors non lies au ticket ;
- documenter les decisions de process ou design system quand elles changent ;
- ne pas lancer de migration ou action destructive sans validation explicite.

Pour un gros changement front :

- valider desktop et mobile ;
- verifier que les composants restent reutilisables ;
- regarder si une factorisation est pertinente ;
- nettoyer les reliquats CSS/vues/routes quand une exploration devient obsolete.

## Deploiement

Le repo contient un `Procfile` :

```Procfile
release: bundle exec rails db:migrate
web: bundle exec rails server -p $PORT
```

Avant de deployer :

- verifier les variables d'environnement ;
- verifier les credentials Rails ;
- verifier les migrations ;
- verifier les services externes : PostgreSQL, Cloudinary, SMTP, Redis si utilise.
