# frozen_string_literal: true

class PublicV2::Categories::CategorySectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(section:, debug: false)
    @section = section
    @debug = debug
  end

  private

  attr_reader :section

  def component_classes
    component_class_names(
      "pv2-category-catalog-section",
      "pv2-category-catalog-section--#{section.accent_role}",
      "grid w-full min-w-0",
      debug_class
    )
  end
end
