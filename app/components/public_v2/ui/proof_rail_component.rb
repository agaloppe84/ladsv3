# frozen_string_literal: true

class PublicV2::Ui::ProofRailComponent < ViewComponent::Base
  include PublicV2::Debuggable

  VARIANTS = %i[default compact soft].freeze

  def initialize(items:, label: nil, variant: :default, classes: nil, debug: false)
    @items = items
    @label = label
    @variant = VARIANTS.include?(variant.to_sym) ? variant.to_sym : :default
    @classes = classes
    @debug = debug
  end

  private

  attr_reader :items, :label, :variant, :classes

  def component_classes
    [
      "pv2-ui-proof-rail",
      "pv2-ui-proof-rail--#{variant}",
      "grid w-full min-w-0 gap-2",
      debug_class,
      classes
    ].compact.join(" ")
  end
end
