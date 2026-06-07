# frozen_string_literal: true

require_relative "geometry"
require_relative "layout_primitives"
require_relative "solid_profiles"

module PublicV2
  module Products
    module ExplodedView
      module BarGeometry
        module_function

        def centered_box(center_x:, center_y:, width:, height:, rx:)
          LayoutRules.centered_on(center_x:, center_y:, width:, height:, rx:)
        end

        def horizontal_center_line(box, inset_x:)
          "M#{box.x + inset_x} #{box.center_y}H#{box.right - inset_x}"
        end

        def vertical_ticks(box, inset_x:, inset_y:)
          "M#{box.x + inset_x} #{box.y + inset_y}V#{box.bottom - inset_y}" \
            "M#{box.right - inset_x} #{box.y + inset_y}V#{box.bottom - inset_y}"
        end

        def threshold_detail_path(box, line_inset_x:, tick_inset_x:, tick_inset_y:)
          horizontal_center_line(box, inset_x: line_inset_x) +
            vertical_ticks(box, inset_x: tick_inset_x, inset_y: tick_inset_y)
        end

        def side_center_points(box, inset_x:)
          [
            Point.new(x: box.x + inset_x, y: box.center_y),
            Point.new(x: box.right - inset_x, y: box.center_y)
          ]
        end

        def translate_points(points, y:)
          points.map { |point| Point.new(x: point.x, y:) }
        end
      end

      class BarElement
        VARIANTS = %i[zipped_load_bar vertical_handle threshold bottom_bar].freeze

        attr_reader(
          :variant,
          :hit,
          :body,
          :top,
          :height,
          :marker,
          :grip,
          :magnet_points,
          :detail_inset_x,
          :tick_inset_x,
          :tick_inset_y,
          :solid_profile
        )

        def self.build(variant:, **options)
          case variant.to_sym
          when :zipped_load_bar
            zipped_load_bar(
              hit: options.fetch(:hit),
              body: options.fetch(:body),
              top: options.fetch(:top),
              height: options.fetch(:height),
              marker: options.fetch(:marker),
              grip: options.fetch(:grip),
              solid_profile: options.fetch(:solid_profile, nil)
            )
          when :vertical_handle
            vertical_handle(
              hit: options.fetch(:hit),
              body: options.fetch(:body),
              marker: options.fetch(:marker),
              grip: options.fetch(:grip),
              solid_profile: options.fetch(:solid_profile, nil)
            )
          when :threshold
            threshold(
              hit: options.fetch(:hit),
              body: options.fetch(:body),
              marker: options.fetch(:marker),
              detail_inset_x: options.fetch(:detail_inset_x, 180),
              tick_inset_x: options.fetch(:tick_inset_x, 520),
              tick_inset_y: options.fetch(:tick_inset_y, 24),
              solid_profile: options.fetch(:solid_profile, nil)
            )
          when :bottom_bar
            bottom_bar(
              hit: options.fetch(:hit),
              body: options.fetch(:body),
              marker: options.fetch(:marker),
              grip: options.fetch(:grip),
              magnet_points: options.fetch(:magnet_points),
              detail_inset_x: options.fetch(:detail_inset_x, 190),
              solid_profile: options.fetch(:solid_profile, nil)
            )
          else
            raise ArgumentError, "Unknown bar variant: #{variant}"
          end
        end

        def self.zipped_load_bar(hit:, body:, top:, height:, marker:, grip:, solid_profile: nil)
          new(
            variant: :zipped_load_bar,
            hit:,
            body:,
            top:,
            height:,
            marker:,
            grip:,
            solid_profile:
          )
        end

        def self.vertical_handle(hit:, body:, marker:, grip:, solid_profile: nil)
          new(
            variant: :vertical_handle,
            hit:,
            body:,
            marker:,
            grip:,
            solid_profile:
          )
        end

        def self.threshold(hit:, body:, marker:, detail_inset_x: 180, tick_inset_x: 520, tick_inset_y: 24, solid_profile: nil)
          new(
            variant: :threshold,
            hit:,
            body:,
            marker:,
            detail_inset_x:,
            tick_inset_x:,
            tick_inset_y:,
            solid_profile:
          )
        end

        def self.bottom_bar(hit:, body:, marker:, grip:, magnet_points:, detail_inset_x: 190, solid_profile: nil)
          new(
            variant: :bottom_bar,
            hit:,
            body:,
            marker:,
            grip:,
            magnet_points:,
            detail_inset_x:,
            solid_profile:
          )
        end

        def initialize(
          variant:,
          hit:,
          marker:,
          body: nil,
          top: nil,
          height: nil,
          grip: nil,
          magnet_points: [],
          detail_inset_x: nil,
          tick_inset_x: nil,
          tick_inset_y: nil,
          solid_profile: nil
        )
          @variant = variant.to_sym
          raise ArgumentError, "Unknown bar variant: #{variant}" unless VARIANTS.include?(@variant)

          @hit = hit
          @body = body
          @top = top
          @height = height
          @marker = marker
          @grip = grip
          @magnet_points = magnet_points
          @detail_inset_x = detail_inset_x
          @tick_inset_x = tick_inset_x
          @tick_inset_y = tick_inset_y
          @solid_profile = solid_profile
        end

        def with_solid_profile(solid_profile)
          self.class.new(
            variant:,
            hit:,
            marker:,
            body:,
            top:,
            height:,
            grip:,
            magnet_points:,
            detail_inset_x:,
            tick_inset_x:,
            tick_inset_y:,
            solid_profile:
          )
        end

        def bottom
          return top + height if top && height

          require_option(:body).bottom
        end

        def outline_path
          require_variant(:zipped_load_bar, "outline_path")

          "M1165 #{top}H6635Q6685 #{top} 6710 #{top + 48}" \
            "L6740 #{top + 108}Q6762 #{top + 154} 6718 #{bottom}" \
            "H1082Q1038 #{bottom} 1060 #{top + 108}" \
            "L1090 #{top + 48}Q1115 #{top} 1165 #{top}Z"
        end

        def handle
          require_variant(:zipped_load_bar, "handle")

          grip || BarGeometry.centered_box(center_x: 3_900, center_y: top + 85, width: 420, height: 50, rx: 18)
        end

        def detail_path
          case variant
          when :zipped_load_bar
            "M1260 #{top}V#{bottom}M6540 #{top}V#{bottom}M1430 #{top + 50}V#{top + 136}M6370 #{top + 50}V#{top + 136}"
          when :threshold
            BarGeometry.threshold_detail_path(
              body,
              line_inset_x: require_option(:detail_inset_x),
              tick_inset_x: require_option(:tick_inset_x),
              tick_inset_y: require_option(:tick_inset_y)
            )
          when :bottom_bar
            BarGeometry.horizontal_center_line(body, inset_x: require_option(:detail_inset_x))
          else
            raise ArgumentError, "#{variant} bar does not define detail_path"
          end
        end

        private

        def require_option(name)
          value = public_send(name)
          raise ArgumentError, "#{variant} bar requires #{name}" if value.nil?

          value
        end

        def require_variant(expected_variant, method_name)
          return if variant == expected_variant

          raise ArgumentError, "#{variant} bar does not define #{method_name}"
        end
      end
    end
  end
end
