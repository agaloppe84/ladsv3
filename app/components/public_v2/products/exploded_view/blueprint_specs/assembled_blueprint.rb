# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        ElementDefinition = Struct.new(
          :id,
          :part_id,
          :type,
          :variant,
          :slot,
          :box,
          :options,
          :attached_features,
          :registry_entry,
          keyword_init: true
        ) do
          def registry_key
            ElementRegistry.key(type, variant)
          end

          def renderer_family
            registry_entry&.renderer_family
          end
        end

        GroupDefinition = Struct.new(:id, :element_ids, :attached, keyword_init: true)

        CalloutDefinition = Struct.new(:part_id, :marker, :placement, :slot, :options, keyword_init: true)

        class AssembledBlueprint
          attr_reader :spec, :elements, :groups, :callouts

          def initialize(spec:, elements:, groups:, callouts:)
            @spec = spec
            @elements = elements
            @groups = groups
            @callouts = callouts
          end

          def element(id)
            elements_by_id.fetch(id.to_s)
          end

          def group(id)
            groups_by_id.fetch(id.to_s)
          end

          def callout(part_id)
            callouts_by_part_id.fetch(part_id.to_s)
          end

          def slot_for_part(part_id)
            slots_by_part_id[part_id.to_s]
          end

          def renderer_families
            elements.map(&:renderer_family).compact.uniq.sort
          end

          private

          def elements_by_id
            @elements_by_id ||= elements.each_with_object({}) { |element, index| index[element.id] = element }
          end

          def groups_by_id
            @groups_by_id ||= groups.each_with_object({}) { |group, index| index[group.id] = group }
          end

          def callouts_by_part_id
            @callouts_by_part_id ||= callouts.each_with_object({}) { |callout, index| index[callout.part_id] = callout }
          end

          def slots_by_part_id
            @slots_by_part_id ||= elements.each_with_object({}) do |element, index|
              index[element.part_id] = element.slot if element.part_id && element.slot
            end
          end
        end
      end
    end
  end
end
