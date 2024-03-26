# frozen_string_literal: true

class FlashesComponent < ViewComponent::Base

  def initialize(flashes)
    @flashes = flashes
  end

  def render?
    @flashes.any?
  end

end
