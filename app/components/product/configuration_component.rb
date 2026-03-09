# frozen_string_literal: true

class Product::ConfigurationComponent < ViewComponent::Base
  def initialize(product:)
    @product = product
  end

  def render?
    show_specs? || show_motorization? || show_rals?
  end

  private

  attr_reader :product

  def show_specs?
    product.infos.present? || product.options.any?
  end

  def show_motorization?
    product.motorists.any?
  end

  def show_rals?
    product.rals.any?
  end

  def show_canvas_selector?
    product.manufacturers.any? { |manufacturer| manufacturer.name.to_s.downcase.include?("dickson") }
  end

  def initial_tab
    return "specs" if show_specs?
    return "motorization" if show_motorization?
    return "rals" if show_rals?

    "specs"
  end
end
