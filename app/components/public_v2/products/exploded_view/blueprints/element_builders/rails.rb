# frozen_string_literal: true

require_relative "../../solid_profiles"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Rails
            private

            def horizontal_rail_element(
              preset:,
              x:,
              y:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              marker_side: :right,
              width: nil,
              height: nil,
              rx: nil,
              solid_profile: nil,
              **variant_options
            )
              body = standard_box(preset, x:, y:, width:, height:, rx:)

              rail = RailElement.build(
                variant: :horizontal_guide,
                hit: layout_box(LayoutRules.hit_box(body, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                body:,
                marker: layout_anchor(body, side: marker_side, gap: marker_gap),
                **variant_options
              )
              return rail unless solid_profile

              rail.with_solid_profile(horizontal_rail_solid_profile(solid_profile, rail:))
            end

            def vertical_rail_pair_element(
              reference:,
              preset:,
              left_gap:,
              right_gap:,
              y:,
              height:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              marker_side: :left,
              width: nil,
              rx: nil,
              slot_count:,
              slot_start: y,
              slot_finish: y + height,
              inner_inset_x:,
              inner_top_inset: 0,
              inner_bottom_inset: 0,
              solid_profile: nil,
              attached_features: nil
            )
              rail_width = standard_dimension(preset, :width, override: width)
              rail_rx = standard_value(preset, :rx, override: rx)
              left = layout_box(
                LayoutRules.left_of(
                  reference,
                  gap: layout_gap(left_gap),
                  y:,
                  width: rail_width,
                  height:,
                  rx: rail_rx
                )
              )
              right = layout_box(
                LayoutRules.right_of(
                  reference,
                  gap: layout_gap(right_gap),
                  y:,
                  width: rail_width,
                  height:,
                  rx: rail_rx
                )
              )

              rail = RailElement.build(
                variant: :vertical_pair,
                hit: layout_box(LayoutRules.hit_box(left, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                left:,
                right:,
                marker: layout_anchor(left, side: marker_side, gap: marker_gap),
                slot_ys: RailGeometry.distributed_positions(start: slot_start, finish: slot_finish, count: slot_count),
                inner_inset_x:,
                inner_top_inset:,
                inner_bottom_inset:
              )
              rail = rail.with_solid_profiles(vertical_rail_pair_solid_profiles(solid_profile, rail:)) if solid_profile
              rail = rail.with_attached_features(vertical_rail_pair_attached_features(attached_features, rail:)) if attached_features

              rail
            end

            def zipped_coulisse_element(
              top:,
              bottom:,
              hit:,
              marker:
            )
              RailElement.build(
                variant: :zipped_coulisse,
                top:,
                bottom:,
                hit: layout_box(hit),
                marker: layout_point(marker)
              )
            end

            def horizontal_rail_solid_profile(config, rail:)
              return config if config.is_a?(SolidProfile)

              options = solid_profile_options(config)

              SolidProfiles.horizontal_rail(
                id: options.fetch(:id),
                box: rail.body,
                screw_points: options.fetch(:screw_points, rail.screw_points),
                cap_ratio: options.fetch(:cap_ratio, 0.29),
                point_radius: options.fetch(:point_radius, 24),
                tones: options.fetch(:tones, {})
              )
            end

            def vertical_rail_pair_solid_profiles(config, rail:)
              options = solid_profile_options(config)

              SolidProfiles.vertical_rail_pair(
                id: options.fetch(:id),
                left: rail.left,
                right: rail.right,
                slot_ys: options.fetch(:slot_ys, rail.slot_ys),
                cap_ratio: options.fetch(:cap_ratio, 0.29),
                point_radius: options.fetch(:point_radius, 18),
                tones: options.fetch(:tones, {})
              )
            end

            def vertical_rail_pair_attached_features(config, rail:)
              attached_feature_options(config).transform_values do |options|
                vertical_rail_pair_attached_feature(options, rail:)
              end
            end

            def vertical_rail_pair_attached_feature(options, rail:)
              slot = options.fetch(:slot, :inside_bottom_centered).to_sym
              unless slot == :inside_bottom_centered
                raise ArgumentError, "Unsupported vertical rail attached feature slot: #{slot}"
              end

              left = layout_box(
                LayoutRules.inside_bottom_centered(
                  rail.left,
                  width: options.fetch(:width),
                  height: options.fetch(:height),
                  bottom_gap: options.fetch(:bottom_gap),
                  rx: options[:rx]
                )
              )
              right = layout_box(
                LayoutRules.inside_bottom_centered(
                  rail.right,
                  width: options.fetch(:width),
                  height: options.fetch(:height),
                  bottom_gap: options.fetch(:bottom_gap),
                  rx: options[:rx]
                )
              )

              RailAttachedFeature.new(
                id: options.fetch(:id),
                slot:,
                left:,
                right:,
                tone: options.fetch(:tone, :dark)
              )
            end

            def solid_profile_options(config)
              case config
              when Hash
                config.transform_keys(&:to_sym)
              else
                raise ArgumentError, "solid_profile must be a SolidProfile or a Hash config"
              end
            end

            def attached_feature_options(config)
              case config
              when Hash
                config.each_with_object({}) do |(id, options), features|
                  features[id.to_sym] = options.transform_keys(&:to_sym).merge(id: id.to_s)
                end
              else
                raise ArgumentError, "attached_features must be a Hash config"
              end
            end
          end
        end
      end
    end
  end
end
