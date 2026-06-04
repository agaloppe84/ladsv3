# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      class BaseDrawingComponent < ViewComponent::Base
        def initialize(layout:, title_id:, svg_description_id:, active_part_id:, svg_description:)
          @layout = layout
          @title_id = title_id
          @svg_description_id = svg_description_id
          @active_part_id = active_part_id.to_s
          @svg_description = svg_description
        end

        private

        attr_reader :layout, :title_id, :svg_description_id, :active_part_id, :svg_description

        def active_part_class(part_id)
          "is-active" if active_part?(part_id)
        end

        def aria_pressed(part_id)
          active_part?(part_id) ? "true" : "false"
        end

        def active_part?(part_id)
          part_id.to_s == active_part_id
        end

        def callout_for(part_id)
          callout = layout.callout(part_id)
          return unless callout

          dot = callout.dot
          text = callout.text

          tag.g(class: "pv2-product-exploded__callout", aria: { hidden: "true" }) do
            safe_join(
              [
                tag.path(d: callout.path, class: "pv2-product-exploded__callout-line"),
                tag.circle(cx: dot.x, cy: dot.y, r: callout.dot_radius || 20, class: "pv2-product-exploded__callout-dot"),
                tag.text(
                  callout.label,
                  x: text.x,
                  y: text.y,
                  class: "pv2-product-exploded__callout-label",
                  "text-anchor": callout.resolved_text_anchor,
                  "dominant-baseline": callout.resolved_dominant_baseline
                )
              ]
            )
          end
        end
      end
    end
  end
end
