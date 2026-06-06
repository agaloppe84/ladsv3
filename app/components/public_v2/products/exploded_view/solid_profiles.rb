# frozen_string_literal: true

require_relative "geometry"

module PublicV2
  module Products
    module ExplodedView
      SolidBand = Struct.new(:offset, :height, :tone, keyword_init: true) do
        def self.coerce(value)
          value.is_a?(self) ? value : new(**value)
        end

        def tone
          self[:tone].to_sym
        end
      end

      SolidPoint = Struct.new(:point, :radius, :tone, keyword_init: true) do
        def self.coerce(value, radius: 20, tone: :dark)
          case value
          when self
            value
          when Point
            new(point: value, radius:, tone:)
          else
            new(**value)
          end
        end

        def radius
          self[:radius] || 20
        end

        def tone
          (self[:tone] || :dark).to_sym
        end
      end

      class SolidProfile
        AXES = %i[horizontal vertical].freeze

        attr_reader :id, :variant, :axis, :box, :clip_box, :bands, :points

        def initialize(id:, box:, bands:, points: [], variant: :linear_profile, axis: :horizontal, clip_box: nil)
          @id = id.to_s
          @variant = variant.to_sym
          @axis = axis.to_sym
          raise ArgumentError, "Unknown solid profile axis: #{axis}" unless AXES.include?(@axis)

          @box = box
          @clip_box = clip_box || box
          @bands = bands.map { |band| SolidBand.coerce(band) }.freeze
          @points = points.map { |point| SolidPoint.coerce(point) }.freeze
        end

        def tones
          (bands.map(&:tone) + points.map(&:tone)).uniq
        end

        def horizontal?
          axis == :horizontal
        end

        def vertical?
          axis == :vertical
        end
      end

      module SolidProfiles
        LINEAR_THREE_BAND_TONES = {
          cap: :light,
          middle: :mid,
          point: :dark
        }.freeze

        module_function

        def horizontal_rail(id:, box:, screw_points:, cap_ratio: 0.29, point_radius: 24, tones: {})
          linear_three_band(
            id:,
            box:,
            axis: :horizontal,
            variant: :horizontal_rail,
            points: screw_points,
            cap_ratio:,
            point_radius:,
            tones:
          )
        end

        def vertical_rail(id:, box:, slot_ys:, cap_ratio: 0.29, point_radius: 18, tones: {})
          linear_three_band(
            id:,
            box:,
            axis: :vertical,
            variant: :vertical_rail,
            points: slot_ys.map { |y| Point.new(x: box.center_x, y:) },
            cap_ratio:,
            point_radius:,
            tones:
          )
        end

        def vertical_rail_pair(id:, left:, right:, slot_ys:, cap_ratio: 0.29, point_radius: 18, tones: {})
          {
            left: vertical_rail(id: "#{id}-left", box: left, slot_ys:, cap_ratio:, point_radius:, tones:),
            right: vertical_rail(id: "#{id}-right", box: right, slot_ys:, cap_ratio:, point_radius:, tones:)
          }
        end

        def linear_three_band(id:, box:, axis:, points:, cap_ratio:, point_radius:, tones:, variant:)
          cross_size = axis.to_sym == :vertical ? box.width : box.height
          cap_size = (cross_size * cap_ratio).round
          middle_size = cross_size - (cap_size * 2)
          raise ArgumentError, "#{variant} solid profile needs a positive middle band" if middle_size <= 0

          resolved_tones = LINEAR_THREE_BAND_TONES.merge((tones || {}).transform_keys(&:to_sym))

          SolidProfile.new(
            id:,
            variant:,
            axis:,
            box:,
            bands: [
              SolidBand.new(offset: 0, height: cap_size, tone: resolved_tones.fetch(:cap)),
              SolidBand.new(offset: cap_size, height: middle_size, tone: resolved_tones.fetch(:middle)),
              SolidBand.new(offset: cross_size - cap_size, height: cap_size, tone: resolved_tones.fetch(:cap))
            ],
            points: points.map do |point|
              SolidPoint.new(point:, radius: point_radius, tone: resolved_tones.fetch(:point))
            end
          )
        end
      end
    end
  end
end
