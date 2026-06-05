# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Motors
            private

            def tubular_motor_element(
              drawing_right:,
              y:,
              head_preset:,
              tube_preset:,
              tube_x:,
              tube_cap_width:,
              marker_gap:,
              hit_x:,
              hit_y_offset:,
              hit_width:,
              hit_height:,
              tube_y_offset:,
              head_width: nil,
              head_height: nil,
              head_rx: nil,
              tube_height: nil,
              tube_rx: nil,
              marker_side: :right
            )
              resolved_head_width = standard_dimension(head_preset, :width, override: head_width)
              head = standard_box(
                head_preset,
                x: drawing_right - resolved_head_width,
                y:,
                width: resolved_head_width,
                height: head_height,
                rx: head_rx
              )
              tube = layout_box(
                LayoutRules.left_of(
                  head,
                  gap: layout_gap(:attached),
                  y: head.y + tube_y_offset,
                  width: head.x - tube_x,
                  height: standard_dimension(tube_preset, :height, override: tube_height),
                  rx: standard_value(tube_preset, :rx, override: tube_rx)
                )
              )

              MotorElement.build(
                variant: :tubular,
                hit: layout_box(Box.new(x: hit_x, y: head.y + hit_y_offset, width: hit_width, height: hit_height)),
                tube:,
                tube_cap_width:,
                head:,
                marker: layout_anchor(head, side: marker_side, gap: marker_gap)
              )
            end
          end
        end
      end
    end
  end
end
