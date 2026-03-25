# frozen_string_literal: true

class HomeOpenDayComponent < ViewComponent::Base
  RANGE_DEFINITIONS = [
    { label: "Stores bannes", category_names: ["Stores extérieurs"] },
    { label: "Pergostores", category_names: ["Pergostores"] },
    { label: "Pergolas", category_names: ["Pergolas"] },
    { label: "Moustiquaires", category_names: ["Moustiquaires"] },
    { label: "Stores intérieurs", category_names: ["Stores intérieurs"] }
  ].freeze

  def initialize(categories:)
    @categories = categories
  end

  private

  attr_reader :categories

  def open_day_ranges
    @open_day_ranges ||= RANGE_DEFINITIONS.map do |definition|
      category = find_category(definition[:category_names])
      product = category&.products&.find { |candidate| candidate.images.attached? } || category&.products&.first

      {
        label: definition[:label],
        category: category,
        product: product,
        image: product&.images&.first
      }
    end
  end

  def right_panel_visuals
    @right_panel_visuals ||= [
      { range: range_for("Stores intérieurs"), fallback: "magasin-02.jpeg" },
      { range: range_for("Pergolas"), fallback: "magasin-05.jpeg" }
    ]
  end

  def all_category_names
    @all_category_names ||= categories.filter_map do |category|
      category.name.to_s.strip.presence
    end.uniq
  end

  def range_for(label)
    open_day_ranges.find { |range| range[:label] == label }
  end

  def find_category(names)
    categories.find do |category|
      names.any? { |name| category.name.to_s.casecmp?(name) }
    end
  end
end
