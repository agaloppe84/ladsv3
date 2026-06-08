# frozen_string_literal: true

require_relative "base_drawing_component"
require_relative "layouts"

module PublicV2
  module Products
    module ExplodedView
      class GenericDrawingComponent < BaseDrawingComponent
        RendererFamily = Struct.new(:name, :layout_class, :component_class_name, keyword_init: true) do
          def component_class
            component_class_name.split("::").inject(Object) { |constant, name| constant.const_get(name) }
          end
        end

        RENDERER_FAMILIES = [
          RendererFamily.new(
            name: :zipped_screen,
            layout_class: ZippedScreenLayout,
            component_class_name: "PublicV2::Products::ExplodedView::Renderers::ZippedScreenComponent"
          ),
          RendererFamily.new(
            name: :side_guided_roller,
            layout_class: SideGuidedRollerLayout,
            component_class_name: "PublicV2::Products::ExplodedView::Renderers::SideGuidedRollerComponent"
          ),
          RendererFamily.new(
            name: :pleated_lateral,
            layout_class: PleatedLateralLayout,
            component_class_name: "PublicV2::Products::ExplodedView::Renderers::PleatedLateralComponent"
          ),
          RendererFamily.new(
            name: :honeycomb_shade,
            layout_class: HoneycombShadeLayout,
            component_class_name: "PublicV2::Products::ExplodedView::Renderers::HoneycombShadeComponent"
          ),
          RendererFamily.new(
            name: :venetian_blind,
            layout_class: VenetianBlindLayout,
            component_class_name: "PublicV2::Products::ExplodedView::Renderers::VenetianBlindComponent"
          ),
          RendererFamily.new(
            name: :roller_duo,
            layout_class: RollerDuoLayout,
            component_class_name: "PublicV2::Products::ExplodedView::Renderers::RollerDuoComponent"
          )
        ].freeze

        def initialize(parts:, part_ids_by_slot: {}, **options)
          @parts = parts
          @part_ids_by_slot = part_ids_by_slot.to_h.transform_keys(&:to_s)

          super(**options)
        end

        private

        attr_reader :parts, :part_ids_by_slot

        def part_id_for_slot(slot, fallback:)
          part_ids_by_slot.fetch(slot.to_s, fallback)
        end

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

        def layout_renderer_family
          renderer_family&.name
        end

        def layout_renderer_component
          family = renderer_family
          return unless family

          family.component_class.new(
            layout:,
            parts:,
            title_id:,
            svg_description_id:,
            active_part_id:,
            svg_description:,
            show_layout_grid: show_layout_grid?,
            part_ids_by_slot:
          )
        end

        def renderer_family
          @renderer_family ||= RENDERER_FAMILIES.find { |family| layout.is_a?(family.layout_class) }
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

require_relative "renderers/zipped_screen_component"
require_relative "renderers/side_guided_roller_component"
require_relative "renderers/pleated_lateral_component"
require_relative "renderers/honeycomb_shade_component"
require_relative "renderers/venetian_blind_component"
require_relative "renderers/roller_duo_component"
