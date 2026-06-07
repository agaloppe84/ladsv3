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
          :left,
          :right,
          :tone,
          :solid_profile
        )

        def self.plissee_lock(hit:, marker:, solid_profile:)
          new(
            variant: :plissee_lock,
            hit:,
            marker:,
            solid_profile:
          )
        end

        def self.magnetic_receivers(hit:, marker:, solid_profile:)
          new(
            variant: :magnetic_receivers,
            hit:,
            marker:,
            solid_profile:
          )
        end

        def self.rail_bavettes(hit:, left:, right:, marker:, tone: :dark, solid_profile:)
          new(
            variant: :rail_bavettes,
            hit:,
            marker:,
            left:,
            right:,
            tone:,
            solid_profile:
          )
        end

        def self.build(variant:, **options)
          case variant.to_sym
          when :plissee_lock
            plissee_lock(
              hit: options.fetch(:hit),
              marker: options.fetch(:marker),
              solid_profile: options.fetch(:solid_profile)
            )
          when :magnetic_receivers
            magnetic_receivers(
              hit: options.fetch(:hit),
              marker: options.fetch(:marker),
              solid_profile: options.fetch(:solid_profile)
            )
          when :rail_bavettes
            rail_bavettes(
              hit: options.fetch(:hit),
              left: options.fetch(:left),
              right: options.fetch(:right),
              marker: options.fetch(:marker),
              tone: options.fetch(:tone, :dark),
              solid_profile: options.fetch(:solid_profile)
            )
          else
            raise ArgumentError, "Unknown closure variant: #{variant}"
          end
        end

        def initialize(
          variant:,
          hit:,
          marker:,
          left: nil,
          right: nil,
          tone: nil,
          solid_profile:
        )
          @variant = variant.to_sym
          raise ArgumentError, "Unknown closure variant: #{variant}" unless VARIANTS.include?(@variant)

          @hit = hit
          @marker = marker
          @left = left
          @right = right
          @tone = tone&.to_sym
          raise ArgumentError, "#{variant} closure requires solid_profile" unless solid_profile

          @solid_profile = solid_profile
        end
      end
    end
  end
end
