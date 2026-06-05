# frozen_string_literal: true

require_relative "bars"
require_relative "callouts"
require_relative "fabrics"
require_relative "geometry"
require_relative "housings"
require_relative "layout_primitives"
require_relative "rails"

module PublicV2
  module Products
    module ExplodedView
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
          BarGeometry.centered_box(center_x: 3_900, center_y: top + 85, width: 420, height: 50, rx: 18)
        end

        def detail_path
          "M1260 #{top}V#{bottom}M6540 #{top}V#{bottom}M1430 #{top + 50}V#{top + 136}M6370 #{top + 50}V#{top + 136}"
        end
      end

      DrawingLayout = Struct.new(
        :svg_width,
        :svg_height,
        :grid,
        :groups,
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
          RailGeometry.horizontal_inner_path(body, inset_y: 58)
        end

        def screw_points
          RailGeometry.centered_screw_points(body, side_inset: 680)
        end
      end

      PlisseeProfileLayout = Struct.new(:hit, :left, :right, :marker, :slot_ys, keyword_init: true) do
        def outline_path(box)
          RailGeometry.rounded_box_path(box)
        end

        def inner_path(box)
          RailGeometry.vertical_inner_path(box, inset_x: 74, top: box.y + 90, bottom: box.bottom - 90)
        end
      end

      PlisseeFabricLayout = Struct.new(:hit, :body, :marker, :pleat_xs, :thread_ys, keyword_init: true) do
        def surface_path
          top_points = pleat_points(body.y, 34).each_with_index.map do |point, index|
            command = index.zero? ? "M" : "L"
            "#{command}#{point.x} #{point.y}"
          end
          bottom_points = pleat_points(body.bottom, -34).reverse.map { |point| "L#{point.x} #{point.y}" }

          "#{top_points.join}#{bottom_points.join}Z"
        end

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

        def pleat_points(origin_y, amplitude)
          pleat_xs.each_with_index.map do |x, index|
            Point.new(x:, y: pleat_y(origin_y, amplitude, index))
          end
        end

        def pleat_edge_path(origin_y, amplitude)
          pleat_points(origin_y, amplitude).each_with_index.map do |point, index|
            command = index.zero? ? "M" : "L"

            "#{command}#{point.x} #{point.y}"
          end.join
        end

        def pleat_y(origin_y, amplitude, index)
          origin_y + (index.even? ? 0 : amplitude)
        end
      end
      PlisseeHandleLayout = Struct.new(:hit, :body, :marker, :grip, keyword_init: true)

      PlisseeThresholdLayout = Struct.new(:hit, :body, :marker, keyword_init: true) do
        def detail_path
          BarGeometry.threshold_detail_path(body, line_inset_x: 180, tick_inset_x: 520, tick_inset_y: 24)
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
        :grid,
        :groups,
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
          HousingGeometry.rounded_box_path(body)
        end

        def roll_path
          HousingGeometry.rounded_box_path(roll)
        end
      end

      EnrollableRailPairLayout = Struct.new(:hit, :left, :right, :marker, :slot_ys, keyword_init: true) do
        def outline_path(box)
          RailGeometry.rounded_box_path(box)
        end

        def inner_path(box, bottom_y = box.bottom)
          RailGeometry.vertical_inner_path(box, inset_x: 68, bottom: bottom_y)
        end
      end

      EnrollableFabricLayout = Struct.new(:hit, :body, :marker, :grid, :edge_fastener_ys, :edge_fastener_radius, keyword_init: true) do
        def grid_path
          grid.path
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
          BarGeometry.horizontal_center_line(body, inset_x: 190)
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
        :grid,
        :groups,
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
