# frozen_string_literal: true

require_relative "base_drawing_component"

module PublicV2
  module Products
    module ExplodedView
      class StoreDuetteDrawingComponent < BaseDrawingComponent
        DUETTE_SLOT_HEIGHT = 80
        DUETTE_SLOT_RADIUS = 22
        DUETTE_CORD_TAB_WIDTH = 34
        DUETTE_CORD_TAB_HEIGHT = 68
        DUETTE_CORD_TAB_RADIUS = 12
        DUETTE_INTERMEDIATE_LINE_HEIGHT = 8
        DUETTE_INTERMEDIATE_POINT_RADIUS = 18
        DUETTE_INTERMEDIATE_HANDLE_WIDTH = 360
        DUETTE_INTERMEDIATE_HANDLE_HEIGHT = 48
        DUETTE_INTERMEDIATE_HANDLE_RADIUS = 20

        private

        def duette_top_rail_slot
          Box.new(
            x: layout.fabric.body.x,
            y: layout.top_rail.body.bottom,
            width: layout.fabric.body.width,
            height: DUETTE_SLOT_HEIGHT,
            rx: DUETTE_SLOT_RADIUS
          )
        end

        def duette_bottom_rail_slot
          Box.new(
            x: layout.fabric.body.x,
            y: layout.bottom_rail.body.y - DUETTE_SLOT_HEIGHT,
            width: layout.fabric.body.width,
            height: DUETTE_SLOT_HEIGHT,
            rx: DUETTE_SLOT_RADIUS
          )
        end

        def duette_bottom_rounded_rect_path(box, radius:)
          radius = [radius, box.width / 2, box.height].min

          [
            "M#{box.x} #{box.y}",
            "H#{box.right}",
            "V#{box.bottom - radius}",
            "Q#{box.right} #{box.bottom} #{box.right - radius} #{box.bottom}",
            "H#{box.x + radius}",
            "Q#{box.x} #{box.bottom} #{box.x} #{box.bottom - radius}",
            "V#{box.y}",
            "Z"
          ].join
        end

        def duette_cord_tabs(slot, direction:)
          [layout.cords.left_x, layout.cords.right_x].map do |x|
            y = direction.to_sym == :up ? slot.y - DUETTE_CORD_TAB_HEIGHT + 8 : slot.bottom - 8

            Box.new(
              x: x - (DUETTE_CORD_TAB_WIDTH / 2),
              y:,
              width: DUETTE_CORD_TAB_WIDTH,
              height: DUETTE_CORD_TAB_HEIGHT,
              rx: DUETTE_CORD_TAB_RADIUS
            )
          end
        end

        def duette_intermediate_line
          rail = layout.intermediate_rail.body

          Box.new(
            x: rail.x + 230,
            y: rail.center_y - (DUETTE_INTERMEDIATE_LINE_HEIGHT / 2),
            width: rail.width - 460,
            height: DUETTE_INTERMEDIATE_LINE_HEIGHT,
            rx: DUETTE_INTERMEDIATE_LINE_HEIGHT / 2
          )
        end

        def duette_intermediate_handle
          rail = layout.intermediate_rail.body

          Box.new(
            x: rail.center_x - (DUETTE_INTERMEDIATE_HANDLE_WIDTH / 2),
            y: rail.center_y - (DUETTE_INTERMEDIATE_HANDLE_HEIGHT / 2),
            width: DUETTE_INTERMEDIATE_HANDLE_WIDTH,
            height: DUETTE_INTERMEDIATE_HANDLE_HEIGHT,
            rx: DUETTE_INTERMEDIATE_HANDLE_RADIUS
          )
        end

        def duette_intermediate_cord_points
          rail = layout.intermediate_rail.body

          [layout.cords.left_x, layout.cords.right_x].map do |x|
            Point.new(x:, y: rail.center_y)
          end
        end
      end
    end
  end
end
