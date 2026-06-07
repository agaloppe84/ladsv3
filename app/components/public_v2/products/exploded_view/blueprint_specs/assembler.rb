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
            AssembledBlueprint.new(
              spec:,
              elements: assemble_elements,
              groups: assemble_groups,
              callouts: assemble_callouts
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

          def assemble_callouts
            spec.callouts.map do |callout|
              CalloutDefinition.new(
                part_id: callout.fetch("part_id"),
                marker: point(callout.fetch("marker")),
                placement: callout["placement"],
                options: callout.reject { |key, _| %w[part_id marker placement].include?(key) }
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
