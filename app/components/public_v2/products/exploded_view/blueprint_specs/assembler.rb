# frozen_string_literal: true

require_relative "../geometry"
require_relative "assembled_blueprint"
require_relative "element_registry"

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        class Assembler
          attr_reader :spec, :registry

          def initialize(spec, registry: ElementRegistry.default)
            @spec = spec
            @registry = registry
          end

          def assemble
            elements = assemble_elements
            groups = assemble_groups

            AssembledBlueprint.new(
              spec:,
              elements:,
              groups:,
              callouts: assemble_callouts(elements:)
            )
          end

          private

          def assemble_elements
            spec.elements.map do |element|
              type = element.fetch("type")
              variant = element.fetch("variant")

              ElementDefinition.new(
                id: element.fetch("id"),
                part_id: element["part_id"],
                type:,
                variant:,
                slot: element["slot"],
                box: optional_box(element["box"]),
                options: element.fetch("options", {}),
                attached_features: Array(element["attached_features"]),
                registry_entry: registry.fetch(type, variant)
              )
            end
          end

          def assemble_groups
            spec.groups.map do |group|
              GroupDefinition.new(
                id: group.fetch("id"),
                element_ids: Array(group.fetch("element_ids")),
                attached: !!group["attached"]
              )
            end
          end

          def assemble_callouts(elements:)
            slots_by_part_id = elements.each_with_object({}) do |element, index|
              index[element.part_id] = element.slot if element.part_id && element.slot
            end

            spec.callouts.map do |callout|
              part_id = callout.fetch("part_id")

              CalloutDefinition.new(
                part_id:,
                marker: point(callout.fetch("marker")),
                placement: callout["placement"],
                slot: callout["slot"] || slots_by_part_id[part_id],
                options: callout.reject { |key, _| %w[part_id marker placement slot].include?(key) }
              )
            end
          end

          def optional_box(value)
            value && box(value)
          end

          def box(value)
            Box.new(
              x: value.fetch("x"),
              y: value.fetch("y"),
              width: value.fetch("width"),
              height: value.fetch("height"),
              rx: value["rx"]
            )
          end

          def point(value)
            Point.new(
              x: value.fetch("x"),
              y: value.fetch("y")
            )
          end
        end
      end
    end
  end
end
