# frozen_string_literal: true

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        class Spec
          attr_reader :data, :path

          def initialize(data:, path: nil)
            @data = data
            @path = path
          end

          def schema_version
            data["schema_version"]
          end

          def product
            data.fetch("product", {})
          end

          def product_slug
            product.fetch("slug", "").to_s
          end

          def product_category
            product.fetch("category", "").to_s
          end

          def product_aliases
            Array(product["aliases"]).map(&:to_s)
          end

          def parts
            Array(data["parts"])
          end

          def elements
            Array(data["elements"])
          end

          def groups
            Array(data["groups"])
          end

          def callouts
            Array(data["callouts"])
          end

          def render_options
            data.fetch("render_options", {})
          end

          def presets
            data.fetch("presets", {})
          end

          def canvas
            data.fetch("canvas", {})
          end

          def validation_rules
            data.fetch("validation", {})
          end

          def source_file_name
            return "" unless path

            File.basename(path.to_s, ".json")
          end

          def source_category
            return "" unless path

            File.basename(File.dirname(path.to_s))
          end
        end
      end
    end
  end
end
