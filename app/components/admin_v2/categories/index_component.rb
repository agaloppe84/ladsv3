# frozen_string_literal: true

class AdminV2::Categories::IndexComponent < ViewComponent::Base
  def initialize(categories:)
    @categories = categories.to_a
  end

  private

  attr_reader :categories
end
