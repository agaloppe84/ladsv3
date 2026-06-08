# frozen_string_literal: true

require_relative "exploded_view/generic_drawing_component"
require_relative "exploded_view/blueprints/data_blueprint"

class PublicV2::Products::ExplodedViewExperimentComponent < ViewComponent::Base
  include PublicV2::Debuggable

  def initialize(product_page:, debug: false, blueprint: nil, show_layout_grid: nil)
    @product_page = product_page
    @debug = debug
    @blueprint = blueprint || default_blueprint
    @show_layout_grid = show_layout_grid
  end

  def render?
    blueprint&.render_for?(product_page) || false
  end

  private

  attr_reader :product_page, :blueprint

  def default_blueprint
    data_blueprint
  end

  def data_blueprint
    PublicV2::Products::ExplodedView::Blueprints::DataBlueprint.find_for_product(product_page)
  end

  def component_classes
    component_class_names(
      "pv2-product-exploded",
      "grid w-full min-w-0",
      debug_class
    )
  end

  def component_attributes
    attributes = { data: component_data }
    attributes[:style] = blueprint.css_style unless blueprint.css_style.empty?

    tag.attributes(attributes)
  end

  def component_data
    with_debug_data(
      controller: "exploded-view",
      exploded_view_active_id_value: active_part_id
    )
  end

  def parts
    blueprint.parts
  end

  def metrics
    blueprint.metrics
  end

  def exploded_layout
    blueprint.layout
  end

  def drawing_component
    blueprint.drawing_component
  end

  def drawing_component_options
    options = {
      layout: exploded_layout,
      title_id: title_id,
      svg_description_id: svg_description_id,
      active_part_id: active_part_id,
      svg_description: svg_description,
      show_layout_grid: show_layout_grid
    }
    options[:parts] = parts if drawing_component <= PublicV2::Products::ExplodedView::GenericDrawingComponent
    options[:part_ids_by_slot] = blueprint.part_ids_by_slot if drawing_component <= PublicV2::Products::ExplodedView::GenericDrawingComponent

    options
  end

  def eyebrow
    blueprint.eyebrow
  end

  def introduction
    blueprint.introduction
  end

  def svg_description
    blueprint.svg_description
  end

  def show_layout_grid
    return @show_layout_grid unless @show_layout_grid.nil?

    blueprint.show_layout_grid?
  end

  def active_part_id
    parts.first.id
  end

  def title_id
    "pv2-product-exploded-title"
  end

  def svg_description_id
    "pv2-product-exploded-description"
  end

  def panel_id(part)
    "pv2-product-exploded-panel-#{part.id}"
  end
end
