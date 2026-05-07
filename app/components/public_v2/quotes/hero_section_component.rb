# frozen_string_literal: true

class PublicV2::Quotes::HeroSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(quote_page:, debug: false)
    @quote_page = quote_page
    @debug = debug
  end

  private

  attr_reader :quote_page

  def component_classes
    [
      "pv2-quote-hero pv2-quote-hero-v2",
      "grid w-full min-w-0 gap-4",
      debug_class
    ].compact.join(" ")
  end
end
