# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        class PresetSlotLayout
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

            explicit_box_for(element, required:)
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
