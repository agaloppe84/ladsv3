# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      Point = Struct.new(:x, :y, keyword_init: true)

      Box = Struct.new(:x, :y, :width, :height, :rx, keyword_init: true) do
        def right
          x + width
        end

        def bottom
          y + height
        end

        def center_x
          x + (width / 2)
        end

        def center_y
          y + (height / 2)
        end
      end
    end
  end
end
