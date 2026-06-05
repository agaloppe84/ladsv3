# frozen_string_literal: true

require_relative "geometry"

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
          :marker
        )

        def self.tubular(hit:, tube:, tube_cap_width:, head:, marker:)
          new(
            variant: :tubular,
            hit:,
            tube:,
            tube_cap_width:,
            head:,
            marker:
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
              marker: options.fetch(:marker)
            )
          else
            raise ArgumentError, "Unknown motor variant: #{variant}"
          end
        end

        def initialize(variant:, hit:, tube:, tube_cap_width:, head:, marker:)
          @variant = variant.to_sym
          raise ArgumentError, "Unknown motor variant: #{variant}" unless VARIANTS.include?(@variant)

          @hit = hit
          @tube = tube
          @tube_cap_width = tube_cap_width
          @head = head
          @marker = marker
        end

        def tube_cap_path
          cap_right = tube.x + tube_cap_width

          "M#{tube.x + tube.rx} #{tube.y}H#{cap_right}V#{tube.bottom}H#{tube.x + tube.rx}" \
            "Q#{tube.x} #{tube.bottom} #{tube.x} #{tube.bottom - tube.rx}" \
            "V#{tube.y + tube.rx}Q#{tube.x} #{tube.y} #{tube.x + tube.rx} #{tube.y}Z"
        end

        def tube_path
          "M#{tube.x + tube.rx} #{tube.y}H#{tube.right}V#{tube.bottom}H#{tube.x + tube.rx}" \
            "Q#{tube.x} #{tube.bottom} #{tube.x} #{tube.bottom - tube.rx}" \
            "V#{tube.y + tube.rx}Q#{tube.x} #{tube.y} #{tube.x + tube.rx} #{tube.y}Z"
        end

        def detail_path
          "M#{tube.x + tube_cap_width} #{tube.y}V#{tube.bottom}"
        end

        def head_path
          right_radius = head.rx

          "M#{head.x} #{head.y}H#{head.right - right_radius}" \
            "Q#{head.right} #{head.y} #{head.right} #{head.y + right_radius}" \
            "V#{head.bottom - right_radius}Q#{head.right} #{head.bottom} #{head.right - right_radius} #{head.bottom}" \
            "H#{head.x}V#{head.y}Z"
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
