# frozen_string_literal: true

require_relative "../../solid_profiles"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Closures
            private

            def plissee_lock_element(
              handle:,
              radius:,
              catch_divisions:,
              catch_indexes:,
              hit_inset_left:,
              hit_inset_y:,
              hit_width:,
              marker_offset_x:,
              marker_offset_y:
            )
              flat_x = handle.body.right
              catch_step = handle.body.height / catch_divisions
              catches = catch_indexes.map do |index|
                Point.new(x: flat_x, y: handle.body.y + (catch_step * index))
              end

              ClosureElement.build(
                variant: :plissee_lock,
                hit: layout_box(
                  Box.new(
                    x: flat_x - hit_inset_left,
                    y: handle.body.y - hit_inset_y,
                    width: hit_width,
                    height: handle.body.height + (hit_inset_y * 2)
                  )
                ),
                marker: layout_point(Point.new(x: flat_x + marker_offset_x, y: handle.body.center_y + marker_offset_y)),
                catches:,
                radius:
              )
            end

            def magnetic_receiver_element(
              bottom_bar:,
              hit_inset_x:,
              hit_y_offset:,
              hit_height:,
              marker_offset_y:,
              receiver_offset_y:,
              radius:,
              solid_profile: nil
            )
              receiver_points = BarGeometry.translate_points(bottom_bar.magnet_points, y: bottom_bar.body.bottom + receiver_offset_y)

              ClosureElement.build(
                variant: :magnetic_receivers,
                hit: layout_box(
                  Box.new(
                    x: bottom_bar.body.x + hit_inset_x,
                    y: bottom_bar.body.bottom + hit_y_offset,
                    width: bottom_bar.body.width - (hit_inset_x * 2),
                    height: hit_height
                  )
                ),
                marker: layout_point(Point.new(x: bottom_bar.body.center_x, y: bottom_bar.body.bottom + marker_offset_y)),
                receiver_points:,
                radius:,
                solid_profile: solid_profile && magnetic_receiver_solid_profile(solid_profile, receiver_points:, radius:)
              )
            end

            def rail_bavettes_element(
              rails:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              feature_id: nil,
              width: nil,
              height: nil,
              bottom_gap: nil,
              rx: nil,
              solid_profile: nil
            )
              feature = feature_id && rails.attached_feature(feature_id)
              if feature_id && !feature
                raise ArgumentError, "rails do not define attached feature #{feature_id.inspect}"
              end

              left, right = if feature
                              [feature.left, feature.right]
                            else
                              [
                                layout_box(
                                  LayoutRules.inside_bottom_centered(
                                    rails.left,
                                    width:,
                                    height:,
                                    bottom_gap:,
                                    rx:
                                  )
                                ),
                                layout_box(
                                  LayoutRules.inside_bottom_centered(
                                    rails.right,
                                    width:,
                                    height:,
                                    bottom_gap:,
                                    rx:
                                  )
                                )
                              ]
                            end
              unless left && right
                raise ArgumentError, "rail_bavettes_element needs attached feature #{feature_id.inspect} or explicit geometry"
              end
              tone = feature&.tone || :dark

              ClosureElement.build(
                variant: :rail_bavettes,
                hit: layout_box(LayoutRules.hit_box(right, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                left:,
                right:,
                marker: layout_point(Point.new(x: rails.right.right + marker_gap, y: right.center_y)),
                tone:,
                solid_profile: solid_profile && rail_bavettes_solid_profile(solid_profile, left:, right:, tone:)
              )
            end

            def magnetic_receiver_solid_profile(config, receiver_points:, radius:)
              return config if config.is_a?(SolidAccessoryProfile)

              options = closure_solid_profile_options(config)

              SolidProfiles.magnetic_receivers(
                id: options.fetch(:id),
                points: receiver_points,
                radius:,
                base_width: options[:base_width],
                base_height: options.fetch(:base_height, 16),
                base_offset_y: options.fetch(:base_offset_y, 58),
                base_rx: options[:base_rx],
                point_radius: options.fetch(:point_radius, 22),
                tones: options.fetch(:tones, {})
              )
            end

            def rail_bavettes_solid_profile(config, left:, right:, tone:)
              return config if config.is_a?(SolidAccessoryProfile)

              options = closure_solid_profile_options(config)

              SolidProfiles.accessory_rect_pair(
                id: options.fetch(:id),
                left:,
                right:,
                tone: options.fetch(:tone, tone),
                variant: options.fetch(:variant, :rail_bavettes),
                tones: options.fetch(:tones, {})
              )
            end

            def closure_solid_profile_options(config)
              case config
              when Hash
                config.transform_keys(&:to_sym)
              else
                raise ArgumentError, "solid_profile must be a Hash config"
              end
            end
          end
        end
      end
    end
  end
end
