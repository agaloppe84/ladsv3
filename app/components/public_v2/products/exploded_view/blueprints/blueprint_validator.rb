# frozen_string_literal: true

require_relative "../blueprint_specs/validator"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        class BlueprintValidator
          PRIMARY_BOX_METHODS = %i[
            hit
            body
            left
            right
            tube
            head
            roll
            grip
          ].freeze

          PRIMARY_POINT_METHODS = %i[marker].freeze
          VALID_TEXT_ANCHORS = %w[start middle end].freeze
          VALID_BASELINES = %w[middle central hanging text-before-edge text-after-edge].freeze
          VALID_ANIMATION_PROFILES = %i[draw none].freeze

          Result = Struct.new(:blueprint, :errors, :warnings, keyword_init: true) do
            def ok?
              errors.empty?
            end

            def name
              blueprint.class.name.split("::").last
            end

            def summary
              status = ok? ? "OK" : "KO"
              "#{name}: #{status} (#{errors.size} errors, #{warnings.size} warnings)"
            end
          end

          class ValidationError < StandardError; end

          def self.validate_all(root: BlueprintSpecs::Loader::DEFAULT_ROOT)
            validate_specs(root:)
          end

          def self.validate_all!(root: BlueprintSpecs::Loader::DEFAULT_ROOT, output: $stdout)
            validate_specs!(root:, output:)
          end

          def self.validate_specs(root: BlueprintSpecs::Loader::DEFAULT_ROOT)
            BlueprintSpecs::Validator.validate_all(root:)
          end

          def self.validate_specs!(root: BlueprintSpecs::Loader::DEFAULT_ROOT, output: $stdout)
            BlueprintSpecs::Validator.validate_all!(root:, output:)
          end

          def self.validate_spec_layouts(root: BlueprintSpecs::Loader::DEFAULT_ROOT)
            BlueprintSpecs::Validator.validate_layouts(root:)
          end

          def self.validate_spec_layouts!(root: BlueprintSpecs::Loader::DEFAULT_ROOT, output: $stdout)
            BlueprintSpecs::Validator.validate_layouts!(root:, output:)
          end

          def initialize(blueprint)
            @blueprint = blueprint
            @layout = blueprint.layout
            @errors = []
            @warnings = []
          end

          def validate
            validate_parts_contract
            validate_render_options
            validate_grid_contract
            validate_primary_geometry
            validate_callouts

            Result.new(blueprint:, errors:, warnings:)
          end

          private

          attr_reader :blueprint, :layout, :errors, :warnings

          def validate_parts_contract
            ids = blueprint.parts.map(&:id)
            order = blueprint.part_order

            add_error("part_order contains duplicate ids") if order.uniq.size != order.size
            add_error("part definitions contain duplicate ids") if ids.uniq.size != ids.size
            add_error("part_order does not match part definitions: #{order.inspect} vs #{ids.inspect}") unless order == ids

            ids.each do |id|
              add_error("missing callout for part #{id.inspect}") unless layout.callout(id)
            end
          end

          def validate_render_options
            add_error("show_layout_grid? must return a boolean") unless [true, false].include?(blueprint.show_layout_grid?)
            unless VALID_ANIMATION_PROFILES.include?(blueprint.callout_animation_profile)
              add_error("invalid callout animation profile #{blueprint.callout_animation_profile.inspect}")
            end
          end

          def validate_grid_contract
            grid = layout.grid
            unless grid
              add_error("missing layout grid")
              return
            end

            frame = grid.frame
            add_error("grid frame width must be an integer number of cells") unless divisible?(frame.width, grid.minor_step)
            add_error("grid frame height must be an integer number of cells") unless divisible?(frame.height, grid.minor_step)
            add_error("svg_width must wrap the grid frame and horizontal margin") unless layout.svg_width == frame.right + frame.x
            add_error("svg_height must wrap the grid frame and vertical margin") unless layout.svg_height == frame.bottom + frame.y
            add_error("major grid step must be a multiple of minor grid step") unless divisible?(grid.major_step, grid.minor_step)
          end

          def validate_primary_geometry
            primary_boxes.each do |label, box|
              validate_box(label, box)
            end

            primary_points.each do |label, point|
              validate_point(label, point)
            end
          end

          def validate_callouts
            blueprint.parts.each do |part|
              callout = layout.callout(part.id)
              next unless callout

              validate_callout(part.id, callout)
            end
          end

          def validate_callout(part_id, callout)
            validate_point("callout #{part_id} marker", callout.marker)
            validate_point("callout #{part_id} dot", callout.dot, require_snap: false)
            validate_point("callout #{part_id} text", callout.text, require_snap: false)

            callout.path
            add_error("callout #{part_id} first_length must be positive") unless callout.first_length.to_f.positive?
            add_error("callout #{part_id} has invalid animation profile #{callout.resolved_animation_profile.inspect}") unless VALID_ANIMATION_PROFILES.include?(callout.resolved_animation_profile)
            add_error("callout #{part_id} has invalid text anchor #{callout.resolved_text_anchor.inspect}") unless VALID_TEXT_ANCHORS.include?(callout.resolved_text_anchor.to_s)
            add_error("callout #{part_id} has invalid dominant baseline #{callout.resolved_dominant_baseline.inspect}") unless VALID_BASELINES.include?(callout.resolved_dominant_baseline.to_s)
          rescue ArgumentError => error
            add_error("callout #{part_id} is invalid: #{error.message}")
          end

          def validate_box(label, box)
            add_error("#{label} has non-positive width") unless box.width.to_f.positive?
            add_error("#{label} has non-positive height") unless box.height.to_f.positive?
            add_error("#{label} is outside the SVG canvas") unless box_inside_canvas?(box)
            add_warning("#{label} is outside the layout grid") unless box_inside_grid?(box)
            add_error("#{label} position is not snapped to #{snap_unit}px") unless snapped_position?(box.x, axis: :x) && snapped_position?(box.y, axis: :y)
            add_error("#{label} size is not snapped to #{snap_unit}px") unless snapped_length?(box.width) && snapped_length?(box.height)
          end

          def validate_point(label, point, require_snap: true)
            add_error("#{label} is outside the SVG canvas") unless point_inside_canvas?(point)
            add_warning("#{label} is outside the layout grid") unless point_inside_grid?(point)
            return unless require_snap

            add_error("#{label} is not snapped to #{snap_unit}px") unless snapped_position?(point.x, axis: :x) && snapped_position?(point.y, axis: :y)
          end

          def primary_boxes
            @primary_boxes ||= layout_members.flat_map do |name, value|
              element_boxes(name, value)
            end
          end

          def primary_points
            @primary_points ||= layout_members.flat_map do |name, value|
              element_points(name, value)
            end
          end

          def layout_members
            layout.each_pair.reject do |name, _value|
              %i[svg_width svg_height grid groups callouts].include?(name)
            end
          end

          def element_boxes(name, value)
            return [] if value.nil?
            return [[name, value]] if value.is_a?(Box)

            PRIMARY_BOX_METHODS.filter_map do |method_name|
              next unless value.respond_to?(method_name)

              box = value.public_send(method_name)
              ["#{name}.#{method_name}", box] if box.is_a?(Box)
            end
          end

          def element_points(name, value)
            return [[name, value]] if value.is_a?(Point)
            return [] if value.nil?

            PRIMARY_POINT_METHODS.filter_map do |method_name|
              next unless value.respond_to?(method_name)

              point = value.public_send(method_name)
              ["#{name}.#{method_name}", point] if point.is_a?(Point)
            end
          end

          def grid_frame
            layout.grid.frame
          end

          def snap_unit
            blueprint.layout_config.fetch(:grid_snap_unit, CanvasSpec::DEFAULT_SNAP_UNIT)
          end

          def box_inside_canvas?(box)
            box.x >= 0 && box.y >= 0 && box.right <= layout.svg_width && box.bottom <= layout.svg_height
          end

          def box_inside_grid?(box)
            box.x >= grid_frame.x && box.y >= grid_frame.y && box.right <= grid_frame.right && box.bottom <= grid_frame.bottom
          end

          def point_inside_canvas?(point)
            point.x >= 0 && point.y >= 0 && point.x <= layout.svg_width && point.y <= layout.svg_height
          end

          def point_inside_grid?(point)
            point.x >= grid_frame.x && point.y >= grid_frame.y && point.x <= grid_frame.right && point.y <= grid_frame.bottom
          end

          def snapped_position?(value, axis:)
            origin = axis == :x ? grid_frame.x : grid_frame.y
            divisible?(value - origin, snap_unit)
          end

          def snapped_length?(value)
            divisible?(value, snap_unit)
          end

          def divisible?(value, step)
            (value.to_f % step).zero?
          end

          def add_error(message)
            errors << message
          end

          def add_warning(message)
            warnings << message
          end
        end
      end
    end
  end
end
