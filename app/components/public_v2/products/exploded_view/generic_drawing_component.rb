# frozen_string_literal: true

require_relative "base_drawing_component"

module PublicV2
  module Products
    module ExplodedView
      class GenericDrawingComponent < BaseDrawingComponent
        def initialize(parts:, **options)
          @parts = parts

          super(**options)
        end

        private

        attr_reader :parts

        def part_group(part_id, class_suffix:, hit:, marker:, aria_label: nil, &block)
          tag.g(
            class: class_names(
              "pv2-product-exploded__part",
              "pv2-product-exploded__part--#{class_suffix}",
              active_part_class(part_id)
            ),
            data: {
              exploded_view_target: "part",
              part_id:
            },
            role: "button",
            tabindex: "0",
            aria: {
              pressed: aria_pressed(part_id),
              label: aria_label || part_label(part_id)
            },
            "data-action": "click->exploded-view#select keydown->exploded-view#selectKey"
          ) do
            safe_join(
              [
                hit_rect(hit),
                capture(&block),
                marker_for(part_id, marker:),
                callout_for(part_id)
              ].compact
            )
          end
        end

        def mirror_part_group(part_id, class_suffix:, hit:, aria_label: nil, &block)
          tag.g(
            class: class_names(
              "pv2-product-exploded__part",
              "pv2-product-exploded__part--#{class_suffix}",
              active_part_class(part_id)
            ),
            data: {
              exploded_view_target: "part",
              part_id:
            },
            role: "button",
            tabindex: "0",
            aria: {
              pressed: aria_pressed(part_id),
              label: aria_label || part_label(part_id)
            },
            "data-action": "click->exploded-view#select keydown->exploded-view#selectKey"
          ) do
            safe_join(
              [
                hit_rect(hit),
                capture(&block)
              ].compact
            )
          end
        end

        def hit_rect(box)
          tag.rect(
            x: box.x,
            y: box.y,
            width: box.width,
            height: box.height,
            class: "pv2-product-exploded__hit-area"
          )
        end

        def mirrored_hit_box(box)
          Box.new(
            x: layout.svg_width - box.x - box.width,
            y: box.y,
            width: box.width,
            height: box.height,
            rx: box.rx
          )
        end

        def vertical_zippe_layout?
          layout.respond_to?(:coffre) && layout.respond_to?(:coulisse)
        end

        def enroulable_verticale_layout?
          layout.respond_to?(:cassette) && layout.respond_to?(:rails)
        end

        def plissee_layout?
          layout.respond_to?(:guide) && layout.respond_to?(:profiles)
        end

        def duette_layout?
          layout.respond_to?(:top_rail) && layout.respond_to?(:intermediate_rail) && layout.respond_to?(:cords)
        end

        def venetian_layout?
          layout.respond_to?(:headrail) && layout.respond_to?(:slats) && layout.respond_to?(:control)
        end

        def right_vertical_pair_hit_box(rails, hit_offset: 80)
          Box.new(
            x: rails.right.x - hit_offset,
            y: rails.hit.y,
            width: rails.hit.width,
            height: rails.hit.height,
            rx: rails.hit.rx
          )
        end

        def venetian_cord_hit_box
          xs = layout.slats.cord_xs
          left = xs.min - 74
          right = xs.max + 74
          top = layout.slats.cord_top - 90
          bottom = layout.slats.cord_bottom + 90

          Box.new(x: left, y: top, width: right - left, height: bottom - top, rx: 0)
        end

        def unsupported_layout!
          raise ArgumentError, "GenericDrawingComponent does not support #{layout.class.name}"
        end

        def marker_for(part_id, marker:)
          tag.g(class: "pv2-product-exploded__marker", transform: "translate(#{marker.x} #{marker.y})") do
            safe_join(
              [
                tag.circle(r: 68),
                tag.text(part_number(part_id), y: 25)
              ]
            )
          end
        end

        def part_number(part_id)
          part(part_id).number
        end

        def part_label(part_id)
          part(part_id).label
        end

        def part(part_id)
          parts_by_id.fetch(part_id.to_s)
        end

        def parts_by_id
          @parts_by_id ||= parts.each_with_object({}) do |part, index|
            index[part.id] = part
          end
        end

        def class_names(*values)
          values.compact.reject(&:empty?).join(" ")
        end
      end
    end
  end
end
