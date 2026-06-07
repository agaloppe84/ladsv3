# frozen_string_literal: true

require_relative "geometry"
require_relative "solid_profiles"

module PublicV2
  module Products
    module ExplodedView
      class MotorElement
        VARIANTS = %i[tubular].freeze

        attr_reader(
          :variant,
          :hit,
          :tube,
          :tube_cap_width,
          :head,
          :marker,
          :solid_profile
        )

        def self.tubular(hit:, tube:, tube_cap_width:, head:, marker:, solid_profile: nil)
          new(
            variant: :tubular,
            hit:,
            tube:,
            tube_cap_width:,
            head:,
            marker:,
            solid_profile:
          )
        end

        def self.build(variant:, **options)
          case variant.to_sym
          when :tubular
            tubular(
              hit: options.fetch(:hit),
              tube: options.fetch(:tube),
              tube_cap_width: options.fetch(:tube_cap_width),
              head: options.fetch(:head),
              marker: options.fetch(:marker),
              solid_profile: options.fetch(:solid_profile, nil)
            )
          else
            raise ArgumentError, "Unknown motor variant: #{variant}"
          end
        end

        def initialize(variant:, hit:, tube:, tube_cap_width:, head:, marker:, solid_profile: nil)
          @variant = variant.to_sym
          raise ArgumentError, "Unknown motor variant: #{variant}" unless VARIANTS.include?(@variant)

          @hit = hit
          @tube = tube
          @tube_cap_width = tube_cap_width
          @head = head
          @marker = marker
          @solid_profile = solid_profile
        end

        def with_solid_profile(solid_profile)
          self.class.new(
            variant:,
            hit:,
            tube:,
            tube_cap_width:,
            head:,
            marker:,
            solid_profile:
          )
        end

        def large_hole
          Point.new(x: head.x + 175, y: head.center_y)
        end

        def small_holes
          [
            Point.new(x: head.x + 50, y: head.center_y - 44),
            Point.new(x: head.x + 50, y: head.center_y + 44)
          ]
        end
      end
    end
  end
end
