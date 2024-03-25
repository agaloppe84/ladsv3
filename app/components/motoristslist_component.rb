# frozen_string_literal: true

class MotoristslistComponent < ViewComponent::Base

  def initialize(motorists)
    @motorists = motorists
  end

  def render?
    @motorists.any?
  end

end
