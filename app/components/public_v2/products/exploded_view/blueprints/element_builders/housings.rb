# frozen_string_literal: true

require_relative "../../solid_profiles"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Housings
            private

            def zipped_coffre_element(
              reference:,
              preset:,
              gap:,
              x:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              width: nil,
              height: nil,
              rx: nil,
              marker_side: :left,
              hole_offsets:,
              solid_profile: nil
            )
              body = standard_below_box(reference, preset:, gap:, x:, width:, height:, rx:)

              housing = HousingElement.build(
                variant: :zipped_coffre,
                hit: layout_box(HousingGeometry.expanded_box(body, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                body:,
                marker: layout_anchor(body, side: marker_side, gap: marker_gap),
                hole_pairs: HousingGeometry.symmetric_hole_pairs(body, offsets: hole_offsets)
              )
              return housing unless solid_profile

              housing.with_solid_profile(housing_solid_profile(solid_profile, housing:))
            end

            def cassette_housing_element(
              preset:,
              x:,
              y:,
              marker_gap:,
              hit_inset_x:,
              hit_inset_y:,
              roll_inset_x:,
              roll_y_offset:,
              roll_height:,
              roll_radius:,
              screw_side_inset:,
              width: nil,
              height: nil,
              rx: nil,
              marker_side: :right,
              solid_profile: nil
            )
              body = standard_box(preset, x:, y:, width:, height:, rx:)

              housing = HousingElement.build(
                variant: :cassette,
                hit: layout_box(HousingGeometry.expanded_box(body, inset_x: hit_inset_x, inset_y: hit_inset_y)),
                body:,
                roll: layout_box(
                  HousingGeometry.inset_box(
                    body,
                    inset_x: roll_inset_x,
                    y_offset: roll_y_offset,
                    height: roll_height,
                    rx: roll_radius
                  )
                ),
                marker: layout_anchor(body, side: marker_side, gap: marker_gap),
                screw_points: HousingGeometry.centered_screw_points(body, side_inset: screw_side_inset)
              )
              return housing unless solid_profile

              housing.with_solid_profile(housing_solid_profile(solid_profile, housing:))
            end

            def housing_solid_profile(config, housing:)
              return config if config.is_a?(SolidHousingProfile)

              options = solid_housing_profile_options(config)
              style = options.fetch(:style, :front_housing).to_sym
              points = housing_solid_profile_points(options, housing:)

              case style
              when :front_housing
                SolidProfiles.front_housing(
                  id: options.fetch(:id),
                  box: housing.body,
                  points:,
                  point_radius: options.fetch(:point_radius, 22),
                  opening: options[:opening],
                  cheeks: options[:cheeks],
                  features: housing_solid_profile_features(options, housing:),
                  tones: options.fetch(:tones, {})
                )
              when :front_coffre
                SolidProfiles.front_coffre(
                  id: options.fetch(:id),
                  box: housing.body,
                  points:,
                  point_radius: options.fetch(:point_radius, 22),
                  opening: options.fetch(:opening, {}),
                  cheeks: options.fetch(:cheeks, {}),
                  features: housing_solid_profile_features(options, housing:),
                  tones: options.fetch(:tones, {})
                )
              else
                raise ArgumentError, "Unknown solid housing style: #{style}"
              end
            end

            def housing_solid_profile_points(options, housing:)
              return [] if options[:points] == false
              return options[:points] if options.key?(:points)

              housing.screw_points.any? ? housing.screw_points : housing.holes
            end

            def housing_solid_profile_features(options, housing:)
              [
                housing_roll_feature(options[:roll], housing:)
              ].compact
            end

            def housing_roll_feature(config, housing:)
              return unless config && housing.roll

              options = config.transform_keys(&:to_sym)

              SolidHousingFeature.new(
                id: "roll",
                kind: :rect,
                box: housing.roll,
                tone: options.fetch(:tone, :mid),
                rx: options.fetch(:rx, housing.roll.rx)
              )
            end

            def solid_housing_profile_options(config)
              case config
              when Hash
                config.transform_keys(&:to_sym)
              else
                raise ArgumentError, "solid_profile must be a SolidHousingProfile or a Hash config"
              end
            end
          end
        end
      end
    end
  end
end
