# frozen_string_literal: true

require_relative "element_registry"

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        class LayoutStrategyRegistry
          Strategy = Struct.new(
            :name,
            :preset,
            :required_slots,
            :slot_registry_keys,
            :allowed_slots,
            :single_element_slots,
            :required_groups,
            keyword_init: true
          ) do
            def required_slots
              Array(self[:required_slots]).map(&:to_s)
            end

            def allowed_slots
              Array(self[:allowed_slots] || required_slots).map(&:to_s)
            end

            def single_element_slots
              Array(self[:single_element_slots] || required_slots).map(&:to_s)
            end

            def slot_registry_keys
              (self[:slot_registry_keys] || {}).transform_keys(&:to_s).transform_values(&:to_s)
            end

            def required_groups
              Array(self[:required_groups]).map do |group|
                GroupContract.new(
                  id: group.fetch(:id).to_s,
                  slots: Array(group.fetch(:slots)).map(&:to_s),
                  attached: group.fetch(:attached)
                )
              end
            end
          end

          GroupContract = Struct.new(:id, :slots, :attached, keyword_init: true) do
            def attached?
              !!attached
            end
          end

          Diagnostic = Struct.new(:strategy, :errors, keyword_init: true) do
            def match?
              errors.empty?
            end
          end

          Resolution = Struct.new(:matches, :diagnostics, keyword_init: true) do
            def match?
              matches.size == 1
            end

            def ambiguous?
              matches.size > 1
            end

            def strategy
              matches.first if match?
            end

            def failure_summary
              relevant_diagnostics.map { |diagnostic| diagnostic_summary(diagnostic) }.join("; ")
            end

            private

            def relevant_diagnostics
              same_preset = diagnostics.reject { |diagnostic| preset_mismatch?(diagnostic) }
              candidates = same_preset.empty? ? diagnostics : same_preset
              min_error_count = candidates.map { |diagnostic| diagnostic.errors.size }.min

              candidates.select { |diagnostic| diagnostic.errors.size == min_error_count }
            end

            def preset_mismatch?(diagnostic)
              diagnostic.errors.any? { |error| error.start_with?("preset ") }
            end

            def diagnostic_summary(diagnostic)
              "#{diagnostic.strategy.name}: #{diagnostic.errors.join(', ')}"
            end
          end

          StrategyResolutionError = Class.new(StandardError)

          DEFAULT_STRATEGIES = [
            Strategy.new(
              name: :roller_duo,
              preset: "vertical-product-layout",
              required_slots: %w[headrail top-supports roll fabric bottom-bar controls],
              slot_registry_keys: {
                "roll" => "bar:roll-tube",
                "fabric" => "fabric:duo-bands-solid"
              },
              required_groups: [
                { id: "mecanisme-haut", slots: %w[headrail roll top-supports], attached: false },
                { id: "tablier-duo", slots: %w[roll fabric bottom-bar], attached: false },
                { id: "commande-laterale", slots: %w[controls], attached: false },
                { id: "toile-barre", slots: %w[fabric bottom-bar], attached: true }
              ]
            ),
            Strategy.new(
              name: :venetian,
              preset: "vertical-product-layout",
              required_slots: %w[headrail top-supports fabric ladder-cords bottom-bar controls],
              slot_registry_keys: {
                "fabric" => "slat:venetian-pack",
                "controls" => "control:venetian-wand"
              },
              required_groups: [
                { id: "tablier-venitien", slots: %w[headrail fabric bottom-bar], attached: false },
                { id: "pose-haute", slots: %w[headrail top-supports], attached: false },
                { id: "lames-cordons", slots: %w[fabric ladder-cords], attached: true },
                { id: "commande-laterale", slots: %w[controls], attached: false }
              ]
            ),
            Strategy.new(
              name: :honeycomb_shade,
              preset: "vertical-product-layout",
              required_slots: %w[top-rail top-supports fabric intermediate-rail bottom-rail guide-cords],
              slot_registry_keys: {
                "top-rail" => "rail:duette-head",
                "fabric" => "fabric:honeycomb-solid"
              },
              required_groups: [
                { id: "tablier-duette", slots: %w[top-rail fabric intermediate-rail bottom-rail], attached: false },
                { id: "pose-haute", slots: %w[top-rail top-supports], attached: false },
                { id: "toile-rail-intermediaire", slots: %w[fabric intermediate-rail], attached: true },
                { id: "cordons-toile", slots: %w[guide-cords fabric], attached: false }
              ]
            ),
            Strategy.new(
              name: :pleated_lateral,
              preset: "horizontal-product-layout",
              required_slots: %w[top-guide fabric side-profiles handle bottom-threshold closure],
              slot_registry_keys: {
                "fabric" => "fabric:pleated-solid",
                "handle" => "bar:vertical-handle"
              },
              required_groups: [
                { id: "toile-poignee", slots: %w[fabric handle], attached: true },
                { id: "poignee-verrouillage", slots: %w[handle closure], attached: true }
              ]
            ),
            Strategy.new(
              name: :side_guided_roller,
              preset: "vertical-product-layout",
              required_slots: %w[top-housing fabric side-guides bottom-bar closure attached-features],
              slot_registry_keys: {
                "top-housing" => "housing:kiss-50-cassette",
                "fabric" => "fabric:bordered-grid-solid"
              },
              required_groups: [
                { id: "caisson-toile", slots: %w[top-housing fabric], attached: false },
                { id: "toile-coulisses", slots: %w[fabric side-guides], attached: false },
                { id: "fermeture-barre", slots: %w[bottom-bar closure], attached: true },
                { id: "coulisses-bavettes", slots: %w[side-guides attached-features], attached: true }
              ]
            ),
            Strategy.new(
              name: :zipped_screen,
              preset: "vertical-product-layout",
              required_slots: %w[motor top-supports top-housing fabric side-guides bottom-bar],
              slot_registry_keys: {
                "top-housing" => "housing:front-coffre",
                "fabric" => "fabric:zipped-solid",
                "bottom-bar" => "bar:zipped-load"
              },
              required_groups: [
                { id: "motorisation", slots: %w[motor], attached: true },
                { id: "toile-coulisses", slots: %w[fabric side-guides], attached: false },
                { id: "coffre-toile-barre", slots: %w[top-housing fabric bottom-bar], attached: false }
              ]
            )
          ].freeze

          def self.default
            new(DEFAULT_STRATEGIES)
          end

          def initialize(strategies = DEFAULT_STRATEGIES)
            @strategies = strategies
          end

          def resolve(layout_preset:, elements:, groups: nil)
            diagnostics = strategies.map do |strategy|
              Diagnostic.new(
                strategy:,
                errors: strategy_errors(strategy, layout_preset:, elements:, groups:)
              )
            end

            Resolution.new(
              matches: diagnostics.select(&:match?).map(&:strategy),
              diagnostics:
            )
          end

          def resolve!(layout_preset:, elements:, groups: nil, spec_name:)
            resolution = resolve(layout_preset:, elements:, groups:)
            return resolution.strategy if resolution.match?

            if resolution.ambiguous?
              raise StrategyResolutionError, "Multiple data layout strategies match #{spec_name.inspect}: #{resolution.matches.map(&:name).join(', ')}"
            end

            raise StrategyResolutionError, "No data layout strategy for #{spec_name.inspect}: #{resolution.failure_summary}"
          end

          private

          attr_reader :strategies

          def strategy_errors(strategy, layout_preset:, elements:, groups:)
            slots = slots_by_name(elements)
            errors = []

            if layout_preset != strategy.preset
              errors << "preset must be #{strategy.preset.inspect}, got #{layout_preset.inspect}"
            end

            missing_slots = strategy.required_slots - slots.keys
            errors << "missing slots: #{missing_slots.join(', ')}" unless missing_slots.empty?

            unexpected_slots = slots.keys - strategy.allowed_slots
            errors << "unexpected slots: #{unexpected_slots.join(', ')}" unless unexpected_slots.empty?

            strategy.single_element_slots.each do |slot|
              next unless slots[slot]&.size.to_i > 1

              errors << "slot #{slot.inspect} maps to multiple elements: #{slots[slot].map { |element| element_id(element) }.join(', ')}"
            end

            strategy.slot_registry_keys.each do |slot, expected_registry_key|
              elements_for_slot = slots[slot]
              next if elements_for_slot.nil? || elements_for_slot.empty? || elements_for_slot.size > 1

              actual_registry_key = registry_key(elements_for_slot.first)
              next if actual_registry_key == expected_registry_key

              errors << "slot #{slot.inspect} needs #{expected_registry_key.inspect}, got #{actual_registry_key.inspect}"
            end

            errors.concat(group_errors(strategy, elements:, groups:)) if groups

            errors
          end

          def group_errors(strategy, elements:, groups:)
            elements_by_id = elements.each_with_object({}) do |element, index|
              index[element_id(element)] = element
            end
            groups_by_id = groups.each_with_object({}) do |group, index|
              index[group_id(group)] = group
            end

            strategy.required_groups.flat_map do |contract|
              group = groups_by_id[contract.id]
              if group.nil?
                ["missing group #{contract.id.inspect}"]
              else
                group_contract_errors(contract, group:, elements_by_id:)
              end
            end
          end

          def group_contract_errors(contract, group:, elements_by_id:)
            errors = []

            actual_slots = group_element_ids(group).filter_map { |id| element_slot(elements_by_id[id]) }.sort
            expected_slots = contract.slots.sort
            if actual_slots != expected_slots
              errors << "group #{contract.id.inspect} needs slots #{expected_slots.join(', ')}, got #{actual_slots.join(', ')}"
            end

            if group_attached?(group) != contract.attached?
              errors << "group #{contract.id.inspect} attached must be #{contract.attached?}"
            end

            errors
          end

          def slots_by_name(elements)
            elements.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |element, slots|
              slot = element_slot(element)
              slots[slot] << element unless slot.to_s.empty?
            end
          end

          def element_slot(element)
            return nil unless element

            element.respond_to?(:slot) ? element.slot : element["slot"]
          end

          def registry_key(element)
            return element.registry_key if element.respond_to?(:registry_key)

            type = element["type"]
            variant = element["variant"]
            return nil if type.to_s.empty? || variant.to_s.empty?

            ElementRegistry.key(type, variant)
          end

          def element_id(element)
            element.respond_to?(:id) ? element.id : element["id"]
          end

          def group_id(group)
            group.respond_to?(:id) ? group.id : group["id"]
          end

          def group_element_ids(group)
            group.respond_to?(:element_ids) ? group.element_ids : Array(group["element_ids"])
          end

          def group_attached?(group)
            group.respond_to?(:attached) ? !!group.attached : !!group["attached"]
          end
        end
      end
    end
  end
end
