# frozen_string_literal: true

class EventFlashComponent < ViewComponent::Base

  def initialize(event)
    @event = event
  end

  def render?
    @event.present?
  end

end
