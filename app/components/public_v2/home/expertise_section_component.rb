# frozen_string_literal: true

class PublicV2::Home::ExpertiseSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(home_page:, debug: false)
    @home_page = home_page
    @debug = debug
  end

  private

  attr_reader :home_page

  def component_classes
    [
      "pv2-home-section pv2-home-warm__matrix",
      "grid w-full min-w-0 gap-5",
      debug_class
    ].compact.join(" ")
  end
end
