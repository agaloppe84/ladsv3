# frozen_string_literal: true

class PublicV2::Categories::SummarySectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(category_index_page:, debug: false)
    @category_index_page = category_index_page
    @debug = debug
  end

  private

  attr_reader :category_index_page

  def component_classes
    component_class_names(
      "pv2-public-index__summary",
      "grid w-full min-w-0 gap-4 min-[1121px]:grid-cols-[minmax(0,0.65fr)_minmax(0,0.55fr)]",
      debug_class
    )
  end
end
