# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      class ClosureElement
        VARIANTS = %i[plissee_lock magnetic_receivers rail_bavettes].freeze

        attr_reader(
          :variant,
          :hit,
          :marker,
          :catches,
          :receiver_points,
          :radius,
          :left,
          :right
        )

        def self.plissee_lock(hit:, marker:, catches:, radius:)
          new(
            variant: :plissee_lock,
            hit:,
            marker:,
            catches:,
            radius:
          )
        end

        def self.magnetic_receivers(hit:, marker:, receiver_points:, radius:)
          new(
            variant: :magnetic_receivers,
            hit:,
            marker:,
            receiver_points:,
            radius:
          )
        end

        def self.rail_bavettes(hit:, left:, right:, marker:)
          new(
            variant: :rail_bavettes,
            hit:,
            marker:,
            left:,
            right:
          )
        end

        def initialize(
          variant:,
          hit:,
          marker:,
          catches: [],
          receiver_points: [],
          radius: nil,
          left: nil,
          right: nil
        )
          @variant = variant.to_sym
          raise ArgumentError, "Unknown closure variant: #{variant}" unless VARIANTS.include?(@variant)

          @hit = hit
          @marker = marker
          @catches = catches
          @receiver_points = receiver_points
          @radius = radius
          @left = left
          @right = right
        end

        def catch_path(point)
          require_variant(:plissee_lock, "catch_path")

          "M#{point.x} #{point.y - radius}" \
            "A#{radius} #{radius} 0 0 1 #{point.x} #{point.y + radius}" \
            "L#{point.x} #{point.y - radius}Z"
        end

        def echo_paths(point)
          require_variant(:plissee_lock, "echo_paths")

          [radius + 34, radius + 74, radius + 114].map do |echo_radius|
            "M#{point.x} #{point.y - echo_radius}" \
              "A#{echo_radius} #{echo_radius} 0 0 1 #{point.x} #{point.y + echo_radius}"
          end
        end

        def receiver_path(point)
          require_variant(:magnetic_receivers, "receiver_path")

          "M#{point.x - radius} #{point.y}A#{radius} #{radius} 0 0 0 #{point.x + radius} #{point.y}" \
            "M#{point.x - (radius + 42)} #{point.y + 58}H#{point.x + radius + 42}"
        end

        private

        def require_variant(expected_variant, method_name)
          return if variant == expected_variant

          raise ArgumentError, "#{variant} closure does not define #{method_name}"
        end
      end
    end
  end
end
