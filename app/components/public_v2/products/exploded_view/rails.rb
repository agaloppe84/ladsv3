# frozen_string_literal: true

require_relative "geometry"

module PublicV2
  module Products
    module ExplodedView
      module RailGeometry
        module_function

        ZIP_COULISSE = {
          outer_left_x: 570,
          inner_left_x: 606,
          inner_right_x: 712,
          outer_right_x: 748,
          radius: 38
        }.freeze

        def rounded_box_path(box)
          "M#{box.x + box.rx} #{box.y}H#{box.right - box.rx}" \
            "Q#{box.right} #{box.y} #{box.right} #{box.y + box.rx}" \
            "V#{box.bottom - box.rx}Q#{box.right} #{box.bottom} #{box.right - box.rx} #{box.bottom}" \
            "H#{box.x + box.rx}Q#{box.x} #{box.bottom} #{box.x} #{box.bottom - box.rx}" \
            "V#{box.y + box.rx}Q#{box.x} #{box.y} #{box.x + box.rx} #{box.y}Z"
        end

        def horizontal_inner_path(box, inset_y:)
          "M#{box.x} #{box.y + inset_y}H#{box.right}" \
            "M#{box.x} #{box.bottom - inset_y}H#{box.right}"
        end

        def vertical_inner_path(box, inset_x:, top: box.y, bottom: box.bottom)
          "M#{box.x + inset_x} #{top}V#{bottom}" \
            "M#{box.right - inset_x} #{top}V#{bottom}"
        end

        def distributed_positions(start:, finish:, count:)
          raise ArgumentError, "count must be greater than 0" if count.to_i < 1

          step = (finish - start) / (count + 1)

          Array.new(count) { |index| start + step + (index * step) }
        end

        def centered_screw_points(box, side_inset:)
          [
            Point.new(x: box.x + side_inset, y: box.center_y),
            Point.new(x: box.center_x, y: box.center_y),
            Point.new(x: box.right - side_inset, y: box.center_y)
          ]
        end
      end

      class RailElement
        VARIANTS = %i[zipped_coulisse horizontal_guide vertical_pair].freeze

        attr_reader(
          :variant,
          :hit,
          :body,
          :left,
          :right,
          :top,
          :bottom,
          :marker,
          :slot_ys,
          :inner_inset_x,
          :inner_inset_y,
          :inner_top_inset,
          :inner_bottom_inset,
          :screw_side_inset
        )

        def self.zipped_coulisse(top:, bottom:, hit:, marker:)
          new(
            variant: :zipped_coulisse,
            top:,
            bottom:,
            hit:,
            marker:
          )
        end

        def self.horizontal_guide(hit:, body:, marker:, inner_inset_y: 58, screw_side_inset: 680)
          new(
            variant: :horizontal_guide,
            hit:,
            body:,
            marker:,
            inner_inset_y:,
            screw_side_inset:
          )
        end

        def self.vertical_pair(
          hit:,
          left:,
          right:,
          marker:,
          slot_ys:,
          inner_inset_x:,
          inner_top_inset: 0,
          inner_bottom_inset: 0
        )
          new(
            variant: :vertical_pair,
            hit:,
            left:,
            right:,
            marker:,
            slot_ys:,
            inner_inset_x:,
            inner_top_inset:,
            inner_bottom_inset:
          )
        end

        def initialize(
          variant:,
          hit:,
          marker:,
          body: nil,
          left: nil,
          right: nil,
          top: nil,
          bottom: nil,
          slot_ys: [],
          inner_inset_x: nil,
          inner_inset_y: nil,
          inner_top_inset: 0,
          inner_bottom_inset: 0,
          screw_side_inset: nil
        )
          @variant = variant.to_sym
          raise ArgumentError, "Unknown rail variant: #{variant}" unless VARIANTS.include?(@variant)

          @hit = hit
          @body = body
          @left = left
          @right = right
          @top = top
          @bottom = bottom
          @marker = marker
          @slot_ys = slot_ys
          @inner_inset_x = inner_inset_x
          @inner_inset_y = inner_inset_y
          @inner_top_inset = inner_top_inset
          @inner_bottom_inset = inner_bottom_inset
          @screw_side_inset = screw_side_inset
        end

        def outline_path(box = nil)
          return zipped_coulisse_outline_path if variant == :zipped_coulisse

          RailGeometry.rounded_box_path(box || require_option(:body))
        end

        def profile_path
          require_variant(:zipped_coulisse, "profile_path")

          geometry = RailGeometry::ZIP_COULISSE

          "M#{geometry.fetch(:inner_left_x)} #{top}V#{bottom}" \
            "M#{geometry.fetch(:inner_right_x)} #{top}V#{bottom}"
        end

        def inner_path(box = nil, bottom_y = nil)
          case variant
          when :horizontal_guide
            RailGeometry.horizontal_inner_path(body, inset_y: require_option(:inner_inset_y))
          when :vertical_pair
            rail = box || require_option(:left)
            RailGeometry.vertical_inner_path(
              rail,
              inset_x: require_option(:inner_inset_x),
              top: rail.y + inner_top_inset,
              bottom: bottom_y || rail.bottom - inner_bottom_inset
            )
          else
            raise ArgumentError, "#{variant} rail does not define inner_path"
          end
        end

        def screw_points
          require_variant(:horizontal_guide, "screw_points")

          RailGeometry.centered_screw_points(body, side_inset: require_option(:screw_side_inset))
        end

        private

        def zipped_coulisse_outline_path
          geometry = RailGeometry::ZIP_COULISSE
          radius = geometry.fetch(:radius)

          "M#{geometry.fetch(:inner_left_x) + 2} #{top}H#{geometry.fetch(:inner_right_x) - 2}" \
            "Q#{geometry.fetch(:outer_right_x)} #{top} #{geometry.fetch(:outer_right_x)} #{top + radius}" \
            "V#{bottom - radius}Q#{geometry.fetch(:outer_right_x)} #{bottom} #{geometry.fetch(:inner_right_x) - 2} #{bottom}" \
            "H#{geometry.fetch(:inner_left_x) + 2}Q#{geometry.fetch(:outer_left_x)} #{bottom} #{geometry.fetch(:outer_left_x)} #{bottom - radius}" \
            "V#{top + radius}Q#{geometry.fetch(:outer_left_x)} #{top} #{geometry.fetch(:inner_left_x) + 2} #{top}Z"
        end

        def require_option(name)
          value = public_send(name)
          raise ArgumentError, "#{variant} rail requires #{name}" if value.nil?

          value
        end

        def require_variant(expected_variant, method_name)
          return if variant == expected_variant

          raise ArgumentError, "#{variant} rail does not define #{method_name}"
        end
      end
    end
  end
end
