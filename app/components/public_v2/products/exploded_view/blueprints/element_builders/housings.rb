# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Housings
            private

            def zipped_coffre_element(
              reference:,
              preset:,
              gap:,
              x:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              width: nil,
              height: nil,
              rx: nil,
              marker_side: :left,
              hole_offsets:
            )
              body = standard_below_box(reference, preset:, gap:, x:, width:, height:, rx:)

              HousingElement.build(
                variant: :zipped_coffre,
                hit: layout_box(HousingGeometry.expanded_box(body, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                body:,
                marker: layout_anchor(body, side: marker_side, gap: marker_gap),
                hole_pairs: HousingGeometry.symmetric_hole_pairs(body, offsets: hole_offsets)
              )
            end

            def cassette_housing_element(
              preset:,
              x:,
              y:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              roll_inset_x:,
              roll_y_offset:,
              roll_height:,
              roll_radius:,
              screw_side_inset:,
              width: nil,
              height: nil,
              rx: nil,
              marker_side: :right
            )
              body = standard_box(preset, x:, y:, width:, height:, rx:)

              HousingElement.build(
                variant: :cassette,
                hit: layout_box(HousingGeometry.expanded_box(body, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                body:,
                roll: layout_box(
                  HousingGeometry.inset_box(
                    body,
                    inset_x: roll_inset_x,
                    y_offset: roll_y_offset,
                    height: roll_height,
                    rx: roll_radius
                  )
                ),
                marker: layout_anchor(body, side: marker_side, gap: marker_gap),
                screw_points: HousingGeometry.centered_screw_points(body, side_inset: screw_side_inset)
              )
            end
          end
        end
      end
    end
  end
end
