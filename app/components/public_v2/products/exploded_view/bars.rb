# frozen_string_literal: true

require_relative "geometry"

module PublicV2
  module Products
    module ExplodedView
      module BarGeometry
        module_function

        def centered_box(center_x:, center_y:, width:, height:, rx:)
          Box.new(
            x: center_x - (width / 2),
            y: center_y - (height / 2),
            width:,
            height:,
            rx:
          )
        end

        def horizontal_center_line(box, inset_x:)
          "M#{box.x + inset_x} #{box.center_y}H#{box.right - inset_x}"
        end

        def vertical_ticks(box, inset_x:, inset_y:)
          "M#{box.x + inset_x} #{box.y + inset_y}V#{box.bottom - inset_y}" \
            "M#{box.right - inset_x} #{box.y + inset_y}V#{box.bottom - inset_y}"
        end

        def threshold_detail_path(box, line_inset_x:, tick_inset_x:, tick_inset_y:)
          horizontal_center_line(box, inset_x: line_inset_x) +
            vertical_ticks(box, inset_x: tick_inset_x, inset_y: tick_inset_y)
        end

        def side_center_points(box, inset_x:)
          [
            Point.new(x: box.x + inset_x, y: box.center_y),
            Point.new(x: box.right - inset_x, y: box.center_y)
          ]
        end

        def translate_points(points, y:)
          points.map { |point| Point.new(x: point.x, y:) }
        end
      end
    end
  end
end
