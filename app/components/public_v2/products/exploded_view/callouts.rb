# frozen_string_literal: true

require_relative "geometry"

module PublicV2
  module Products
    module ExplodedView
      module CalloutAnchor
        module_function

        def outside(box, side:, gap:)
          case side.to_sym
          when :right then Point.new(x: box.right + gap, y: box.center_y)
          when :left then Point.new(x: box.x - gap, y: box.center_y)
          when :top then Point.new(x: box.center_x, y: box.y - gap)
          when :bottom then Point.new(x: box.center_x, y: box.bottom + gap)
          else
            raise ArgumentError, "Unknown callout anchor side: #{side}"
          end
        end
      end

      module CalloutRoute
        SIDE_DIRECTIONS = {
          top: :up,
          right: :right,
          bottom: :down,
          left: :left,
          up: :up,
          down: :down
        }.freeze

        PRESETS = {
          up_right: { start_direction: :up, turn_direction: :right },
          up_left: { start_direction: :up, turn_direction: :left },
          down_left: { start_direction: :down, turn_direction: :left },
          down_right: { start_direction: :down, turn_direction: :right },
          left_down: { start_direction: :left, turn_direction: :down },
          left_up: { start_direction: :left, turn_direction: :up },
          right_up: { start_direction: :right, turn_direction: :up },
          right_down: { start_direction: :right, turn_direction: :down },
          right: { start_direction: :right },
          left: { start_direction: :left },
          up: { start_direction: :up },
          down: { start_direction: :down }
        }.freeze

        module_function

        def resolve(route)
          return {} if route.nil?

          PRESETS.fetch(route.to_sym).dup
        end

        def from_sides(anchor_side:, label_side: anchor_side)
          start_direction = direction_for(anchor_side)
          finish_direction = direction_for(label_side)

          return { start_direction: start_direction } if start_direction == finish_direction

          { start_direction:, turn_direction: finish_direction }
        end

        def direction_for(side)
          SIDE_DIRECTIONS.fetch(side.to_sym)
        end
      end

      module CalloutMeasure
        LENGTHS = {
          xs: 140,
          sm: 220,
          md: 310,
          lg: 430,
          xl: 520
        }.freeze

        module_function

        def resolve(value)
          return LENGTHS.fetch(value.to_sym) if value.is_a?(Symbol) || value.is_a?(String)

          value
        end
      end

      module CalloutPlacement
        AUTO = :auto
        ANCHOR_SIDES = %i[top right bottom left].freeze

        PRESETS = {
          top_housing: {
            anchor_side: :top,
            label_side: :auto,
            first_length: 230,
            second_length: :xl
          },
          top_rail: {
            anchor_side: :top,
            label_side: :auto,
            first_length: 250,
            second_length: :lg
          },
          bottom_rail: {
            anchor_side: :bottom,
            label_side: :auto,
            first_length: 230,
            second_length: :lg
          },
          bottom_bar: {
            anchor_side: :bottom,
            label_side: :auto,
            first_length: 160,
            second_length: :lg
          },
          left_vertical_pair: {
            anchor_side: :left,
            label_side: :bottom,
            first_length: 310,
            second_length: 180
          },
          side_fabric: {
            anchor_side: :right,
            first_length: :lg
          },
          center_fabric: {
            anchor_side: :top,
            label_side: :auto,
            first_length: 230,
            second_length: :lg
          },
          right_attached_panel: {
            anchor_side: :top,
            label_side: :left,
            first_length: 230,
            second_length: 330
          },
          right_outside_up: {
            anchor_side: :right,
            label_side: :top,
            first_length: 290,
            second_length: 170
          },
          left_outside: {
            anchor_side: :left,
            first_length: :lg
          }
        }.freeze

        module_function

        def preset_options(placement)
          return {} if placement.nil? || placement.to_sym == AUTO

          PRESETS.fetch(placement.to_sym).dup
        end

        def resolve(marker:, frame:, anchor_side:, label_side:, second_length:)
          resolved_anchor_side = resolve_anchor_side(marker:, frame:, anchor_side:)
          resolved_label_side = resolve_label_side(
            marker:,
            frame:,
            anchor_side: resolved_anchor_side,
            label_side:,
            second_length:
          )

          CalloutRoute.from_sides(anchor_side: resolved_anchor_side, label_side: resolved_label_side)
        end

        def auto?(value)
          value.nil? || value.to_sym == AUTO
        end

        def resolve_anchor_side(marker:, frame:, anchor_side:)
          return anchor_side.to_sym unless auto?(anchor_side)

          {
            left: (marker.x - frame.x).abs,
            right: (frame.right - marker.x).abs,
            top: (marker.y - frame.y).abs,
            bottom: (frame.bottom - marker.y).abs
          }.min_by { |_side, distance| distance }.first
        end

        def resolve_label_side(marker:, frame:, anchor_side:, label_side:, second_length:)
          return anchor_side if second_length.to_f.zero?
          return label_side.to_sym unless auto?(label_side)

          case anchor_side.to_sym
          when :top, :bottom then marker.x <= frame.center_x ? :right : :left
          when :left, :right then marker.y <= frame.center_y ? :down : :up
          else
            raise ArgumentError, "Unknown callout anchor side: #{anchor_side}"
          end
        end
      end

      CalloutLayout = Struct.new(
        :label,
        :marker,
        :start_direction,
        :turn_direction,
        :first_length,
        :second_length,
        :text_offset_x,
        :text_offset_y,
        :text_anchor,
        :dominant_baseline,
        :marker_radius,
        :corner_radius,
        :dot_radius,
        :animation_profile,
        :label_reveal_direction,
        keyword_init: true
      ) do
        DEFAULT_ANIMATION_PROFILE = :draw
        DEFAULT_LABEL_REVEAL_DIRECTION = :left_to_right

        def path
          start_vector = direction_vector(start_direction)
          start = point_from(marker, start_vector, marker_radius || 68)

          return straight_path(start, point_from(start, start_vector, first_length)) unless bent?

          turn_vector = direction_vector(turn_direction)
          bend = [corner_radius || 42, first_length.abs, second_length.abs].min
          corner = point_from(start, start_vector, first_length)
          before_corner = point_from(corner, start_vector, -bend)
          after_corner = point_from(corner, turn_vector, bend)
          finish = point_from(corner, turn_vector, second_length)

          "M#{format_number(start.x)} #{format_number(start.y)}" \
            "L#{format_number(before_corner.x)} #{format_number(before_corner.y)}" \
            "Q#{format_number(corner.x)} #{format_number(corner.y)} #{format_number(after_corner.x)} #{format_number(after_corner.y)}" \
            "L#{format_number(finish.x)} #{format_number(finish.y)}"
        end

        def dot
          start_vector = direction_vector(start_direction)
          start = point_from(marker, start_vector, marker_radius || 68)

          return point_from(start, start_vector, first_length) unless bent?

          turn_vector = direction_vector(turn_direction)
          corner = point_from(start, start_vector, first_length)

          point_from(corner, turn_vector, second_length)
        end

        def text
          Point.new(
            x: dot.x + resolved_text_offset_x,
            y: dot.y + resolved_text_offset_y
          )
        end

        def resolved_text_anchor
          text_anchor || (vertical_final_direction? ? "middle" : horizontal_text_anchor)
        end

        def resolved_dominant_baseline
          dominant_baseline || "middle"
        end

        def bent?
          !turn_direction.nil? && second_length.to_f != 0.0
        end

        def route_kind
          bent? ? :bent : :straight
        end

        def final_direction
          (bent? ? turn_direction : start_direction).to_sym
        end

        def final_axis
          vertical_final_direction? ? :vertical : :horizontal
        end

        def resolved_animation_profile
          (animation_profile || DEFAULT_ANIMATION_PROFILE).to_sym
        end

        def resolved_label_reveal_direction
          (label_reveal_direction || DEFAULT_LABEL_REVEAL_DIRECTION).to_sym
        end

        def css_class
          [
            "pv2-product-exploded__callout",
            "pv2-product-exploded__callout--#{css_token(route_kind)}",
            "pv2-product-exploded__callout--final-#{css_token(final_direction)}",
            "pv2-product-exploded__callout--axis-#{css_token(final_axis)}",
            "pv2-product-exploded__callout--animation-#{css_token(resolved_animation_profile)}"
          ].join(" ")
        end

        def label_reveal_class
          [
            "pv2-product-exploded__callout-label-reveal",
            "pv2-product-exploded__callout-label-reveal--#{css_token(resolved_label_reveal_direction)}"
          ].join(" ")
        end

        private

        def vertical_final_direction?
          %i[up down].include?(final_direction)
        end

        def horizontal_text_anchor
          final_direction == :left ? "end" : "start"
        end

        def resolved_text_offset_x
          return text_offset_x unless text_offset_x.nil?

          vertical_final_direction? ? 0 : horizontal_text_offset_x
        end

        def resolved_text_offset_y
          return text_offset_y unless text_offset_y.nil?

          case final_direction
          when :up then -92
          when :down then 92
          else 0
          end
        end

        def horizontal_text_offset_x
          final_direction == :left ? -76 : 76
        end

        def direction_vector(direction)
          case direction.to_sym
          when :right then Point.new(x: 1, y: 0)
          when :left then Point.new(x: -1, y: 0)
          when :down then Point.new(x: 0, y: 1)
          when :up then Point.new(x: 0, y: -1)
          else
            raise ArgumentError, "Unknown callout direction: #{direction}"
          end
        end

        def point_from(origin, vector, distance)
          Point.new(x: origin.x + (vector.x * distance), y: origin.y + (vector.y * distance))
        end

        def straight_path(start, finish)
          "M#{format_number(start.x)} #{format_number(start.y)}" \
            "L#{format_number(finish.x)} #{format_number(finish.y)}"
        end

        def format_number(value)
          value.to_i == value ? value.to_i : value.round(2)
        end

        def css_token(value)
          value.to_s.tr("_", "-")
        end
      end
    end
  end
end
