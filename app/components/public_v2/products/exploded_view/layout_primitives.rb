# frozen_string_literal: true

require_relative "callouts"
require_relative "geometry"

module PublicV2
  module Products
    module ExplodedView
      CanvasGrid = Struct.new(:frame, :minor_step, :major_step, keyword_init: true) do
        def minor_path
          path_for(step: minor_step)
        end

        def major_path
          path_for(step: major_step)
        end

        private

        def path_for(step:)
          return "" if step.to_f <= 0

          [
            positions(start: frame.x, finish: frame.right, step:).map { |x| "M#{format_number(x)} #{frame.y}V#{frame.bottom}" },
            positions(start: frame.y, finish: frame.bottom, step:).map { |y| "M#{frame.x} #{format_number(y)}H#{frame.right}" }
          ].flatten.join
        end

        def positions(start:, finish:, step:)
          values = []
          value = start + step

          while value < finish
            values << value
            value += step
          end

          values
        end

        def format_number(value)
          value.to_i == value ? value.to_i : value.round(2)
        end
      end

      LayoutGroup = Struct.new(:id, :boxes, keyword_init: true) do
        def bounds
          Box.union(boxes)
        end

        def outside_anchor(side:, gap:)
          CalloutAnchor.outside(bounds, side:, gap:)
        end
      end

      module LayoutRules
        module_function

        def below(reference, gap:, x: reference.x, width: reference.width, height:, rx: nil)
          Box.new(x:, y: reference.bottom + gap, width:, height:, rx:)
        end

        def above(reference, gap:, x: reference.x, width: reference.width, height:, rx: nil)
          Box.new(x:, y: reference.y - gap - height, width:, height:, rx:)
        end

        def right_of(reference, gap:, y: reference.y, width:, height: reference.height, rx: nil)
          Box.new(x: reference.right + gap, y:, width:, height:, rx:)
        end

        def left_of(reference, gap:, y: reference.y, width:, height: reference.height, rx: nil)
          Box.new(x: reference.x - gap - width, y:, width:, height:, rx:)
        end

        def expand(box, inset_x:, inset_y:)
          Box.new(
            x: box.x - inset_x,
            y: box.y - inset_y,
            width: box.width + (inset_x * 2),
            height: box.height + (inset_y * 2),
            rx: box.rx
          )
        end

        def hit_box(box, inset_x:, inset_y:)
          expand(box, inset_x:, inset_y:)
        end

        def mirror_x(box, canvas_width:)
          Box.new(
            x: canvas_width - box.x - box.width,
            y: box.y,
            width: box.width,
            height: box.height,
            rx: box.rx
          )
        end

        def centered_on(center_x:, center_y:, width:, height:, rx: nil)
          Box.new(
            x: center_x - (width / 2),
            y: center_y - (height / 2),
            width:,
            height:,
            rx:
          )
        end

        def inside_bottom_centered(parent, width:, height:, bottom_gap:, rx: nil)
          Box.new(
            x: parent.center_x - (width / 2),
            y: parent.bottom - bottom_gap - height,
            width:,
            height:,
            rx:
          )
        end

        def point_outside(box, side:, gap:)
          CalloutAnchor.outside(box, side:, gap:)
        end

        def centered_point(box, offset_x: 0, offset_y: 0)
          Point.new(x: box.center_x + offset_x, y: box.center_y + offset_y)
        end

        def snap(value, step:, origin: 0)
          origin + (((value - origin).to_f / step).round * step)
        end
      end
    end
  end
end
