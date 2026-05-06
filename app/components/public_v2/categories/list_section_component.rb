# frozen_string_literal: true

class PublicV2::Categories::ListSectionComponent < ViewComponent::Base
  def initialize(sections:)
    @sections = sections
  end

  private

  attr_reader :sections
end
