# frozen_string_literal: true

require_relative "geometry"
require_relative "solid_profiles"

module PublicV2
  module Products
    module ExplodedView
      SlatPatternLayer = Struct.new(:id, :path, :tone, keyword_init: true) do
        def self.coerce(value)
          value.is_a?(self) ? value : new(**value)
        end

        def tone
          (self[:tone] || :light).to_sym
        end
      end

      class SlatPattern
        attr_reader :id, :variant, :clip_box, :layers, :axis

        def initialize(id:, variant:, clip_box:, layers:, axis: :horizontal)
          @id = id.to_s
          @variant = variant.to_sym
          @clip_box = clip_box
          @layers = layers.map { |layer| SlatPatternLayer.coerce(layer) }.freeze
          @axis = axis.to_sym
        end

        def tones
          layers.map(&:tone).uniq
        end
      end

      module SlatPatterns
        VENETIAN_TONE_CYCLE = %i[light mid light mid].freeze

        module_function

        def venetian_pack(id:, slats:, tone_cycle: VENETIAN_TONE_CYCLE)
          SlatPattern.new(
            id:,
            variant: :venetian_pack,
            clip_box: Box.new(
              x: slats.body.x,
              y: slats.slat_top,
              width: slats.body.width,
              height: slats.slat_bottom - slats.slat_top,
              rx: 0
            ),
            axis: :horizontal,
            layers: slats.slat_centers.map.with_index do |center_y, index|
              SlatPatternLayer.new(
                id: "slat-#{index + 1}",
                path: slats.slat_path(center_y),
                tone: tone_cycle[index % tone_cycle.length]
              )
            end
          )
        end
      end

      class SlatElement
        VARIANTS = %i[venetian_pack].freeze

        attr_reader(
          :variant,
          :hit,
          :body,
          :marker,
          :slat_count,
          :slat_height,
          :tilt,
          :ladder_xs,
          :lift_cord_xs,
          :slat_pattern,
          :cord_solid_profile
        )

        def self.build(variant:, **options)
          case variant.to_sym
          when :venetian_pack
            venetian_pack(
              hit: options.fetch(:hit),
              body: options.fetch(:body),
              marker: options.fetch(:marker),
              slat_count: options.fetch(:slat_count),
              slat_height: options.fetch(:slat_height),
              tilt: options.fetch(:tilt),
              ladder_xs: options.fetch(:ladder_xs),
              lift_cord_xs: options.fetch(:lift_cord_xs),
              slat_pattern: options.fetch(:slat_pattern, nil),
              cord_solid_profile: options.fetch(:cord_solid_profile, nil)
            )
          else
            raise ArgumentError, "Unknown slat variant: #{variant}"
          end
        end

        def self.venetian_pack(hit:, body:, marker:, slat_count:, slat_height:, tilt:, ladder_xs:, lift_cord_xs:, slat_pattern: nil, cord_solid_profile: nil)
          new(
            variant: :venetian_pack,
            hit:,
            body:,
            marker:,
            slat_count:,
            slat_height:,
            tilt:,
            ladder_xs:,
            lift_cord_xs:,
            slat_pattern:,
            cord_solid_profile:
          )
        end

        def initialize(variant:, hit:, body:, marker:, slat_count:, slat_height:, tilt:, ladder_xs:, lift_cord_xs:, slat_pattern: nil, cord_solid_profile: nil)
          @variant = variant.to_sym
          raise ArgumentError, "Unknown slat variant: #{variant}" unless VARIANTS.include?(@variant)

          @hit = hit
          @body = body
          @marker = marker
          @slat_count = slat_count
          @slat_height = slat_height
          @tilt = tilt
          @ladder_xs = ladder_xs
          @lift_cord_xs = lift_cord_xs
          @slat_pattern = slat_pattern
          @cord_solid_profile = cord_solid_profile
        end

        def with_cord_solid_profile(cord_solid_profile)
          self.class.new(
            variant:,
            hit:,
            body:,
            marker:,
            slat_count:,
            slat_height:,
            tilt:,
            ladder_xs:,
            lift_cord_xs:,
            slat_pattern:,
            cord_solid_profile:
          )
        end

        def with_slat_pattern(slat_pattern)
          self.class.new(
            variant:,
            hit:,
            body:,
            marker:,
            slat_count:,
            slat_height:,
            tilt:,
            ladder_xs:,
            lift_cord_xs:,
            slat_pattern:,
            cord_solid_profile:
          )
        end

        def slat_centers
          step = (body.height - slat_height) / (slat_count - 1)

          Array.new(slat_count) { |index| body.y + (slat_height / 2) + (index * step) }
        end

        def slat_top
          slat_centers.first - (slat_height / 2)
        end

        def slat_bottom
          slat_centers.last + (slat_height / 2)
        end

        def slat_path(center_y)
          top = center_y - (slat_height / 2)
          bottom = center_y + (slat_height / 2)
          side_inset = tilt
          points = [
            Point.new(x: body.x + side_inset, y: top),
            Point.new(x: body.right - side_inset, y: top),
            Point.new(x: body.right, y: bottom),
            Point.new(x: body.x, y: bottom)
          ]

          rounded_polygon_path(points, radius: slat_corner_radius)
        end

        def cord_xs
          (ladder_xs + lift_cord_xs).minmax
        end

        def cord_top
          slat_top - 110
        end

        def cord_bottom
          slat_bottom + 110
        end

        def cord_segment_boxes(segment_width: 12)
          half_width = segment_width / 2

          cord_xs.flat_map do |x|
            cord_segment_ranges.map do |top, bottom|
              Box.new(
                x: x - half_width,
                y: top,
                width: segment_width,
                height: bottom - top,
                rx: half_width
              )
            end
          end
        end

        def cord_points
          cord_xs.flat_map do |x|
            slat_centers.map { |center_y| Point.new(x:, y: center_y) }
          end
        end

        private

        def slat_corner_radius
          [16, slat_height / 4, tilt / 2].min
        end

        def cord_segment_ranges
          centers = slat_centers
          ranges = [[cord_top, centers.first]]

          centers.each_cons(2) do |previous_center, center_y|
            previous_bottom = previous_center + (slat_height / 2)
            ranges << [previous_bottom, center_y]
          end

          ranges << [slat_bottom, cord_bottom]
        end

        def rounded_polygon_path(points, radius:)
          rounded_points = points.each_with_index.map do |point, index|
            previous_point = points[index - 1]
            next_point = points[(index + 1) % points.length]

            {
              point:,
              in: point_toward(point, previous_point, radius),
              out: point_toward(point, next_point, radius)
            }
          end
          first = rounded_points.first
          path = "M#{point_token(first.fetch(:out))}"

          rounded_points.drop(1).each do |rounded_point|
            path += "L#{point_token(rounded_point.fetch(:in))}" \
              "Q#{point_token(rounded_point.fetch(:point))} #{point_token(rounded_point.fetch(:out))}"
          end

          path + "L#{point_token(first.fetch(:in))}" \
            "Q#{point_token(first.fetch(:point))} #{point_token(first.fetch(:out))}Z"
        end

        def point_toward(point, target, distance)
          dx = target.x - point.x
          dy = target.y - point.y
          length = Math.sqrt((dx * dx) + (dy * dy))
          return point if length.zero?

          ratio = [distance / length, 1].min
          Point.new(x: point.x + (dx * ratio), y: point.y + (dy * ratio))
        end

        def point_token(point)
          "#{format_number(point.x)} #{format_number(point.y)}"
        end

        def format_number(value)
          value.to_i == value ? value.to_i : value.round(2)
        end
      end
    end
  end
end
