# frozen_string_literal: true

class PublicV2::Ui::PanelComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default accent soft rail elevated outline inset flashy].freeze
  PADDINGS = %i[sm md lg].freeze

  renders_one :actions

  def initialize(kicker: nil, title: nil, text: nil, id: nil, variant: :default, data: {}, classes: nil, padding: :md, debug: false)
    @kicker = kicker
    @title = title
    @text = text
    @id = id
    @variant = normalize_option(variant, VARIANTS, :default)
    @data = data
    @classes = classes
    @padding = normalize_option(padding, PADDINGS, :md)
    @debug = debug
  end

  private

  attr_reader :kicker, :title, :text, :id, :variant, :data, :classes, :padding

  def component_classes
    component_class_names(
      "pv2-ui-panel",
      "pv2-ui-panel--#{variant}",
      "pv2-ui-panel--pad-#{padding}",
      "grid w-full min-w-0 gap-[0.78rem]",
      debug_class,
      classes
    )
  end

  def component_data
    with_debug_data(data)
  end

  def render_header?
    kicker.present? || title.present? || text.present? || actions?
  end
end
