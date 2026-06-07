# frozen_string_literal: true

require_relative "../../solid_profiles"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilders
          module Supports
            private

            def mount_support_pair_element(
              reference:,
              gap:,
              width:,
              height:,
              inset_x:,
              marker_gap:,
              pair_class: MountSupportPair,
              rx: 38,
              hit_inset_x: 80,
              hit_inset_y: 80,
              solid_profile: nil
            )
              support_width = layout_size(width)
              support_height = layout_size(height)
              support_y = reference.y - layout_gap(gap) - support_height
              support_inset_x = layout_size(inset_x)
              left = layout_box(Box.new(x: reference.x + support_inset_x, y: support_y, width: support_width, height: support_height, rx:))
              right = layout_box(Box.new(x: reference.right - support_inset_x - support_width, y: support_y, width: support_width, height: support_height, rx:))
              hit = layout_box(LayoutRules.hit_box(Box.union([left, right]), inset_x: hit_inset_x, inset_y: hit_inset_y), preserve_size: true)

              pair_class.new(
                hit:,
                left:,
                right:,
                marker: layout_anchor(right, side: :right, gap: marker_gap),
                solid_profiles: solid_profile ? support_pair_solid_profiles(solid_profile, left:, right:) : nil
              )
            end

            def support_pair_solid_profiles(config, left:, right:)
              return config if config.is_a?(Hash) && config.values.all? { |profile| profile.is_a?(SolidSupportProfile) }

              options = solid_support_profile_options(config)
              SolidProfiles.mount_support_pair(
                id: options.fetch(:id),
                left:,
                right:,
                point_inset: options[:point_inset],
                point_radius: options.fetch(:point_radius, 20),
                point_specs: options[:point_specs],
                accent_inset_x: support_option(options, :accent_inset_x, legacy_name: :detail_inset_x, default: 42),
                accent_inset_y: support_option(options, :accent_inset_y, legacy_name: :detail_inset_y, default: 62),
                accent_height: support_option(options, :accent_height, legacy_name: :detail_height, default: 10),
                accent_rows: support_option(options, :accent_rows, legacy_name: :detail_rows),
                accent_style: support_option(options, :accent_style, legacy_name: :detail_style, default: :horizontal_pair),
                tones: options.fetch(:tones, {})
              )
            end

            def support_option(options, name, legacy_name:, default: nil)
              return options.fetch(name) if options.key?(name)
              return options.fetch(legacy_name) if options.key?(legacy_name)

              default
            end

            def solid_support_profile_options(config)
              case config
              when Hash
                config.transform_keys(&:to_sym)
              else
                raise ArgumentError, "solid_profile must be a SolidSupportProfile pair or a Hash config"
              end
            end
          end
        end
      end
    end
  end
end
