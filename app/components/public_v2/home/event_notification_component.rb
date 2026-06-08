# frozen_string_literal: true

class PublicV2::Home::EventNotificationComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(event:, debug: false)
    @event = event
    @debug = debug
  end

  def render?
    event.present?
  end

  private

  attr_reader :event

  def title_text
    event.title.to_s.squish.presence || "Information importante"
  end

  def message_text
    event.content.to_s.squish
  end

  def component_classes
    component_class_names(
      "pv2-home-event-notification",
      "grid w-full min-w-0",
      debug_class
    )
  end
end
