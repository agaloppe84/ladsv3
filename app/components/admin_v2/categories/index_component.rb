# frozen_string_literal: true

class AdminV2::Categories::IndexComponent < ViewComponent::Base
  def initialize(categories:, pagination: nil)
    @categories = categories.to_a
    @pagination = pagination
  end

  private

  attr_reader :categories, :pagination
end
