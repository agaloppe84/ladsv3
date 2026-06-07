# frozen_string_literal: true

require "json"
require "pathname"
require_relative "spec"

module PublicV2
  module Products
    module ExplodedView
      module BlueprintSpecs
        class Loader
          DEFAULT_ROOT = if Object.const_defined?(:Rails)
                           ::Rails.root.join("config/public_v2/blueprints")
                         else
                           Pathname.new("config/public_v2/blueprints")
                         end

          class LoadError < StandardError; end

          attr_reader :root

          def initialize(root: DEFAULT_ROOT)
            @root = Pathname.new(root.to_s)
          end

          def schema_path
            root.join("schema/v1.json")
          end

          def spec_paths
            return [] unless root.exist?

            Pathname.glob(root.join("**/*.json")).reject do |path|
              path.dirname.to_s.end_with?("/schema")
            end.sort
          end

          def all
            spec_paths.map { |path| load(path) }
          end

          def find_by_product_slug(slug)
            normalized_slug = normalize_slug(slug)

            all.find do |spec|
              spec.product_slug == normalized_slug || spec.product_aliases.include?(normalized_slug)
            end
          end

          def load(path)
            path = Pathname.new(path.to_s)
            Spec.new(data: JSON.parse(path.read), path:)
          rescue JSON::ParserError => error
            raise LoadError, "#{path}: invalid JSON: #{error.message}"
          rescue Errno::ENOENT
            raise LoadError, "#{path}: file not found"
          end

          private

          def normalize_slug(slug)
            slug.to_s.strip.downcase
          end
        end
      end
    end
  end
end
