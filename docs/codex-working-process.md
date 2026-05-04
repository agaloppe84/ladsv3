# Codex Working Process

Derniere mise a jour : 2026-05-04

Ce document sert de contexte de travail pour les sessions Codex sur ce repo. Il decrit la maniere de collaborer, les contraintes a respecter et les reflexes a garder avant de modifier l'Admin V2.

## Contexte General

Projet : Rails 7 existant pour un site de store.

Sprint courant : Admin V2 experimental, front/design system/dark mode.

Objectif principal : construire une zone Admin V2 isolee, moderne et fluide, sans casser l'admin classique ni le site public.

Documents a lire au debut d'un nouveau chat Codex :

1. `docs/admin-v2-design-system.md`
2. `docs/codex-working-process.md`

## Langue Et Style

- Repondre en francais.
- Etre direct, concret et pragmatique.
- Faire des audits avant les changements importants.
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
- lancement de serveur si l'utilisateur dit qu'il teste lui-meme ;
- ajout de tests Rails dans ce sprint, sauf demande explicite ;
- refonte des modeles ;
- refonte de l'admin classique ;
- modification du site public sans validation explicite.

Ne jamais lancer :

- `rails db:migrate` ;
- `rails db:reset` ;
- `bundle install` ;
- `npm install`, `yarn install`, `pnpm install`, `bun install` ;
- commandes destructives type `rm`, `git reset --hard`, `git checkout --` sans demande explicite.

## Avant De Toucher Au Code

Toujours commencer par comprendre l'existant.

Checks utiles :

- `git status --short`
- routes concernees ;
- controllers existants ;
- modeles et schema ;
- vues admin classique ;
- vues Admin V2 ;
- composants ViewComponent existants ;
- Stimulus controllers existants ;
- patterns similaires deja implementes.

Pour les demandes ambigues :

- faire un audit ;
- proposer une approche ;
- attendre le "go" si l'utilisateur a demande explicitement un audit ou une proposition.

Si l'utilisateur dit "go", implementer jusqu'au bout dans le meme tour quand c'est raisonnable.

## Gestion Du Worktree

Le worktree peut contenir des changements utilisateur.

Regles :

- ne jamais revert un changement non fait par Codex ;
- si des fichiers touches par l'utilisateur sont lies a la tache, les lire et s'adapter ;
- si les changements sont sans rapport, les ignorer ;
- ne pas faire de commit sans demande ;
- ne pas faire de branche sans demande.

## Admin V2 : Regles D'Isolation

Toujours privilegier des nouveaux fichiers dans :

- `app/controllers/admin_v2`
- `app/views/admin_v2`
- `app/components/admin_v2`
- `app/javascript/admin_v2/controllers`
- `app/assets/stylesheets/admin_v2.css`

Ne pas modifier l'admin classique pour faire marcher l'Admin V2.

Ne pas reutiliser directement les vues de l'admin classique.

Le backend existant peut etre appele, mais les flows UI V2 doivent rester autonomes.

## Process Pour Ajouter Un Modele Admin V2

Audit avant implementation :

1. Identifier le modele reel.
2. Lire le schema.
3. Lire les associations.
4. Lire l'admin classique.
5. Lire les vues publiques si le modele est public.
6. Identifier si le modele est simple ou complexe.
7. Verifier les risques DB, permissions, N+1 et UX.

Decision UX :

- modele simple : index + new/show drawer + autosave dans drawer ;
- modele complexe : workspace central dedie, drawer de contexte ;
- pas de delete par defaut ;
- pas de migration par defaut ;
- create simple termine dans le drawer, sauf Product qui ouvre ensuite l'atelier edit.

Implementation typique :

1. routes Admin V2 ;
2. item sidebar ;
3. controller principal ;
4. controller scoped si autosave ;
5. controllers de panels si besoin ;
6. composants resource `IndexComponent`, `RowComponent`, badges ;
7. vues `index`, `_index_frame`, `_results_frame` ;
8. vues `new`, `show`, `_drawer_frame`, `_drawer_summary` ;
9. panels drawer ;
10. checks routes/syntaxe/rendu.

## Patterns Hotwire A Respecter

Frames standards :

- `admin_v2_main`
- `admin_v2_drawer`
- `admin_v2_*_results`

Recherche live :

- GET ;
- `live-search` ;
- target frame dedie ;
- remplacer uniquement le results frame ;
- eviter les loaders qui bougent la largeur du header.

Autosave :

- `autosave-field` au blur pour text inputs ;
- `toggle-association` au clic/change pour radio/checkbox ;
- `inline-form` pour pending state ;
- `action-state` dans le header du panel.

Create simple :

- formulaire dans drawer ;
- succes : replace index/main, replace drawer show, replace nav, append live feed ;
- erreur : re-render `new` dans drawer avec status 422.

## Devise Et Turbo

Le formulaire de login Devise doit garder une navigation HTML complete.

Regle actuelle :

- `app/views/devise/sessions/new.html.erb` utilise `data-turbo="false"` sur le form.

Pourquoi :

- si Devise submit en `TURBO_STREAM`, la redirection vers `/admin-v2` peut rendre les streams Admin V2 dans la page sign_in ;
- apres login, on veut `Devise::SessionsController#create as HTML`, puis `GET /admin-v2 as HTML`.

Ne pas retirer cette contrainte sans verifier le login.

## DB Et Donnees

Par defaut :

- ne pas migrer ;
- ne pas reset ;
- ne pas seed ;
- ne pas creer de donnees ;
- ne pas persister de logs de session ;
- ne pas ajouter de table d'audit dans ce sprint.

Pour les logs Admin V2 :

- session-only ;
- pas de modele `ActivityLog` ;
- pas d'Action Cable obligatoire ;
- pas de donnees sensibles dans le feed.

## Tests Et Verification

Dans ce sprint, ne pas ajouter de tests Rails sans demande.

Checks non destructifs utiles :

- `ruby -c` sur les controllers/components Ruby ajoutes ;
- `bin/rails routes -g ...` ou `bin/rails routes -c ...` ;
- `git diff --check` ;
- rendu via `bin/rails runner` avec stub quand possible ;
- lecture des logs fournis par l'utilisateur.

Si la DB locale est inaccessible depuis le sandbox, ne pas forcer. Utiliser des stubs de rendu quand c'est suffisant.

Ne pas lancer de serveur si l'utilisateur a dit qu'il le fera lui-meme.

## Documentation

Ces docs font partie du systeme.

Mettre a jour `docs/admin-v2-design-system.md` quand :

- un modele Admin V2 est ajoute ;
- un composant reusable est cree ;
- un pattern UX/Hotwire change ;
- la palette, la typo ou le layout evolue.

Mettre a jour `docs/codex-working-process.md` quand :

- une nouvelle contrainte de collaboration est decidee ;
- une commande devient interdite ou autorisee ;
- une nouvelle regle de verification apparait ;
- un incident important revele un piege a documenter.

## Prompt Court Pour Nouveau Chat

Au debut d'un nouveau chat, l'utilisateur peut dire :

```text
Tu interviens sur ce repo Rails. Lis d'abord docs/admin-v2-design-system.md et docs/codex-working-process.md. Respecte les contraintes : Admin V2 isole, audit avant changement important, pas de DB/migration/dependance/test/serveur/commit sans demande. Continue le design system Graphite Store Console.
```

## Definition Of Done

Pour une implementation Admin V2, le travail est termine quand :

- le scope est isole dans Admin V2 ;
- les patterns existants sont respectes ;
- les fichiers modifies sont limites au besoin ;
- les routes sont verifiees ;
- la syntaxe Ruby est OK ;
- `git diff --check` est OK ;
- les docs sont mises a jour si un pattern important a change ;
- la reponse finale liste clairement ce qui a ete fait et ce qui n'a pas ete lance.
