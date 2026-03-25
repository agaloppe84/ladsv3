# frozen_string_literal: true

class HomeOpenDayComponent < ViewComponent::Base
  def initialize(categories:)
    @categories = categories
  end

  private

  attr_reader :categories

  def all_category_names
    @all_category_names ||= categories.filter_map do |category|
      category.name.to_s.strip.presence
    end.uniq
  end
end
