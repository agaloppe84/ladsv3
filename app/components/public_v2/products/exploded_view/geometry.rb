# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      Point = Struct.new(:x, :y, keyword_init: true)

      Box = Struct.new(:x, :y, :width, :height, :rx, keyword_init: true) do
        def self.union(*boxes)
          boxes = boxes.flatten.compact
          raise ArgumentError, "boxes must not be empty" if boxes.empty?

          left = boxes.map(&:x).min
          top = boxes.map(&:y).min
          right = boxes.map(&:right).max
          bottom = boxes.map(&:bottom).max

          new(x: left, y: top, width: right - left, height: bottom - top)
        end

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
