# frozen_string_literal: true

require "securerandom"

class PublicV2::Ui::ShowcaseCarouselComponent < ViewComponent::Base
  include PublicV2::Debuggable

  renders_many :slides, PublicV2::Ui::ShowcaseCarouselSlideComponent

  VARIANTS = %i[default soft].freeze
  SIZES = %i[compact md wide].freeze

  def initialize(items: [], label: nil, title: nil, text: nil, id: nil, aria_label: nil, variant: :default, size: :md, show_pagination: true, classes: nil, data: {}, debug: false)
    @items = Array(items)
    @label = label
    @title = title
    @text = text
    @id = id.presence || "pv2-showcase-carousel-#{SecureRandom.hex(4)}"
    @aria_label = aria_label
    @variant = normalize_option(variant, VARIANTS, :default)
    @size = normalize_option(size, SIZES, :md)
    @show_pagination = show_pagination
    @classes = classes
    @data = data
    @debug = debug
  end

  def render?
    slide_components.any?
  end

  private

  attr_reader :items, :label, :title, :text, :id, :aria_label, :variant, :size, :show_pagination, :classes, :data

  def slide_components
    @slide_components ||= item_slide_components + slides
  end

  def item_slide_components
    items.map do |item|
      PublicV2::Ui::ShowcaseCarouselSlideComponent.new(**item.to_h.symbolize_keys, debug: debug?)
    end
  end

  def component_classes
    component_class_names(
      "pv2-ui-showcase-carousel",
      "pv2-ui-showcase-carousel--#{variant}",
      "pv2-ui-showcase-carousel--#{size}",
      "grid w-full min-w-0 gap-4",
      debug_class,
      classes
    )
  end

  def component_data
    with_debug_data(data).merge(
      controller: [data[:controller], "showcase-carousel"].compact.join(" ")
    )
  end

  def render_header?
    label.present? || title.present? || text.present?
  end

  def render_pagination?
    show_pagination && slide_components.size > 1
  end

  def modal_label
    title.presence || label.presence || "Apercu"
  end

  def track_label
    aria_label.presence || label.presence || title.presence || "Carousel"
  end
end
