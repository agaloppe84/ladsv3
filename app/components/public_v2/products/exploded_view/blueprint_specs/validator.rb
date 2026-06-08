# frozen_string_literal: true

require "json"
require_relative "../blueprints/data_blueprint"
require_relative "element_registry"
require_relative "layout_strategy_registry"
require_relative "loader"
require_relative "preset_registry"

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        class Validator
          CATEGORIES = %w[
            moustiquaires
            pergolas
            portes-de-garage
            stores-exterieurs
            stores-interieurs
            volets-battants
            volets-roulants
          ].freeze

          REQUIRED_TOP_LEVEL_KEYS = %w[
            schema_version
            product
            sources
            technical_data
            render_options
            canvas
            parts
            metrics
            elements
            groups
            callouts
            validation
          ].freeze

          FORBIDDEN_RAW_SVG_KEYS = %w[
            d
            detail_path
            outline_path
            path_d
            profile_path
            raw_svg
            surface_path
            svg_path
          ].freeze

          ID_PATTERN = /\A[a-z0-9][a-z0-9-]*\z/
          TOKEN_PATTERN = /\A[a-z0-9][a-z0-9_-]*\z/
          VALID_ANIMATION_PROFILES = %w[draw none].freeze

          Result = Struct.new(:name, :path, :errors, :warnings, keyword_init: true) do
            def ok?
              errors.empty?
            end

            def summary
              status = ok? ? "OK" : "KO"
              "#{name}: #{status} (#{errors.size} errors, #{warnings.size} warnings)"
            end
          end

          class ValidationError < StandardError; end

          def self.validate_all(root: Loader::DEFAULT_ROOT)
            loader = Loader.new(root:)
            specs = loader.spec_paths.map { |path| loader.load(path) }
            results = [validate_schema(loader)]
            results << validate_catalog(specs, root: loader.root)
            results.concat(specs.map { |spec| new(spec, root: loader.root).validate })
            results
          end

          def self.validate_all!(root: Loader::DEFAULT_ROOT, output: $stdout)
            results = validate_all(root:)
            results.each { |result| output.puts(result.summary) }

            failing_results = results.reject(&:ok?)
            return results if failing_results.empty?

            details = failing_results.flat_map do |result|
              result.errors.map { |error| "#{result.name}: #{error}" }
            end.join("\n")

            raise ValidationError, "Blueprint spec validation failed:\n#{details}"
          end

          def self.validate_layouts(root: Loader::DEFAULT_ROOT)
            loader = Loader.new(root:)
            loader.spec_paths.map do |path|
              spec = loader.load(path)
              validate_layout(spec, root: loader.root)
            end
          end

          def self.validate_layouts!(root: Loader::DEFAULT_ROOT, output: $stdout)
            results = validate_layouts(root:)
            results.each { |result| output.puts(result.summary) }

            failing_results = results.reject(&:ok?)
            return results if failing_results.empty?

            details = failing_results.flat_map do |result|
              result.errors.map { |error| "#{result.name}: #{error}" }
            end.join("\n")

            raise ValidationError, "Blueprint spec layout validation failed:\n#{details}"
          end

          def self.validate_schema(loader)
            errors = []
            warnings = []
            path = loader.schema_path

            if path.exist?
              JSON.parse(path.read)
            else
              errors << "missing schema file"
            end
          rescue JSON::ParserError => error
            errors << "invalid JSON schema: #{error.message}"
          ensure
            return Result.new(name: "schema/v1.json", path:, errors:, warnings:)
          end

          def self.validate_catalog(specs, root:)
            errors = []
            warnings = []
            slug_paths = specs.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |spec, mapping|
              ([spec.product_slug] + spec.product_aliases).reject(&:empty?).each do |slug|
                mapping[slug] << spec.path.relative_path_from(root).to_s
              end
            end

            slug_paths.each do |slug, paths|
              errors << "slug #{slug.inspect} is declared by multiple specs: #{paths.join(', ')}" if paths.size > 1
            end

            warnings << "no blueprint specs found yet" if specs.empty?

            Result.new(name: "catalog", path: root, errors:, warnings:)
          end

          def self.validate_layout(spec, root:)
            errors = []
            warnings = []
            name = spec.path.relative_path_from(root).to_s
            blueprint = Blueprints::DataBlueprint.new(spec)
            layout = blueprint.layout

            errors << "layout.svg_width must be positive" unless layout.svg_width.to_f.positive?
            errors << "layout.svg_height must be positive" unless layout.svg_height.to_f.positive?
            errors << "layout.grid is missing" unless layout.grid

            spec.parts.each do |part|
              part_id = part.fetch("id")
              errors << "layout is missing callout #{part_id.inspect}" unless layout.callout(part_id)
            end
          rescue StandardError => error
            errors << "#{error.class}: #{error.message}"
          ensure
            return Result.new(name: "layout/#{name}", path: spec.path, errors:, warnings:)
          end

          def initialize(spec, root: Loader::DEFAULT_ROOT, registry: ElementRegistry.default, preset_registry: PresetRegistry.default)
            @spec = spec
            @root = Pathname.new(root.to_s)
            @registry = registry
            @preset_registry = preset_registry
            @errors = []
            @warnings = []
          end

          def validate
            validate_top_level_contract
            validate_product_contract
            validate_presets
            validate_render_options
            validate_canvas
            validate_parts
            validate_elements
            validate_groups
            validate_callouts
            validate_layout_slot_contract
            validate_layout_strategy_contract
            validate_raw_svg_keys

            Result.new(name:, path: spec.path, errors:, warnings:)
          end

          private

          attr_reader :spec, :root, :registry, :preset_registry, :errors, :warnings

          def name
            return spec.path.relative_path_from(root).to_s if spec.path
            return spec.product_slug unless spec.product_slug.empty?

            "inline-spec"
          rescue ArgumentError
            spec.path.to_s
          end

          def validate_top_level_contract
            missing_keys = REQUIRED_TOP_LEVEL_KEYS - spec.data.keys
            add_error("missing top-level keys: #{missing_keys.join(', ')}") unless missing_keys.empty?
            add_error("schema_version must be 1") unless spec.schema_version == 1
          end

          def validate_product_contract
            add_error("product.slug is required") if spec.product_slug.empty?
            add_error("product.slug must use kebab-case") if !spec.product_slug.empty? && !valid_id?(spec.product_slug)

            category = spec.product_category
            add_error("product.category is required") if category.empty?
            add_error("product.category is not supported: #{category.inspect}") if !category.empty? && !CATEGORIES.include?(category)

            if spec.path
              add_error("file name must match product.slug") if !spec.source_file_name.empty? && spec.source_file_name != spec.product_slug
              add_error("folder name must match product.category") if !spec.source_category.empty? && spec.source_category != category
            end

            duplicate_aliases = duplicates(spec.product_aliases)
            add_error("product.aliases contains duplicate slugs: #{duplicate_aliases.join(', ')}") unless duplicate_aliases.empty?
            spec.product_aliases.each do |product_alias|
              add_error("product alias must use kebab-case: #{product_alias.inspect}") unless valid_id?(product_alias)
            end
          end

          def validate_presets
            presets = spec.presets
            return if presets.empty?

            unless presets.is_a?(Hash)
              add_error("presets must be an object")
              return
            end

            unknown_keys = presets.keys - %w[layout callouts]
            add_error("presets contains unknown keys: #{unknown_keys.join(', ')}") unless unknown_keys.empty?

            layout = presets["layout"]
            if layout
              add_error("presets.layout must use kebab-case: #{layout.inspect}") unless valid_id?(layout)
              add_error("presets.layout is unknown: #{layout.inspect}") if valid_id?(layout) && !preset_registry.layout?(layout)
            end

            callouts = presets["callouts"]
            if callouts
              add_error("presets.callouts must use kebab-case: #{callouts.inspect}") unless valid_id?(callouts)
              add_error("presets.callouts is unknown: #{callouts.inspect}") if valid_id?(callouts) && !preset_registry.callouts?(callouts)
            end
          end

          def validate_render_options
            show_grid = spec.render_options["show_layout_grid"]
            add_error("render_options.show_layout_grid must be a boolean") unless show_grid.nil? || [true, false].include?(show_grid)

            animation = spec.render_options["callout_animation_profile"]
            add_error("render_options.callout_animation_profile is invalid: #{animation.inspect}") unless animation.nil? || VALID_ANIMATION_PROFILES.include?(animation)
          end

          def validate_canvas
            %w[columns rows].each do |key|
              add_error("canvas.#{key} must be a positive integer") unless positive_integer?(spec.canvas[key])
            end

            %w[cell major_every snap_unit].each do |key|
              value = spec.canvas[key]
              add_error("canvas.#{key} must be a positive integer") unless value.nil? || positive_integer?(value)
            end

            %w[margin radius].each do |key|
              value = spec.canvas[key]
              add_error("canvas.#{key} must be a non-negative integer") unless value.nil? || non_negative_integer?(value)
            end
          end

          def validate_parts
            part_ids = spec.parts.map { |part| part["id"].to_s }
            add_error("parts must not be empty") if part_ids.empty?
            validate_unique_ids("parts", part_ids)

            spec.parts.each do |part|
              add_error("part id must use kebab-case: #{part['id'].inspect}") unless valid_id?(part["id"])
              add_error("part #{part['id'].inspect} needs a number") if part["number"].to_s.empty?
              add_error("part #{part['id'].inspect} needs a label") if part["label"].to_s.empty?
            end
          end

          def validate_elements
            element_ids = spec.elements.map { |element| element["id"].to_s }
            add_error("elements must not be empty") if element_ids.empty?
            validate_unique_ids("elements", element_ids)

            spec.elements.each do |element|
              element_id = element["id"]
              type = element["type"]
              variant = element["variant"]

              add_error("element id must use kebab-case: #{element_id.inspect}") unless valid_id?(element_id)
              add_error("element #{element_id.inspect} needs a valid type") unless valid_token?(type)
              add_error("element #{element_id.inspect} needs a valid variant") unless valid_token?(variant)
              registry_entry = validate_registry_entry(element_id, type, variant) if valid_token?(type) && valid_token?(variant)

              slot = element["slot"]
              add_error("element #{element_id.inspect} slot must use kebab-case: #{slot.inspect}") unless slot.nil? || valid_id?(slot)

              part_id = element["part_id"]
              add_error("element #{element_id.inspect} references unknown part #{part_id.inspect}") if part_id && !part_ids.include?(part_id)

              validate_element_options(element_id, element["options"], registry_entry, slot:)
              validate_box("element #{element_id.inspect}", element["box"]) if element["box"]
            end

            return unless require_solid_renderers?

            missing_element_part_ids = part_ids - spec.elements.filter_map { |element| element["part_id"] }
            add_error("parts without renderable elements: #{missing_element_part_ids.join(', ')}") unless missing_element_part_ids.empty?
          end

          def validate_registry_entry(element_id, type, variant)
            unless registry.registered?(type, variant)
              add_error("element #{element_id.inspect} uses unknown type/variant #{ElementRegistry.key(type, variant).inspect}")
              return nil
            end

            entry = registry.fetch(type, variant)
            return entry unless require_solid_renderers?
            return entry if registry.supported?(type, variant)

            add_error("element #{element_id.inspect} does not have a supported solid renderer")
            entry
          end

          def validate_element_options(element_id, options, registry_entry, slot:)
            return if options.nil? && !registry_entry

            unless options.nil? || options.is_a?(Hash)
              add_error("element #{element_id.inspect} options must be an object")
              return
            end
            return unless registry_entry

            option_values = options.to_h
            option_keys = option_values.keys.map(&:to_s)

            missing_keys = registry_entry.required_option_keys_for(slot) - option_keys
            unless missing_keys.empty?
              add_error("element #{element_id.inspect} is missing required options for slot #{slot.inspect}: #{missing_keys.join(', ')}")
            end

            unknown_keys = option_keys - registry_entry.option_keys
            add_error("element #{element_id.inspect} has unknown options: #{unknown_keys.sort.join(', ')}") unless unknown_keys.empty?

            option_values.each do |key, value|
              expected_type = registry_entry.option_type_for(key)
              next unless expected_type
              next if option_value_matches_type?(value, expected_type)

              add_error("element #{element_id.inspect} option #{key.inspect} must be #{option_type_label(expected_type)}")
            end
          end

          def validate_groups
            validate_unique_ids("groups", spec.groups.map { |group| group["id"].to_s })

            spec.groups.each do |group|
              group_id = group["id"]
              add_error("group id must use kebab-case: #{group_id.inspect}") unless valid_id?(group_id)
              Array(group["element_ids"]).each do |element_id|
                add_error("group #{group_id.inspect} references unknown element #{element_id.inspect}") unless element_ids.include?(element_id)
              end
            end
          end

          def validate_callouts
            seen_part_ids = []

            spec.callouts.each do |callout|
              part_id = callout["part_id"]
              seen_part_ids << part_id
              add_error("callout references unknown part #{part_id.inspect}") unless part_ids.include?(part_id)
              validate_point("callout #{part_id.inspect} marker", callout["marker"])

              animation = callout["animation_profile"]
              add_error("callout #{part_id.inspect} has invalid animation_profile #{animation.inspect}") unless animation.nil? || VALID_ANIMATION_PROFILES.include?(animation)

              placement = callout["placement"]
              add_error("callout #{part_id.inspect} has invalid placement #{placement.inspect}") unless placement.nil? || valid_token?(placement)

              slot = callout["slot"]
              add_error("callout #{part_id.inspect} slot must use kebab-case: #{slot.inspect}") unless slot.nil? || valid_id?(slot)
            end

            missing_callouts = part_ids - seen_part_ids
            add_error("missing callouts for parts: #{missing_callouts.join(', ')}") unless missing_callouts.empty?
            validate_unique_ids("callouts.part_id", seen_part_ids)
          end

          def validate_layout_slot_contract
            layout_preset = spec.presets["layout"]
            return if layout_preset.to_s.empty? || !preset_registry.layout?(layout_preset)

            preset = preset_registry.layout(layout_preset)
            element_slots = spec.elements.filter_map { |element| element["slot"] }

            unknown_element_slots = element_slots.reject { |slot| preset.slots.include?(slot) }.uniq
            add_error("elements use slots not declared by layout preset #{layout_preset.inspect}: #{unknown_element_slots.join(', ')}") unless unknown_element_slots.empty?

            missing_required_slots = preset.required_slots - element_slots
            add_error("layout preset #{layout_preset.inspect} is missing required slots: #{missing_required_slots.join(', ')}") unless missing_required_slots.empty?

            Array(preset.required_slot_groups).each do |slot_group|
              next if (slot_group & element_slots).any?

              add_error("layout preset #{layout_preset.inspect} is missing one of required slots: #{slot_group.join(' or ')}")
            end

            unknown_callout_slots = spec.callouts.filter_map do |callout|
              slot = callout["slot"] || element_slot_for_part(callout["part_id"])
              slot if slot && !preset.slots.include?(slot)
            end.uniq
            add_error("callouts use slots not declared by layout preset #{layout_preset.inspect}: #{unknown_callout_slots.join(', ')}") unless unknown_callout_slots.empty?

            validate_callout_preset_slots(preset)
          end

          def validate_callout_preset_slots(layout_preset)
            callout_preset = spec.presets["callouts"]
            return if callout_preset.to_s.empty? || !preset_registry.callouts?(callout_preset)

            spec.callouts.each do |callout|
              next if callout["placement"] || explicit_callout_route?(callout)

              part_id = callout["part_id"]
              slot = callout["slot"] || element_slot_for_part(part_id)
              if slot.to_s.empty?
                add_error("callout #{part_id.inspect} needs a slot or explicit placement")
                next
              end

              next unless layout_preset.slots.include?(slot)

              default_options = preset_registry.default_callout_options(callout_preset, slot)
              add_error("callout #{part_id.inspect} slot #{slot.inspect} has no default options in callout preset #{callout_preset.inspect}") if default_options.empty?
            end
          end

          def validate_layout_strategy_contract
            layout_preset = spec.presets["layout"]
            return if layout_preset.to_s.empty? || !preset_registry.layout?(layout_preset)

            resolution = LayoutStrategyRegistry.default.resolve(
              layout_preset:,
              elements: spec.elements,
              groups: spec.groups
            )
            return if resolution.match?

            if resolution.ambiguous?
              add_error("layout strategy is ambiguous for preset #{layout_preset.inspect}: #{resolution.matches.map(&:name).join(', ')}")
            else
              add_error("no data layout strategy matches preset #{layout_preset.inspect}: #{resolution.failure_summary}")
            end
          end

          def validate_raw_svg_keys
            offenders = forbidden_key_paths(spec.data)
            return if offenders.empty?

            add_error("raw SVG/path keys are forbidden: #{offenders.join(', ')}")
          end

          def validate_box(label, box)
            unless box.is_a?(Hash)
              add_error("#{label} box must be an object")
              return
            end

            %w[x y width height].each do |key|
              add_error("#{label}.box.#{key} must be numeric") unless numeric?(box[key])
            end
            add_error("#{label}.box.width must be positive") unless positive_number?(box["width"])
            add_error("#{label}.box.height must be positive") unless positive_number?(box["height"])
          end

          def validate_point(label, point)
            unless point.is_a?(Hash)
              add_error("#{label} must be an object")
              return
            end

            %w[x y].each do |key|
              add_error("#{label}.#{key} must be numeric") unless numeric?(point[key])
            end
          end

          def part_ids
            @part_ids ||= spec.parts.map { |part| part["id"].to_s }
          end

          def element_ids
            @element_ids ||= spec.elements.map { |element| element["id"].to_s }
          end

          def element_slot_for_part(part_id)
            slots_by_part_id[part_id.to_s]
          end

          def slots_by_part_id
            @slots_by_part_id ||= spec.elements.each_with_object({}) do |element, slots|
              slots[element["part_id"]] = element["slot"] if element["part_id"] && element["slot"]
            end
          end

          def explicit_callout_route?(callout)
            %w[route anchor_side start_direction turn_direction first_length second_length].any? do |key|
              callout.key?(key)
            end
          end

          def validate_unique_ids(label, values)
            duplicate_values = duplicates(values.reject(&:empty?))
            add_error("#{label} contains duplicate ids: #{duplicate_values.join(', ')}") unless duplicate_values.empty?
          end

          def duplicates(values)
            values.group_by(&:itself).select { |_, grouped_values| grouped_values.size > 1 }.keys
          end

          def forbidden_key_paths(value, prefix = nil)
            case value
            when Hash
              value.flat_map do |key, child_value|
                key_path = [prefix, key].compact.join(".")
                nested = forbidden_key_paths(child_value, key_path)
                FORBIDDEN_RAW_SVG_KEYS.include?(key.to_s) ? [key_path, *nested] : nested
              end
            when Array
              value.each_with_index.flat_map { |child_value, index| forbidden_key_paths(child_value, "#{prefix}[#{index}]") }
            else
              []
            end
          end

          def valid_id?(value)
            value.to_s.match?(ID_PATTERN)
          end

          def valid_token?(value)
            value.to_s.match?(TOKEN_PATTERN)
          end

          def require_solid_renderers?
            !!spec.validation_rules.fetch("require_solid_renderers", false)
          end

          def numeric?(value)
            value.is_a?(Numeric)
          end

          def positive_number?(value)
            numeric?(value) && value.positive?
          end

          def positive_integer?(value)
            value.is_a?(Integer) && value.positive?
          end

          def non_negative_integer?(value)
            value.is_a?(Integer) && value >= 0
          end

          def option_value_matches_type?(value, expected_type)
            Array(expected_type).any? do |type|
              case type.to_sym
              when :array
                value.is_a?(Array)
              when :boolean
                [true, false].include?(value)
              when :integer
                value.is_a?(Integer)
              when :number
                value.is_a?(Numeric)
              when :object
                value.is_a?(Hash)
              when :string
                value.is_a?(String)
              else
                false
              end
            end
          end

          def option_type_label(expected_type)
            Array(expected_type).map do |type|
              case type.to_sym
              when :array then "an array"
              when :boolean then "a boolean"
              when :integer then "an integer"
              when :number then "a number"
              when :object then "an object"
              when :string then "a string"
              else type.to_s
              end
            end.join(" or ")
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
