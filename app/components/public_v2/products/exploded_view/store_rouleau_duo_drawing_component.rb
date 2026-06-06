# frozen_string_literal: true

require_relative "base_drawing_component"

module PublicV2
  module Products
    module ExplodedView
      class StoreRouleauDuoDrawingComponent < BaseDrawingComponent
        ROLL_HIGHLIGHT_HEIGHT = 36
        ROLL_HIGHLIGHT_INSET_X = 180
        BOTTOM_BAR_LINE_HEIGHT = 8

        private

        def duo_roll_highlight
          roll = layout.roll.body

          Box.new(
            x: roll.x + ROLL_HIGHLIGHT_INSET_X,
            y: roll.y + 38,
            width: roll.width - (ROLL_HIGHLIGHT_INSET_X * 2),
            height: ROLL_HIGHLIGHT_HEIGHT,
            rx: ROLL_HIGHLIGHT_HEIGHT / 2
          )
        end

        def duo_bottom_bar_line
          bar = layout.bottom_bar.body

          Box.new(
            x: bar.x + 260,
            y: bar.center_y - (BOTTOM_BAR_LINE_HEIGHT / 2),
            width: bar.width - 520,
            height: BOTTOM_BAR_LINE_HEIGHT,
            rx: BOTTOM_BAR_LINE_HEIGHT / 2
          )
        end

        def duo_support_detail_path(support)
          "M#{support.x + 48} #{support.center_y}H#{support.right - 48}" \
            "M#{support.center_x} #{support.y + 38}V#{support.bottom - 38}"
        end
      end
    end
  end
end
