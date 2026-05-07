# frozen_string_literal: true

class PublicV2::Categories::ListSectionComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(sections:, category_index_page:)
    @sections = sections
    @category_index_page = category_index_page
  end

  private

  attr_reader :sections, :category_index_page

  def component_classes
    [
      "pv2-public-index__categories",
      "grid w-full min-w-0 gap-5",
      debug_class
    ].compact.join(" ")
  end
end
