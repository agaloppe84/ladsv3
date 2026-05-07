# frozen_string_literal: true

class PublicV2::Content::HeroComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(kicker:, title:, text:, panel_label: nil, panel_value: nil, panel_text: nil, actions: [], classes: nil)
    @kicker = kicker
    @title = title
    @text = text
    @panel_label = panel_label
    @panel_value = panel_value
    @panel_text = panel_text
    @actions = actions
    @classes = classes
  end

  private

  attr_reader :kicker, :title, :text, :panel_label, :panel_value, :panel_text, :actions, :classes

  def component_classes
    [
      "pv2-public-hero",
      "pv2-ui-hero",
      "grid w-full min-w-0 grid-cols-1 gap-4 pl-4 min-[1121px]:grid-cols-[minmax(0,1fr)_minmax(260px,.34fr)] min-[1121px]:items-end",
      debug_class,
      classes
    ].compact.join(" ")
  end

  def render_panel?
    panel_label.present? || panel_value.present? || panel_text.present?
  end
end
