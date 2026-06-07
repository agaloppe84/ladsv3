# frozen_string_literal: true

require_relative "../layout_primitives"

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        class PresetSlotLayout
          GENERATED_VERTICAL_FABRIC_RULES = [
            {
              element_preset: "fabric_bordered",
              reference_slot: "top-housing",
              gap: 480,
              inset_x: 480,
              height: :standard,
              rx: :standard
            },
            {
              element_preset: "fabric_duo",
              reference_slot: "roll",
              gap: :exploded_sm,
              width: :standard,
              height: :standard,
              rx: :standard,
              align: :center
            }
          ].freeze

          GENERATED_VERTICAL_BOTTOM_BAR_RULES = [
            {
              element_preset: "bar_bottom_charge",
              reference_slot: "fabric",
              gap: :exploded_md,
              side_extension: 130,
              height: :standard,
              rx: :standard
            },
            {
              element_preset: "bar_venetian_bottom",
              reference_slot: "fabric",
              gap: :slats_to_bottom_bar,
              width: :reference,
              height: :standard,
              rx: :standard
            },
            {
              element_preset: "bar_zipped_load",
              reference_slot: "fabric",
              gap: :fabric_to_load_bar,
              side_extension: 240,
              height: :standard,
              rx: 34
            },
            {
              element_preset: "bar_threshold",
              slot: "bottom-rail",
              reference_slot: "fabric",
              gap: 420,
              side_extension: 140,
              height: 150,
              rx: 32
            }
          ].freeze

          GENERATED_HORIZONTAL_ANCHOR_RULES = [
            {
              element_preset: "rail_horizontal_guide",
              slot: "top-guide",
              x: :center_on_canvas,
              y: 470,
              width: :standard,
              height: :standard,
              rx: :standard
            }
          ].freeze

          GENERATED_HORIZONTAL_FABRIC_RULES = [
            {
              element_preset: "fabric_pleated",
              reference_slot: "top-guide",
              gap: :guide_to_fabric,
              offset_x: 340,
              width: :standard,
              height: :standard,
              rx: :standard
            }
          ].freeze

          GENERATED_HORIZONTAL_BOTTOM_BAR_RULES = [
            {
              element_preset: "bar_threshold",
              slot: "bottom-threshold",
              reference_slot: "fabric",
              x_reference_slot: "top-guide",
              gap: 460,
              inset_x: 160,
              height: :standard,
              rx: :standard
            }
          ].freeze

          attr_reader :blueprint, :assembled, :preset

          def initialize(blueprint:, assembled:)
            @blueprint = blueprint
            @assembled = assembled
            @preset = blueprint.layout_preset_definition
          end

          def element_for_slot(slot, required: false)
            elements = elements_by_slot[slot.to_s] || []
            if elements.empty?
              raise ArgumentError, "layout preset #{preset_id.inspect} needs slot #{slot.inspect}" if required

              return nil
            end
            raise ArgumentError, "layout slot #{slot.inspect} maps to multiple elements: #{elements.map(&:id).join(', ')}" if elements.size > 1

            elements.first
          end

          def box_for_slot(slot, required: true)
            element = element_for_slot(slot, required:)
            return nil unless element

            box_for_element(element, required:)
          end

          def gap_between(upper_slot, lower_slot)
            upper = box_for_slot(upper_slot)
            lower = box_for_slot(lower_slot)

            lower.y - upper.bottom
          end

          def slots_for_stack(name)
            Array(preset&.stack_rules&.fetch(name.to_s, []))
          end

          def explicit_box_for(element, required: true)
            return element.box if element.box
            raise ArgumentError, "element #{element.id.inspect} in slot #{element.slot.inspect} needs an explicit box override" if required

            nil
          end

          private

          def box_for_element(element, required: true)
            slot = element.slot.to_s
            return boxes_by_slot[slot] if boxes_by_slot.key?(slot)

            box = element.box || generated_box_for(element)
            boxes_by_slot[slot] = box if box
            return box if box
            raise ArgumentError, "element #{element.id.inspect} in slot #{element.slot.inspect} needs an explicit box override or a preset-generated box" if required

            nil
          end

          def generated_box_for(element)
            case preset_id
            when "vertical-product-layout"
              generated_vertical_box_for(element)
            when "horizontal-product-layout"
              generated_horizontal_box_for(element)
            end
          end

          def generated_vertical_box_for(element)
            case element.slot
            when "fabric"
              generated_vertical_fabric_box(element)
            when "bottom-bar", "bottom-rail"
              generated_vertical_bottom_bar_box(element)
            end
          end

          def generated_horizontal_box_for(element)
            case element.slot
            when "top-guide"
              generated_horizontal_anchor_box(element)
            when "fabric"
              generated_horizontal_fabric_box(element)
            when "bottom-threshold"
              generated_horizontal_bottom_bar_box(element)
            end
          end

          def generated_vertical_fabric_box(element)
            GENERATED_VERTICAL_FABRIC_RULES.each do |rule|
              next unless rule_matches_element?(rule, element)

              reference = box_for_slot(rule.fetch(:reference_slot), required: false)
              standard = element_standard(element)
              next unless reference && standard

              return snap_box(box_from_reference(reference, standard:, rule:))
            end

            nil
          end

          def generated_vertical_bottom_bar_box(element)
            GENERATED_VERTICAL_BOTTOM_BAR_RULES.each do |rule|
              next unless rule_matches_element?(rule, element)

              reference = box_for_slot(rule.fetch(:reference_slot), required: false)
              standard = element_standard(element)
              next unless reference && standard

              return snap_box(box_from_reference(reference, standard:, rule:))
            end

            nil
          end

          def generated_horizontal_anchor_box(element)
            GENERATED_HORIZONTAL_ANCHOR_RULES.each do |rule|
              next unless rule_matches_element?(rule, element)

              standard = element_standard(element)
              next unless standard

              return snap_box(
                Box.new(
                  x: absolute_x(rule.fetch(:x), width: standard_dimension(standard, rule.fetch(:width), :width)),
                  y: rule.fetch(:y),
                  width: standard_dimension(standard, rule.fetch(:width), :width),
                  height: standard_dimension(standard, rule.fetch(:height), :height),
                  rx: standard_dimension(standard, rule.fetch(:rx), :rx)
                )
              )
            end

            nil
          end

          def generated_horizontal_fabric_box(element)
            GENERATED_HORIZONTAL_FABRIC_RULES.each do |rule|
              next unless rule_matches_element?(rule, element)

              reference = box_for_slot(rule.fetch(:reference_slot), required: false)
              standard = element_standard(element)
              next unless reference && standard

              return snap_box(box_from_reference(reference, standard:, rule:))
            end

            nil
          end

          def generated_horizontal_bottom_bar_box(element)
            GENERATED_HORIZONTAL_BOTTOM_BAR_RULES.each do |rule|
              next unless rule_matches_element?(rule, element)

              reference = box_for_slot(rule.fetch(:reference_slot), required: false)
              standard = element_standard(element)
              next unless reference && standard

              return snap_box(box_from_reference(reference, standard:, rule:))
            end

            nil
          end

          def rule_matches_element?(rule, element)
            return false unless element_preset(element) == rule.fetch(:element_preset)

            rule.fetch(:slot, element.slot) == element.slot
          end

          def box_from_reference(reference, standard:, rule:)
            x_reference = rule[:x_reference_slot] ? box_for_slot(rule.fetch(:x_reference_slot), required: false) : reference
            y_reference = rule[:y_reference_slot] ? box_for_slot(rule.fetch(:y_reference_slot), required: false) : reference
            return nil unless x_reference && y_reference

            width = box_width(x_reference, standard:, rule:)
            x = box_x(x_reference, width:, rule:)

            Box.new(
              x:,
              y: y_reference.bottom + resolved_gap(rule.fetch(:gap)),
              width:,
              height: standard_dimension(standard, rule.fetch(:height), :height),
              rx: standard_dimension(standard, rule.fetch(:rx), :rx)
            )
          end

          def absolute_x(value, width:)
            case value
            when :center_on_canvas
              (canvas_spec.svg_width - width) / 2
            when Numeric
              value
            else
              raise ArgumentError, "Unknown generated box x value: #{value.inspect}"
            end
          end

          def box_width(reference, standard:, rule:)
            if rule.key?(:side_extension)
              reference.width + (rule.fetch(:side_extension) * 2)
            elsif rule.key?(:inset_x)
              reference.width - (rule.fetch(:inset_x) * 2)
            else
              standard_dimension(standard, rule.fetch(:width), :width, reference:)
            end
          end

          def box_x(reference, width:, rule:)
            base_x = if rule.key?(:side_extension)
                       reference.x - rule.fetch(:side_extension)
                     elsif rule.fetch(:align, nil) == :center
                       reference.center_x - (width / 2)
                     else
                       reference.x + rule.fetch(:inset_x, 0)
                     end

            base_x + rule.fetch(:offset_x, 0)
          end

          def standard_dimension(standard, value, dimension, reference: nil)
            return reference.public_send(dimension) if value == :reference && reference
            return standard.public_send(dimension) if value == :standard

            value
          end

          def snap_box(box)
            canvas_spec.snap_box(box, preserve_size: false)
          end

          def resolved_gap(value)
            LayoutStandards.resolve_gap(value.is_a?(String) ? value.to_sym : value)
          end

          def element_standard(element)
            preset_name = element_preset(element)
            return nil if preset_name.to_s.empty?

            LayoutStandards.element(preset_name)
          rescue KeyError
            nil
          end

          def element_preset(element)
            element.options["preset"].to_s
          end

          def canvas_spec
            @canvas_spec ||= CanvasSpec.new(
              columns: layout_config.fetch(:grid_columns),
              rows: layout_config.fetch(:grid_rows),
              cell: layout_config.fetch(:grid_cell, CanvasSpec::DEFAULT_CELL),
              margin: layout_config.fetch(:grid_margin, CanvasSpec::DEFAULT_MARGIN),
              major_every: layout_config.fetch(:grid_major_every, CanvasSpec::DEFAULT_MAJOR_EVERY),
              radius: layout_config.fetch(:grid_radius, CanvasSpec::DEFAULT_RADIUS),
              snap_unit: layout_config.fetch(:grid_snap_unit, CanvasSpec::DEFAULT_SNAP_UNIT)
            )
          end

          def layout_config
            blueprint.layout_config
          end

          def boxes_by_slot
            @boxes_by_slot ||= {}
          end

          def preset_id
            preset&.id || blueprint.layout_preset
          end

          def elements_by_slot
            @elements_by_slot ||= assembled.elements.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |element, index|
              index[element.slot] << element if element.slot
            end
          end
        end
      end
    end
  end
end
