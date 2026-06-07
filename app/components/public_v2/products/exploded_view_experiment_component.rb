# frozen_string_literal: true

require_relative "exploded_view/moustiquaire_plissee_drawing_component"
require_relative "exploded_view/moustiquaire_enroulable_verticale_drawing_component"
require_relative "exploded_view/store_vertical_zippe_drawing_component"
require_relative "exploded_view/store_venitien_drawing_component"
require_relative "exploded_view/store_duette_drawing_component"
require_relative "exploded_view/store_rouleau_duo_drawing_component"
require_relative "exploded_view/generic_drawing_component"
require_relative "exploded_view/blueprints/moustiquaire_plissee"
require_relative "exploded_view/blueprints/moustiquaire_enroulable_verticale"
require_relative "exploded_view/blueprints/store_vertical_zippe"
require_relative "exploded_view/blueprints/store_venitien"
require_relative "exploded_view/blueprints/store_duette"
require_relative "exploded_view/blueprints/store_rouleau_duo"
require_relative "exploded_view/blueprints/data_blueprint"

class PublicV2::Products::ExplodedViewExperimentComponent < ViewComponent::Base
  include PublicV2::Debuggable

  BLUEPRINT_SOURCES = %i[legacy json].freeze

  DEFAULT_BLUEPRINTS = [
    PublicV2::Products::ExplodedView::Blueprints::MoustiquairePlissee,
    PublicV2::Products::ExplodedView::Blueprints::MoustiquaireEnroulableVerticale,
    PublicV2::Products::ExplodedView::Blueprints::StoreVenitien,
    PublicV2::Products::ExplodedView::Blueprints::StoreDuette,
    PublicV2::Products::ExplodedView::Blueprints::StoreRouleauDuo,
    PublicV2::Products::ExplodedView::Blueprints::StoreVerticalZippe
  ].freeze

  def initialize(product_page:, debug: false, blueprint: nil, show_layout_grid: nil, blueprint_source: :legacy)
    @product_page = product_page
    @debug = debug
    @blueprint_source = blueprint_source.to_sym
    @blueprint = blueprint || default_blueprint
    @show_layout_grid = show_layout_grid
  end

  def render?
    blueprint&.render_for?(product_page) || false
  end

  private

  attr_reader :product_page, :blueprint, :blueprint_source

  def default_blueprint
    validate_blueprint_source!

    return data_blueprint if blueprint_source == :json

    DEFAULT_BLUEPRINTS.map(&:new).find { |candidate| candidate.render_for?(product_page) } ||
      PublicV2::Products::ExplodedView::Blueprints::StoreVerticalZippe.new
  end

  def data_blueprint
    PublicV2::Products::ExplodedView::Blueprints::DataBlueprint.find_for_product(product_page)
  end

  def validate_blueprint_source!
    return if BLUEPRINT_SOURCES.include?(blueprint_source)

    raise ArgumentError, "Unknown blueprint source: #{blueprint_source.inspect}"
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
