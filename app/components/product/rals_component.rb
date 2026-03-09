# frozen_string_literal: true

class Product::RalsComponent < ViewComponent::Base
  def initialize(rals:)
    @rals = rals
  end

  def render?
    @rals.any?
  end
end
