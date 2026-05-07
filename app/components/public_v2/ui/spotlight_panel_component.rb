# frozen_string_literal: true

class PublicV2::Ui::SpotlightPanelComponent < ViewComponent::Base
  include PublicV2::Debuggable

  renders_one :actions
  renders_one :footer

  VARIANTS = %i[soft flashy].freeze
  SIZES = %i[md lg].freeze
  TAGS = %i[article aside div section].freeze

  def initialize(kicker: nil, title: nil, text: nil, id: nil, variant: :soft, size: :md, tag: :section, data: {}, classes: nil, debug: false)
    @kicker = kicker
    @title = title
    @text = text
    @id = id
    @variant = normalize_option(variant, VARIANTS, :soft)
    @size = normalize_option(size, SIZES, :md)
    @html_tag = normalize_option(tag, TAGS, :section)
    @data = data
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :kicker, :title, :text, :id, :variant, :size, :html_tag, :data, :classes

  def component_classes
    component_class_names(
      "pv2-ui-spotlight-panel",
      "pv2-ui-spotlight-panel--#{variant}",
      "pv2-ui-spotlight-panel--#{size}",
      "grid w-full min-w-0",
      debug_class,
      classes
    )
  end

  def component_data
    with_debug_data(data)
  end

  def render_header?
    kicker.present? || title.present? || text.present?
  end

  def render_body?
    content.present?
  end
end
