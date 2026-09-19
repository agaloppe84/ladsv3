# Pages juridiques du site classique

## Intégration réalisée

- `/mentions-legales` et `/politique-de-confidentialite` utilisent le layout et le footer classiques.
- Le formulaire de devis classique renvoie vers la politique et explique la base précontractuelle du traitement.
- Aucun changement dans les fichiers V2, le mailer, la base de données ou les traitements de conservation.
- Les documents Word ont servi de références ; leurs consignes internes ne sont pas publiées.

## Informations restant à finaliser avant publication

L'intégration est prête à être examinée localement. Elle ne constitue pas une certification de conformité. Les rubriques suivantes restent incomplètes :

1. **Médiateur** : obtenir le nom, l'adresse et le site du médiateur auquel la société a effectivement adhéré, puis ajouter cette rubrique aux mentions légales. La rubrique Réclamations ne remplace pas la médiation. Aucun médiateur n'a été inventé.
2. **Hébergeur** : les pages reprennent la plateforme et les coordonnées publiques Heroku/Salesforce. Les conditions additionnelles Heroku désignent Heroku, Inc., société du Delaware, pour les transactions par carte ; cela ne prouve pas à lui seul l'identité de l'entité hébergeuse applicable au compte. Au besoin, demander cette identification au support Heroku. Ne pas substituer automatiquement Salesforce France ou Salesforce, Inc.
3. **Conservation** : la politique fixe une règle de 12 mois, mais aucun nettoyage automatique n'existe. Mettre en œuvre la procédure ci-dessous avant de présenter cette règle comme appliquée.
4. **Services techniques** : préciser les durées des journaux et sauvegardes, les régions/pays de traitement et les garanties des transferts après vérification du compte et des contrats. Ces informations ne peuvent pas être déduites du dépôt Git. La rubrique Localisation reste générale dans l'attente de ces éléments.
5. **Cookies** : vérifier dans un navigateur neuf les sessions et les chargements de Google Maps, Dickson Designer, Cloudinary et JSPM. Relever noms, fournisseurs, finalités et durées des traceurs. Si des traceurs non exemptés sont constatés, prévoir leur blocage avant consentement dans une intervention distincte. La page d'information ne vaut pas recueil du consentement.
6. **Date** : remplacer la date de version de la politique lors de sa finalisation si nécessaire.

## Procédure recommandée pour les demandes sans suite

La société n'utilise ces données que pour répondre aux demandes. Il n'est donc pas nécessaire de conserver un historique anonymisé pour des statistiques. La suppression est plus simple, sous réserve des dossiers clients, obligations de preuve et litiges.

1. Désigner la personne chargée de vérifier les dossiers et les messageries.
2. Relever le dernier échange réel dans le dossier ou les e-mails. `updated_at` n'est pas une preuve de dernier contact ; le champ `processed` n'indique pas qu'une demande a ou non abouti à un contrat.
3. Programmer le retrait des demandes sans suite à l'expiration des 12 mois. Pour les questions générales, partir de leur clôture. Une revue régulière aide à préparer les échéances mais ne doit pas allonger silencieusement le délai annoncé.
4. Vérifier les éventuelles obligations de conservation avant de supprimer. Conserver séparément et avec accès restreint les seules pièces nécessaires au dossier client ou à un litige.
5. Supprimer la demande dans l'administration classique, qui dispose déjà de cette action. Attention : les deux versions utilisent la même table `quotes`, sans champ d'origine ; cette suppression est visible depuis les deux administrations.
6. Supprimer aussi les copies devenues inutiles dans les boîtes d'envoi et de réception, les transferts, exports et corbeilles. Le mailer actuel transmet l'ensemble du devis à deux adresses internes, sans envoyer d'accusé de réception au visiteur ; les destinataires n'ont pas été modifiés.
7. Définir la rotation des sauvegardes et les précautions après restauration pour ne pas réintroduire durablement des demandes supprimées. Vérifier séparément les journaux techniques.
8. Garder une trace minimale des opérations (date, nombre de dossiers, responsable), sans recopier les données supprimées.

Aucune suppression n'a été exécutée. Toute automatisation future nécessite un cadrage de la date de référence et des exceptions ; ne pas lancer une purge globale fondée uniquement sur `created_at` ou `updated_at`.

## Recette locale

- Ouvrir les deux URLs directement et depuis le footer, sur ordinateur et mobile.
- Vérifier les titres, le retour à l'accueil, les liens e-mail/téléphone, le sommaire et la navigation clavier.
- Vérifier le lien et le texte sous le formulaire de devis sans envoyer de demande réelle.
- Vérifier que le footer V2 ne contient pas les nouveaux liens et que ses directives `noindex` sont conservées.
- Le lancement du serveur, la vérification visuelle et le push restent à la main de l'utilisateur.

## Sources officielles consultées

- CNIL, conservation : https://www.cnil.fr/fr/passer-laction/les-durees-de-conservation-des-donnees
- Heroku, conditions additionnelles : https://www.heroku.com/policy/additional-terms/
- Heroku, coordonnées : https://www.heroku.com/contact/
- Ministère de l'Économie, médiation : https://www.economie.gouv.fr/dgccrf/les-fiches-pratiques/la-mediation-de-la-consommation-ce-que-vous-devez-savoir

Ces notes sont internes et ne sont pas rendues par les pages publiques.
