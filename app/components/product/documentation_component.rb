# frozen_string_literal: true

class Product::DocumentationComponent < ViewComponent::Base
  def initialize(documentations:)
    @documentations = documentations
  end

  def render?
    @documentations.attached?
  end
end
