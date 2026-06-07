# frozen_string_literal: true

require_relative "../blueprint_specs/validator"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        class BlueprintValidator
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
        end
      end
    end
  end
end
