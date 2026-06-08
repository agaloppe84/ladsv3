# frozen_string_literal: true

require_relative "../../solid_profiles"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Bars
            private

            def zipped_load_bar_element(top:, preset:, hit:, marker:, height: nil, body: nil, grip: nil, solid_profile: nil)
              bar_height = standard_dimension(preset, :height, override: height)
              body = layout_box(body || default_zipped_load_bar_body(hit:, top:, height: bar_height))
              grip = layout_box(grip || default_zipped_load_bar_grip(body))

              bar = BarElement.build(
                variant: :zipped_load_bar,
                hit: layout_box(hit),
                body:,
                top:,
                height: bar_height,
                marker: layout_point(marker),
                grip:
              )
              return bar unless solid_profile

              bar.with_solid_profile(horizontal_bar_solid_profile(solid_profile, bar:))
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
              grip_rx:,
              solid_profile: nil
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

              grip = layout_box(
                BarGeometry.centered_box(
                  center_x: body.center_x,
                  center_y: body.center_y,
                  width: grip_width,
                  height: grip_height,
                  rx: grip_rx
                )
              )
              bar = BarElement.build(
                variant: :vertical_handle,
                hit: layout_box(LayoutRules.hit_box(body, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                body:,
                marker: layout_anchor(body, side: :right, gap: marker_gap),
                grip:
              )
              return bar unless solid_profile

              bar.with_solid_profile(horizontal_bar_solid_profile(solid_profile, bar:))
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
              solid_profile: nil,
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

              bar = BarElement.build(
                variant: :threshold,
                hit: layout_box(LayoutRules.hit_box(body, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                body:,
                marker: layout_anchor(body, side: :right, gap: marker_gap),
                **variant_options
              )
              return bar unless solid_profile

              bar.with_solid_profile(horizontal_bar_solid_profile(solid_profile, bar:))
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
              solid_profile: nil,
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

              bar = BarElement.build(
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
              return bar unless solid_profile

              bar.with_solid_profile(horizontal_bar_solid_profile(solid_profile, bar:))
            end

            def horizontal_bar_solid_profile(config, bar:)
              return config if config.is_a?(SolidBarProfile)

              options = solid_bar_profile_options(config)
              points = if options[:points] == false
                         []
                       else
                         options.fetch(:points, [])
                       end

              SolidProfiles.horizontal_bar(
                id: options.fetch(:id),
                box: bar.body,
                body_tone: options[:body_tone],
                accent: bar_profile_option(options, :accent, legacy_name: :detail),
                embouts: options[:embouts],
                grip: solid_bar_grip_options(options[:grip], bar:),
                extensions: options.fetch(:extensions, []),
                tabs: options.fetch(:tabs, []),
                points:,
                point_radius: options.fetch(:point_radius, 18),
                features: options.fetch(:features, []),
                axis: options.fetch(:axis, :horizontal),
                tones: options.fetch(:tones, {})
              )
            end

            def bar_profile_option(options, name, legacy_name:)
              return options.fetch(name) if options.key?(name)
              return options.fetch(legacy_name) if options.key?(legacy_name)
            end

            def solid_bar_grip_options(config, bar:)
              return unless config
              return bar.grip if config == true

              options = config.transform_keys(&:to_sym)
              return options if options[:box] || bar.grip.nil?

              options.merge(box: bar.grip)
            end

            def solid_bar_profile_options(config)
              case config
              when Hash
                config.transform_keys(&:to_sym)
              else
                raise ArgumentError, "solid_profile must be a SolidBarProfile or a Hash config"
              end
            end

            def default_zipped_load_bar_body(hit:, top:, height:)
              Box.new(
                x: hit.x + 25,
                y: top,
                width: hit.width - 60,
                height:,
                rx: 34
              )
            end

            def default_zipped_load_bar_grip(body)
              BarGeometry.centered_box(
                center_x: body.center_x,
                center_y: body.center_y,
                width: 420,
                height: 50,
                rx: 18
              )
            end
          end
        end
      end
    end
  end
end
