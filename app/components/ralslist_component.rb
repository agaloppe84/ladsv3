# frozen_string_literal: true

class RalslistComponent < ViewComponent::Base

  def initialize(rals)
    @rals = rals
  end

  def render?
    @rals.present?
  end

end
