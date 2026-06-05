# frozen_string_literal: true

require_relative "geometry"

module PublicV2
  module Products
    module ExplodedView
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
        keyword_init: true
      ) do
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

        private

        def bent?
          !turn_direction.nil? && second_length.to_f != 0.0
        end

        def final_direction
          (bent? ? turn_direction : start_direction).to_sym
        end

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
      end

      MotorLayout = Struct.new(:hit, :tube, :tube_cap_width, :head, :marker, keyword_init: true) do
        def tube_cap_path
          cap_right = tube.x + tube_cap_width

          "M#{tube.x + tube.rx} #{tube.y}H#{cap_right}V#{tube.bottom}H#{tube.x + tube.rx}" \
            "Q#{tube.x} #{tube.bottom} #{tube.x} #{tube.bottom - tube.rx}" \
            "V#{tube.y + tube.rx}Q#{tube.x} #{tube.y} #{tube.x + tube.rx} #{tube.y}Z"
        end

        def tube_path
          "M#{tube.x + tube.rx} #{tube.y}H#{tube.right}V#{tube.bottom}H#{tube.x + tube.rx}" \
            "Q#{tube.x} #{tube.bottom} #{tube.x} #{tube.bottom - tube.rx}" \
            "V#{tube.y + tube.rx}Q#{tube.x} #{tube.y} #{tube.x + tube.rx} #{tube.y}Z"
        end

        def detail_path
          "M#{tube.x + tube_cap_width} #{tube.y}V#{tube.bottom}"
        end

        def head_path
          right_radius = head.rx

          "M#{head.x} #{head.y}H#{head.right - right_radius}" \
            "Q#{head.right} #{head.y} #{head.right} #{head.y + right_radius}" \
            "V#{head.bottom - right_radius}Q#{head.right} #{head.bottom} #{head.right - right_radius} #{head.bottom}" \
            "H#{head.x}V#{head.y}Z"
        end

        def large_hole
          Point.new(x: head.x + 175, y: head.center_y)
        end

        def small_holes
          [
            Point.new(x: head.x + 50, y: head.center_y - 44),
            Point.new(x: head.x + 50, y: head.center_y + 44)
          ]
        end
      end

      CoffreLayout = Struct.new(:hit, :body, :marker, :hole_pairs, keyword_init: true) do
        def holes
          hole_pairs.flatten
        end
      end

      FabricLayout = Struct.new(:hit, :body, :marker, :line_ys, :tick_ys, keyword_init: true)

      CoulisseLayout = Struct.new(:top, :bottom, :hit, :marker, keyword_init: true) do
        def outline_path
          "M608 #{top}H710Q748 #{top} 748 #{top + 38}V#{bottom - 38}" \
            "Q748 #{bottom} 710 #{bottom}H608Q570 #{bottom} 570 #{bottom - 38}" \
            "V#{top + 38}Q570 #{top} 608 #{top}Z"
        end

        def profile_path
          "M606 #{top}V#{bottom}M712 #{top}V#{bottom}"
        end
      end

      BarreLayout = Struct.new(:hit, :top, :height, :marker, keyword_init: true) do
        def bottom
          top + height
        end

        def outline_path
          "M1165 #{top}H6635Q6685 #{top} 6710 #{top + 48}" \
            "L6740 #{top + 108}Q6762 #{top + 154} 6718 #{bottom}" \
            "H1082Q1038 #{bottom} 1060 #{top + 108}" \
            "L1090 #{top + 48}Q1115 #{top} 1165 #{top}Z"
        end

        def handle
          Box.new(x: 3685, y: top + 58, width: 430, height: 48, rx: 18)
        end

        def detail_path
          "M1260 #{top}V#{bottom}M6540 #{top}V#{bottom}M1430 #{top + 50}V#{top + 136}M6370 #{top + 50}V#{top + 136}"
        end
      end

      DrawingLayout = Struct.new(
        :svg_width,
        :svg_height,
        :support_marker,
        :motor,
        :coffre,
        :fabric,
        :coulisse,
        :barre,
        :callouts,
        keyword_init: true
      ) do
        def callout(part_id)
          callouts[part_id.to_s]
        end
      end

      PlisseeRailLayout = Struct.new(:hit, :body, :marker, keyword_init: true) do
        def inner_path
          inset_y = 58

          "M#{body.x} #{body.y + inset_y}H#{body.right}" \
            "M#{body.x} #{body.bottom - inset_y}H#{body.right}"
        end

        def screw_points
          [
            Point.new(x: body.x + 680, y: body.center_y),
            Point.new(x: body.center_x, y: body.center_y),
            Point.new(x: body.right - 680, y: body.center_y)
          ]
        end
      end

      PlisseeProfileLayout = Struct.new(:hit, :left, :right, :marker, :slot_ys, keyword_init: true) do
        def outline_path(box)
          "M#{box.x + box.rx} #{box.y}H#{box.right - box.rx}" \
            "Q#{box.right} #{box.y} #{box.right} #{box.y + box.rx}" \
            "V#{box.bottom - box.rx}Q#{box.right} #{box.bottom} #{box.right - box.rx} #{box.bottom}" \
            "H#{box.x + box.rx}Q#{box.x} #{box.bottom} #{box.x} #{box.bottom - box.rx}" \
            "V#{box.y + box.rx}Q#{box.x} #{box.y} #{box.x + box.rx} #{box.y}Z"
        end

        def inner_path(box)
          "M#{box.x + 74} #{box.y + 90}V#{box.bottom - 90}" \
            "M#{box.right - 74} #{box.y + 90}V#{box.bottom - 90}"
        end
      end

      PlisseeFabricLayout = Struct.new(:hit, :body, :marker, :pleat_xs, :thread_ys, keyword_init: true) do
        def top_pleat_path
          pleat_edge_path(body.y, 34)
        end

        def bottom_pleat_path
          pleat_edge_path(body.bottom, -34)
        end

        def side_path
          "M#{body.x} #{body.y}V#{body.bottom}M#{body.right} #{body.y}V#{body.bottom}"
        end

        def top_pleat_y(index)
          pleat_y(body.y, 34, index)
        end

        def bottom_pleat_y(index)
          pleat_y(body.bottom, -34, index)
        end

        private

        def pleat_edge_path(origin_y, amplitude)
          pleat_xs.each_with_index.map do |x, index|
            command = index.zero? ? "M" : "L"
            y = pleat_y(origin_y, amplitude, index)

            "#{command}#{x} #{y}"
          end.join
        end

        def pleat_y(origin_y, amplitude, index)
          origin_y + (index.even? ? 0 : amplitude)
        end
      end
      PlisseeHandleLayout = Struct.new(:hit, :body, :marker, :grip, keyword_init: true)

      PlisseeThresholdLayout = Struct.new(:hit, :body, :marker, keyword_init: true) do
        def detail_path
          "M#{body.x + 180} #{body.center_y}H#{body.right - 180}" \
            "M#{body.x + 520} #{body.y + 24}V#{body.bottom - 24}" \
            "M#{body.right - 520} #{body.y + 24}V#{body.bottom - 24}"
        end
      end

      PlisseeLockLayout = Struct.new(:hit, :marker, :catches, :radius, keyword_init: true) do
        def catch_path(point)
          "M#{point.x} #{point.y - radius}" \
            "A#{radius} #{radius} 0 0 1 #{point.x} #{point.y + radius}" \
            "L#{point.x} #{point.y - radius}Z"
        end

        def echo_paths(point)
          [radius + 34, radius + 74, radius + 114].map do |echo_radius|
            "M#{point.x} #{point.y - echo_radius}" \
              "A#{echo_radius} #{echo_radius} 0 0 1 #{point.x} #{point.y + echo_radius}"
          end
        end
      end

      PlisseeDrawingLayout = Struct.new(
        :svg_width,
        :svg_height,
        :guide,
        :profiles,
        :fabric,
        :handle,
        :threshold,
        :lock,
        :callouts,
        keyword_init: true
      ) do
        def callout(part_id)
          callouts[part_id.to_s]
        end
      end

      EnrollableCassetteLayout = Struct.new(:hit, :body, :roll, :marker, :screw_points, keyword_init: true) do
        def outline_path
          rounded_box_path(body)
        end

        def roll_path
          rounded_box_path(roll)
        end

        private

        def rounded_box_path(box)
          "M#{box.x + box.rx} #{box.y}H#{box.right - box.rx}" \
            "Q#{box.right} #{box.y} #{box.right} #{box.y + box.rx}" \
            "V#{box.bottom - box.rx}Q#{box.right} #{box.bottom} #{box.right - box.rx} #{box.bottom}" \
            "H#{box.x + box.rx}Q#{box.x} #{box.bottom} #{box.x} #{box.bottom - box.rx}" \
            "V#{box.y + box.rx}Q#{box.x} #{box.y} #{box.x + box.rx} #{box.y}Z"
        end
      end

      EnrollableRailPairLayout = Struct.new(:hit, :left, :right, :marker, :slot_ys, keyword_init: true) do
        def outline_path(box)
          "M#{box.x + box.rx} #{box.y}H#{box.right - box.rx}" \
            "Q#{box.right} #{box.y} #{box.right} #{box.y + box.rx}" \
            "V#{box.bottom - box.rx}Q#{box.right} #{box.bottom} #{box.right - box.rx} #{box.bottom}" \
            "H#{box.x + box.rx}Q#{box.x} #{box.bottom} #{box.x} #{box.bottom - box.rx}" \
            "V#{box.y + box.rx}Q#{box.x} #{box.y} #{box.x + box.rx} #{box.y}Z"
        end

        def inner_path(box, bottom_y = box.bottom)
          "M#{box.x + 68} #{box.y}V#{bottom_y}" \
            "M#{box.right - 68} #{box.y}V#{bottom_y}"
        end
      end

      EnrollableFabricLayout = Struct.new(:hit, :body, :marker, :vertical_lines, :horizontal_lines, :edge_fastener_ys, :edge_fastener_radius, keyword_init: true) do
        def grid_path
          [
            vertical_lines.map { |x| "M#{x} #{body.y}V#{body.bottom}" },
            horizontal_lines.map { |y| "M#{body.x} #{y}H#{body.right}" }
          ].flatten.join
        end

        def left_fastener_path(y)
          "M#{body.x} #{y - edge_fastener_radius}" \
            "A#{edge_fastener_radius} #{edge_fastener_radius} 0 0 1 #{body.x} #{y + edge_fastener_radius}" \
            "L#{body.x} #{y - edge_fastener_radius}Z"
        end

        def right_fastener_path(y)
          "M#{body.right} #{y - edge_fastener_radius}" \
            "A#{edge_fastener_radius} #{edge_fastener_radius} 0 0 0 #{body.right} #{y + edge_fastener_radius}" \
            "L#{body.right} #{y - edge_fastener_radius}Z"
        end
      end

      EnrollableBottomBarLayout = Struct.new(:hit, :body, :marker, :grip, :magnet_points, keyword_init: true) do
        def detail_path
          "M#{body.x + 190} #{body.center_y}H#{body.right - 190}"
        end
      end

      EnrollableLockLayout = Struct.new(:hit, :marker, :receiver_points, :radius, keyword_init: true) do
        def receiver_path(point)
          "M#{point.x - radius} #{point.y}A#{radius} #{radius} 0 0 0 #{point.x + radius} #{point.y}" \
            "M#{point.x - (radius + 42)} #{point.y + 58}H#{point.x + radius + 42}"
        end
      end

      EnrollableBavetteLayout = Struct.new(:hit, :left, :right, :marker, keyword_init: true)

      EnrollableDrawingLayout = Struct.new(
        :svg_width,
        :svg_height,
        :cassette,
        :rails,
        :fabric,
        :bottom_bar,
        :lock,
        :bavettes,
        :callouts,
        keyword_init: true
      ) do
        def callout(part_id)
          callouts[part_id.to_s]
        end
      end
    end
  end
end
