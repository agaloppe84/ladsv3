# frozen_string_literal: true

class PublicV2::Ui::SectionShellComponent < ViewComponent::Base
  include PublicV2::Debuggable

  renders_one :actions

  VARIANTS = %i[default soft outline tinted dark].freeze
  PADDINGS = %i[none sm md lg].freeze

  def initialize(kicker: nil, title: nil, text: nil, id: nil, variant: :default, padding: :md, data: {}, classes: nil, debug: false)
    @kicker = kicker
    @title = title
    @text = text
    @id = id
    @variant = normalize_variant(variant)
    @padding = normalize_padding(padding)
    @data = data
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :kicker, :title, :text, :id, :variant, :padding, :data, :classes

  def component_classes
    [
      "pv2-ui-section-shell",
      "pv2-ui-section-shell--#{variant}",
      "pv2-ui-section-shell--pad-#{padding}",
      "grid w-full min-w-0 gap-4",
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

  def normalize_variant(value)
    candidate = value.to_sym
    VARIANTS.include?(candidate) ? candidate : :default
  end

  def normalize_padding(value)
    candidate = value.to_sym
    PADDINGS.include?(candidate) ? candidate : :md
  end
end
