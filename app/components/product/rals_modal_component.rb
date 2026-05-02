# frozen_string_literal: true

class Product::RalsModalComponent < ViewComponent::Base
  def initialize(rals:, title: "Tous les coloris armature")
    @rals = rals
    @title = title
  end

  def render?
    @rals.size > 12
  end
end
