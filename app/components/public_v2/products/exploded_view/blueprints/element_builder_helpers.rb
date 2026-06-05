# frozen_string_literal: true

require_relative "../layouts"
require_relative "element_builders/bars"
require_relative "element_builders/closures"
require_relative "element_builders/controls"
require_relative "element_builders/fabrics"
require_relative "element_builders/housings"
require_relative "element_builders/motors"
require_relative "element_builders/rails"
require_relative "element_builders/slats"
require_relative "element_builders/standards"

module PublicV2
  module Products
    module ExplodedView
      module Blueprints
        module ElementBuilderHelpers
          include ElementBuilders::Standards
          include ElementBuilders::Fabrics
          include ElementBuilders::Rails
          include ElementBuilders::Housings
          include ElementBuilders::Motors
          include ElementBuilders::Bars
          include ElementBuilders::Closures
          include ElementBuilders::Slats
          include ElementBuilders::Controls
        end
      end
    end
  end
end
