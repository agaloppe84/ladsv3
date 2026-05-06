# frozen_string_literal: true

class PublicV2::LayoutsTestPage
  Section = Struct.new(:number, :title, :description, :layouts, keyword_init: true)
  Layout = Struct.new(:code, :name, :purpose, :pattern, :density, :role, :mood, :weight, keyword_init: true)
  VariantAxis = Struct.new(:key, :name, :description, :values, keyword_init: true)
  ComposerStep = Struct.new(:number, :title, :description, keyword_init: true)
  ComposerPreset = Struct.new(:code, :name, :intent, :brief, :global_code, :section_codes, :micro_codes, :variants, :avoid, keyword_init: true)
  ComponentBrick = Struct.new(:code, :name, :component, :role, :best_for, :avoid, keyword_init: true)
  GenerationRecipe = Struct.new(:code, :name, :intent, :prompt, :global_codes, :section_codes, :micro_codes, :component_codes, :variants, :weights, :reject, keyword_init: true)
  PromptFacet = Struct.new(:key, :name, :examples, keyword_init: true)

  SECTIONS = [
    Section.new(
      number: "01",
      title: "Global layouts",
      description: "Structures de pages completes : navigation, hero, contenu principal, preuves, catalogue et conversion.",
      layouts: [
        Layout.new(code: "G01", name: "Marketing spine", purpose: "Home claire avec progression verticale.", pattern: :marketing_spine),
        Layout.new(code: "G02", name: "Split page", purpose: "Promesse forte et media de meme poids.", pattern: :split_page),
        Layout.new(code: "G03", name: "Editorial grid", purpose: "Lecture magazine avec asymetrie controlee.", pattern: :editorial_grid),
        Layout.new(code: "G04", name: "Catalogue grid", purpose: "Scan produit, filtres, tri et pagination.", pattern: :catalogue_grid),
        Layout.new(code: "G05", name: "List detail", purpose: "Explorer une liste et voir le detail adjacent.", pattern: :list_detail),
        Layout.new(code: "G06", name: "Supporting pane", purpose: "Contenu principal avec panneau contextuel.", pattern: :supporting_pane),
        Layout.new(code: "G07", name: "Feed layout", purpose: "Parcourir des contenus repetables et visuels.", pattern: :feed_layout),
        Layout.new(code: "G08", name: "Longform story", purpose: "Raconter une progression verticale dense.", pattern: :longform_story),
        Layout.new(code: "G09", name: "Bento overview", purpose: "Resume riche avec priorites visibles.", pattern: :bento_overview),
        Layout.new(code: "G10", name: "Commerce landing", purpose: "Promesse, categories, preuves et devis.", pattern: :commerce_landing),
        Layout.new(code: "G11", name: "Guided choice homepage", purpose: "Orienter vite vers le bon besoin.", pattern: :guided_choice_homepage),
        Layout.new(code: "G12", name: "Showroom first", purpose: "Faire du lieu la preuve principale.", pattern: :showroom_first),
        Layout.new(code: "G13", name: "Local trust page", purpose: "Mettre la zone locale et les preuves en avant.", pattern: :local_trust_page),
        Layout.new(code: "G14", name: "Product finder", purpose: "Choix progressif avant catalogue.", pattern: :product_finder),
        Layout.new(code: "G15", name: "Service hub", purpose: "Organiser conseil, pose et SAV.", pattern: :service_hub),
        Layout.new(code: "G16", name: "Comparison hub", purpose: "Comparer familles, usages et niveaux.", pattern: :comparison_hub),
        Layout.new(code: "G17", name: "Quote funnel page", purpose: "Transformer la page en parcours devis.", pattern: :quote_funnel_page),
        Layout.new(code: "G18", name: "Editorial commerce", purpose: "Mixer conseil, narration et produits.", pattern: :editorial_commerce),
        Layout.new(code: "G19", name: "Proof led page", purpose: "Construire la page autour des preuves.", pattern: :proof_led_page),
        Layout.new(code: "G20", name: "Campaign landing", purpose: "Promesse courte, offre et action rapide.", pattern: :campaign_landing),
        Layout.new(code: "G21", name: "Local services homepage", purpose: "Page locale orientee services et action.", pattern: :local_services_homepage),
        Layout.new(code: "G22", name: "Product taxonomy hub", purpose: "Explorer les familles par niveaux.", pattern: :product_taxonomy_hub),
        Layout.new(code: "G23", name: "Quote guided journey", purpose: "Parcours devis guide en plusieurs blocs.", pattern: :quote_guided_journey),
        Layout.new(code: "G24", name: "Showroom commerce hybrid", purpose: "Mixer lieu physique et catalogue.", pattern: :showroom_commerce_hybrid),
        Layout.new(code: "G25", name: "Trust first homepage", purpose: "Commencer par rassurer avant de vendre.", pattern: :trust_first_homepage),
        Layout.new(code: "G26", name: "Problem solution page", purpose: "Partir des problemes puis presenter les solutions.", pattern: :problem_solution_page),
        Layout.new(code: "G27", name: "Advisory landing", purpose: "Faire du conseil le fil conducteur.", pattern: :advisory_landing),
        Layout.new(code: "G28", name: "Comparison marketplace", purpose: "Comparer plusieurs offres ou familles.", pattern: :comparison_marketplace),
        Layout.new(code: "G29", name: "Installation services page", purpose: "Expliquer pose, suivi et SAV.", pattern: :installation_services_page),
        Layout.new(code: "G30", name: "Category education hub", purpose: "Eduquer avant de pousser au choix.", pattern: :category_education_hub),
        Layout.new(code: "G31", name: "Seasonal campaign hub", purpose: "Organiser une campagne saisonniere.", pattern: :seasonal_campaign_hub),
        Layout.new(code: "G32", name: "Regional landing page", purpose: "Ancrer le discours dans une zone.", pattern: :regional_landing_page),
        Layout.new(code: "G33", name: "Maintenance SAV hub", purpose: "Centraliser maintenance et depannage.", pattern: :maintenance_sav_hub),
        Layout.new(code: "G34", name: "Financing offer page", purpose: "Presenter offre, budget et reassurance.", pattern: :financing_offer_page),
        Layout.new(code: "G35", name: "Inspiration gallery page", purpose: "Faire choisir par inspiration visuelle.", pattern: :inspiration_gallery_page),
        Layout.new(code: "G36", name: "Search first catalogue", purpose: "Commencer par la recherche et filtrer vite.", pattern: :search_first_catalogue),
        Layout.new(code: "G37", name: "Progressive disclosure page", purpose: "Reveler les infos par paliers.", pattern: :progressive_disclosure_page),
        Layout.new(code: "G38", name: "Multi entry homepage", purpose: "Proposer plusieurs entrees equivalentes.", pattern: :multi_entry_homepage),
        Layout.new(code: "G39", name: "Proof archive page", purpose: "Indexer avis, projets et garanties.", pattern: :proof_archive_page),
        Layout.new(code: "G40", name: "Minimal conversion page", purpose: "Reduire la page a la conversion utile.", pattern: :minimal_conversion_page),
        Layout.new(code: "G41", name: "Project planner homepage", purpose: "Structurer une page autour du projet.", pattern: :project_planner_homepage, role: :planner),
        Layout.new(code: "G42", name: "Need diagnosis page", purpose: "Faire partir l'utilisateur de son besoin.", pattern: :need_diagnosis_page, role: :diagnostic),
        Layout.new(code: "G43", name: "Advisor profile page", purpose: "Mettre l'expertise humaine au centre.", pattern: :advisor_profile_page, role: :trust),
        Layout.new(code: "G44", name: "Warranty assurance page", purpose: "Rassurer avec garanties et engagements.", pattern: :warranty_assurance_page, role: :trust),
        Layout.new(code: "G45", name: "Brand partner hub", purpose: "Organiser marques et partenaires.", pattern: :brand_partner_hub, role: :proof),
        Layout.new(code: "G46", name: "Appointment booking page", purpose: "Conduire vers une prise de rendez-vous.", pattern: :appointment_booking_page, role: :conversion),
        Layout.new(code: "G47", name: "Express quote landing", purpose: "Faire une demande rapide et directe.", pattern: :express_quote_landing, role: :conversion),
        Layout.new(code: "G48", name: "Deep catalogue story", purpose: "Raconter avant d'ouvrir le catalogue.", pattern: :deep_catalogue_story, role: :education),
        Layout.new(code: "G49", name: "Mixed media homepage", purpose: "Combiner photos, preuves et entrees.", pattern: :mixed_media_homepage, role: :inspiration),
        Layout.new(code: "G50", name: "Local proof map", purpose: "Ancrer la confiance par la carte.", pattern: :local_proof_map, role: :local),
        Layout.new(code: "G51", name: "Service comparison page", purpose: "Comparer les niveaux de service.", pattern: :service_comparison_page, role: :comparison),
        Layout.new(code: "G52", name: "Installation process hub", purpose: "Faire comprendre le deroule d'un projet.", pattern: :installation_process_hub, role: :process),
        Layout.new(code: "G53", name: "Product configurator page", purpose: "Construire un choix par options.", pattern: :product_configurator_page, role: :configurator),
        Layout.new(code: "G54", name: "Before after archive", purpose: "Classer des transformations visuelles.", pattern: :before_after_archive, role: :proof),
        Layout.new(code: "G55", name: "Offers index page", purpose: "Presenter offres et mises en avant.", pattern: :offers_index_page, role: :campaign),
        Layout.new(code: "G56", name: "Customer stories hub", purpose: "Rassembler retours et cas clients.", pattern: :customer_stories_hub, role: :proof),
        Layout.new(code: "G57", name: "Quick access homepage", purpose: "Donner des raccourcis tres visibles.", pattern: :quick_access_homepage, role: :navigation),
        Layout.new(code: "G58", name: "Expert content hub", purpose: "Classer guides, conseils et ressources.", pattern: :expert_content_hub, role: :education),
        Layout.new(code: "G59", name: "Maintenance request page", purpose: "Orienter vers maintenance et SAV.", pattern: :maintenance_request_page, role: :support),
        Layout.new(code: "G60", name: "Cross sell catalogue", purpose: "Relier familles et produits associes.", pattern: :cross_sell_catalogue, role: :commerce),
        Layout.new(code: "G61", name: "Long scroll landing", purpose: "Derouler une narration dense.", pattern: :long_scroll_landing, role: :story),
        Layout.new(code: "G62", name: "Compact local landing", purpose: "Page locale courte et efficace.", pattern: :compact_local_landing, role: :local),
        Layout.new(code: "G63", name: "Visual category portal", purpose: "Entrer par grandes zones visuelles.", pattern: :visual_category_portal, role: :navigation),
        Layout.new(code: "G64", name: "Appointment first homepage", purpose: "Mettre le rendez-vous en premier.", pattern: :appointment_first_homepage, role: :conversion),
        Layout.new(code: "G65", name: "Project cost guide", purpose: "Aider a comprendre les budgets.", pattern: :project_cost_guide, role: :pricing),
        Layout.new(code: "G66", name: "Urgent repair landing", purpose: "Traiter les demandes rapides ou urgentes.", pattern: :urgent_repair_landing, role: :support),
        Layout.new(code: "G67", name: "Decision tree page", purpose: "Guider par embranchements successifs.", pattern: :decision_tree_page, role: :diagnostic),
        Layout.new(code: "G68", name: "Proof and CTA page", purpose: "Alterner preuves et actions.", pattern: :proof_and_cta_page, role: :conversion),
        Layout.new(code: "G69", name: "Split catalogue story", purpose: "Catalogue a cote d'un recit conseil.", pattern: :split_catalogue_story, role: :commerce),
        Layout.new(code: "G70", name: "Planner dashboard page", purpose: "Vue projet dense avec modules.", pattern: :planner_dashboard_page, role: :planner),
        Layout.new(code: "G71", name: "Product education funnel", purpose: "Apprendre puis convertir.", pattern: :product_education_funnel, role: :education),
        Layout.new(code: "G72", name: "Contractor trust page", purpose: "Valoriser equipe, pose et suivi.", pattern: :contractor_trust_page, role: :trust),
        Layout.new(code: "G73", name: "Lead magnet landing", purpose: "Echanger ressource contre contact.", pattern: :lead_magnet_landing, role: :conversion),
        Layout.new(code: "G74", name: "Category comparison index", purpose: "Comparer categories avant navigation.", pattern: :category_comparison_index, role: :comparison),
        Layout.new(code: "G75", name: "Visual quote builder", purpose: "Composer une demande avec visuels.", pattern: :visual_quote_builder, role: :configurator),
        Layout.new(code: "G76", name: "Timeline homepage", purpose: "Montrer l'accompagnement dans le temps.", pattern: :timeline_homepage, role: :process),
        Layout.new(code: "G77", name: "Service area hub", purpose: "Structurer les zones desservies.", pattern: :service_area_hub, role: :local),
        Layout.new(code: "G78", name: "Premium offer page", purpose: "Presenter une offre haut de gamme.", pattern: :premium_offer_page, role: :campaign),
        Layout.new(code: "G79", name: "Minimal showroom page", purpose: "Page showroom courte et tres visuelle.", pattern: :minimal_showroom_page, role: :showroom),
        Layout.new(code: "G80", name: "Random starter homepage", purpose: "Base polyvalente pour generation aleatoire.", pattern: :random_starter_homepage, role: :random)
      ]
    ),
    Section.new(
      number: "02",
      title: "Section layouts",
      description: "Compositions de sections : hero, preuves, medias, categories, comparaison, process et CTA.",
      layouts: [
        Layout.new(code: "S01", name: "Hero split", purpose: "Texte et visuel en deux colonnes.", pattern: :hero_split),
        Layout.new(code: "S02", name: "Hero panel media", purpose: "Panel expressif et image alignee.", pattern: :hero_panel_media),
        Layout.new(code: "S03", name: "Feature grid", purpose: "Trois benefices courts et comparables.", pattern: :feature_grid),
        Layout.new(code: "S04", name: "Proof strip", purpose: "Preuves compactes sous une promesse.", pattern: :proof_strip),
        Layout.new(code: "S05", name: "Media text", purpose: "Image dominante avec explication calme.", pattern: :media_text),
        Layout.new(code: "S06", name: "Text media", purpose: "Argumentation avant preuve visuelle.", pattern: :text_media),
        Layout.new(code: "S07", name: "Comparison row", purpose: "Comparer options, categories ou usages.", pattern: :comparison_row),
        Layout.new(code: "S08", name: "Process steps", purpose: "Expliquer une sequence simple.", pattern: :process_steps),
        Layout.new(code: "S09", name: "Product band", purpose: "Mettre en avant familles ou produits.", pattern: :product_band),
        Layout.new(code: "S10", name: "Compact CTA", purpose: "Conversion courte en fin de section.", pattern: :compact_cta),
        Layout.new(code: "S11", name: "Diagnostic chooser", purpose: "Aider a choisir selon le contexte.", pattern: :diagnostic_chooser),
        Layout.new(code: "S12", name: "Split proof stack", purpose: "Message a gauche, preuves empilees a droite.", pattern: :split_proof_stack),
        Layout.new(code: "S13", name: "Category rail", purpose: "Navigation courte dans une section dense.", pattern: :category_rail),
        Layout.new(code: "S14", name: "Sticky compare", purpose: "Comparer avec un repere fixe.", pattern: :sticky_compare),
        Layout.new(code: "S15", name: "Gallery statement", purpose: "Galerie visuelle avec phrase forte.", pattern: :gallery_statement),
        Layout.new(code: "S16", name: "Trust cluster", purpose: "Regrouper labels, chiffres et preuves.", pattern: :trust_cluster),
        Layout.new(code: "S17", name: "FAQ preview", purpose: "Lever les objections en section compacte.", pattern: :faq_preview),
        Layout.new(code: "S18", name: "Quote mini funnel", purpose: "Mini parcours devis dans une section.", pattern: :quote_mini_funnel),
        Layout.new(code: "S19", name: "Before after band", purpose: "Montrer transformation ou choix avant/apres.", pattern: :before_after_band),
        Layout.new(code: "S20", name: "Local showroom strip", purpose: "Ancrer la page avec lieu, horaire et acces.", pattern: :local_showroom_strip),
        Layout.new(code: "S21", name: "Hero with decision cards", purpose: "Hero plus choix immediats.", pattern: :hero_decision_cards),
        Layout.new(code: "S22", name: "Hero local proof rail", purpose: "Hero avec preuves locales visibles.", pattern: :hero_local_proof_rail),
        Layout.new(code: "S23", name: "Hero quote form", purpose: "Hero directement oriente demande.", pattern: :hero_quote_form),
        Layout.new(code: "S24", name: "Media grid intro", purpose: "Intro avec grille media plus texte.", pattern: :media_grid_intro),
        Layout.new(code: "S25", name: "Category decision matrix", purpose: "Aider a comparer les categories.", pattern: :category_decision_matrix),
        Layout.new(code: "S26", name: "Product family carousel", purpose: "Faire defiler les familles produit.", pattern: :product_family_carousel),
        Layout.new(code: "S27", name: "Service promise row", purpose: "Aligner promesses de service.", pattern: :service_promise_row),
        Layout.new(code: "S28", name: "Installation timeline", purpose: "Rendre la pose lisible par etapes.", pattern: :installation_timeline),
        Layout.new(code: "S29", name: "Credentials band", purpose: "Afficher certifications et preuves courtes.", pattern: :credentials_band),
        Layout.new(code: "S30", name: "Testimonial wall", purpose: "Grouper plusieurs retours clients.", pattern: :testimonial_wall),
        Layout.new(code: "S31", name: "Map and contact strip", purpose: "Lier zone, contact et acces.", pattern: :map_contact_strip),
        Layout.new(code: "S32", name: "Pricing offer teaser", purpose: "Introduire budget ou offre.", pattern: :pricing_offer_teaser),
        Layout.new(code: "S33", name: "Problem cards", purpose: "Lister des situations client.", pattern: :problem_cards),
        Layout.new(code: "S34", name: "Solution stack", purpose: "Empiler solutions et benefices.", pattern: :solution_stack),
        Layout.new(code: "S35", name: "Resource links strip", purpose: "Proposer guides, docs ou familles.", pattern: :resource_links_strip),
        Layout.new(code: "S36", name: "Gallery mosaic", purpose: "Donner une respiration visuelle dense.", pattern: :gallery_mosaic),
        Layout.new(code: "S37", name: "Before after compare", purpose: "Comparer deux etats cote a cote.", pattern: :before_after_compare),
        Layout.new(code: "S38", name: "FAQ accordion block", purpose: "Regrouper objections et reponses.", pattern: :faq_accordion_block),
        Layout.new(code: "S39", name: "Sticky CTA band", purpose: "Maintenir une action forte visible.", pattern: :sticky_cta_band),
        Layout.new(code: "S40", name: "Closing reassurance block", purpose: "Finir par reassurance et action.", pattern: :closing_reassurance_block),
        Layout.new(code: "S41", name: "Hero media stack", purpose: "Hero avec medias empiles.", pattern: :hero_media_stack, role: :hero),
        Layout.new(code: "S42", name: "Hero triple entry", purpose: "Trois entrees fortes dans le hero.", pattern: :hero_triple_entry, role: :hero),
        Layout.new(code: "S43", name: "Floating proof bar", purpose: "Preuves flottantes sous un message.", pattern: :floating_proof_bar, role: :proof),
        Layout.new(code: "S44", name: "Split checklist", purpose: "Argument et checklist cote a cote.", pattern: :split_checklist, role: :content),
        Layout.new(code: "S45", name: "Category stepper", purpose: "Naviguer par paliers de categorie.", pattern: :category_stepper, role: :navigation),
        Layout.new(code: "S46", name: "Product option matrix", purpose: "Comparer des options produit.", pattern: :product_option_matrix, role: :comparison),
        Layout.new(code: "S47", name: "Services cards rail", purpose: "Rail de services scannable.", pattern: :services_cards_rail, role: :services),
        Layout.new(code: "S48", name: "Trust metrics grid", purpose: "Chiffres et preuves en grille.", pattern: :trust_metrics_grid, role: :proof),
        Layout.new(code: "S49", name: "Quote form aside", purpose: "Formulaire a cote du contenu.", pattern: :quote_form_aside, role: :conversion),
        Layout.new(code: "S50", name: "Showroom visit band", purpose: "Inviter a visiter le showroom.", pattern: :showroom_visit_band, role: :showroom),
        Layout.new(code: "S51", name: "Expert note section", purpose: "Ajouter un conseil editorial.", pattern: :expert_note_section, role: :education),
        Layout.new(code: "S52", name: "Installation checklist", purpose: "Verifier les etapes de pose.", pattern: :installation_checklist, role: :process),
        Layout.new(code: "S53", name: "Comparison table compact", purpose: "Comparer en tableau court.", pattern: :comparison_table_compact, role: :comparison),
        Layout.new(code: "S54", name: "Project gallery rail", purpose: "Montrer plusieurs projets.", pattern: :project_gallery_rail, role: :gallery),
        Layout.new(code: "S55", name: "Local area map band", purpose: "Associer zone et preuves locales.", pattern: :local_area_map_band, role: :local),
        Layout.new(code: "S56", name: "Financing cards", purpose: "Presenter options de budget.", pattern: :financing_cards, role: :pricing),
        Layout.new(code: "S57", name: "Partner proof strip", purpose: "Afficher marques et labels.", pattern: :partner_proof_strip, role: :proof),
        Layout.new(code: "S58", name: "Maintenance alert band", purpose: "Mettre en avant SAV ou urgence.", pattern: :maintenance_alert_band, role: :support),
        Layout.new(code: "S59", name: "Sticky summary block", purpose: "Resume visible dans une section longue.", pattern: :sticky_summary_block, role: :navigation),
        Layout.new(code: "S60", name: "Conversion footer block", purpose: "Terminer une section par action.", pattern: :conversion_footer_block, role: :conversion),
        Layout.new(code: "S61", name: "Product finder section", purpose: "Mini recherche produit locale.", pattern: :product_finder_section, role: :finder),
        Layout.new(code: "S62", name: "Story proof split", purpose: "Recit et preuve en miroir.", pattern: :story_proof_split, role: :story),
        Layout.new(code: "S63", name: "Workshop note band", purpose: "Note atelier courte et credible.", pattern: :workshop_note_band, role: :trust),
        Layout.new(code: "S64", name: "Contact decision row", purpose: "Choisir le bon mode de contact.", pattern: :contact_decision_row, role: :conversion),
        Layout.new(code: "S65", name: "Vertical offer stack", purpose: "Empiler offres ou niveaux.", pattern: :vertical_offer_stack, role: :pricing),
        Layout.new(code: "S66", name: "Feature spotlight grid", purpose: "Spotlight plus features autour.", pattern: :feature_spotlight_grid, role: :content),
        Layout.new(code: "S67", name: "Safety reassurance band", purpose: "Rassurer sur qualite et garanties.", pattern: :safety_reassurance_band, role: :trust),
        Layout.new(code: "S68", name: "Category moodboard", purpose: "Inspirer par collage de categories.", pattern: :category_moodboard, role: :inspiration),
        Layout.new(code: "S69", name: "Quote progress strip", purpose: "Afficher progression d'une demande.", pattern: :quote_progress_strip, role: :process),
        Layout.new(code: "S70", name: "Service area cards", purpose: "Cartes de zones desservies.", pattern: :service_area_cards, role: :local),
        Layout.new(code: "S71", name: "Availability calendar strip", purpose: "Montrer disponibilites possibles.", pattern: :availability_calendar_strip, role: :booking),
        Layout.new(code: "S72", name: "Mini docs hub", purpose: "Regrouper documents utiles.", pattern: :mini_docs_hub, role: :resources),
        Layout.new(code: "S73", name: "Material sample grid", purpose: "Afficher finitions ou echantillons.", pattern: :material_sample_grid, role: :options),
        Layout.new(code: "S74", name: "Review carousel", purpose: "Faire defiler des avis.", pattern: :review_carousel, role: :proof),
        Layout.new(code: "S75", name: "Installation before proof", purpose: "Associer avant/apres et pose.", pattern: :installation_before_proof, role: :proof),
        Layout.new(code: "S76", name: "Store locator compact", purpose: "Localiser showroom et contact.", pattern: :store_locator_compact, role: :local),
        Layout.new(code: "S77", name: "Product specs spotlight", purpose: "Mettre specs et visuel en avant.", pattern: :product_specs_spotlight, role: :specs),
        Layout.new(code: "S78", name: "Offer comparison cards", purpose: "Comparer des offres par cartes.", pattern: :offer_comparison_cards, role: :comparison),
        Layout.new(code: "S79", name: "Advisor CTA panel", purpose: "Action centree sur le conseil.", pattern: :advisor_cta_panel, role: :conversion),
        Layout.new(code: "S80", name: "Random section stack", purpose: "Bloc polyvalent pour generation.", pattern: :random_section_stack, role: :random)
      ]
    ),
    Section.new(
      number: "03",
      title: "Micro layouts",
      description: "Organisation interne des petites surfaces : cards, stats, lignes meta, listes, formulaires et actions.",
      layouts: [
        Layout.new(code: "M01", name: "Media top card", purpose: "Card produit ou categorie classique.", pattern: :media_top_card),
        Layout.new(code: "M02", name: "Media side card", purpose: "Comparer vite image et texte.", pattern: :media_side_card),
        Layout.new(code: "M03", name: "Stat cell", purpose: "Chiffre, label et explication courte.", pattern: :stat_cell),
        Layout.new(code: "M04", name: "Icon list item", purpose: "Liste lisible avec repere visuel.", pattern: :icon_list_item),
        Layout.new(code: "M05", name: "Badge row", purpose: "Tags, filtres ou attributs rapides.", pattern: :badge_row),
        Layout.new(code: "M06", name: "Button row", purpose: "Action principale et secondaire.", pattern: :button_row),
        Layout.new(code: "M07", name: "Meta row", purpose: "Infos techniques sur une ligne.", pattern: :meta_row),
        Layout.new(code: "M08", name: "Label value", purpose: "Donnee structuree et scannable.", pattern: :label_value),
        Layout.new(code: "M09", name: "Mini timeline", purpose: "Etapes compactes dans un petit bloc.", pattern: :mini_timeline),
        Layout.new(code: "M10", name: "Form row", purpose: "Label, champ, aide et action.", pattern: :form_row),
        Layout.new(code: "M11", name: "Compact product tile", purpose: "Produit lisible dans une petite surface.", pattern: :compact_product_tile),
        Layout.new(code: "M12", name: "Option selector row", purpose: "Choisir une option sans quitter le flux.", pattern: :option_selector_row),
        Layout.new(code: "M13", name: "Trust badge cell", purpose: "Preuve ou certification tres compacte.", pattern: :trust_badge_cell),
        Layout.new(code: "M14", name: "Inline quote action", purpose: "Action devis integree au contenu.", pattern: :inline_quote_action),
        Layout.new(code: "M15", name: "Mini comparison cell", purpose: "Comparer deux choix dans une card.", pattern: :mini_comparison_cell),
        Layout.new(code: "M16", name: "Availability chip group", purpose: "Disponibilite, delai ou zone en chips.", pattern: :availability_chip_group),
        Layout.new(code: "M17", name: "Spec highlight row", purpose: "Donnee technique mise en evidence.", pattern: :spec_highlight_row),
        Layout.new(code: "M18", name: "Step compact card", purpose: "Une etape claire dans un parcours.", pattern: :step_compact_card),
        Layout.new(code: "M19", name: "Contact method row", purpose: "Comparer appel, showroom et formulaire.", pattern: :contact_method_row),
        Layout.new(code: "M20", name: "Proof quote card", purpose: "Citation ou preuve courte et scannable.", pattern: :proof_quote_card),
        Layout.new(code: "M21", name: "Product mini card", purpose: "Mini carte produit reutilisable.", pattern: :product_mini_card),
        Layout.new(code: "M22", name: "Category mini tile", purpose: "Tuile courte pour entree categorie.", pattern: :category_mini_tile),
        Layout.new(code: "M23", name: "Service chip", purpose: "Service affiche comme choix rapide.", pattern: :service_chip),
        Layout.new(code: "M24", name: "Proof badge row", purpose: "Ligne compacte de preuves.", pattern: :proof_badge_row),
        Layout.new(code: "M25", name: "Rating snippet", purpose: "Avis ou note en surface courte.", pattern: :rating_snippet),
        Layout.new(code: "M26", name: "Quote input group", purpose: "Mini formulaire de demande.", pattern: :quote_input_group),
        Layout.new(code: "M27", name: "Contact CTA chip", purpose: "Action contact tres compacte.", pattern: :contact_cta_chip),
        Layout.new(code: "M28", name: "Opening hours cell", purpose: "Horaires lisibles dans une card.", pattern: :opening_hours_cell),
        Layout.new(code: "M29", name: "Location mini card", purpose: "Adresse ou zone en bloc court.", pattern: :location_mini_card),
        Layout.new(code: "M30", name: "Installation step item", purpose: "Une etape de pose en ligne.", pattern: :installation_step_item),
        Layout.new(code: "M31", name: "Before after thumb", purpose: "Mini comparaison visuelle.", pattern: :before_after_thumb),
        Layout.new(code: "M32", name: "Option pill group", purpose: "Choix multiples en pastilles.", pattern: :option_pill_group),
        Layout.new(code: "M33", name: "Mini spec table", purpose: "Tableau technique tres court.", pattern: :mini_spec_table),
        Layout.new(code: "M34", name: "Price estimate hint", purpose: "Indice de budget non dominant.", pattern: :price_estimate_hint),
        Layout.new(code: "M35", name: "Product status chip", purpose: "Etat produit ou disponibilite.", pattern: :product_status_chip),
        Layout.new(code: "M36", name: "Advice callout", purpose: "Conseil court dans le flux.", pattern: :advice_callout),
        Layout.new(code: "M37", name: "Partner logo tile", purpose: "Logo ou marque en tuile.", pattern: :partner_logo_tile),
        Layout.new(code: "M38", name: "Testimonial mini card", purpose: "Retour client format compact.", pattern: :testimonial_mini_card),
        Layout.new(code: "M39", name: "Download doc row", purpose: "Lien document ou fiche technique.", pattern: :download_doc_row),
        Layout.new(code: "M40", name: "Error help inline row", purpose: "Aide ou erreur proche du champ.", pattern: :error_help_inline_row),
        Layout.new(code: "M41", name: "Small media badge", purpose: "Media court avec badge.", pattern: :small_media_badge, role: :media),
        Layout.new(code: "M42", name: "Checklist item", purpose: "Item coche ou valide.", pattern: :checklist_item, role: :checklist),
        Layout.new(code: "M43", name: "Timeline dot row", purpose: "Ligne de progression miniature.", pattern: :timeline_dot_row, role: :process),
        Layout.new(code: "M44", name: "Toggle card", purpose: "Carte activable ou selectable.", pattern: :toggle_card, role: :choice),
        Layout.new(code: "M45", name: "Small compare row", purpose: "Comparer deux options en ligne.", pattern: :small_compare_row, role: :comparison),
        Layout.new(code: "M46", name: "Inline availability", purpose: "Disponibilite dans une ligne.", pattern: :inline_availability, role: :availability),
        Layout.new(code: "M47", name: "Mini map pin", purpose: "Repere lieu ou zone.", pattern: :mini_map_pin, role: :local),
        Layout.new(code: "M48", name: "Phone chip", purpose: "Action appel compacte.", pattern: :phone_chip, role: :contact),
        Layout.new(code: "M49", name: "Email chip", purpose: "Action email compacte.", pattern: :email_chip, role: :contact),
        Layout.new(code: "M50", name: "Calendar slot chip", purpose: "Creneau ou rendez-vous.", pattern: :calendar_slot_chip, role: :booking),
        Layout.new(code: "M51", name: "Product color row", purpose: "Afficher coloris ou finitions.", pattern: :product_color_row, role: :options),
        Layout.new(code: "M52", name: "Material swatch cell", purpose: "Echantillon ou matiere.", pattern: :material_swatch_cell, role: :options),
        Layout.new(code: "M53", name: "Guarantee mini tile", purpose: "Garantie en mini surface.", pattern: :guarantee_mini_tile, role: :trust),
        Layout.new(code: "M54", name: "Certification row", purpose: "Certification ou label.", pattern: :certification_row, role: :proof),
        Layout.new(code: "M55", name: "Micro FAQ item", purpose: "Question/reponse compacte.", pattern: :micro_faq_item, role: :faq),
        Layout.new(code: "M56", name: "Price badge", purpose: "Signal prix ou estimation.", pattern: :price_badge, role: :pricing),
        Layout.new(code: "M57", name: "Status ribbon card", purpose: "Carte avec statut visible.", pattern: :status_ribbon_card, role: :status),
        Layout.new(code: "M58", name: "Mini service card", purpose: "Service en petite carte.", pattern: :mini_service_card, role: :services),
        Layout.new(code: "M59", name: "Advisor avatar row", purpose: "Conseiller ou equipe en ligne.", pattern: :advisor_avatar_row, role: :trust),
        Layout.new(code: "M60", name: "Project tag cluster", purpose: "Tags projet regroupes.", pattern: :project_tag_cluster, role: :tags),
        Layout.new(code: "M61", name: "Measurement note", purpose: "Note technique ou mesure.", pattern: :measurement_note, role: :note),
        Layout.new(code: "M62", name: "Quick action bar", purpose: "Actions rapides horizontales.", pattern: :quick_action_bar, role: :actions),
        Layout.new(code: "M63", name: "Thumbnail rail item", purpose: "Item de galerie miniature.", pattern: :thumbnail_rail_item, role: :gallery),
        Layout.new(code: "M64", name: "Resource doc pill", purpose: "Document en pastille.", pattern: :resource_doc_pill, role: :resources),
        Layout.new(code: "M65", name: "Video teaser tile", purpose: "Tuile video ou media.", pattern: :video_teaser_tile, role: :media),
        Layout.new(code: "M66", name: "Project area chip", purpose: "Zone ou usage du projet.", pattern: :project_area_chip, role: :tags),
        Layout.new(code: "M67", name: "Urgency notice", purpose: "Alerte courte ou urgence.", pattern: :urgency_notice, role: :notice),
        Layout.new(code: "M68", name: "Success toast shape", purpose: "Feedback positif compact.", pattern: :success_toast_shape, role: :feedback),
        Layout.new(code: "M69", name: "Form helper block", purpose: "Aide contextuelle proche d'un champ.", pattern: :form_helper_block, role: :form),
        Layout.new(code: "M70", name: "Numeric proof pill", purpose: "Chiffre preuve en pastille.", pattern: :numeric_proof_pill, role: :proof),
        Layout.new(code: "M71", name: "Opening status dot", purpose: "Statut ouvert/ferme.", pattern: :opening_status_dot, role: :status),
        Layout.new(code: "M72", name: "Before after label", purpose: "Label pour comparaison visuelle.", pattern: :before_after_label, role: :proof),
        Layout.new(code: "M73", name: "Address line", purpose: "Adresse concise.", pattern: :address_line, role: :local),
        Layout.new(code: "M74", name: "Warranty line", purpose: "Garantie en ligne courte.", pattern: :warranty_line, role: :trust),
        Layout.new(code: "M75", name: "Compact accordion row", purpose: "Ligne pliable compacte.", pattern: :compact_accordion_row, role: :faq),
        Layout.new(code: "M76", name: "Feature bullet pair", purpose: "Deux benefices en paire.", pattern: :feature_bullet_pair, role: :content),
        Layout.new(code: "M77", name: "Quote summary chip", purpose: "Resume de demande.", pattern: :quote_summary_chip, role: :quote),
        Layout.new(code: "M78", name: "Delivery delay cell", purpose: "Delai ou timing visible.", pattern: :delivery_delay_cell, role: :availability),
        Layout.new(code: "M79", name: "Product recommendation row", purpose: "Recommandation en ligne.", pattern: :product_recommendation_row, role: :commerce),
        Layout.new(code: "M80", name: "Random micro tile", purpose: "Micro bloc polyvalent pour generation.", pattern: :random_micro_tile, role: :random)
      ]
    )
  ].freeze

  VARIANT_AXES = [
    VariantAxis.new(
      key: :orientation,
      name: "Orientation",
      description: "Inversion et priorite visuelle sans creer un nouveau layout.",
      values: [
        { key: :copy_left_media_right, label: "Texte gauche / media droite", effect: "Lecture classique, rassurante." },
        { key: :media_left_copy_right, label: "Media gauche / texte droite", effect: "Impact visuel avant argument." },
        { key: :proof_before_action, label: "Preuve avant action", effect: "Conversion plus douce." },
        { key: :action_before_proof, label: "Action avant preuve", effect: "Parcours plus direct." }
      ]
    ),
    VariantAxis.new(
      key: :density,
      name: "Densite",
      description: "Quantite d'air, hauteur et nombre d'elements visibles.",
      values: [
        { key: :compact, label: "Compacte", effect: "Scan rapide, pages utilitaires." },
        { key: :balanced, label: "Equilibree", effect: "Default Public V2." },
        { key: :spacious, label: "Large", effect: "Premium, showroom, respiration." }
      ]
    ),
    VariantAxis.new(
      key: :accent,
      name: "Accent",
      description: "Force du signal graphique applique aux blocs.",
      values: [
        { key: :soft, label: "Faible", effect: "Rassurant et sobre." },
        { key: :balanced, label: "Moyen", effect: "Signal clair sans saturer." },
        { key: :spotlight, label: "Fort", effect: "Message commercial ou CTA." }
      ]
    ),
    VariantAxis.new(
      key: :columns,
      name: "Colonnes",
      description: "Nombre de pistes desktop avant adaptation mobile.",
      values: [
        { key: :one, label: "1 colonne", effect: "Recit vertical." },
        { key: :two, label: "2 colonnes", effect: "Comparaison ou media + contenu." },
        { key: :three, label: "3 colonnes", effect: "Categories, preuves, services." },
        { key: :four, label: "4 colonnes", effect: "Index, specs, micro-cards." }
      ]
    ),
    VariantAxis.new(
      key: :mobile_order,
      name: "Ordre mobile",
      description: "Priorite de lecture sur petit ecran.",
      values: [
        { key: :promise_first, label: "Promesse d'abord", effect: "Comprendre avant voir." },
        { key: :media_first, label: "Media d'abord", effect: "Inspection visuelle immediate." },
        { key: :action_first, label: "Action d'abord", effect: "Demande rapide." },
        { key: :proof_first, label: "Preuve d'abord", effect: "Rassurer avant convertir." }
      ]
    ),
    VariantAxis.new(
      key: :rhythm,
      name: "Rythme",
      description: "Cadence generale de la composition.",
      values: [
        { key: :quiet, label: "Calme", effect: "Premium sobre." },
        { key: :editorial, label: "Editorial", effect: "Narration, conseil, lecture." },
        { key: :commercial, label: "Commercial", effect: "Offre, CTA, decision." },
        { key: :technical, label: "Technique", effect: "Specs, preuves, comparaison." }
      ]
    )
  ].freeze

  COMPOSER_PROCESS = [
    ComposerStep.new(number: "01", title: "Intention", description: "Nommer le role de la page ou section : premium, devis, local, catalogue, diagnostic, preuve."),
    ComposerStep.new(number: "02", title: "Inventaire", description: "Lister ce qui existe vraiment : photo forte, CTA, categories, preuves, specs, contraintes mobile."),
    ComposerStep.new(number: "03", title: "Squelette", description: "Choisir un global layout compatible avec l'intention avant de choisir les sections."),
    ComposerStep.new(number: "04", title: "Sections", description: "Assembler 3 a 6 sections qui creent une progression, pas une simple collection de blocs."),
    ComposerStep.new(number: "05", title: "Micros", description: "Piocher les micro-layouts pour servir les sections : badges, stats, lignes meta, actions, preuves."),
    ComposerStep.new(number: "06", title: "Variantes", description: "Appliquer orientation, densite, accent, colonnes, ordre mobile et rythme."),
    ComposerStep.new(number: "07", title: "Rejet", description: "Ecarter les combinaisons incoherentes : trop d'accents forts, mauvais ordre mobile, densite contradictoire."),
    ComposerStep.new(number: "08", title: "Vue TEST", description: "Generer dans une page *_test, comparer, puis integrer seulement la composition validee.")
  ].freeze

  COMPOSER_PRESETS = [
    ComposerPreset.new(
      code: "C01",
      name: "Home premium locale",
      intent: "Rassurer avant de convertir.",
      brief: "Home sobre avec showroom, preuve locale et conversion douce.",
      global_code: "G24",
      section_codes: %w[S22 S50 S57 S64 S40],
      micro_codes: %w[M70 M73 M74 M48],
      variants: {
        orientation: :copy_left_media_right,
        density: :spacious,
        accent: :soft,
        columns: :two,
        mobile_order: :proof_first,
        rhythm: :quiet
      },
      avoid: ["CTA trop agressif en hero", "Plus d'un spotlight fort au-dessus de la ligne de flottaison"]
    ),
    ComposerPreset.new(
      code: "C02",
      name: "Home devis rapide",
      intent: "Reduire la friction de demande.",
      brief: "Parcours court : besoin, formulaire, progression, contact direct.",
      global_code: "G17",
      section_codes: %w[S23 S69 S49 S60],
      micro_codes: %w[M26 M77 M50 M69],
      variants: {
        orientation: :action_before_proof,
        density: :compact,
        accent: :spotlight,
        columns: :two,
        mobile_order: :action_first,
        rhythm: :commercial
      },
      avoid: ["Galerie decorative", "Longue narration avant le premier champ"]
    ),
    ComposerPreset.new(
      code: "C03",
      name: "Produit technique",
      intent: "Aider a comparer et comprendre.",
      brief: "Page produit dense avec options, specs, finitions et preuves.",
      global_code: "G53",
      section_codes: %w[S46 S77 S73 S53 S75],
      micro_codes: %w[M33 M51 M52 M56],
      variants: {
        orientation: :media_left_copy_right,
        density: :balanced,
        accent: :balanced,
        columns: :three,
        mobile_order: :media_first,
        rhythm: :technical
      },
      avoid: ["Accent flashy sur chaque spec", "Tableaux trop larges sans repli mobile"]
    ),
    ComposerPreset.new(
      code: "C04",
      name: "Inspiration categorie",
      intent: "Faire choisir par usage et image.",
      brief: "Entree visuelle, moodboard, galerie, avant/apres et categories.",
      global_code: "G35",
      section_codes: %w[S36 S68 S54 S19 S13],
      micro_codes: %w[M31 M65 M66 M22],
      variants: {
        orientation: :media_left_copy_right,
        density: :spacious,
        accent: :balanced,
        columns: :three,
        mobile_order: :media_first,
        rhythm: :editorial
      },
      avoid: ["Trop de texte avant les images", "Grille image sans entree de navigation claire"]
    ),
    ComposerPreset.new(
      code: "C05",
      name: "Confiance showroom",
      intent: "Mettre l'humain et le lieu au centre.",
      brief: "Recit court autour de l'equipe, du showroom, des marques et des avis.",
      global_code: "G12",
      section_codes: %w[S50 S63 S74 S57 S20],
      micro_codes: %w[M59 M54 M38 M73],
      variants: {
        orientation: :proof_before_action,
        density: :balanced,
        accent: :soft,
        columns: :two,
        mobile_order: :proof_first,
        rhythm: :quiet
      },
      avoid: ["Offre commerciale trop tot", "Photo showroom trop petite"]
    ),
    ComposerPreset.new(
      code: "C06",
      name: "Support local compact",
      intent: "Resoudre vite un besoin urgent ou SAV.",
      brief: "Page courte avec zone, disponibilite, contact et preuve de service.",
      global_code: "G66",
      section_codes: %w[S58 S76 S64 S71],
      micro_codes: %w[M71 M48 M47 M67],
      variants: {
        orientation: :action_before_proof,
        density: :compact,
        accent: :balanced,
        columns: :one,
        mobile_order: :action_first,
        rhythm: :technical
      },
      avoid: ["Navigation trop profonde", "CTA secondaire concurrent"]
    )
  ].freeze

  COMPONENT_BRICKS = [
    ComponentBrick.new(
      code: "B01",
      name: "Action dock",
      component: "PublicV2::Ui::ActionDockComponent",
      role: "conversion",
      best_for: "CTA devis compact, hero moderne, sidebar, bento.",
      avoid: "Remplacer une section entiere par un dock trop gros."
    ),
    ComponentBrick.new(
      code: "B02",
      name: "Proof rail",
      component: "PublicV2::Ui::ProofRailComponent",
      role: "preuve",
      best_for: "Chiffres, labels, garanties, signaux locaux.",
      avoid: "Empiler plus de quatre preuves sans hierarchie."
    ),
    ComponentBrick.new(
      code: "B03",
      name: "Step rail",
      component: "PublicV2::Ui::StepRailComponent",
      role: "process",
      best_for: "Parcours devis, pose, accompagnement, diagnostic.",
      avoid: "Ajouter des etapes vagues qui ne changent pas l'action."
    ),
    ComponentBrick.new(
      code: "B04",
      name: "Choice tile",
      component: "PublicV2::Ui::ChoiceTileComponent",
      role: "decision",
      best_for: "Entrees produit, besoins, usages, options.",
      avoid: "Trop de choix equivalents au-dessus de la ligne de flottaison."
    ),
    ComponentBrick.new(
      code: "B05",
      name: "Panel variants",
      component: "PublicV2::Ui::PanelComponent",
      role: "surface",
      best_for: "Bloc calme, rail, soft, outline ou flashy compact.",
      avoid: "Utiliser flashy comme fond principal de page."
    ),
    ComponentBrick.new(
      code: "B06",
      name: "Spotlight panel",
      component: "PublicV2::Ui::SpotlightPanelComponent",
      role: "signal",
      best_for: "Promesse courte, preuve forte, bloc premium.",
      avoid: "Multiplier les spotlights dans la meme section."
    ),
    ComponentBrick.new(
      code: "B07",
      name: "Media frame",
      component: "PublicV2::Ui::MediaFrameComponent",
      role: "media",
      best_for: "Photo module, vignette, preuve showroom.",
      avoid: "Photo hero par defaut quand le brief demande une ambiance interface."
    ),
    ComponentBrick.new(
      code: "B08",
      name: "Badge cluster",
      component: "PublicV2::Ui::BadgeComponent",
      role: "meta",
      best_for: "Tags, services, labels, categories rapides.",
      avoid: "Faire porter toute la comprehension aux badges."
    )
  ].freeze

  GENERATION_RECIPES = [
    GenerationRecipe.new(
      code: "R01",
      name: "Premium devis moderne",
      intent: "Home design, conversion lisible, photo secondaire.",
      prompt: "Premium/design moderne, oriente devis, photo max 25%, flashy seulement en dock ou badge.",
      global_codes: %w[G40 G46 G70],
      section_codes: %w[S49 S60 S69 S79],
      micro_codes: %w[M26 M62 M70 M77],
      component_codes: %w[B01 B02 B03 B07],
      variants: { density: :balanced, accent: :balanced, mobile_order: :action_first, rhythm: :technical },
      weights: { conversion: 5, premium: 4, media: 2, complexity: 3 },
      reject: ["Photo hero dominante", "Titre long", "Plus d'un bloc flashy"]
    ),
    GenerationRecipe.new(
      code: "R02",
      name: "Bento conseil",
      intent: "Rassurer, guider, puis convertir.",
      prompt: "Bento calme avec preuves, choix produits et action devis compacte.",
      global_codes: %w[G09 G24 G27],
      section_codes: %w[S43 S48 S51 S64],
      micro_codes: %w[M36 M42 M59 M70],
      component_codes: %w[B01 B02 B04 B05],
      variants: { density: :balanced, accent: :soft, mobile_order: :proof_first, rhythm: :quiet },
      weights: { conversion: 3, premium: 5, media: 2, complexity: 3 },
      reject: ["CTA avant toute reassurance", "Bento trop symetrique", "Grille sans priorite"]
    ),
    GenerationRecipe.new(
      code: "R03",
      name: "Catalogue vers devis",
      intent: "Faire choisir une famille avant le formulaire.",
      prompt: "Entrees produits nettes, micro choix, photo discrete, devis proche.",
      global_codes: %w[G14 G22 G57],
      section_codes: %w[S13 S25 S45 S60],
      micro_codes: %w[M22 M32 M44 M79],
      component_codes: %w[B01 B04 B05 B08],
      variants: { density: :compact, accent: :balanced, mobile_order: :promise_first, rhythm: :commercial },
      weights: { conversion: 4, premium: 3, media: 1, complexity: 2 },
      reject: ["Trop de categories visibles", "Photo produit plus forte que le choix", "CTA cache"]
    ),
    GenerationRecipe.new(
      code: "R04",
      name: "Confiance locale compacte",
      intent: "Prouver l'ancrage local sans page vitrine.",
      prompt: "Preuves locales, showroom en vignette, contact direct et demande devis courte.",
      global_codes: %w[G13 G25 G62],
      section_codes: %w[S22 S50 S55 S64],
      micro_codes: %w[M47 M48 M70 M73],
      component_codes: %w[B01 B02 B07 B08],
      variants: { density: :compact, accent: :soft, mobile_order: :proof_first, rhythm: :quiet },
      weights: { conversion: 3, premium: 4, media: 2, complexity: 2 },
      reject: ["Carte ou photo trop grande", "Texte institutionnel", "Preuves redondantes"]
    ),
    GenerationRecipe.new(
      code: "R05",
      name: "Diagnostic guide",
      intent: "Partir du besoin et reduire l'incertitude.",
      prompt: "Diagnostic court, trois choix maximum, etapes visibles, action devis en fin de bloc.",
      global_codes: %w[G42 G67 G75],
      section_codes: %w[S11 S18 S25 S69],
      micro_codes: %w[M18 M26 M44 M77],
      component_codes: %w[B01 B03 B04 B05],
      variants: { density: :balanced, accent: :balanced, mobile_order: :promise_first, rhythm: :technical },
      weights: { conversion: 5, premium: 3, media: 1, complexity: 4 },
      reject: ["Plus de trois choix initiaux", "Etapes non actionnables", "Formulaire complet en hero"]
    )
  ].freeze

  PROMPT_FACETS = [
    PromptFacet.new(
      key: :objective,
      name: "Objectif",
      examples: ["home premium orientee devis", "page produit technique", "categorie inspiration", "contact local compact"]
    ),
    PromptFacet.new(
      key: :media_presence,
      name: "Presence photo",
      examples: ["aucune", "vignette", "module secondaire", "photo forte", "hero media"]
    ),
    PromptFacet.new(
      key: :conversion_pressure,
      name: "Pression devis",
      examples: ["douce", "visible", "directe", "formulaire court", "appel prioritaire"]
    ),
    PromptFacet.new(
      key: :micro_layout,
      name: "Micro-layout souhaite",
      examples: ["dock", "rail", "bento", "choice tiles", "step rail", "proof cluster"]
    ),
    PromptFacet.new(
      key: :constraints,
      name: "Contraintes",
      examples: ["textes courts", "flashy petit", "mobile promesse d'abord", "max trois choix", "pas de grande photo"]
    )
  ].freeze

  def sections
    SECTIONS
  end

  def layout_count
    sections.sum { |section| section.layouts.size }
  end

  def random_pool
    sections.flat_map(&:layouts)
  end

  def variant_axes
    VARIANT_AXES
  end

  def variant_multiplier
    variant_axes.reduce(1) { |total, axis| total * axis.values.size }
  end

  def estimated_combination_count
    layout_count * variant_multiplier
  end

  def composer_process
    COMPOSER_PROCESS
  end

  def composer_presets
    COMPOSER_PRESETS
  end

  def component_bricks
    COMPONENT_BRICKS
  end

  def generation_recipes
    GENERATION_RECIPES
  end

  def prompt_facets
    PROMPT_FACETS
  end

  def layout_by_code(code)
    layouts_by_code.fetch(code.to_s)
  end

  def layouts_for_codes(codes)
    codes.map { |code| layout_by_code(code) }
  end

  def variant_summary(preset)
    preset.variants.map do |key, value|
      axis = variant_axes.find { |candidate| candidate.key == key }
      variant = axis&.values&.find { |candidate| candidate[:key] == value }

      {
        axis: axis&.name || key.to_s.tr("_", " "),
        value: variant&.fetch(:label) || value.to_s.tr("_", " ")
      }
    end
  end

  def recipe_components(recipe)
    recipe.component_codes.map { |code| component_bricks_by_code.fetch(code) }
  end

  def recipe_score(recipe)
    recipe.weights.values.sum
  end

  private

  def layouts_by_code
    @layouts_by_code ||= random_pool.to_h { |layout| [layout.code, layout] }
  end

  def component_bricks_by_code
    @component_bricks_by_code ||= component_bricks.to_h { |brick| [brick.code, brick] }
  end
end
