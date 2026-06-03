# frozen_string_literal: true

class PublicV2::Contact::MapCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(contact_page:, debug: false)
    @contact_page = contact_page
    @debug = debug
  end

  private

  attr_reader :contact_page

  def contact_info
    contact_page.contact_info
  end

  def city_label
    contact_info.city.to_s.sub(/\A\d+\s*/, "")
  end

  def component_classes
    component_class_names(
      "pv2-contact-map-card",
      debug_class
    )
  end

  def svg_id(name)
    "#{component_id}-#{name.to_s.dasherize}"
  end

  def svg_url(name)
    "url(##{svg_id(name)})"
  end

  def component_id
    @component_id ||= "pv2-contact-map-#{object_id}"
  end
end
