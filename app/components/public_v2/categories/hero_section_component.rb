# frozen_string_literal: true

class PublicV2::Categories::HeroSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(category_index_page:, debug: false)
    @category_index_page = category_index_page
    @debug = debug
  end

  private

  attr_reader :category_index_page

  def component_classes
    component_class_names(
      "pv2-public-index__hero pv2-public-index-hero-v2",
      "grid w-full min-w-0 gap-4",
      debug_class
    )
  end

  def proof_variant(index)
    %w[accent contrast plain][index % 3]
  end
end
