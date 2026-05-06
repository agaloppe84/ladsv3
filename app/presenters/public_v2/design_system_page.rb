# frozen_string_literal: true

class PublicV2::DesignSystemPage
  OptionPreview = Struct.new(:number, :content, keyword_init: true)

  NAV_ITEMS = [
    { key: :home, label: "Accueil", path_key: :home },
    { key: :products, label: "Produits", path_key: :categories },
    { key: :quote, label: "Devis", path_key: :quote },
    { key: :contact, label: "Contact", path_key: :contact }
  ].freeze

  KIT_SECTIONS = [
    { id: "public-v2-kit-foundations", label: "Fondations", number: "01" },
    { id: "public-v2-kit-layout", label: "Layout", number: "02" },
    { id: "public-v2-kit-navigation", label: "Navigation", number: "03" },
    { id: "public-v2-kit-content", label: "Contenu", number: "04" },
    { id: "public-v2-kit-products", label: "Produits", number: "05" },
    { id: "public-v2-kit-forms", label: "Formulaires", number: "06" },
    { id: "public-v2-kit-feedback", label: "Etats", number: "07" },
    { id: "public-v2-kit-motion", label: "Motion", number: "08" },
    { id: "public-v2-kit-pages", label: "Pages", number: "09" },
    { id: "public-v2-kit-components", label: "ViewComponents", number: "10" }
  ].freeze

  OPTION_LIST_CONCEPTS = [
    {
      variant: :rail,
      label: "Concept 01",
      title: "Rail sequentiel compact",
      text: "Liste ordonnee premium : scan rapide, ordre visible, hauteur contenue."
    },
    {
      variant: :chips,
      label: "Concept 02",
      title: "Spec chips timeline",
      text: "Chips techniques compactes, utiles pour comparer beaucoup d'options."
    },
    {
      variant: :focus,
      label: "Concept 03",
      title: "Option focus dynamique",
      text: "Stepper interactif : tres compact, un detail lisible a la fois."
    },
    {
      variant: :blueprint,
      label: "Concept 04",
      title: "Blueprint technique",
      text: "Lecture plus expressive, proche d'une fiche technique premium."
    },
    {
      variant: :accordion,
      label: "Concept 05",
      title: "Accordion resume",
      text: "Mobile friendly : titres courts visibles, detail au clic."
    }
  ].freeze

  COMPONENT_INVENTORY = [
    ["Layout Rails", "app/views/layouts/public_v2.html.erb", "Shell global Public V2 avec tokens, navbar, event banner, contenu et footer."],
    ["Service", "PublicV2::ContactInfo", "Source unique des coordonnees, liens contact, preuve footer, horaires et map showroom."],
    ["Layout", "PublicV2::Layout::NavbarComponent", "Logo, liens, telephone, menu mobile, etat actif et controles theme."],
    ["Layout", "PublicV2::Layout::FooterComponent", "Coordonnees, horaires, preuves et liens utiles."],
    ["Content", "PublicV2::Content::HeroComponent", "Kicker, H1, lead, panel preuve et actions."],
    ["Content", "PublicV2::Content::SectionHeaderComponent", "En-tetes de sections home et standard."],
    ["Content", "PublicV2::Content::CtaBandComponent", "Bande CTA inter-section ou fin de page."],
    ["Content", "PublicV2::Content::InfoCardComponent", "Coordonnees, preuves et informations contextuelles."],
    ["Content", "PublicV2::Content::PartnersComponent", "Logo wall partenaires avec hover accent."],
    ["Home", "PublicV2::Home::HeroSectionComponent", "Hero home reel avec copy, actions, proofline, media et produit mis en avant."],
    ["Home", "PublicV2::Home::ExpertiseSectionComponent", "Section besoins metier : soleil, fermeture, confort."],
    ["Home", "PublicV2::Home::CategoryGridSectionComponent", "Grille familles produits de la home."],
    ["Home", "PublicV2::Home::ProductRowsSectionComponent", "Selection catalogue en lignes comparables."],
    ["Home", "PublicV2::Home::ShowroomSectionComponent", "Bloc showroom image + texte."],
    ["Home", "PublicV2::Home::QuoteShortcutSectionComponent", "Raccourci devis avec produit preselectionnable."],
    ["Categories", "PublicV2::Categories::SummarySectionComponent", "Synthese catalogue avec chiffres cles."],
    ["Categories", "PublicV2::Categories::HeroSectionComponent", "Hero categories/index branche sur le presenter."],
    ["Categories", "PublicV2::Categories::ListSectionComponent", "Liste des categories et produits associes."],
    ["Categories", "PublicV2::Categories::CtaSectionComponent", "CTA final categories/index."],
    ["Products", "PublicV2::Products::HeroComponent", "Hero fiche produit avec media, preuves et actions."],
    ["Products", "PublicV2::Products::HeaderSectionComponent", "Breadcrumb + hero fiche produit, sans chemins prepares dans la vue."],
    ["Products", "PublicV2::Products::DetailsSectionComponent", "Sections detail fiche produit : devis, marques, infos, options, coloris, services, galerie, docs."],
    ["Products", "PublicV2::Products::RelatedSectionComponent", "Produits proches a comparer dans la meme categorie."],
    ["Products", "PublicV2::Products::OptionListComponent", "Explorations compactes pour les options ordonnees : rail, chips, focus, blueprint et accordion."],
    ["Products", "PublicV2::Products::ProductCardComponent", "Card catalogue avec image, famille, nom et resume."],
    ["Products", "PublicV2::Products::CategoryBlockComponent", "Bloc categorie avec media, tags et grille produits."],
    ["Quotes", "PublicV2::Quotes::HeroSectionComponent", "Hero devis dedie."],
    ["Quotes", "PublicV2::Quotes::FormSectionComponent", "Layout devis avec formulaire, produit selectionne, etapes et contact direct."],
    ["Contact", "PublicV2::Contact::HeroSectionComponent", "Hero contact dedie avec coordonnees centralisees."],
    ["Contact", "PublicV2::Contact::DetailsSectionComponent", "Coordonnees et carte showroom."],
    ["Contact", "PublicV2::Contact::ShowroomSectionComponent", "Section pedagogique showroom avant devis."],
    ["Contact", "PublicV2::Contact::CtaSectionComponent", "CTA final contact."],
    ["Forms", "PublicV2::Forms::FieldComponent", "Input, select, textarea, hint et erreur."],
    ["Forms", "PublicV2::Forms::QuoteFormComponent", "Formulaire devis complet avec produit preselectionne."],
    ["Feedback", "PublicV2::Ui::NotificationBannerComponent", "Information importante, alert et toast."],
    ["Feedback", "PublicV2::Ui::EmptyStateComponent", "Etat vide avec action optionnelle."],
    ["UI", "PublicV2::Ui::PanelComponent", "Surface full-width avec header, actions, body, padding et variantes default, accent, soft, rail, elevated, outline, inset, flashy."],
    ["UI", "PublicV2::Ui::SpotlightPanelComponent", "Panel expressif soft ou flashy pour preuves fortes, contrats et CTA premium."],
    ["UI", "PublicV2::Ui::DropdownComponent", "Dropdown custom reutilisable avec trigger, contenu slotte et controller Stimulus Public V2."],
    ["UI", "PublicV2::Ui::ButtonComponent", "Boutons et liens avec variants, tailles, formes, full-width et debug frame optionnel."],
    ["UI", "PublicV2::Ui::BadgeComponent", "Badges RGE, sur mesure, destockage et services."],
    ["UI", "PublicV2::Ui::MediaFrameComponent", "Image stable, placeholder et ratios."],
    ["UI", "PublicV2::Ui::BreadcrumbComponent", "Fil d'Ariane public reutilisable."],
    ["UI", "PublicV2::Ui::StatCardComponent", "Chiffres showroom, experience, delais et garanties."]
  ].freeze

  def initialize(categories:, products:, destock_products:, featured_product:, primary_image_resolver:, path_builder:)
    @categories = categories
    @products = products
    @destock_products = destock_products
    @featured_product = featured_product
    @primary_image_resolver = primary_image_resolver
    @path_builder = path_builder
  end

  attr_reader :categories, :products, :destock_products

  def kit_sections
    KIT_SECTIONS
  end

  def component_inventory
    COMPONENT_INVENTORY
  end

  def option_list_concepts
    OPTION_LIST_CONCEPTS
  end

  def featured_product
    @featured_product || products.first
  end

  def featured_category
    featured_product&.category || categories.first
  end

  def featured_image
    product_image(featured_product)
  end

  def sample_products
    products.first(4)
  end

  def sample_categories
    categories.first(4)
  end

  def sample_option_items
    source_options = featured_product&.options.to_a
    source_options = fallback_option_texts.map { |content| OptionPreview.new(content: content) } if source_options.blank?

    ordered_options(source_options).first(8).each_with_index.map do |option, index|
      OptionPreview.new(number: format("%02d", index + 1), content: option.content.to_s.squish)
    end
  end

  def nav_items
    NAV_ITEMS.map do |item|
      item.except(:path_key).merge(path: path_builder.call(item[:path_key]))
    end
  end

  def accent_groups
    PublicV2::ThemePalette.groups
  end

  def quote_preview
    Quote.new(product: featured_product&.name)
  end

  def quote_products
    (products + destock_products).uniq
  end

  def fallback_product_name
    "Store banne coffre"
  end

  def fallback_category_name
    "Protection solaire"
  end

  def product_image(product)
    primary_image_resolver.call(product) if product.present?
  end

  private

  attr_reader :primary_image_resolver, :path_builder

  def ordered_options(options)
    options.sort_by do |option|
      [
        option.respond_to?(:order) && option.order.present? ? option.order : 999_999,
        option.respond_to?(:created_at) && option.created_at.present? ? option.created_at : Time.zone.at(0),
        option.respond_to?(:id) && option.id.present? ? option.id : 0
      ]
    end
  end

  def fallback_option_texts
    [
      "Toile acrylique teint masse 290g/m2, unie ou rayee.",
      "Avancee adaptee au projet et aux contraintes de facade.",
      "Lambrequin droit ou a vagues selon finition.",
      "Manoeuvre manuelle ou motorisation radio.",
      "Largeur sur mesure apres prise de cotes.",
      "Options : eclairage, automatisme vent/soleil, domotique."
    ]
  end
end
