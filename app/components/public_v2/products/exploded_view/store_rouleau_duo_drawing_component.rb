# frozen_string_literal: true

require_relative "base_drawing_component"

module PublicV2
  module Products
    module ExplodedView
      class StoreRouleauDuoDrawingComponent < BaseDrawingComponent
        ROLL_HIGHLIGHT_HEIGHT = 36
        ROLL_HIGHLIGHT_INSET_X = 180

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
      end
    end
  end
end
