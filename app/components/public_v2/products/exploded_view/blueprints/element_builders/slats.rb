# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Slats
            private

            def venetian_slat_pack_element(
              reference:,
              preset:,
              gap:,
              x:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              slat_count:,
              slat_height:,
              tilt:,
              ladder_offsets:,
              lift_cord_offsets:,
              width: nil,
              height: nil,
              rx: nil
            )
              body = standard_below_box(reference, preset:, gap:, x:, width:, height:, rx:)

              SlatElement.build(
                variant: :venetian_pack,
                hit: layout_box(LayoutRules.hit_box(body, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                body:,
                marker: layout_anchor(body, side: :top, gap: marker_gap),
                slat_count:,
                slat_height: layout_size(slat_height),
                tilt: layout_size(tilt),
                ladder_xs: element_x_offsets(body, ladder_offsets),
                lift_cord_xs: element_x_offsets(body, lift_cord_offsets)
              )
            end

            def element_x_offsets(box, offsets)
              offsets.map do |offset|
                x = case offset
                    when :center
                      box.center_x
                    when Numeric
                      offset.negative? ? box.right + offset : box.x + offset
                    else
                      raise ArgumentError, "Unknown x offset: #{offset.inspect}"
                    end

                layout_point(Point.new(x:, y: box.center_y)).x
              end
            end
          end
        end
      end
    end
  end
end
