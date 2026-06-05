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
            route_options = CalloutRoute.resolve(route)
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
              first_length:,
              second_length:,
              marker_radius:,
              corner_radius:,
              dot_radius:,
              **route_options.merge(direction_options)
            )
          end
        end
      end
    end
  end
end
