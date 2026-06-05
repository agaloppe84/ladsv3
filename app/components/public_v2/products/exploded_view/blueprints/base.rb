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

          def layout_grid
            margin_x = layout_config.fetch(:grid_margin_x, 260)
            margin_y = layout_config.fetch(:grid_margin_y, 180)

            CanvasGrid.new(
              frame: Box.new(
                x: margin_x,
                y: margin_y,
                width: layout_config.fetch(:svg_width) - (margin_x * 2),
                height: layout_config.fetch(:svg_height) - (margin_y * 2),
                rx: layout_config.fetch(:grid_radius, 118)
              ),
              minor_step: layout_config.fetch(:grid_minor_step, 120),
              major_step: layout_config.fetch(:grid_major_step, 480)
            )
          end
        end
      end
    end
  end
end
