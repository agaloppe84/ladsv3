# frozen_string_literal: true

class PublicV2::Contact::VisitGuideComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(contact_page:, debug: false)
    @contact_page = contact_page
    @debug = debug
  end

  private

  attr_reader :contact_page

  def component_classes
    component_class_names(
      "pv2-contact-visit-guide",
      "grid w-full min-w-0 gap-4",
      debug_class
    )
  end

  def cards
    [
      { key: :photo, title: "Photos du projet", text: "Façade, terrasse, baie, garage ou fenêtre : un visuel suffit souvent pour cadrer." },
      { key: :dimensions, title: "Dimensions utiles", text: "Largeur, hauteur, avancée ou ordre d'idée : on affine ensuite ensemble." },
      { key: :showroom, title: "Showroom", text: "Toiles, moteurs, coffres et finitions deviennent plus faciles à choisir sur place." },
      { key: :follow, title: "Conseil local", text: "Une équipe terrain pour relier le besoin, la pose et le suivi après chantier." }
    ]
  end

  def card_icon(key)
    paths = {
      photo: [
        tag.path(d: "M4 6.8A2.8 2.8 0 0 1 6.8 4h10.4A2.8 2.8 0 0 1 20 6.8v10.4a2.8 2.8 0 0 1-2.8 2.8H6.8A2.8 2.8 0 0 1 4 17.2Z"),
        tag.path(d: "M8 15.3l2.4-2.6 2.1 2.1 1.6-1.7L17.5 17H6.5Z", fill: "var(--pv2-contact-guide-icon-cutout)"),
        tag.circle(cx: "15.5", cy: "8.3", r: "1.6", fill: "var(--pv2-contact-guide-icon-cutout)")
      ],
      dimensions: [
        tag.path(d: "M4.4 16.7L16.7 4.4l3.9 3.9-12.3 12.3Z"),
        tag.path(d: "M8.1 13l1.4 1.4M10.6 10.5l1.4 1.4M13.1 8l1.4 1.4", fill: "none", stroke: "var(--pv2-contact-guide-icon-cutout)", "stroke-linecap": "round", "stroke-width": "1.6")
      ],
      showroom: [
        tag.path(d: "M3.6 9.1 12 4l8.4 5.1v10.3H3.6Z"),
        tag.path(d: "M7.2 19.4v-6.2h9.6v6.2", fill: "var(--pv2-contact-guide-icon-cutout)"),
        tag.path(d: "M8 9.4h8", fill: "none", stroke: "var(--pv2-contact-guide-icon-cutout)", "stroke-linecap": "round", "stroke-width": "1.7")
      ],
      follow: [
        tag.path(d: "M12 3.2 19.5 6v5.7c0 4.6-3.1 7.9-7.5 9.1-4.4-1.2-7.5-4.5-7.5-9.1V6Z"),
        tag.path(d: "m8.6 12.1 2.1 2.1 5-5", fill: "none", stroke: "var(--pv2-contact-guide-icon-cutout)", "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "1.8")
      ]
    }

    tag.svg(
      safe_join(paths.fetch(key)),
      class: "pv2-contact-visit-guide__icon",
      viewBox: "0 0 24 24",
      fill: "currentColor",
      aria: { hidden: true },
      focusable: "false"
    )
  end
end
