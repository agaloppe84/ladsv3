# frozen_string_literal: true

require_relative "../blueprint_specs/loader"
require_relative "../blueprint_specs/assembler"
require_relative "../schema"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        class DataBlueprint
          DEFAULT_ACCENT = "#009e96"
          DEFAULT_ACCENT_INK = "#ffffff"
          DEFAULT_ANIMATION_PROFILE = "draw"
          DEFAULT_SHOW_LAYOUT_GRID = true

          attr_reader :spec

          def self.find_for_product(product_page, loader: BlueprintSpecs::Loader.new)
            spec = loader.find_by_product_slug(product_page.product.slug)
            spec && new(spec)
          end

          def initialize(spec)
            @spec = spec
          end

          def render_for?(product_page)
            slug = product_page.product.slug.to_s

            spec.product_slug == slug || spec.product_aliases.include?(slug)
          end

          def parts
            @parts ||= spec.parts.map do |part|
              Part.new(
                id: part.fetch("id"),
                number: part.fetch("number"),
                label: part.fetch("label"),
                measurement: part["measurement"],
                detail: part["detail"]
              )
            end
          end

          def part_order
            @part_order ||= parts.map(&:id)
          end

          def metrics
            @metrics ||= Array(spec.data["metrics"]).map do |metric|
              Metric.new(
                label: metric.fetch("label"),
                value: metric.fetch("value"),
                note: metric["note"]
              )
            end
          end

          def technical_data
            spec.data.fetch("technical_data", {})
          end

          def assembled_blueprint
            @assembled_blueprint ||= BlueprintSpecs::Assembler.new(spec).assemble
          end

          def elements
            assembled_blueprint.elements
          end

          def groups
            assembled_blueprint.groups
          end

          def callouts
            assembled_blueprint.callouts
          end

          def layout_config
            @layout_config ||= begin
              canvas = spec.canvas

              {
                grid_columns: canvas.fetch("columns"),
                grid_rows: canvas.fetch("rows"),
                grid_cell: canvas.fetch("cell", 120),
                grid_margin: canvas.fetch("margin", 60),
                grid_major_every: canvas.fetch("major_every", 4),
                grid_radius: canvas.fetch("radius", 72),
                grid_snap_unit: canvas.fetch("snap_unit", 10)
              }
            end
          end

          def render_options
            @render_options ||= {
              show_layout_grid: spec.render_options.fetch("show_layout_grid", DEFAULT_SHOW_LAYOUT_GRID),
              callout_animation_profile: spec.render_options.fetch("callout_animation_profile", DEFAULT_ANIMATION_PROFILE).to_sym
            }
          end

          def show_layout_grid?
            !!render_options.fetch(:show_layout_grid)
          end

          def callout_animation_profile
            render_options.fetch(:callout_animation_profile)
          end

          def theme
            @theme ||= begin
              accent = spec.render_options.fetch("accent", DEFAULT_ACCENT)

              Theme.new(
                accent:,
                accent_rgb: rgb_values(accent),
                accent_ink: DEFAULT_ACCENT_INK
              )
            end
          end

          def css_style
            theme.css_style
          end

          def eyebrow
            publisher = primary_source["publisher"].to_s
            return "Blueprint JSON" if publisher.empty?

            "Blueprint JSON · #{publisher}"
          end

          def introduction
            "Blueprint charge depuis une spec JSON. Cette couche data-driven sert a supprimer progressivement les fichiers Ruby specifiques aux produits."
          end

          def svg_description
            "Spec JSON du blueprint #{spec.product_slug}."
          end

          def layout
            raise NotImplementedError, "DataBlueprint does not build a drawing layout yet"
          end

          def drawing_component
            raise NotImplementedError, "DataBlueprint does not have a generic drawing component yet"
          end

          private

          def primary_source
            Array(spec.data["sources"]).first || {}
          end

          def rgb_values(hex)
            normalized = hex.to_s.delete_prefix("#")
            return nil unless normalized.match?(/\A[0-9a-fA-F]{6}\z/)

            normalized.scan(/../).map { |pair| pair.to_i(16) }.join(", ")
          end
        end
      end
    end
  end
end
