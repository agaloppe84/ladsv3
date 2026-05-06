# frozen_string_literal: true

class PublicV2::Categories::HeroSectionComponent < ViewComponent::Base
  def initialize(category_index_page:)
    @category_index_page = category_index_page
  end

  private

  attr_reader :category_index_page
end
