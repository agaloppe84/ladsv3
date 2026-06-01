# frozen_string_literal: true

class PublicV2::Products::OptionListComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[rail chips focus blueprint accordion list].freeze

  def initialize(items:, variant: :rail, kicker: nil, title: nil, text: nil, classes: nil, debug: false)
    @items = items
    @variant = normalize_option(variant, VARIANTS, :rail)
    @kicker = kicker
    @title = title
    @text = text
    @classes = classes
    @debug = debug
  end

  def render?
    option_items.any?
  end

  private

  attr_reader :items, :variant, :kicker, :title, :text, :classes

  def component_classes
    component_class_names(
      "pv2-product-options-list",
      "pv2-product-options-list--#{variant}",
      "grid w-full min-w-0 gap-3",
      debug_class,
      classes
    )
  end

  def component_data
    data = {}
    data[:controller] = "option-list" if interactive?
    data[:option_list_initial_index_value] = 0 if interactive?
    with_debug_data(data)
  end

  def interactive?
    variant.in?(%i[focus accordion])
  end

  def render_header?
    kicker.present? || title.present? || text.present?
  end

  def option_items
    @option_items ||= Array(items).filter_map.with_index do |item, index|
      content = option_content(item)
      next if content.blank?

      {
        number: option_number(item, index),
        content: content
      }
    end
  end

  def option_content(item)
    if item.respond_to?(:content)
      item.content
    elsif item.is_a?(Hash)
      item[:content] || item["content"]
    else
      item
    end.to_s.squish
  end

  def option_number(item, index)
    explicit_number =
      if item.respond_to?(:number)
        item.number
      elsif item.is_a?(Hash)
        item[:number] || item["number"]
      end

    explicit_number.to_s.presence || Kernel.format("%02d", index + 1)
  end

  def active_panel?(index)
    index.zero?
  end
end
