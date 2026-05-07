# frozen_string_literal: true

class PublicV2::Contact::HeroSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(contact_page:, debug: false)
    @contact_page = contact_page
    @debug = debug
  end

  private

  attr_reader :contact_page

  def component_classes
    [
      "pv2-contact-hero pv2-contact-hero-v2",
      "grid w-full min-w-0 gap-4",
      debug_class
    ].compact.join(" ")
  end
end
