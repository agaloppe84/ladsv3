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
    @variant = normalize_option(variant, VARIANTS, :default)
    @padding = normalize_option(padding, PADDINGS, :md)
    @data = data
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :kicker, :title, :text, :id, :variant, :padding, :data, :classes

  def component_classes
    component_class_names(
      "pv2-ui-section-shell",
      "pv2-ui-section-shell--#{variant}",
      "pv2-ui-section-shell--pad-#{padding}",
      "grid w-full min-w-0 gap-4",
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
