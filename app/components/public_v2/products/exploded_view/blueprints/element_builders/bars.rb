# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Bars
            private

            def zipped_load_bar_element(top:, preset:, hit:, marker:, height: nil)
              BarElement.build(
                variant: :zipped_load_bar,
                hit: layout_box(hit),
                top:,
                height: standard_dimension(preset, :height, override: height),
                marker: layout_point(marker)
              )
            end

            def vertical_handle_bar_element(
              reference:,
              preset:,
              gap:,
              y:,
              height:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              width: nil,
              rx: nil,
              grip_width:,
              grip_height:,
              grip_rx:
            )
              body = layout_box(
                LayoutRules.right_of(
                  reference,
                  gap: layout_gap(gap),
                  y:,
                  width: standard_dimension(preset, :width, override: width),
                  height:,
                  rx: standard_value(preset, :rx, override: rx)
                )
              )

              BarElement.build(
                variant: :vertical_handle,
                hit: layout_box(LayoutRules.hit_box(body, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                body:,
                marker: layout_anchor(body, side: :right, gap: marker_gap),
                grip: layout_box(
                  BarGeometry.centered_box(
                    center_x: body.center_x,
                    center_y: body.center_y,
                    width: grip_width,
                    height: grip_height,
                    rx: grip_rx
                  )
                )
              )
            end

            def threshold_bar_element(
              reference:,
              preset:,
              gap:,
              x:,
              width:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              height: nil,
              rx: nil,
              **variant_options
            )
              body = layout_box(
                LayoutRules.below(
                  reference,
                  gap: layout_gap(gap),
                  x:,
                  width:,
                  height: standard_dimension(preset, :height, override: height),
                  rx: standard_value(preset, :rx, override: rx)
                )
              )

              BarElement.build(
                variant: :threshold,
                hit: layout_box(LayoutRules.hit_box(body, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                body:,
                marker: layout_anchor(body, side: :right, gap: marker_gap),
                **variant_options
              )
            end

            def bottom_bar_element(
              reference:,
              preset:,
              gap:,
              x:,
              width:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              height: nil,
              rx: nil,
              grip_width:,
              grip_height:,
              grip_rx:,
              magnet_inset_x:,
              **variant_options
            )
              body = layout_box(
                LayoutRules.below(
                  reference,
                  gap: layout_gap(gap),
                  x:,
                  width:,
                  height: standard_dimension(preset, :height, override: height),
                  rx: standard_value(preset, :rx, override: rx)
                )
              )

              BarElement.build(
                variant: :bottom_bar,
                hit: layout_box(LayoutRules.hit_box(body, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                body:,
                marker: layout_anchor(body, side: :right, gap: marker_gap),
                grip: layout_box(
                  BarGeometry.centered_box(
                    center_x: body.center_x,
                    center_y: body.center_y,
                    width: grip_width,
                    height: grip_height,
                    rx: grip_rx
                  )
                ),
                magnet_points: BarGeometry.side_center_points(body, inset_x: magnet_inset_x),
                **variant_options
              )
            end
          end
        end
      end
    end
  end
end
