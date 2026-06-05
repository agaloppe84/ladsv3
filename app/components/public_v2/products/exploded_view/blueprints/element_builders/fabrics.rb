# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Fabrics
            private

            def fabric_element(
              variant:,
              reference:,
              preset:,
              gap:,
              x:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              marker_side: :top,
              width: nil,
              height: nil,
              rx: nil,
              **variant_options
            )
              body = standard_below_box(reference, preset:, gap:, x:, width:, height:, rx:)

              FabricElement.build(
                variant:,
                hit: layout_box(LayoutRules.hit_box(body, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                body:,
                marker: layout_anchor(body, side: marker_side, gap: marker_gap),
                **variant_options
              )
            end
          end
        end
      end
    end
  end
end
