# frozen_string_literal: true

class PublicV2::Ui::PanelComponent < ViewComponent::Base
  include PublicV2::Debuggable

  renders_one :actions

  def initialize(kicker: nil, title: nil, text: nil, id: nil, variant: :default, data: {}, classes: nil, padding: :md, debug: false)
    @kicker = kicker
    @title = title
    @text = text
    @id = id
    @variant = variant
    @data = data
    @classes = classes
    @padding = padding
    @debug = debug
  end

  private

  attr_reader :kicker, :title, :text, :id, :variant, :data, :classes, :padding

  def component_classes
    [
      "pv2-ui-panel",
      "pv2-ui-panel--#{variant}",
      "pv2-ui-panel--pad-#{padding}",
      "grid w-full min-w-0 gap-[0.78rem]",
      debug_class,
      classes
    ].compact.join(" ")
  end

  def component_data
    with_debug_data(data)
  end

  def render_header?
    kicker.present? || title.present? || text.present? || actions?
  end
end
