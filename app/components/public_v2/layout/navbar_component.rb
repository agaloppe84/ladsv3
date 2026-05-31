# frozen_string_literal: true

class PublicV2::Layout::NavbarComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(items: nil, phone: nil, show_mode_toggle: true, active_key: nil, classes: nil, debug: false)
    @items = items
    @show_mode_toggle = show_mode_toggle
    @active_key = active_key
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :show_mode_toggle, :active_key, :classes

  def component_classes
    component_class_names("pv2-public-nav", "pv2-ui-navbar", "w-full min-w-0", debug_class, classes)
  end

  def items
    @items.presence || [
      { key: :home, label: "Accueil", path: helpers.public_v2_home_path },
      { key: :products, label: "Produits", path: helpers.public_v2_categories_path },
      { key: :quote, label: "Devis", path: helpers.public_v2_new_quote_path },
      { key: :contact, label: "Contact", path: helpers.public_v2_contact_path }
    ]
  end

  def active_item?(item)
    return item[:key].to_s == active_key.to_s if active_key.present? && item[:key].present?

    case item[:key].to_s
    when "home"
      current_path == helpers.public_v2_home_path
    when "products"
      current_path == helpers.public_v2_categories_path || current_path.start_with?(product_path_prefix)
    when "quote"
      current_path == helpers.public_v2_new_quote_path
    when "contact"
      current_path == helpers.public_v2_contact_path
    else
      item[:path].present? && helpers.current_page?(item[:path])
    end
  end

  def link_classes(item)
    "is-active" if active_item?(item)
  end

  def link_aria(item)
    active_item?(item) ? { current: "page" } : {}
  end

  def current_path
    helpers.request.path
  end

  def product_path_prefix
    helpers.public_v2_product_path(slug: "__slug__").delete_suffix("__slug__")
  end
end
