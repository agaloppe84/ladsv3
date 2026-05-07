# frozen_string_literal: true

class PublicV2::Categories::CtaSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(category_index_page:, debug: false)
    @category_index_page = category_index_page
    @debug = debug
  end

  private

  attr_reader :category_index_page

  def component_classes
    component_class_names(
      "pv2-public-index__cta",
      "grid w-full min-w-0 gap-3 min-[1121px]:grid-cols-[minmax(0,0.7fr)_minmax(280px,0.42fr)]",
      debug_class
    )
  end
end
