# frozen_string_literal: true

require_relative "geometry"
require_relative "solid_profiles"

module PublicV2
  module Products
    module ExplodedView
      module RailGeometry
        module_function

        ZIP_COULISSE = {
          outer_left_x: 570,
          inner_left_x: 606,
          inner_right_x: 712,
          outer_right_x: 748,
          radius: 38
        }.freeze

        def distributed_positions(start:, finish:, count:)
          raise ArgumentError, "count must be greater than 0" if count.to_i < 1

          step = (finish - start) / (count + 1)

          Array.new(count) { |index| start + step + (index * step) }
        end

        def centered_screw_points(box, side_inset:)
          [
            Point.new(x: box.x + side_inset, y: box.center_y),
            Point.new(x: box.center_x, y: box.center_y),
            Point.new(x: box.right - side_inset, y: box.center_y)
          ]
        end
      end

      RailAttachedFeature = Struct.new(:id, :slot, :left, :right, :tone, keyword_init: true) do
        def tone
          (self[:tone] || :dark).to_sym
        end

        def boxes
          [left, right].compact
        end
      end

      class RailElement
        VARIANTS = %i[zipped_coulisse horizontal_guide vertical_pair].freeze

        attr_reader(
          :variant,
          :hit,
          :body,
          :left,
          :right,
          :top,
          :bottom,
          :marker,
          :slot_ys,
          :inner_inset_x,
          :inner_inset_y,
          :inner_top_inset,
          :inner_bottom_inset,
          :screw_side_inset,
          :solid_profile,
          :solid_profiles,
          :attached_features
        )

        def self.build(variant:, **options)
          case variant.to_sym
          when :zipped_coulisse
            zipped_coulisse(
              top: options.fetch(:top),
              bottom: options.fetch(:bottom),
              hit: options.fetch(:hit),
              marker: options.fetch(:marker),
              left: options.fetch(:left, nil),
              right: options.fetch(:right, nil),
              solid_profiles: options.fetch(:solid_profiles, nil)
            )
          when :horizontal_guide
            horizontal_guide(
              hit: options.fetch(:hit),
              body: options.fetch(:body),
              marker: options.fetch(:marker),
              inner_inset_y: options.fetch(:inner_inset_y, 58),
              screw_side_inset: options.fetch(:screw_side_inset, 680),
              solid_profile: options.fetch(:solid_profile, nil)
            )
          when :vertical_pair
            vertical_pair(
              hit: options.fetch(:hit),
              left: options.fetch(:left),
              right: options.fetch(:right),
              marker: options.fetch(:marker),
              slot_ys: options.fetch(:slot_ys),
              inner_inset_x: options.fetch(:inner_inset_x),
              inner_top_inset: options.fetch(:inner_top_inset, 0),
              inner_bottom_inset: options.fetch(:inner_bottom_inset, 0),
              solid_profiles: options.fetch(:solid_profiles, nil),
              attached_features: options.fetch(:attached_features, nil)
            )
          else
            raise ArgumentError, "Unknown rail variant: #{variant}"
          end
        end

        def self.zipped_coulisse(top:, bottom:, hit:, marker:, left: nil, right: nil, solid_profiles: nil)
          new(
            variant: :zipped_coulisse,
            top:,
            bottom:,
            hit:,
            marker:,
            left:,
            right:,
            solid_profiles:
          )
        end

        def self.horizontal_guide(hit:, body:, marker:, inner_inset_y: 58, screw_side_inset: 680, solid_profile: nil)
          new(
            variant: :horizontal_guide,
            hit:,
            body:,
            marker:,
            inner_inset_y:,
            screw_side_inset:,
            solid_profile:
          )
        end

        def self.vertical_pair(
          hit:,
          left:,
          right:,
          marker:,
          slot_ys:,
          inner_inset_x:,
          inner_top_inset: 0,
          inner_bottom_inset: 0,
          solid_profiles: nil,
          attached_features: nil
        )
          new(
            variant: :vertical_pair,
            hit:,
            left:,
            right:,
            marker:,
            slot_ys:,
            inner_inset_x:,
            inner_top_inset:,
            inner_bottom_inset:,
            solid_profiles:,
            attached_features:
          )
        end

        def initialize(
          variant:,
          hit:,
          marker:,
          body: nil,
          left: nil,
          right: nil,
          top: nil,
          bottom: nil,
          slot_ys: [],
          inner_inset_x: nil,
          inner_inset_y: nil,
          inner_top_inset: 0,
          inner_bottom_inset: 0,
          screw_side_inset: nil,
          solid_profile: nil,
          solid_profiles: nil,
          attached_features: nil
        )
          @variant = variant.to_sym
          raise ArgumentError, "Unknown rail variant: #{variant}" unless VARIANTS.include?(@variant)

          @hit = hit
          @body = body
          @left = left
          @right = right
          @top = top
          @bottom = bottom
          @marker = marker
          @slot_ys = slot_ys
          @inner_inset_x = inner_inset_x
          @inner_inset_y = inner_inset_y
          @inner_top_inset = inner_top_inset
          @inner_bottom_inset = inner_bottom_inset
          @screw_side_inset = screw_side_inset
          @solid_profile = solid_profile
          @solid_profiles = normalize_solid_profiles(solid_profiles || (solid_profile ? { body: solid_profile } : {}))
          @attached_features = normalize_attached_features(attached_features || {})
        end

        def with_solid_profile(solid_profile)
          with_solid_profiles({ body: solid_profile }, primary: solid_profile)
        end

        def with_solid_profiles(solid_profiles, primary: nil)
          self.class.new(
            variant:,
            hit:,
            marker:,
            body:,
            left:,
            right:,
            top:,
            bottom:,
            slot_ys:,
            inner_inset_x:,
            inner_inset_y:,
            inner_top_inset:,
            inner_bottom_inset:,
            screw_side_inset:,
            solid_profile: primary,
            solid_profiles:,
            attached_features:
          )
        end

        def solid_profile_for(key)
          solid_profiles[key.to_sym]
        end

        def with_attached_features(attached_features)
          self.class.new(
            variant:,
            hit:,
            marker:,
            body:,
            left:,
            right:,
            top:,
            bottom:,
            slot_ys:,
            inner_inset_x:,
            inner_inset_y:,
            inner_top_inset:,
            inner_bottom_inset:,
            screw_side_inset:,
            solid_profile:,
            solid_profiles:,
            attached_features:
          )
        end

        def attached_feature(key)
          attached_features[key.to_sym]
        end

        def zip_edge_box(side:, y:, height:, width: 54, rx: 8)
          require_variant(:zipped_coulisse, "zip_edge_box")

          side = normalize_side(side)
          rail = solid_profile_side_box(side)
          x = side == :right ? rail.x - width : rail.right

          Box.new(x:, y:, width:, height:, rx:)
        end

        def zip_teeth_side(side)
          normalize_side(side) == :right ? :left : :right
        end

        def screw_points
          require_variant(:horizontal_guide, "screw_points")

          RailGeometry.centered_screw_points(body, side_inset: require_option(:screw_side_inset))
        end

        private

        def normalize_solid_profiles(profiles)
          profiles.transform_keys(&:to_sym).freeze
        end

        def normalize_attached_features(features)
          features.transform_keys(&:to_sym).freeze
        end

        def normalize_side(side)
          side = side.to_sym
          return side if %i[left right].include?(side)

          raise ArgumentError, "Unknown rail side: #{side}"
        end

        def solid_profile_side_box(side)
          rail = public_send(side)
          raise ArgumentError, "#{variant} rail requires #{side} rail box" unless rail

          rail
        end

        def require_option(name)
          value = public_send(name)
          raise ArgumentError, "#{variant} rail requires #{name}" if value.nil?

          value
        end

        def require_variant(expected_variant, method_name)
          return if variant == expected_variant

          raise ArgumentError, "#{variant} rail does not define #{method_name}"
        end
      end
    end
  end
end
