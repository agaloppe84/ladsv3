# frozen_string_literal: true

class PublicV2::HomeContentBlueprint
  Block = Struct.new(:key, :kicker, :title, :text, :intent, :items, :media, :cta, keyword_init: true)

  HERO = Block.new(
    key: :hero,
    kicker: "Les Artisans du Store - L'Arbresle",
    title: "Protection solaire et fermetures sur mesure.",
    text: "Stores, volets, pergolas, moustiquaires et portes de garage avec conseil, pose et suivi local dans le Rhone.",
    intent: "Promesse courte, premium et orientee devis.",
    media: {
      image: "magasin-04.jpeg",
      alt: "Showroom Les Artisans du Store avec produits exposes",
      caption: "Showroom et conseil technique"
    },
    cta: [
      { label: "Demander un devis", path_key: :quote, priority: :primary },
      { label: "Voir les familles", path_key: :categories, priority: :secondary }
    ]
  ).freeze

  PROOFS = [
    { value: "35 ans", label: "Experience", text: "Conseil terrain et pose locale." },
    { value: "RGE", label: "Signal confiance", text: "Preuve visible avant devis." },
    { value: "200m2", label: "Showroom", text: "Comparer mecanismes et finitions." },
    { value: "48h", label: "Premier retour", text: "Cadrage rapide de la demande." }
  ].freeze

  NEEDS = [
    { kicker: "Soleil", title: "Se proteger", text: "Stores bannes, screens, toiles et pergolas.", icon: "S" },
    { kicker: "Fermeture", title: "Securiser", text: "Volets roulants, battants et portes de garage.", icon: "F" },
    { kicker: "Confort", title: "Mieux vivre", text: "Moustiquaires, stores interieurs et motorisations.", icon: "C" }
  ].freeze

  PRODUCT_FAMILIES = [
    { kicker: "01", title: "Stores", text: "Ombre, chaleur, luminosite.", meta: "Terrasse et baies", image: "magasin-02.jpeg", alt: "Stores exposes en showroom" },
    { kicker: "02", title: "Volets", text: "Fermeture, confort, securite.", meta: "Maison et renovation", image: "magasin-01.jpeg", alt: "Facade Les Artisans du Store" },
    { kicker: "03", title: "Pergolas", text: "Exterieur plus durable.", meta: "Terrasse", image: "magasin-06.jpeg", alt: "Finitions et echantillons" },
    { kicker: "04", title: "Moustiquaires", text: "Ventiler sans subir.", meta: "Confort quotidien", image: "magasin-04.jpeg", alt: "Showroom Les Artisans du Store" },
    { kicker: "05", title: "Portes de garage", text: "Acces, fermeture, usage.", meta: "Fermeture", image: "magasin-03.jpeg", alt: "Facade et acces" }
  ].freeze

  QUOTE_JOURNEY = [
    { kicker: "01", title: "Exprimer le besoin", text: "Famille produit, lieu et usage.", meta: "Une demande courte" },
    { kicker: "02", title: "Cadrer le contexte", text: "Dimensions, exposition, photo ou contrainte.", meta: "Conseil utile" },
    { kicker: "03", title: "Comparer les options", text: "Mecanisme, toile, motorisation, finition.", meta: "Choix plus clair" },
    { kicker: "04", title: "Recevoir un retour", text: "Premier cadrage pour avancer sans flou.", meta: "Orientation devis" }
  ].freeze

  SHOWROOM = Block.new(
    key: :showroom,
    kicker: "Showroom technique",
    title: "Voir, toucher, comparer avant de chiffrer.",
    text: "Le showroom de L'Arbresle aide a valider les toiles, mecanismes, finitions et contraintes avant devis.",
    intent: "Rassurer et transformer le catalogue en choix concret.",
    media: {
      image: "magasin-06.jpeg",
      alt: "Showroom Les Artisans du Store",
      caption: "200m2 pour comparer"
    },
    items: [
      { title: "Toiles et coloris", text: "Choix visible, pas seulement catalogue." },
      { title: "Mecanismes", text: "Comprendre la tenue et l'usage." },
      { title: "Conseil", text: "Adapter le produit au chantier." }
    ]
  ).freeze

  SERVICE_FLOW = [
    { icon: "C", title: "Conseil", text: "Besoin, budget, usage et contraintes." },
    { icon: "M", title: "Mesure", text: "Prise de cotes et verification technique." },
    { icon: "P", title: "Pose", text: "Fourniture et installation par l'equipe terrain." },
    { icon: "S", title: "SAV", text: "Suivi local apres la pose." }
  ].freeze

  OBJECTIONS = [
    { question: "Je ne sais pas quel produit choisir.", answer: "La home doit proposer une entree par besoin : soleil, fermeture, confort, exterieur." },
    { question: "Je n'ai pas encore les dimensions.", answer: "Le parcours devis doit accepter une demande courte avec photo ou contexte, puis cadrer ensuite." },
    { question: "Je veux comparer avant de demander un prix.", answer: "Les sections produits et showroom doivent aider a comparer usages, options et contraintes." },
    { question: "Je veux savoir qui va poser.", answer: "Le parcours doit rendre visibles conseil, prise de cotes, pose locale et SAV." }
  ].freeze

  FINAL_CTA = Block.new(
    key: :final_cta,
    kicker: "Demande de devis",
    title: "Commencer par un cadrage simple.",
    text: "Une premiere demande permet de confirmer le besoin, le contexte et les options avant un chiffrage plus precis.",
    intent: "CTA final rassurant, pas agressif.",
    cta: [
      { label: "Demander un devis", path_key: :quote, priority: :primary },
      { label: "Contacter le showroom", path_key: :contact, priority: :secondary }
    ]
  ).freeze

  def hero
    HERO
  end

  def proofs
    PROOFS
  end

  def needs
    NEEDS
  end

  def product_families
    PRODUCT_FAMILIES
  end

  def quote_journey
    QUOTE_JOURNEY
  end

  def showroom
    SHOWROOM
  end

  def service_flow
    SERVICE_FLOW
  end

  def objections
    OBJECTIONS
  end

  def final_cta
    FINAL_CTA
  end

  def source_notes
    [
      { label: "Home classique", text: "35 ans, Rhone, L'Arbresle, Expert RGE, gamme complete." },
      { label: "Home-v2", text: "Devis 48h, showroom 200m2, conseil, selection, pose, SAV, catalogue." },
      { label: "Synthese premium", text: "Cadrer le besoin avant de chiffrer, montrer les preuves, guider vers le devis." }
    ]
  end

  def section_sequence
    [
      { key: :hero, label: "Hero devis", component_hint: "Spotlight + Media + ActionDock" },
      { key: :needs, label: "Choix du besoin", component_hint: "IconList ou ProductFamilyGrid" },
      { key: :proofs, label: "Preuves rapides", component_hint: "TrustCluster" },
      { key: :quote_journey, label: "Parcours devis", component_hint: "ProcessList ou QuoteIntake" },
      { key: :product_families, label: "Familles produit", component_hint: "ProductFamilyGrid + ComparisonStrip" },
      { key: :showroom, label: "Showroom conseil", component_hint: "MediaMosaic + SummaryBox" },
      { key: :service_flow, label: "Pose et SAV", component_hint: "IconList" },
      { key: :objections, label: "FAQ objections", component_hint: "FaqAccordion" },
      { key: :final_cta, label: "CTA final", component_hint: "ActionDock ou QuoteIntake" }
    ]
  end
end
