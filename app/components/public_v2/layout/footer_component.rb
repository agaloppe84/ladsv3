# frozen_string_literal: true

class PublicV2::Layout::FooterComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(
    categories: [],
    title: "Un projet de store, volet ou fermeture ?",
    text: nil,
    phone: PublicV2::ContactInfo.phone,
    email: PublicV2::ContactInfo.email,
    eyebrow: PublicV2::ContactInfo.eyebrow,
    address: PublicV2::ContactInfo.address,
    city: PublicV2::ContactInfo.city,
    hours: PublicV2::ContactInfo.hours_text,
    proof_items: PublicV2::ContactInfo.proof_items,
    id: "contact",
    classes: nil,
    debug: false
  )
    @categories = categories
    @title = title
    @text = text.presence || PublicV2::ContactInfo.summary_text
    @phone = phone
    @email = email
    @eyebrow = eyebrow
    @address = address
    @city = city
    @hours = hours
    @proof_items = proof_items.presence || PublicV2::ContactInfo.proof_items
    @id = id
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :categories, :title, :text, :phone, :email, :eyebrow, :address, :city, :hours, :proof_items, :id, :classes

  def component_classes
    component_class_names("pv2-public-footer", "pv2-ui-footer", "grid w-full min-w-0 gap-4", debug_class, classes)
  end

  def phone_href
    "tel:#{phone.to_s.delete(" ")}"
  end

  def mail_href
    "mailto:#{email}"
  end

  def proof_cards
    [
      { label: "Retour devis", value: "48h", text: "Premier cadrage clair." },
      { label: "Showroom", value: "200m2", text: "Voir et comparer." },
      { label: "Projet", value: "Local", text: "Conseil, pose et SAV." }
    ]
  end

  def navigation_items
    [
      { label: "Accueil", path: helpers.public_v2_home_path },
      { label: "Produits", path: helpers.public_v2_categories_path },
      { label: "Devis", path: helpers.public_v2_new_quote_path },
      { label: "Contact", path: helpers.public_v2_contact_path }
    ]
  end

  def category_links
    categories.first(6)
  end
end
