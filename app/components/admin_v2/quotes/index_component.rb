# frozen_string_literal: true

class AdminV2::Quotes::IndexComponent < ViewComponent::Base
  def initialize(quotes:, pagination: nil)
    @quotes = quotes
    @pagination = pagination
  end

  private

  attr_reader :quotes, :pagination
end
