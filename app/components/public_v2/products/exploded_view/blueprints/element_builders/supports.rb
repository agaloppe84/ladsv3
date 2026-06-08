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
              hit_inset_top: nil,
              hit_inset_bottom: nil,
              marker_offset_y: 0,
              solid_profile: nil
            )
              support_width = layout_size(width)
              support_height = layout_size(height)
              support_y = reference.y - layout_gap(gap) - support_height
              support_inset_x = layout_size(inset_x)
              left = layout_box(Box.new(x: reference.x + support_inset_x, y: support_y, width: support_width, height: support_height, rx:))
              right = layout_box(Box.new(x: reference.right - support_inset_x - support_width, y: support_y, width: support_width, height: support_height, rx:))
              hit = layout_box(
                support_pair_hit_box(
                  Box.union([left, right]),
                  inset_x: hit_inset_x,
                  inset_y: hit_inset_y,
                  inset_top: hit_inset_top,
                  inset_bottom: hit_inset_bottom
                ),
                preserve_size: true
              )
              marker = support_pair_marker(right, gap: marker_gap, offset_y: marker_offset_y)

              pair_class.new(
                hit:,
                left:,
                right:,
                marker:,
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
                accent_inset_x: options.fetch(:accent_inset_x, 42),
                accent_inset_y: options.fetch(:accent_inset_y, 62),
                accent_height: options.fetch(:accent_height, 10),
                accent_rows: options[:accent_rows],
                accent_style: options.fetch(:accent_style, :horizontal_pair),
                tones: options.fetch(:tones, {})
              )
            end

            def solid_support_profile_options(config)
              case config
              when Hash
                config.transform_keys(&:to_sym)
              else
                raise ArgumentError, "solid_profile must be a SolidSupportProfile pair or a Hash config"
              end
            end

            def support_pair_hit_box(box, inset_x:, inset_y:, inset_top:, inset_bottom:)
              return LayoutRules.hit_box(box, inset_x:, inset_y:) unless inset_top || inset_bottom

              top = inset_top || inset_y
              bottom = inset_bottom || inset_y
              Box.new(
                x: box.x - inset_x,
                y: box.y - top,
                width: box.width + (inset_x * 2),
                height: box.height + top + bottom,
                rx: box.rx
              )
            end

            def support_pair_marker(right, gap:, offset_y:)
              marker = layout_anchor(right, side: :right, gap:)
              return marker if offset_y.to_f.zero?

              layout_point(Point.new(x: marker.x, y: marker.y + offset_y))
            end
          end
        end
      end
    end
  end
end
