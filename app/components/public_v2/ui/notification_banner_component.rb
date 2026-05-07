# frozen_string_literal: true

class PublicV2::Ui::NotificationBannerComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(event: nil, title: nil, message: nil, variant: :info, icon: "i", classes: nil)
    @event = event
    @title = title
    @message = message
    @variant = variant
    @icon = icon
    @classes = classes
  end

  def render?
    title_text.present? || message_text.present?
  end

  private

  attr_reader :event, :title, :message, :variant, :icon, :classes

  def title_text
    title.presence || event&.title
  end

  def message_text
    message.presence || event&.content
  end

  def component_classes
    [
      "pv2-ui-notice",
      "pv2-ui-notice--#{variant}",
      "grid w-full min-w-0 grid-cols-[auto_minmax(0,1fr)] items-center gap-3 p-[0.9rem]",
      debug_class,
      classes
    ].compact.join(" ")
  end
end
