# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      class BaseDrawingComponent < ViewComponent::Base
        SOLID_GRADIENT_STOPS = {
          light: [
            ["0", "--pv2-exploded-solid-light-hi"],
            ["0.58", "--pv2-exploded-solid-light"],
            ["1", "--pv2-exploded-solid-light-low"]
          ],
          mid: [
            ["0", "--pv2-exploded-solid-mid-hi"],
            ["0.56", "--pv2-exploded-solid-mid"],
            ["1", "--pv2-exploded-solid-mid-low"]
          ]
        }.freeze

        SOLID_TONE_CLASSES = {
          light: "pv2-product-exploded__solid-fill-light",
          mid: "pv2-product-exploded__solid-fill-mid",
          dark: "pv2-product-exploded__solid-fill-dark"
        }.freeze

        def initialize(layout:, title_id:, svg_description_id:, active_part_id:, svg_description:, show_layout_grid: true)
          @layout = layout
          @title_id = title_id
          @svg_description_id = svg_description_id
          @active_part_id = active_part_id.to_s
          @svg_description = svg_description
          @show_layout_grid = show_layout_grid
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

          tag.g(class: callout.css_class, aria: { hidden: "true" }) do
            safe_join(
              [
                tag.path(d: callout.path, pathLength: 1, class: "pv2-product-exploded__callout-line"),
                tag.circle(cx: dot.x, cy: dot.y, r: callout.dot_radius || 20, class: "pv2-product-exploded__callout-dot"),
                tag.g(class: callout.label_reveal_class) do
                  tag.text(
                    callout.label,
                    x: text.x,
                    y: text.y,
                    class: "pv2-product-exploded__callout-label",
                    "text-anchor": callout.resolved_text_anchor,
                    "dominant-baseline": callout.resolved_dominant_baseline
                  )
                end
              ]
            )
          end
        end

        def background_grid
          return unless show_layout_grid?
          return unless layout.respond_to?(:grid)

          grid = layout.grid
          return unless grid

          clip_id = "#{svg_description_id}-layout-grid"
          paths = [
            tag.path(
              d: grid.minor_path,
              class: "pv2-product-exploded__layout-grid-line pv2-product-exploded__layout-grid-line--minor",
              "clip-path": "url(##{clip_id})"
            ),
            tag.path(
              d: grid.major_path,
              class: "pv2-product-exploded__layout-grid-line pv2-product-exploded__layout-grid-line--major",
              "clip-path": "url(##{clip_id})"
            )
          ]

          tag.g(class: "pv2-product-exploded__layout-grid", aria: { hidden: "true" }) do
            safe_join(
              [
                tag.defs do
                  tag.clipPath(id: clip_id) do
                    tag.rect(
                      x: grid.frame.x,
                      y: grid.frame.y,
                      width: grid.frame.width,
                      height: grid.frame.height,
                      rx: grid.frame.rx
                    )
                  end
                end,
                tag.rect(
                  x: grid.frame.x,
                  y: grid.frame.y,
                  width: grid.frame.width,
                  height: grid.frame.height,
                  rx: grid.frame.rx,
                  class: "pv2-product-exploded__layout-grid-surface"
                ),
                *paths
              ]
            )
          end
        end

        def show_layout_grid?
          @show_layout_grid
        end

        def surface_rect(box)
          tag.rect(
            x: box.x,
            y: box.y,
            width: box.width,
            height: box.height,
            rx: box.rx,
            class: "pv2-product-exploded__surface"
          )
        end

        def surface_path(path)
          tag.path(d: path, class: "pv2-product-exploded__surface")
        end

        def solid_profile(profile)
          return unless profile

          id = "#{svg_description_id}-#{profile.id}"
          clip_id = solid_clip_id(id)
          safe_join(
            [
              solid_profile_defs(profile.clip_box, clip_id:, id:, tones: profile.tones, axis: profile.axis),
              *profile.bands.map { |band| solid_band(profile, clip_id:, id:, band:) },
              *profile.points.map { |point| solid_point(point.point, radius: point.radius, tone: point.tone) }
            ]
          )
        end

        def solid_profile_defs(box, clip_id:, id:, tones:, axis: :horizontal)
          tag.defs do
            safe_join(
              [
                tag.clipPath(id: clip_id) do
                  tag.rect(x: box.x, y: box.y, width: box.width, height: box.height, rx: box.rx)
                end,
                *tones.filter_map { |tone| solid_linear_gradient(id, tone, axis:) }
              ]
            )
          end
        end

        def solid_linear_gradient(id, tone, axis: :horizontal)
          stops = SOLID_GRADIENT_STOPS[tone.to_sym]
          return unless stops
          gradient_attrs = if axis.to_sym == :vertical
                             { x1: "0", x2: "1", y1: "0", y2: "0" }
                           else
                             { x1: "0", x2: "0", y1: "0", y2: "1" }
                           end

          tag.linearGradient(id: solid_gradient_id(id, tone), **gradient_attrs) do
            safe_join(
              stops.map do |offset, token|
                tag.stop(offset:, style: "stop-color: var(#{token})")
              end
            )
          end
        end

        def solid_band(profile, clip_id:, id:, band:)
          box = profile.box
          tone = band.tone
          attrs = {
            class: solid_tone_class(tone),
            "clip-path": "url(##{clip_id})"
          }
          attrs.merge!(
            if profile.vertical?
              { x: box.x + band.offset, y: box.y, width: band.height, height: box.height }
            else
              { x: box.x, y: box.y + band.offset, width: box.width, height: band.height }
            end
          )
          attrs[:style] = "fill: url(##{solid_gradient_id(id, tone)})" if SOLID_GRADIENT_STOPS.key?(tone)

          tag.rect(**attrs)
        end

        def solid_point(point, radius:, tone: :dark)
          tag.circle(
            cx: point.x,
            cy: point.y,
            r: radius,
            class: solid_tone_class(tone)
          )
        end

        def solid_tone_class(tone)
          SOLID_TONE_CLASSES.fetch(tone.to_sym)
        end

        def solid_clip_id(id)
          "#{solid_dom_id(id)}-clip"
        end

        def solid_gradient_id(id, tone)
          "#{solid_dom_id(id)}-#{tone}-gradient"
        end

        def solid_dom_id(id)
          id.to_s.gsub(/[^a-zA-Z0-9_-]/, "-")
        end
      end
    end
  end
end
