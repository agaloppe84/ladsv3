# frozen_string_literal: true

class PublicV2::Ui::NotificationBannerComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[info success warning danger].freeze

  def initialize(event: nil, title: nil, message: nil, variant: :info, icon: "i", classes: nil, debug: false)
    @event = event
    @title = title
    @message = message
    @variant = normalize_option(variant, VARIANTS, :info)
    @icon = icon
    @classes = classes
    @debug = debug
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
    component_class_names(
      "pv2-ui-notice",
      "pv2-ui-notice--#{variant}",
      "grid w-full min-w-0 grid-cols-[auto_minmax(0,1fr)] items-center gap-3 p-[0.9rem]",
      debug_class,
      classes
    )
  end
end
