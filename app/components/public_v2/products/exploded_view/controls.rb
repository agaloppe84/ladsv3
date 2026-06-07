# frozen_string_literal: true

require_relative "geometry"
require_relative "solid_profiles"

module PublicV2
  module Products
    module ExplodedView
      class ControlElement
        VARIANTS = %i[venetian_wand].freeze

        attr_reader(
          :variant,
          :hit,
          :body,
          :marker,
          :cord_top,
          :cord_bottom,
          :bead_count,
          :solid_profile
        )

        def self.build(variant:, **options)
          case variant.to_sym
          when :venetian_wand
            venetian_wand(
              hit: options.fetch(:hit),
              body: options.fetch(:body),
              marker: options.fetch(:marker),
              cord_top: options.fetch(:cord_top),
              cord_bottom: options.fetch(:cord_bottom),
              bead_count: options.fetch(:bead_count),
              solid_profile: options.fetch(:solid_profile, nil)
            )
          else
            raise ArgumentError, "Unknown control variant: #{variant}"
          end
        end

        def self.venetian_wand(hit:, body:, marker:, cord_top:, cord_bottom:, bead_count:, solid_profile: nil)
          new(
            variant: :venetian_wand,
            hit:,
            body:,
            marker:,
            cord_top:,
            cord_bottom:,
            bead_count:,
            solid_profile:
          )
        end

        def initialize(variant:, hit:, body:, marker:, cord_top:, cord_bottom:, bead_count:, solid_profile: nil)
          @variant = variant.to_sym
          raise ArgumentError, "Unknown control variant: #{variant}" unless VARIANTS.include?(@variant)

          @hit = hit
          @body = body
          @marker = marker
          @cord_top = cord_top
          @cord_bottom = cord_bottom
          @bead_count = bead_count
          @solid_profile = solid_profile
        end

        def with_solid_profile(solid_profile)
          self.class.new(
            variant:,
            hit:,
            body:,
            marker:,
            cord_top:,
            cord_bottom:,
            bead_count:,
            solid_profile:
          )
        end

        def bead_points
          step = (cord_bottom.y - cord_top.y) / (bead_count - 1)

          Array.new(bead_count) do |index|
            Point.new(x: cord_top.x, y: cord_top.y + (index * step))
          end
        end
      end
    end
  end
end
