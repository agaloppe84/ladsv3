# frozen_string_literal: true

require_relative "geometry"

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
          :bead_count
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
              bead_count: options.fetch(:bead_count)
            )
          else
            raise ArgumentError, "Unknown control variant: #{variant}"
          end
        end

        def self.venetian_wand(hit:, body:, marker:, cord_top:, cord_bottom:, bead_count:)
          new(
            variant: :venetian_wand,
            hit:,
            body:,
            marker:,
            cord_top:,
            cord_bottom:,
            bead_count:
          )
        end

        def initialize(variant:, hit:, body:, marker:, cord_top:, cord_bottom:, bead_count:)
          @variant = variant.to_sym
          raise ArgumentError, "Unknown control variant: #{variant}" unless VARIANTS.include?(@variant)

          @hit = hit
          @body = body
          @marker = marker
          @cord_top = cord_top
          @cord_bottom = cord_bottom
          @bead_count = bead_count
        end

        def cord_path
          "M#{cord_top.x} #{cord_top.y}V#{cord_bottom.y}"
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
