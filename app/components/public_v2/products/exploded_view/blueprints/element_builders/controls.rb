# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Controls
            private

            def venetian_control_element(
              reference:,
              preset:,
              gap:,
              y:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              cord_offset_x:,
              cord_top_offset_y:,
              cord_bottom_offset_y:,
              bead_count:,
              width: nil,
              height: nil,
              rx: nil
            )
              body = layout_box(
                LayoutRules.right_of(
                  reference,
                  gap: layout_gap(gap),
                  y:,
                  width: standard_dimension(preset, :width, override: width),
                  height: standard_dimension(preset, :height, override: height),
                  rx: standard_value(preset, :rx, override: rx)
                )
              )

              cord_x = body.center_x + layout_size(cord_offset_x)
              cord_top = layout_point(Point.new(x: cord_x, y: body.y + cord_top_offset_y))
              cord_bottom = layout_point(Point.new(x: cord_x, y: body.bottom + cord_bottom_offset_y))
              cord_hit = Box.new(
                x: cord_top.x - 40,
                y: [cord_top.y, cord_bottom.y].min,
                width: 80,
                height: (cord_bottom.y - cord_top.y).abs,
                rx: 0
              )

              ControlElement.build(
                variant: :venetian_wand,
                hit: layout_box(LayoutRules.hit_box(Box.union([body, cord_hit]), inset_x: hit_inset_x, inset_y: hit_inset_y), preserve_size: true),
                body:,
                marker: layout_point(Point.new(x: cord_top.x + marker_gap, y: body.center_y)),
                cord_top:,
                cord_bottom:,
                bead_count:
              )
            end
          end
        end
      end
    end
  end
end
