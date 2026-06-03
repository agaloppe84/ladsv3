# frozen_string_literal: true

class PublicV2::Contact::MapSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(contact_page:, debug: false)
    @contact_page = contact_page
    @debug = debug
  end

  private

  attr_reader :contact_page

  def component_classes
    component_class_names(
      "pv2-contact-map-section",
      "grid w-full min-w-0",
      debug_class
    )
  end
end
