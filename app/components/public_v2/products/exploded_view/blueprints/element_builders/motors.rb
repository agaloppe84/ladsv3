# frozen_string_literal: true

require_relative "../../solid_profiles"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Motors
            private

            def tubular_motor_element(
              drawing_right:,
              y:,
              head_preset:,
              tube_preset:,
              tube_x:,
              tube_cap_width:,
              marker_gap:,
              hit_x:,
              hit_y_offset:,
              hit_width:,
              hit_height:,
              tube_y_offset:,
              head_width: nil,
              head_height: nil,
              head_rx: nil,
              tube_height: nil,
              tube_rx: nil,
              marker_side: :right,
              solid_profile: nil
            )
              resolved_head_width = standard_dimension(head_preset, :width, override: head_width)
              head = standard_box(
                head_preset,
                x: drawing_right - resolved_head_width,
                y:,
                width: resolved_head_width,
                height: head_height,
                rx: head_rx
              )
              tube = layout_box(
                LayoutRules.left_of(
                  head,
                  gap: layout_gap(:attached),
                  y: head.y + tube_y_offset,
                  width: head.x - tube_x,
                  height: standard_dimension(tube_preset, :height, override: tube_height),
                  rx: standard_value(tube_preset, :rx, override: tube_rx)
                )
              )

              motor = MotorElement.build(
                variant: :tubular,
                hit: layout_box(Box.new(x: hit_x, y: head.y + hit_y_offset, width: hit_width, height: hit_height)),
                tube:,
                tube_cap_width:,
                head:,
                marker: layout_anchor(head, side: marker_side, gap: marker_gap)
              )
              return motor unless solid_profile

              motor.with_solid_profile(tubular_motor_solid_profile(solid_profile, motor:))
            end

            def tubular_motor_solid_profile(config, motor:)
              return config if config.is_a?(SolidMotorProfile)

              options = solid_motor_profile_options(config)

              SolidProfiles.tubular_motor(
                id: options.fetch(:id),
                tube: motor.tube,
                head: motor.head,
                cap_width: options.fetch(:cap_width, motor.tube_cap_width),
                large_hole: options.fetch(:large_hole, motor.large_hole),
                small_holes: options.fetch(:small_holes, motor.small_holes),
                large_hole_radius: options.fetch(:large_hole_radius, 45),
                small_hole_radius: options.fetch(:small_hole_radius, 18),
                tones: options.fetch(:tones, {})
              )
            end

            def solid_motor_profile_options(config)
              case config
              when Hash
                config.transform_keys(&:to_sym)
              else
                raise ArgumentError, "solid_profile must be a SolidMotorProfile or a Hash config"
              end
            end
          end
        end
      end
    end
  end
end
