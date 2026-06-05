# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Rails
            private

            def horizontal_rail_element(
              preset:,
              x:,
              y:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              marker_side: :right,
              width: nil,
              height: nil,
              rx: nil,
              **variant_options
            )
              body = standard_box(preset, x:, y:, width:, height:, rx:)

              RailElement.build(
                variant: :horizontal_guide,
                hit: layout_box(LayoutRules.hit_box(body, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                body:,
                marker: layout_anchor(body, side: marker_side, gap: marker_gap),
                **variant_options
              )
            end

            def vertical_rail_pair_element(
              reference:,
              preset:,
              left_gap:,
              right_gap:,
              y:,
              height:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              marker_side: :left,
              width: nil,
              rx: nil,
              slot_count:,
              slot_start: y,
              slot_finish: y + height,
              inner_inset_x:,
              inner_top_inset: 0,
              inner_bottom_inset: 0
            )
              rail_width = standard_dimension(preset, :width, override: width)
              rail_rx = standard_value(preset, :rx, override: rx)
              left = layout_box(
                LayoutRules.left_of(
                  reference,
                  gap: layout_gap(left_gap),
                  y:,
                  width: rail_width,
                  height:,
                  rx: rail_rx
                )
              )
              right = layout_box(
                LayoutRules.right_of(
                  reference,
                  gap: layout_gap(right_gap),
                  y:,
                  width: rail_width,
                  height:,
                  rx: rail_rx
                )
              )

              RailElement.build(
                variant: :vertical_pair,
                hit: layout_box(LayoutRules.hit_box(left, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                left:,
                right:,
                marker: layout_anchor(left, side: marker_side, gap: marker_gap),
                slot_ys: RailGeometry.distributed_positions(start: slot_start, finish: slot_finish, count: slot_count),
                inner_inset_x:,
                inner_top_inset:,
                inner_bottom_inset:
              )
            end

            def zipped_coulisse_element(
              top:,
              bottom:,
              hit:,
              marker:
            )
              RailElement.build(
                variant: :zipped_coulisse,
                top:,
                bottom:,
                hit: layout_box(hit),
                marker: layout_point(marker)
              )
            end
          end
        end
      end
    end
  end
end
