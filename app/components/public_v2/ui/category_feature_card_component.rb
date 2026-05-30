# frozen_string_literal: true

class PublicV2::Ui::CategoryFeatureCardComponent < ViewComponent::Base
  include PublicV2::Debuggable

  SIZES = %i[compact md wide].freeze

  def initialize(eyebrow:, title:, title_suffix:, text:, accent:, path: nil, aria_label: nil, size: :md, classes: nil, data: {}, debug: false)
    @eyebrow = eyebrow
    @title = title
    @title_suffix = title_suffix
    @text = text
    @accent = accent
    @path = path
    @aria_label = aria_label
    @size = normalize_option(size, SIZES, :md)
    @classes = classes
    @data = data
    @debug = debug
  end

  private

  attr_reader :eyebrow, :title, :title_suffix, :text, :accent, :path, :aria_label, :size, :classes, :data

  def component_classes
    component_class_names(
      "pv2-ui-category-feature-card group grid min-w-0",
      "pv2-ui-category-feature-card--#{size}",
      ("pv2-ui-category-feature-card--interactive" if link?),
      debug_class,
      classes
    )
  end

  def component_data
    with_debug_data(data)
  end

  def component_style
    "--pv2-category-card-accent: #{accent_color};"
  end

  def link?
    path.present?
  end

  def link_label
    aria_label.presence || "Voir #{title}"
  end

  def accent_color
    return accent if accent.to_s.match?(/\A#[0-9a-f]{6}\z/i)

    "#ff3d12"
  end
end
