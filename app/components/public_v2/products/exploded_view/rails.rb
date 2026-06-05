# frozen_string_literal: true

require_relative "geometry"

module PublicV2
  module Products
    module ExplodedView
      module RailGeometry
        module_function

        def rounded_box_path(box)
          "M#{box.x + box.rx} #{box.y}H#{box.right - box.rx}" \
            "Q#{box.right} #{box.y} #{box.right} #{box.y + box.rx}" \
            "V#{box.bottom - box.rx}Q#{box.right} #{box.bottom} #{box.right - box.rx} #{box.bottom}" \
            "H#{box.x + box.rx}Q#{box.x} #{box.bottom} #{box.x} #{box.bottom - box.rx}" \
            "V#{box.y + box.rx}Q#{box.x} #{box.y} #{box.x + box.rx} #{box.y}Z"
        end

        def horizontal_inner_path(box, inset_y:)
          "M#{box.x} #{box.y + inset_y}H#{box.right}" \
            "M#{box.x} #{box.bottom - inset_y}H#{box.right}"
        end

        def vertical_inner_path(box, inset_x:, top: box.y, bottom: box.bottom)
          "M#{box.x + inset_x} #{top}V#{bottom}" \
            "M#{box.right - inset_x} #{top}V#{bottom}"
        end

        def distributed_positions(start:, finish:, count:)
          raise ArgumentError, "count must be greater than 0" if count.to_i < 1

          step = (finish - start) / (count + 1)

          Array.new(count) { |index| start + step + (index * step) }
        end

        def centered_screw_points(box, side_inset:)
          [
            Point.new(x: box.x + side_inset, y: box.center_y),
            Point.new(x: box.center_x, y: box.center_y),
            Point.new(x: box.right - side_inset, y: box.center_y)
          ]
        end
      end
    end
  end
end
