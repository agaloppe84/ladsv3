# frozen_string_literal: true

require_relative "../layouts"
require_relative "element_builder_helpers"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        class Base
          include ElementBuilderHelpers

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
            first_length: nil,
            route: nil,
            anchor_side: nil,
            label_side: nil,
            placement: nil,
            start_direction: nil,
            turn_direction: nil,
            second_length: nil,
            text_offset_x: nil,
            text_offset_y: nil,
            text_anchor: nil,
            dominant_baseline: nil,
            marker_radius: nil,
            corner_radius: nil,
            dot_radius: nil,
            animation_profile: nil,
            label_reveal_direction: nil
          )
            callout_options = CalloutPlacement.preset_options(placement).merge(
              {
                route:,
                anchor_side:,
                label_side:,
                start_direction:,
                turn_direction:,
                first_length:,
                second_length:,
                text_offset_x:,
                text_offset_y:,
                text_anchor:,
                dominant_baseline:,
                marker_radius:,
                corner_radius:,
                dot_radius:,
                animation_profile:,
                label_reveal_direction:
              }.compact
            )
            resolved_first_length = CalloutMeasure.resolve(
              callout_options.fetch(:first_length) do
                raise ArgumentError, "Callout #{part_id.inspect} needs first_length or a placement preset"
              end
            )
            resolved_second_length = CalloutMeasure.resolve(callout_options.fetch(:second_length, 0))
            resolved_marker = layout_point(marker)
            route = callout_options[:route]
            anchor_side = callout_options[:anchor_side]
            label_side = callout_options[:label_side]
            route_options = if route
                              if route.to_sym == :auto
                                auto_callout_route(marker: resolved_marker, anchor_side:, label_side:, second_length: resolved_second_length)
                              else
                                CalloutRoute.resolve(route)
                              end
                            elsif placement&.to_sym == :auto || auto_callout_side?(anchor_side) || auto_callout_side?(label_side)
                              auto_callout_route(marker: resolved_marker, anchor_side:, label_side:, second_length: resolved_second_length)
                            elsif anchor_side
                              CalloutRoute.from_sides(anchor_side:, label_side: label_side || anchor_side)
                            else
                              {}
                            end
            direction_options = {
              start_direction: callout_options[:start_direction],
              turn_direction: callout_options[:turn_direction],
              text_offset_x: callout_options[:text_offset_x],
              text_offset_y: callout_options[:text_offset_y],
              text_anchor: callout_options[:text_anchor],
              dominant_baseline: callout_options[:dominant_baseline]
            }.compact

            CalloutLayout.new(
              label: part_definitions.fetch(part_id).label,
              marker: resolved_marker,
              first_length: resolved_first_length,
              second_length: resolved_second_length,
              marker_radius: callout_options.fetch(:marker_radius, 58),
              corner_radius: callout_options.fetch(:corner_radius, 46),
              dot_radius: callout_options.fetch(:dot_radius, 18),
              animation_profile: callout_options.fetch(:animation_profile, :draw),
              label_reveal_direction: callout_options.fetch(:label_reveal_direction, :left_to_right),
              **route_options.merge(direction_options)
            )
          end

          def auto_callout_route(marker:, anchor_side:, label_side:, second_length:)
            CalloutPlacement.resolve(
              marker:,
              frame: canvas_spec.frame,
              anchor_side:,
              label_side:,
              second_length:
            )
          end

          def auto_callout_side?(side)
            side&.to_sym == :auto
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
            layout_size(LayoutStandards.resolve_gap(value))
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
