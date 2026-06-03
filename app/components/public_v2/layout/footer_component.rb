# frozen_string_literal: true

class PublicV2::Layout::FooterComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(
    categories: [],
    title: "Parlons de votre projet",
    text: nil,
    phone: PublicV2::ContactInfo.phone,
    email: PublicV2::ContactInfo.email,
    eyebrow: "Les Artisans du Store",
    address: PublicV2::ContactInfo.address,
    city: PublicV2::ContactInfo.city,
    hours: PublicV2::ContactInfo.hours_text,
    id: "contact",
    classes: nil,
    debug: false
  )
    @title = title
    @text = text.presence || "Une photo, quelques dimensions ou une idee suffisent : l'equipe vous oriente vers la bonne solution, au showroom ou a distance."
    @phone = phone
    @email = email
    @eyebrow = eyebrow
    @address = address
    @city = city
    @hours = hours
    @id = id
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :title, :text, :phone, :email, :eyebrow, :address, :city, :hours, :id, :classes

  def component_classes
    component_class_names("pv2-public-footer", "pv2-ui-footer", "grid w-full min-w-0 gap-4", debug_class, classes)
  end

  def phone_href
    "tel:#{phone.to_s.delete(" ")}"
  end

  def mail_href
    "mailto:#{email}"
  end

  def contact_items
    [
      { icon: :phone, value: phone, path: phone_href },
      { icon: :mail, value: email, path: mail_href },
      { icon: :map, value: "#{address}, #{city}", path: helpers.public_v2_contact_path }
    ]
  end

  def contact_icon(icon)
    paths = {
      phone: [
        tag.path(d: "M20.4 15.7v2.08a2.35 2.35 0 0 1-2.56 2.34A18.9 18.9 0 0 1 1.88 4.16 2.35 2.35 0 0 1 4.22 1.6h2.09a2.35 2.35 0 0 1 2.28 1.78l.7 2.82a2.35 2.35 0 0 1-.64 2.25l-.84.84a13.2 13.2 0 0 0 5.9 5.9l.84-.84a2.35 2.35 0 0 1 2.25-.64l2.82.7a2.35 2.35 0 0 1 1.78 2.29Z")
      ],
      mail: [
        tag.path(d: "M4.6 4.4h14.8a2.6 2.6 0 0 1 2.6 2.6v10a2.6 2.6 0 0 1-2.6 2.6H4.6A2.6 2.6 0 0 1 2 17V7a2.6 2.6 0 0 1 2.6-2.6Zm15.48 3.15a1 1 0 0 0-1.33-.5L12 10.88 5.25 7.05a1 1 0 1 0-.98 1.74l7.24 4.1a1 1 0 0 0 .98 0l7.24-4.1a1 1 0 0 0 .35-1.24Z")
      ],
      map: [
        tag.path(d: "M12 1.9a7.8 7.8 0 0 0-7.8 7.8c0 5.72 7.1 12.04 7.4 12.3a1 1 0 0 0 1.32 0c.3-.26 7.38-6.58 7.38-12.3A7.8 7.8 0 0 0 12 1.9Zm0 10.8a3 3 0 1 1 0-6 3 3 0 0 1 0 6Z")
      ]
    }

    tag.svg(
      safe_join(paths.fetch(icon)),
      class: "pv2-public-footer__contact-icon",
      viewBox: "0 0 24 24",
      fill: "currentColor",
      aria: { hidden: true },
      focusable: "false"
    )
  end

  def navigation_items
    [
      { label: "Accueil", path: helpers.public_v2_home_path },
      { label: "Produits", path: helpers.public_v2_categories_path },
      { label: "Devis", path: helpers.public_v2_new_quote_path },
      { label: "Contact", path: helpers.public_v2_contact_path }
    ]
  end
end
