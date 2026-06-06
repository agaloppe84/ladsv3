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

        FABRIC_PATTERN_ROLE_CLASSES = {
          fill: "pv2-product-exploded__fill",
          fabric_solid_edge: "pv2-product-exploded__fabric-solid-edge",
          fabric_solid_edge_detail: "pv2-product-exploded__fabric-solid-edge-detail",
          fabric_solid_grid: "pv2-product-exploded__fabric-solid-grid",
          fabric_solid_surface: "pv2-product-exploded__fabric-solid-surface",
          fabric_pleat_face_light: "pv2-product-exploded__fabric-pleat-face pv2-product-exploded__fabric-pleat-face--light",
          fabric_pleat_face_mid: "pv2-product-exploded__fabric-pleat-face pv2-product-exploded__fabric-pleat-face--mid",
          fabric_pleat_thread: "pv2-product-exploded__fabric-pleat-thread",
          fabric_pleat_thread_point: "pv2-product-exploded__fabric-pleat-thread-point",
          fabric_zip_teeth: "pv2-product-exploded__fabric-zip-teeth",
          grid: "pv2-product-exploded__fabric-grid",
          hairline: "pv2-product-exploded__hairline",
          line: "pv2-product-exploded__fabric-line",
          outline: "pv2-product-exploded__outline",
          profile: "pv2-product-exploded__profile",
          solid_dark: "pv2-product-exploded__solid-fill-dark",
          solid_light: "pv2-product-exploded__solid-fill-light",
          solid_mid: "pv2-product-exploded__solid-fill-mid",
          thread: "pv2-product-exploded__fabric-thread"
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

        def solid_housing_profile(profile)
          return unless profile

          id = "#{svg_description_id}-#{profile.id}"
          clip_id = solid_clip_id(id)
          safe_join(
            [
              solid_profile_defs(profile.body, clip_id:, id:, tones: profile.tones, axis: :horizontal),
              solid_rect(profile.body, clip_id:, id:, tone: profile.body_tone),
              *profile.features.map { |feature| solid_housing_feature(feature, clip_id:, id:) },
              *profile.points.map { |point| solid_point(point.point, radius: point.radius, tone: point.tone) }
            ]
          )
        end

        def fabric_pattern(pattern, slot:)
          return unless pattern

          safe_join(pattern.layers_for(slot).map { |layer| fabric_pattern_layer(layer) })
        end

        def zip_edge_track(teeth_side:, step:, box: nil, x: nil, y: nil, width: nil, height: nil, rx: nil)
          box ||= Box.new(x:, y:, width:, height:, rx:)

          safe_join(
            [
              tag.rect(
                x: box.x,
                y: box.y,
                width: box.width,
                height: box.height,
                rx: box.rx,
                class: "pv2-product-exploded__fabric-solid-edge"
              ),
              tag.path(
                d: FabricPatterns.zip_teeth_path(
                  x: teeth_side.to_sym == :right ? box.right : box.x,
                  top: box.y,
                  bottom: box.bottom,
                  step:,
                  side: teeth_side
                ),
                class: "pv2-product-exploded__fabric-zip-teeth"
              )
            ]
          )
        end

        def fabric_zip_tooth_step(fabric)
          FabricPatterns.zip_tooth_step(body: fabric.body, line_count: fabric.line_count)
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

        def fabric_pattern_layer(layer)
          attrs = {
            class: fabric_pattern_role_class(layer.role)
          }
          attrs["shape-rendering"] = layer.shape_rendering if layer.shape_rendering

          if layer.box
            tag.rect(
              x: layer.box.x,
              y: layer.box.y,
              width: layer.box.width,
              height: layer.box.height,
              rx: layer.box.rx,
              **attrs
            )
          elsif layer.point
            tag.circle(
              cx: layer.point.x,
              cy: layer.point.y,
              r: layer.radius,
              **attrs
            )
          else
            tag.path(d: layer.path, **attrs)
          end
        end

        def fabric_pattern_role_class(role)
          FABRIC_PATTERN_ROLE_CLASSES.fetch(role.to_sym)
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

        def solid_rect(box, clip_id:, id:, tone:)
          attrs = {
            x: box.x,
            y: box.y,
            width: box.width,
            height: box.height,
            rx: box.rx,
            class: solid_tone_class(tone),
            "clip-path": "url(##{clip_id})"
          }
          attrs[:style] = "fill: url(##{solid_gradient_id(id, tone)})" if SOLID_GRADIENT_STOPS.key?(tone)

          tag.rect(**attrs)
        end

        def solid_housing_feature(feature, clip_id:, id:)
          return solid_rect(feature.box, clip_id:, id:, tone: feature.tone) unless feature.kind == :top_rounded_rect

          attrs = {
            d: solid_top_rounded_rect_path(feature.box, radius: feature.rx),
            class: solid_tone_class(feature.tone),
            "clip-path": "url(##{clip_id})"
          }
          attrs[:style] = "fill: url(##{solid_gradient_id(id, feature.tone)})" if SOLID_GRADIENT_STOPS.key?(feature.tone)

          tag.path(**attrs)
        end

        def solid_top_rounded_rect_path(box, radius:)
          radius = [radius, box.width / 2, box.height].min

          [
            "M#{box.x} #{box.bottom}",
            "V#{box.y + radius}",
            "Q#{box.x} #{box.y} #{box.x + radius} #{box.y}",
            "H#{box.right - radius}",
            "Q#{box.right} #{box.y} #{box.right} #{box.y + radius}",
            "V#{box.bottom}",
            "Z"
          ].join
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
