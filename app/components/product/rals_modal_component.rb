# frozen_string_literal: true

class Product::RalsModalComponent < ViewComponent::Base
  def initialize(rals:)
    @rals = rals
  end

  def render?
    @rals.size > 12
  end
end
