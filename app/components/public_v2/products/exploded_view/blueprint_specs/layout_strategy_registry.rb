# frozen_string_literal: true

require_relative "element_registry"

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        class LayoutStrategyRegistry
          Strategy = Struct.new(:name, :preset, :required_slots, :slot_registry_keys, keyword_init: true) do
            def required_slots
              Array(self[:required_slots]).map(&:to_s)
            end

            def slot_registry_keys
              (self[:slot_registry_keys] || {}).transform_keys(&:to_s).transform_values(&:to_s)
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
              }
            ),
            Strategy.new(
              name: :venetian,
              preset: "vertical-product-layout",
              required_slots: %w[headrail top-supports fabric ladder-cords bottom-bar controls],
              slot_registry_keys: {
                "fabric" => "slat:venetian-pack",
                "controls" => "control:venetian-wand"
              }
            ),
            Strategy.new(
              name: :honeycomb_shade,
              preset: "vertical-product-layout",
              required_slots: %w[top-rail top-supports fabric intermediate-rail bottom-rail guide-cords],
              slot_registry_keys: {
                "top-rail" => "rail:duette-head",
                "fabric" => "fabric:honeycomb-solid"
              }
            ),
            Strategy.new(
              name: :pleated_lateral,
              preset: "horizontal-product-layout",
              required_slots: %w[top-guide fabric side-profiles handle bottom-threshold closure],
              slot_registry_keys: {
                "fabric" => "fabric:pleated-solid",
                "handle" => "bar:vertical-handle"
              }
            ),
            Strategy.new(
              name: :side_guided_roller,
              preset: "vertical-product-layout",
              required_slots: %w[top-housing fabric side-guides bottom-bar closure attached-features],
              slot_registry_keys: {
                "top-housing" => "housing:kiss-50-cassette",
                "fabric" => "fabric:bordered-grid-solid"
              }
            ),
            Strategy.new(
              name: :zipped_screen,
              preset: "vertical-product-layout",
              required_slots: %w[motor top-supports top-housing fabric side-guides bottom-bar],
              slot_registry_keys: {
                "top-housing" => "housing:front-coffre",
                "fabric" => "fabric:zipped-solid",
                "bottom-bar" => "bar:zipped-load"
              }
            )
          ].freeze

          def self.default
            new(DEFAULT_STRATEGIES)
          end

          def initialize(strategies = DEFAULT_STRATEGIES)
            @strategies = strategies
          end

          def resolve(layout_preset:, elements:)
            diagnostics = strategies.map do |strategy|
              Diagnostic.new(
                strategy:,
                errors: strategy_errors(strategy, layout_preset:, elements:)
              )
            end

            Resolution.new(
              matches: diagnostics.select(&:match?).map(&:strategy),
              diagnostics:
            )
          end

          def resolve!(layout_preset:, elements:, spec_name:)
            resolution = resolve(layout_preset:, elements:)
            return resolution.strategy if resolution.match?

            if resolution.ambiguous?
              raise StrategyResolutionError, "Multiple data layout strategies match #{spec_name.inspect}: #{resolution.matches.map(&:name).join(', ')}"
            end

            raise StrategyResolutionError, "No data layout strategy for #{spec_name.inspect}: #{resolution.failure_summary}"
          end

          private

          attr_reader :strategies

          def strategy_errors(strategy, layout_preset:, elements:)
            slots = slots_by_name(elements)
            errors = []

            if layout_preset != strategy.preset
              errors << "preset must be #{strategy.preset.inspect}, got #{layout_preset.inspect}"
            end

            missing_slots = strategy.required_slots - slots.keys
            errors << "missing slots: #{missing_slots.join(', ')}" unless missing_slots.empty?

            strategy.required_slots.each do |slot|
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

            errors
          end

          def slots_by_name(elements)
            elements.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |element, slots|
              slot = element_slot(element)
              slots[slot] << element unless slot.to_s.empty?
            end
          end

          def element_slot(element)
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
        end
      end
    end
  end
end
