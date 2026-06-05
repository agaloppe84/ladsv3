# frozen_string_literal: true

require_relative "geometry"
require_relative "layout_primitives"
require_relative "rails"

module PublicV2
  module Products
    module ExplodedView
      module HousingGeometry
        module_function

        def rounded_box_path(box)
          RailGeometry.rounded_box_path(box)
        end

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
          :screw_points
        )

        def self.zipped_coffre(hit:, body:, marker:, hole_pairs:)
          new(
            variant: :zipped_coffre,
            hit:,
            body:,
            marker:,
            hole_pairs:
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

        def initialize(
          variant:,
          hit:,
          body:,
          marker:,
          hole_pairs: [],
          roll: nil,
          screw_points: []
        )
          @variant = variant.to_sym
          raise ArgumentError, "Unknown housing variant: #{variant}" unless VARIANTS.include?(@variant)

          @hit = hit
          @body = body
          @marker = marker
          @hole_pairs = hole_pairs
          @roll = roll
          @screw_points = screw_points
        end

        def holes
          hole_pairs.flatten
        end

        def outline_path
          HousingGeometry.rounded_box_path(body)
        end

        def roll_path
          raise ArgumentError, "#{variant} housing does not define roll_path" if roll.nil?

          HousingGeometry.rounded_box_path(roll)
        end
      end
    end
  end
end
