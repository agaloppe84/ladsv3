# frozen_string_literal: true

require_relative "geometry"
require_relative "layout_primitives"
require_relative "rails"
require_relative "solid_profiles"

module PublicV2
  module Products
    module ExplodedView
      module HousingGeometry
        module_function

        def expanded_box(box, inset_x:, inset_y:)
          LayoutRules.expand(box, inset_x:, inset_y:)
        end

        def inset_box(parent, inset_x:, y_offset:, height:, rx:)
          Box.new(
            x: parent.x + inset_x,
            y: parent.y + y_offset,
            width: parent.width - (inset_x * 2),
            height:,
            rx:
          )
        end

        def centered_screw_points(box, side_inset:)
          RailGeometry.centered_screw_points(box, side_inset:)
        end

        def symmetric_hole_pairs(box, offsets:, y: box.center_y)
          left = offsets.map { |offset| Point.new(x: box.x + offset, y:) }
          right = offsets.reverse.map { |offset| Point.new(x: box.right - offset, y:) }

          [left, right]
        end
      end

      class HousingElement
        VARIANTS = %i[zipped_coffre cassette].freeze

        attr_reader(
          :variant,
          :hit,
          :body,
          :marker,
          :hole_pairs,
          :roll,
          :screw_points,
          :solid_profile
        )

        def self.zipped_coffre(hit:, body:, marker:, hole_pairs:, solid_profile: nil)
          new(
            variant: :zipped_coffre,
            hit:,
            body:,
            marker:,
            hole_pairs:,
            solid_profile:
          )
        end

        def self.cassette(hit:, body:, roll:, marker:, screw_points:)
          new(
            variant: :cassette,
            hit:,
            body:,
            roll:,
            marker:,
            screw_points:
          )
        end

        def self.build(variant:, **options)
          case variant.to_sym
          when :zipped_coffre
            zipped_coffre(
              hit: options.fetch(:hit),
              body: options.fetch(:body),
              marker: options.fetch(:marker),
              hole_pairs: options.fetch(:hole_pairs),
              solid_profile: options.fetch(:solid_profile, nil)
            )
          when :cassette
            cassette(
              hit: options.fetch(:hit),
              body: options.fetch(:body),
              roll: options.fetch(:roll),
              marker: options.fetch(:marker),
              screw_points: options.fetch(:screw_points)
            )
          else
            raise ArgumentError, "Unknown housing variant: #{variant}"
          end
        end

        def initialize(
          variant:,
          hit:,
          body:,
          marker:,
          hole_pairs: [],
          roll: nil,
          screw_points: [],
          solid_profile: nil
        )
          @variant = variant.to_sym
          raise ArgumentError, "Unknown housing variant: #{variant}" unless VARIANTS.include?(@variant)

          @hit = hit
          @body = body
          @marker = marker
          @hole_pairs = hole_pairs
          @roll = roll
          @screw_points = screw_points
          @solid_profile = solid_profile
        end

        def with_solid_profile(solid_profile)
          self.class.new(
            variant:,
            hit:,
            body:,
            marker:,
            hole_pairs:,
            roll:,
            screw_points:,
            solid_profile:
          )
        end

        def holes
          hole_pairs.flatten
        end

      end
    end
  end
end
