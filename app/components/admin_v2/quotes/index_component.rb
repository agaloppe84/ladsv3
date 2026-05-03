# frozen_string_literal: true

class AdminV2::Quotes::IndexComponent < ViewComponent::Base
  def initialize(quotes:)
    @quotes = quotes
  end

  private

  attr_reader :quotes
end
