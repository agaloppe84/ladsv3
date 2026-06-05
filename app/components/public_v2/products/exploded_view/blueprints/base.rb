# frozen_string_literal: true

require_relative "../layouts"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        class Base
          attr_reader :layout_config, :part_order, :theme

          def initialize(layout_overrides: {}, part_order: self.class::DEFAULT_PART_ORDER, theme: self.class::DEFAULT_THEME)
            @layout_config = self.class::DEFAULT_LAYOUT.merge(layout_overrides)
            @part_order = part_order.map(&:to_s)
            @theme = theme
          end

          def parts
            part_order.filter_map { |part_id| part_definitions[part_id] }
          end

          def metrics
            self.class::METRICS
          end

          def technical_data
            self.class::TECHNICAL_DATA
          end

          def layout
            @layout ||= build_layout
          end

          def css_style
            [
              theme.css_style,
              "--pv2-exploded-svg-ratio: #{layout.svg_width} / #{layout.svg_height}"
            ].reject(&:empty?).join("; ")
          end

          private

          def part_definitions
            self.class::PART_DEFINITIONS
          end

          def callout(
            part_id,
            marker:,
            first_length:,
            route: nil,
            anchor_side: nil,
            label_side: nil,
            start_direction: nil,
            turn_direction: nil,
            second_length: 0,
            text_offset_x: nil,
            text_offset_y: nil,
            text_anchor: nil,
            dominant_baseline: nil,
            marker_radius: 58,
            corner_radius: 46,
            dot_radius: 18
          )
            route_options = if route
                              CalloutRoute.resolve(route)
                            elsif anchor_side
                              CalloutRoute.from_sides(anchor_side:, label_side: label_side || anchor_side)
                            else
                              {}
                            end
            direction_options = {
              start_direction:,
              turn_direction:,
              text_offset_x:,
              text_offset_y:,
              text_anchor:,
              dominant_baseline:
            }.compact

            CalloutLayout.new(
              label: part_definitions.fetch(part_id).label,
              marker:,
              first_length: CalloutMeasure.resolve(first_length),
              second_length: CalloutMeasure.resolve(second_length),
              marker_radius:,
              corner_radius:,
              dot_radius:,
              **route_options.merge(direction_options)
            )
          end

          def canvas_spec
            @canvas_spec ||= begin
              cell = layout_config.fetch(:grid_cell, CanvasSpec::DEFAULT_CELL)
              margin = layout_config.fetch(:grid_margin, CanvasSpec::DEFAULT_MARGIN)
              columns = layout_config.fetch(:grid_columns) do
                (layout_config.fetch(:svg_width) - (margin * 2)) / cell
              end
              rows = layout_config.fetch(:grid_rows) do
                (layout_config.fetch(:svg_height) - (margin * 2)) / cell
              end

              CanvasSpec.new(
                columns:,
                rows:,
                cell:,
                margin:,
                major_every: layout_config.fetch(:grid_major_every, CanvasSpec::DEFAULT_MAJOR_EVERY),
                radius: layout_config.fetch(:grid_radius, CanvasSpec::DEFAULT_RADIUS),
                snap_unit: layout_config.fetch(:grid_snap_unit, CanvasSpec::DEFAULT_SNAP_UNIT)
              )
            end
          end

          def layout_grid
            canvas_spec.grid
          end

          def layout_box(box, preserve_size: false)
            canvas_spec.snap_box(box, preserve_size:)
          end

          def layout_size(value)
            canvas_spec.snap_length(value)
          end

          def layout_gap(value)
            layout_size(value)
          end

          def layout_y(value)
            canvas_spec.snap_y(value)
          end

          def layout_point(point)
            canvas_spec.snap_point(point)
          end

          def layout_anchor(box, side:, gap:)
            layout_point(CalloutAnchor.outside(box, side:, gap:))
          end
        end
      end
    end
  end
end
