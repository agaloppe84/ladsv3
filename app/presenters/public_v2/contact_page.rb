# frozen_string_literal: true

class PublicV2::ContactPage
  def initialize(categories:, product_count:)
    @categories = categories
    @product_count = product_count
  end

  attr_reader :categories, :product_count

  def contact_info
    PublicV2::ContactInfo
  end

  def hero_image
    "magasin-04.jpeg"
  end

  def showroom_image
    "magasin-06.jpeg"
  end

  def hero_proof_items
    [
      { value: "200m2", label: "Showroom", text: "Comparer les solutions." },
      { value: "48h", label: "Premier retour", text: "Cadrage devis rapide." },
      { value: product_count_label, label: "Produits", text: "Catalogue et destockage." }
    ]
  end

  def contact_cards
    contact_info.contact_cards
  end

  def map_src
    contact_info.map_src
  end

  def visit_steps
    [
      { kicker: "01", title: "Appeler", text: "Verifier le bon interlocuteur ou caler une visite." },
      { kicker: "02", title: "Comparer", text: "Voir toiles, moteurs, coffres, rails et finitions." },
      { kicker: "03", title: "Cadrer", text: "Repartir avec les infos utiles au devis." }
    ]
  end

  def visit_items
    [
      { icon: "Photo", title: "Photos du projet", text: "Facade, terrasse, baie, garage ou fenetre." },
      { icon: "Dim", title: "Dimensions", text: "Largeur, hauteur ou ordre d'idee suffisent." },
      { icon: "Usage", title: "Contrainte", text: "Soleil, vent, passage, securite ou confort." }
    ]
  end

  def showroom_context_items
    [
      { kicker: "Soleil", title: "Stores et pergolas", text: "Ombre, chaleur, exposition.", points: ["Toile", "Structure", "Moteur"] },
      { kicker: "Fermeture", title: "Volets et garage", text: "Confort, securite, usage quotidien.", points: ["Tablier", "Pose", "Commande"] },
      { kicker: "Air", title: "Moustiquaires", text: "Ventiler sans laisser entrer les nuisibles.", points: ["Discret", "Fenetre", "Entretien"] }
    ]
  end

  def trust_items
    [
      { value: "Conseil", label: "Lecture metier", text: "Avant de parler prix." },
      { value: "Pose", label: "Equipe terrain", text: "La solution reste realiste." },
      { value: "SAV", label: "Suivi local", text: "Un contact apres chantier." }
    ]
  end

  def family_names
    categories.first(6).map(&:name)
  end

  private

  def product_count_label
    product_count.positive? ? product_count : "Catalogue"
  end
end
